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

import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.domain.*

@Secured('stakeHolder() or inProduct()')
class SandboxController {

  static ui = true

  static final id = 'sandbox'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.sandbox', id, true, 2)
  static window =  [title:'is.ui.sandbox',help:'is.ui.sandbox.help',init:'list',toolbar:true]

  static shortcuts = [
          [code:'is.ui.shortcut.ctrlf.code',text:'is.ui.shortcut.ctrlf.text'],
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],

          [code:'is.ui.shortcut.del.code',text:'is.ui.shortcut.sandbox.del.text'],
          [code:'is.ui.shortcut.ctrla.code',text:'is.ui.shortcut.sandbox.ctrla.text'],
          [code:'is.ui.shortcut.ctrlshifta.code',text:'is.ui.shortcut.sandbox.ctrlshifta.text'],
          [code:'is.ui.shortcut.ctrlshiftc.code',text:'is.ui.shortcut.sandbox.ctrlshiftc.text'],
          [code:'is.ui.shortcut.ctrln.code',text:'is.ui.shortcut.sandbox.ctrln.text'],
          [code:'is.ui.shortcut.space.code',text:'is.ui.shortcut.sandbox.space.text']
  ]

  def springSecurityService
  def productBacklogService
  def dropImportService
  def securityService

  static typesBundle = [
          (Story.TYPE_USER_STORY): 'is.story.type.story',
          (Story.TYPE_DEFECT): 'is.story.type.defect',
          (Story.TYPE_TECHNICAL_STORY): 'is.story.type.technical'
  ]

  @Secured('productOwner()')
  def openDialogAcceptAs = {
    def sprint = Sprint.findCurrentSprint(params.long('product')).list()[0]
    render(template:'dialogs/acceptAs',model:[id:id,sprint:sprint])
  }

  @Secured('productOwner()')
  def accept = {
    if(params.list('id').size() == 0){
      render (status: 400, contentType:'application/json', text:[notice:[text:message(code:'is.ui.sandbox.menu.accept.error.no.selection')]] as JSON)
      return
    }
    def stories = Story.getAll(params.list('id'))

    if (params.story || params.int('acceptAs') == 0){
      try {
        stories.each { story ->
          productBacklogService.acceptStoryToProductBacklog(story)
        }
        flash.notice = [text: message(code: 'is.story.acceptedAsStory'), type: 'notice']
        redirect(action: 'list', params:[product:params.product])
        pushOthers "${params.product}-${id}"
        push "${params.product}-productBacklog"
      } catch (IllegalStateException e) {
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
      } catch (RuntimeException e) {
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
      }
    }else if(params.feature || params.int('acceptAs') == 1){
      try {
        stories.each { story ->
          productBacklogService.acceptStoryToFeature(story)
        }
        flash.notice = [text: message(code: 'is.story.acceptedAsFeature'), type: 'notice']
        redirect(action: 'list', params:[product:params.product])
        pushOthers "${params.product}-${id}"
        push "${params.product}-feature"
      } catch (IllegalStateException e) {
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
      } catch (RuntimeException e) {
        if (log.debugEnabled) e.printStackTrace()
        render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:e.getMessage())]] as JSON)
      }
    }else if(params.task || params.int('acceptAs') == 2){
      try {
        stories.each { story ->
          productBacklogService.acceptStoryToUrgentTask(story)
        }
        flash.notice = [text: message(code: 'is.story.acceptedAsUrgentTask'), type: 'notice']
        redirect(action: 'list', params:[product:params.product])
        pushOthers "${params.product}-${id}"
        push "${params.product}-sprintBacklog"
      } catch (IllegalStateException e) {
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
      } catch (RuntimeException e) {
        if (log.debugEnabled) e.printStackTrace()
        render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:e.getMessage())]] as JSON)
      }
    }
  }

  def list = {
    def currentProduct = Product.load(params.product)
    def stories
    if(params.term)
      stories = Story.findInStoriesSuggested(params.long('product'),'%' + params.term + '%').list()
    else
      stories = Story.findAllByBacklogAndState(currentProduct, Story.STATE_SUGGESTED, [sort:'suggestedDate',order:'desc'])

    def template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'

    if (!stories){
      render(template:'window/blank',model:[id:id])
      return
    }

    def typeSelect = typesBundle.collect {k, v -> "'$k':'${message(code:v)}'" }.join(',')

    def featureSelect = "'':'${message(code:'is.ui.sandbox.manage.chooseFeature')}'"
    if (currentProduct.features){
      featureSelect += ','
      featureSelect += currentProduct.features.collect {v -> "'$v.id':'${v.name.encodeAsHTML().encodeAsJavaScript()}'"}.join(',')
    }

    def sprint = Sprint.findCurrentSprint(currentProduct.id).list()[0]
    def user = null
    if (springSecurityService.isLoggedIn())
      user = User.load(springSecurityService.principal.id)

    render(template: template, model: [stories: stories, id: id, typeSelect:typeSelect, featureSelect:featureSelect, sprint:sprint, user:user])
  }

  @Secured('isAuthenticated()')
  def save = {
    def story = new Story(params.story)
    if (params.int('displayTemplate') != 1){
      story.textAs = null
      story.textICan = null
      story.textTo = null
    }

    if (params.feature?.id){
      story.feature = Feature.get(params.long('feature.id'))
    }
    def user = User.get(springSecurityService.principal.id)
    def product = Product.get(params.product)

    try {
      productBacklogService.saveStory(story, product, user)
      this.manageAttachments(story)

      flash.notice = [text: message(code:'is.story.saved'), type: 'notice']
      if (params.continue) {
        redirect(action: 'add', params:[product:params.product])
      } else {
        redirect(action: 'list', params:[product:params.product])
      }
      pushOthers "${params.product}-${id}"

    } catch (AttachmentException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('isAuthenticated()')
  def update = {
    if (params.story.id == null) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def story = Story.get(params.long('story.id'))

    def user = User.load(springSecurityService.principal.id)
    if(!(story.creator.id == user.id) && !securityService.productOwner(story.backlog.id,springSecurityService.authentication)){
      render (status: 403, contentType:'application/json')
      return
    }

    if (params.boolean('loadrich')){
      render(status: 200, text: story.notes?:'')
      return
    }

    // If the version is different, the feature has been modified since the last loading
    if (params.long('story.version') != story.version) {
      def msg = message(code: 'is.stale.object', args: [message(code: 'is.story')])
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    story.properties = params.story

    if (params.int('displayTemplate') && params.int('displayTemplate') != 1){
      story.textAs = null
      story.textICan = null
      story.textTo = null
      story.actor = null
    }

    try {

      if (params.feature?.id && story.feature?.id != params.feature?.id){
        productBacklogService.associateFeature(Feature.get(params.long('feature.id')), story)
      }else{
        if (story.feature && params.feature?.id == '')
          story.feature.removeFromStories(story)
      }

      productBacklogService.updateStory(story)
      this.manageAttachments(story)

      //if success for table view
      if (params.table && params.boolean('table')){
        def returnValue = ""
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
        else
          returnValue = story."${params.name}".encodeAsHTML()
        def version = story.isDirty() ? story.version + 1 : story.version
        render(status: 200, text: [version:version,value:returnValue?:''] as JSON)
        pushOthers "${params.product}-${id}"
        return
      }

      flash.notice = [text: message(code:'is.story.updated'), type: 'notice']
      if(params.continue){
        def next = Story.findNextSuggested(params.long('product'),story.suggestedDate).list()[0]
        if (next){
          redirect(action: 'edit', params:[product:params.product,id:next.id])
          pushOthers "${params.product}-${id}"
          return
        }
      }
      redirect(action: params.referrer?.action ?: 'list',controller: params.referrer?.controller ?: controllerName, id:params.referrer?.id, params:[product:params.product])
      pushOthers "${params.product}-${params.referrer?.controller ?: id}${params.referrer?.id ? '-'+params.referrer.id : ''}"

    } catch (AttachmentException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    }catch (RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('isAuthenticated()')
  def delete = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }
    def stories = Story.getAll(params.list('id'))
    def msg
    def user = User.load(springSecurityService.principal.id)
    def product = Product.load(params.product)
    try {
      stories.each {
        if(!(it.creator.id == user.id) && !securityService.productOwner(it.backlog.id,springSecurityService.authentication)){
          render (status: 403, contentType:'application/json')
          return
        }
        productBacklogService.deleteStory(it, product)
      }
      flash.notice = [text:message(code: 'is.story.deleted'), type:  'notice']
      redirect(action: 'list', params:[product:params.product])
      pushOthers "${params.product}-${id}"
      
    } catch (Exception e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
    }
  }

  @Secured('isAuthenticated()')
  def add = {
    def currentProduct = Product.get(params.product)

    def rankList = []
    def maxRank = currentProduct.stories?.size() + 1
    maxRank.times { rankList << it+1 }

    render(template: 'window/manage', model: [
            rankList: rankList,
            id: id,
            currentPanel: 'add',
            typesLabels: typesBundle.values().collect {v -> message(code: v)},
            typesKeys: typesBundle.keySet().asList(),
            featureSelect:currentProduct.features.asList(),
            story:params.story,
            isUsedTemplate:false
    ])
  }

  @Secured('isAuthenticated()')
  def edit = {
    def currentProduct = Product.get(params.product)

    def rankList = []
    def maxRank = currentProduct.stories.size()
    maxRank.times { rankList << (it + 1) }

    def story = Story.get(params.long('id'))
    if(!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.story.error.not.exist')]] as JSON)
      return
    }

    def user = User.load(springSecurityService.principal.id)
    if(!(story.creator.id == user.id) && !securityService.productOwner(story.backlog.id,springSecurityService.authentication)){
      render (status: 403, contentType:'application/json')
      return
    }

    
    def tempTxt = [story.textAs, story.textICan, story.textTo]*.trim()
    def isUsedTemplate = (tempTxt != ['null', 'null', 'null'] && tempTxt != ['', '', ''] && tempTxt != [null, null, null])

    def next = Story.findNextSuggested(currentProduct.id,story.suggestedDate).list()[0]

    render(template: 'window/manage', model: [
            story: story,
            isUsedTemplate: isUsedTemplate,
            id: id,
            nextStoryId:next?.id?:'', 
            currentPanel: 'edit',
            user: user,
            typesLabels: typesBundle.values().collect {v -> message(code: v)},
            typesKeys: typesBundle.keySet().asList(),
            featureSelect:currentProduct.features.asList(),
            referrer:params.referrer ?: null
    ])
  }

  /**
   * Import stories via drag&drop (and more)
   */
  @Secured('isAuthenticated()')
  def dropImport = {
    if(!params.data) {
      render (status: 400, contentType:'application/json', text:[notice:[text:message(code:'is.error.import.no.data')]] as JSON)
      return
    }
    def data = params.data
    def currentProduct = Product.get(params.long('product'))
    // The actual story field available to import
    def mapping = [
            name: 'is.story.name',
            description: 'is.backlogelement.description',
            feature: 'is.feature',
            notes : 'is.backlogelement.notes'
    ]

    def parsedData = dropImportService.parseText(params.data)

    // When the data is dropped
    if(!params.mapping) {
      // If the data submitted is not considered to be a valid table, then
      // we suggest the user to create a new story with the text he has input as a description
      if(!parsedData) {
        render include(action: 'list', params: [product: params.product])
        render(template: "dialogs/import", model: [id: id, data:data])
        return
      } else {
        // if the data is considered valid, then we ask the user to match his columns with
        // the actual mapping
        if (parsedData.columns.size() > 0 && !params.confirm) {
          render include(action: 'list', params: [product: params.product])
          render(template: "dialogs/import", model: [id: id,
                  data:data,
                  columns:parsedData.columns,
                  mapping:mapping,
                  matchValues:dropImportService.matchBundle(mapping, parsedData.columns)
          ])
          return
        }
      }
    }

    // When the data is validated and the mapping available
    def story
    try {
      def currentUserInstance = User.get(springSecurityService.principal.id)
      def propertiesMap
      for (int i = 0; i < parsedData.count; i++) {
        propertiesMap = [:]
        
        params.mapping.each {
          propertiesMap."${it.key}" = parsedData.data."${it.value}" ? parsedData.data."${it.value}"[i] : null
        }
        // Try to find an existing feature if that field is filled
        if(propertiesMap.feature) {
          propertiesMap.feature = Feature.findByNameLike(propertiesMap.feature.toString(), [cache:true])
        }
        story = new Story(propertiesMap)
        productBacklogService.saveStory(story, currentProduct, currentUserInstance)
      }
      request.notice = [text:message(code: 'is.story.imported')]
      pushOthers "${params.product}-${id}"
      redirect(action: 'list', params:[product:params.product])
    } catch (RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('isAuthenticated()')
  def associateFeature = {
    if(!params.feature || !params.story) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.ui.sandbox.associateFeature.error']] as JSON)
      return
    }
    def feature = Feature.get(params.long('feature.id'))
    def story = Story.get(params.long('story.id'))

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
    def stories = Story.findAllByBacklogAndState(currentProduct, Story.STATE_SUGGESTED, [sort:'suggestedDate',order:'desc'])
    if(!stories){
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.report.error.no.data')]] as JSON)
      return
    } else if(params.get){
      stories.each {
        data << [
                name:it.name,
                description:it.description,
                notes:it.notes?.replaceAll(/<.*?>/, ''),
                type:message(code:typesBundle[it.type]),
                suggestedDate:it.suggestedDate,
                creator:it.creator.firstName + ' ' + it.creator.lastName,
                feature:it.feature?.name,
        ]
      }
      try {
              session.progress = new ProgressSupport()
              session.progress.updateProgress(99,message(code:'is.report.processing'))

      def model = [[product:currentProduct.name,stories:data?:null]]
      def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+'sandbox'+'-'+(g.formatDate(formatName:'is.date.file'))
      chain(controller: 'jasper',
              action: 'index',
              model: [data: model],
              params: [locale:user.preferences.language,
                      _format:params.format,
                      _file:'sandbox',
                      _name:fileName])
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

  @Secured('isAuthenticated()')
  def download = {
    forward(action:'download',controller:'attachmentable',id:params.id)
    return
  }

  @Secured('inProduct()')
  def cloneStory = {

    if(params.list('id').size() == 0){
      render (status: 400, contentType:'application/json', text:[notice:[text:message(code:'is.ui.sandbox.menu.accept.error.no.selection')]] as JSON)
      return
    }
    def stories = Story.getAll(params.list('id'))

    try {
      stories?.each{
        productBacklogService.cloneStory(it)
      }

      def message = stories.size() > 1 ?message(code:'is.story.selection.cloned'):message(code:'is.story.cloned')
      if (params.reload){
        flash.notice = [text: message, type: 'notice']
        redirect(action: 'list', params:[product:params.product])
      }else{
        render(status: 200, contentType:'application/json', text: [notice: [text:message]] as JSON)
      }
      pushOthers "${params.product}-${id}"
    }catch(RuntimeException e){
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code:'is.story.error.not.cloned')]] as JSON)
    }
  }
}
