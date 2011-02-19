/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import grails.plugins.springsecurity.Secured

import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Feature

import org.icescrum.web.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport
import grails.plugin.attachmentable.AttachmentException

@Secured('stakeHolder() or inProduct()')
class ProductBacklogController {
  def productBacklogService
  def springSecurityService

  static ui = true

  static final id = 'productBacklog'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.productBacklog', id, true, 3)
  static window =  [title:'is.ui.productBacklog',help:'is.ui.productBacklog.help',init:'list',toolbar:true]
  static widget =  [title:'is.ui.productBacklog',init:'list',toolbar:false,height:143]

  static shortcuts = [
          [code:'is.ui.shortcut.ctrlf.code',text:'is.ui.shortcut.ctrlf.text'],
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],

          [code:'is.ui.shortcut.del.code',text:'is.ui.shortcut.productBacklog.del.text'],
          [code:'is.ui.shortcut.ctrla.code',text:'is.ui.shortcut.productBacklog.ctrla.text'],
          [code:'is.ui.shortcut.ctrlshiftc.code',text:'is.ui.shortcut.productBacklog.ctrlshiftc.text'],
          [code:'is.ui.shortcut.space.code',text:'is.ui.shortcut.productBacklog.space.text']
  ]

  static stateBundle = [
          (Story.STATE_SUGGESTED):'is.story.state.suggested',
          (Story.STATE_ACCEPTED):'is.story.state.accepted',
          (Story.STATE_ESTIMATED):'is.story.state.estimated',
          (Story.STATE_PLANNED):'is.story.state.planned',
          (Story.STATE_INPROGRESS):'is.story.state.inprogress',
          (Story.STATE_DONE):'is.story.state.done'
  ]

  static typesBundle = [
          (Story.TYPE_USER_STORY): 'is.story.type.story',
          (Story.TYPE_DEFECT): 'is.story.type.defect',
          (Story.TYPE_TECHNICAL_STORY): 'is.story.type.technical'
  ]

  final featureTerm = /feature:(\w)/
  final typeTerm = /type:(\w)/
  def list = {
    def template
    def currentProduct = Product.get(params.product)
    def stories
    if(params.term){
      stories = Story.findInStoriesAcceptedEstimated(params.long('product'),'%' + params.term + '%').list()
    }else
      stories = Story.findAllByBacklogAndStateBetween(currentProduct, Story.STATE_ACCEPTED, Story.STATE_ESTIMATED, [cache: true, sort: 'rank'])

    if (session['widgetsList']?.contains(id)){
      template = 'widget/widgetView'
      stories = stories.findAll{it.state == Story.STATE_ESTIMATED}
    }
    else {
       if(!stories){
          render(template:'window/blank',model:[id:id])
          return
      }
      template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
    }

    def typeSelect = typesBundle.collect {k, v -> "'$k':'${message(code:v)}'" }.join(',')
    def rankSelect = ''
    def maxRank = Story.findAllAcceptedOrEstimated(currentProduct.id).list().size()
    maxRank.times { rankSelect += "'${it+1}':'${it+1}'" + (it < maxRank-1 ? ',' : '') }
    def featureSelect = "'':'${message(code:'is.ui.sandbox.manage.chooseFeature')}'"
    if (currentProduct.features){
      featureSelect += ','
      featureSelect += currentProduct.features.collect {v -> "'$v.id':'${v.name.encodeAsHTML().encodeAsJavaScript()}'"}.join(',')
    }
    def suiteSelect = "'?':'?',"
    def currentSuite = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

    currentSuite = currentSuite.eachWithIndex { t,i ->
      suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size()-1 ? ',' : '')
    }
    render(template: template, model: [stories: stories, id: id, featureSelect:featureSelect, typeSelect:typeSelect,suiteSelect:suiteSelect, rankSelect:rankSelect], params:[product:params.product])
  }

  @Secured('productOwner(#p) or scrumMaster(#p)')
  def update = {

    def msg = message(code: 'is.story.updated')

    if (!params.long('story.id')) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    def story = Story.get(params.long('story.id'))

    if(!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    if (params.boolean('loadrich')){
      render(status: 200, text: story.notes?:'')
      return
    }

    // If the version is different, the feature has been modified since the last loading
    if (params.long('story.version') != story.version) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.stale.object', args: [message(code: 'is.story')])]] as JSON)
      return
    }

    def product = Product.get(params.product)

    try {
      if (params.story.rank && story.rank != params.int('story.rank')) {
        productBacklogService.changeRank(product, story, params.int('story.rank'))
      }

      if(params.story.effort && !params.story.effort.isNumber())
        params.story.effort = null

      story.properties = params.story

      if (params.int('displayTemplate') && params.int('displayTemplate') != 1){
        story.textAs = null
        story.textICan = null
        story.textTo = null
        story.actor = null
      }

      if (params.feature?.id && story.feature?.id != params.feature?.id){
        productBacklogService.associateFeature(Feature.get(params.long('feature.id')), story)
      }else if (story.feature && params.feature?.id == ''){
          story.feature.removeFromStories(story)
      }

      productBacklogService.updateStory(story)
      this.manageAttachments(story)

      //if success for table view
      if (params.table && params.boolean('table')){
        def returnValue
        if (params.name == 'type')
          returnValue = message(code:typesBundle[story.type])
        else if (params.name == 'feature.id')
          returnValue = is.postitIcon(name:story.feature?.name?.encodeAsHTML()?:message(code:message(code:'is.ui.sandbox.manage.chooseFeature')),color:story.feature?.color?:'yellow')+(story.feature?.name?.encodeAsHTML()?:message(code:message(code:'is.ui.sandbox.manage.chooseFeature')))
        else if (params.name == 'notes'){
          returnValue = wikitext.renderHtml(markup:'Textile',text:story."${params.name}")
        }
        else if (params.name == 'description'){
          returnValue = story.description?.encodeAsHTML()?.encodeAsNL2BR()
        }
        else {
          if (params.name == 'effort' && story."${params.name}" == null)
            returnValue = '?'
          else
            returnValue = story."${params.name}".encodeAsHTML()
        }
        def version = story.isDirty() ? story.version + 1 : story.version
        render(status: 200, text: [version:version,value:returnValue?:''] as JSON)
        if (params.name == 'rank' || params.name == 'effort')
          push "${params.product}-${id}"
        else
          pushOthers "${params.product}-${id}"
        return
      }

      flash.notice = [text: msg, type: 'notice']
      if (params.continue) {
        def next = Story.findNextAcceptedOrEstimated(params.long('product'),story.rank + 1).list(sort:'rank',order:'asc')[0]
        if (next){
          redirect(action: 'edit', params:[product:params.product,id:next.id])
        }else{
          redirect(action: 'list', params:[product:params.product])
        }
      }else{
        redirect(action: params.referrer?.action ?: 'list',controller: params.referrer?.controller ?: controllerName, id:params.referrer?.id, params:[product:params.product])
        pushOthers "${params.product}-${params.referrer?.controller ?: id}${params.referrer?.id ? '-'+params.referrer.id : ''}"
      }
    } catch (AttachmentException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }catch(IllegalStateException e){
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    }
  }

  @Secured('productOwner()')
  def delete = {
    if (!params.id) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.story.error.not.exist']] as JSON)
      return
    }
    def stories = Story.getAll(params.list('id'))

    if(!stories) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    def msg
    def product = Product.load(params.product)
    try {
      stories.each {
        productBacklogService.deleteStory(it, product)
      }
      flash.notice = [text: message(code: 'is.story.deleted'), type: 'notice']
      redirect(action: 'list', params:[product:params.product])
      pushOthers "${params.product}-${id}"
    } catch (Exception e) {
      render(status: 400, contentType:'application/json', text: message(code: 'is.story.error.not.deleted'))
    }
  }

  @Secured('productOwner(#p) or scrumMaster(#p)')
  def edit = {
    if (!params.id) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.story.error.not.exist']] as JSON)
      return
    }
    def currentProduct = Product.get(params.product)
    def effortNumSuite =( params.referrer ? [] : ['?']) + PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

    def rankList = []
    def maxRank = Story.findAllAcceptedOrEstimated(params.long('product')).list().size()
    maxRank.times { rankList << (it + 1) }

    def story = Story.get(params.long('id'))

    if(!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    def tempTxt = [story.textAs, story.textICan, story.textTo]*.trim()
    def isUsedTemplate = (tempTxt != ['null', 'null', 'null'] && tempTxt != ['', '', ''] && tempTxt != [null, null, null])
    def next = Story.findNextAcceptedOrEstimated(params.long('product'),story.rank + 1).list(sort:'rank',order:'asc')[0]
    render(template: 'window/manage', model: [
            story: story,
            isUsedTemplate: isUsedTemplate,
            effortNumSuite: effortNumSuite,
            id: id,
            currentPanel: 'edit',
            nextStoryId:next?.id?:'',
            rankList: rankList,
            typesLabels: typesBundle.values().collect {v -> message(code: v)},
            typesKeys: typesBundle.keySet().asList(),
            featureSelect:currentProduct.features.asList(),
            referrer:params.referrer ?: null
    ])
  }

  @Secured('productOwner()')
  def dropImport = {
    if(!params.data) {
      render (status: 400, contentType:'application/json', text:[notice:[text:message(code:'is.error.import.no.data')]] as JSON)
      return
    }
    try{
      def parsedData = params.data.replace("\n", "\t").split("\t")
      def processedData = [
              (parsedData[0]): [],
              (parsedData[1]): [],
              (parsedData[2]): []
      ]
      for (int i = 3; i < parsedData.size(); i++) {
        processedData[parsedData[i % 3]] << parsedData[i]
      }
      def currentUserInstance = User.get(springSecurityService.principal.id)
      for (int i = 0; i < processedData['ID'].size(); i++) {
        def story = new Story(name: processedData['Name'][i], description: processedData['Desc'][i])
        productBacklogService.saveStory(story, Product.get(params.product), currentUserInstance)
      }
      flash.notice = [text:message(code: 'is.story.imported')]
      redirect(action: 'list', params:[product:params.product])
      pushOthers "${params.product}-${id}"

    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def changeRank = {

    if(!params.idmoved) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    def movedItem = Story.get(params.long('idmoved'))

    if(!movedItem) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    def position = params.int('position')
    if (movedItem == null || position == null)
       render(status: 400, contentType:'application/json',text: [notice: [text: message(code:'is.story.rank.error')]] as JSON)
    if (productBacklogService.changeRank(Product.get(params.product), movedItem, position)) {
      render(status: 200)
      pushOthers "${params.product}-${id}"
    } else {
       render(status: 400, contentType:'application/json',text: [notice: [text: message(code:'is.story.rank.error')]] as JSON)
    }
  }

  @Secured('teamMember() or scrumMaster()')
  def estimate = {
    if(!params.id) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.story.error.not.exist']] as JSON)
      return
    }
    def story = Story.get(params.long('id'))

    if(!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    productBacklogService.estimateStory(story, params.value)
    render(status: 200,text:params.value)
    pushOthers "${params.product}-${id}"
  }

  def associateFeature = {
    if(!params.feature || !params.story) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.ui.productBacklog.associateFeature.error']] as JSON)
      return
    }
    def feature = Feature.get(params.long('feature.id'))
    def story = Story.get(params.long('story.id'))

    if(!feature || !story) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.ui.productBacklog.associateFeature.error']] as JSON)
      return
    }
    try {
      productBacklogService.associateFeature(feature, story)
      redirect(action: 'list', params:[product:params.product])
      pushOthers "${params.product}-${id}"
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  def print = {
    def user = User.load(springSecurityService.principal?.id)
    def currentProduct = Product.get(params.product)
    def data = []
    def stories = Story.findAllByBacklogAndStateBetween(currentProduct, Story.STATE_ACCEPTED, Story.STATE_ESTIMATED, [cache: true, sort: 'rank'])
    if(!stories){
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.report.error.no.data')]] as JSON)
      return
    } else if(params.get){
      stories.each {
        data << [
                name:it.name,
                rank:it.rank,
                description:it.description,
                notes:wikitext.renderHtml([markup:'Textile',text:it.notes],null),
                type:message(code:typesBundle[it.type]),
                acceptedDate:it.acceptedDate,
                estimatedDate:it.estimatedDate,
                creator:it.creator.firstName + ' ' + it.creator.lastName,
                feature:it.feature?.name,
        ]
      }
      try {
              session.progress = new ProgressSupport()
              session.progress.updateProgress(99,message(code:'is.report.processing'))
        def model = [[product:currentProduct.name,stories:data?:null]]
        def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+'backlog'+'-'+(g.formatDate(formatName:'is.date.file'))

        chain(controller: 'jasper',
                action: 'index',
                model: [data: model],
                params: [locale:user.preferences.language,_format:params.format,_file:'backlog',_name:fileName])
        session.progress?.completeProgress(message(code: 'is.report.complete'))
      } catch (Exception e) {
        if (log.debugEnabled) e.printStackTrace()
        session.progress.progressError(message(code: 'is.report.error'))
      }
    } else if(params.status){
      render(status:200,contentType: 'application/json', text:session.progress as JSON)
    } else {
      render(template: 'dialogs/report', model: [id: id])
    }
  }

  private manageAttachments(def story){
    def user = User.load(springSecurityService.principal.id)
    if (story.id && !params.story.list('attachments') && story.attachments*.id.size() > 0){
      story.removeAllAttachments()
    }else if (story.attachments*.id.size() > 0){
      story.attachments*.id.each {
        if (!params.story.list('attachments').contains(it.toString()))
         story.removeAttachment(it)
      }
    }
    def uploadedFiles = []
    params.list('attachments')?.each{ attachment ->
       attachment.split(':').with {
         if (session.uploadedFiles[it[0]])
           uploadedFiles << [file:new File(session.uploadedFiles[it[0]]),name:it[1]]
       }
    }
    if (uploadedFiles)
      story.addAttachments(user,uploadedFiles)
    session.uploadedFiles = null
  }

  def download = {
    forward(action:'download',controller:'attachmentable',id:params.id)
    return
  }
}