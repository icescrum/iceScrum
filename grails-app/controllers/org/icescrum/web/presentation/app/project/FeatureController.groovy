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
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story

import org.icescrum.web.support.MenuBarSupport
import org.icescrum.core.domain.User
import org.icescrum.core.support.ProgressSupport
import grails.plugin.attachmentable.AttachmentException

@Secured('inProduct()')
class FeatureController {
  def featureService
  def springSecurityService

  static ui = true

  static final id = 'feature'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.feature',id , false, 2)
  static window =  [title:'is.ui.feature',help:'is.ui.feature.help',init:'list',toolbar:true]
  static widget =  [title:'is.ui.feature',init:'list',toolbar:true,height:143]

  static shortcuts = [
          [code:'is.ui.shortcut.ctrlf.code',text:'is.ui.shortcut.ctrlf.text'],
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],
          [code:'is.ui.shortcut.del.code',text:'is.ui.shortcut.feature.del.text'],
          [code:'is.ui.shortcut.ctrla.code',text:'is.ui.shortcut.feature.ctrla.text'],
          [code:'is.ui.shortcut.ctrln.code',text:'is.ui.shortcut.feature.ctrln.text'],
          [code:'is.ui.shortcut.space.code',text:'is.ui.shortcut.feature.space.text']
  ]

  static typesBundle = [
          (Feature.TYPE_FUNCTIONAL): 'is.feature.type.functional',
          (Feature.TYPE_ARCHITECTURAL): 'is.feature.type.architectural'
  ]

  static colorsSelect = [
          'blue':'is.postit.color.blue',
          'green':'is.postit.color.green',
          'red':'is.postit.color.red',
          'orange':'is.postit.color.orange',
          'violet':'is.postit.color.violet',
          'gray':'is.postit.color.gray',
          'pink':'is.postit.color.pink',
          'bluelight':'is.postit.color.bluelight'
  ]

  @Secured('productOwner()')
  def save = {
    def feature = new Feature(params.feature)
    try {
      featureService.saveFeature(feature, Product.get(params.product))
      this.manageAttachments(feature)

      flash.notice = [text: message(code: 'is.feature.saved'), type: 'notice']
      if (params.continue) {
        redirect(action: 'add', params:[product:params.product])
      } else {
        redirect(action: 'list', params:[product:params.product])
      }
      pushOthers "${params.product}-${id}"
    } catch (AttachmentException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    }catch(RuntimeException e){
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:feature)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def update = {
    def msg
    if (!params.long('feature.id')) {
      msg = message(code: 'is.feature.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def feature = Feature.get(params.long('feature.id'))

    if(!feature) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.not.exist')]] as JSON)
      return
    }

    // If the version is different, the feature has been modified since the last loading
    if (params.long('feature.version') != feature.version) {
      msg = message(code: 'is.stale.object', args: [message(code: 'is.feature')])
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def product = Product.get(params.product)

    def successRank = true
    if (params.int('feature.rank') && feature.rank != params.int('feature.rank')) {
      if (!featureService.changeRank(product, feature, params.int('feature.rank'))) {
        msg = message(code: 'is_feature_error')
        successRank = false
      }
    }

    if (successRank) {
      feature.properties = params.feature
      try {
        featureService.updateFeature(feature, product)
        this.manageAttachments(feature)

        if (params.table && params.boolean('table')){
          def returnValue = ""
          if (params.name == 'type')
            returnValue = message(code:typesBundle[feature.type])
          else if (params.name == 'description'){
            returnValue = feature.description?.encodeAsHTML()?.encodeAsNL2BR()
          }
          else
            returnValue = feature."${params.name}".encodeAsHTML()

          def version = feature.isDirty() ? feature.version + 1 : feature.version
          render(status: 200, text: [version:version,value:returnValue?:''] as JSON)
          if (params.name == 'rank')
            push "${params.product}-${id}"
          else
            pushOthers "${params.product}-${id}"
          return
        }

        flash.notice = [text: message(code: 'is.feature.updated'), type: 'notice']
        if (params.continue) {
          def next = Feature.findByBacklogAndRank(Product.get(params.product), feature.rank + 1, [cache: true])
          if (next){
            redirect(action: 'edit', params:[product:params.product,id:next.id])
          }else{
            redirect(action: 'list', params:[product:params.product])
          }
        } else {
          redirect(action: 'list', params:[product:params.product])
        }
        pushOthers "${params.product}-${id}"

      } catch (AttachmentException e) {
        e.printStackTrace()
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
      }catch(RuntimeException e){
        render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:feature)]] as JSON)
      }
    }
  }

  @Secured('productOwner()')
  def delete = {

    if(!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.not.exist')]] as JSON)
      return
    }

    def features = Feature.getAll(params.list('id'))

    if(!features) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.not.exist')]] as JSON)
      return
    }
    def product = Product.get(params.product)
    try {
      features.each { feature ->
        featureService.deleteFeature(feature, product)
      }
      flash.notice = [text: message(code: 'is.feature.deleted'), type: 'notice']
      redirect(action: 'list', params:[product:params.product])
      pushOthers "${params.product}-${id}"
    }catch(RuntimeException e){
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.linked.story')]] as JSON)
    }
  }

  def list = {
    def features
    def template
    if(params.term && params.term != '')
      features = Feature.findInAll(params.long('product'), '%' + params.term + '%').list()
    else
      features = Feature.findAllByBacklog(Product.load(params.product), [cache: true, sort: 'rank'])

    if (session['widgetsList']?.contains(id))
      template = 'widget/widgetView'
    else {
      if (!features){
        render(template:'window/blank',model:[id:id])
        return
      }
      template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
    }

    def currentProduct = Product.get(params.product)
    def maxRank = currentProduct.features.size()
    def effortFeature = { feature ->
      feature.stories?.sum{it.effort ?: 0}
    }
    def linkedDoneStories = { feature ->
      feature.stories?.sum{(it.state == Story.STATE_DONE) ? 1 : 0}
    }

    //Pour la vue tableau
    def rankSelect = ''
    maxRank.times { rankSelect += "'${it + 1}':'${it + 1}'" + (it < maxRank - 1 ? ',' : '') }
    def typeSelect = typesBundle.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
    def suiteSelect = "'?':'?',"
    def currentSuite = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

    currentSuite = currentSuite.eachWithIndex { t,i ->
      suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size()-1 ? ',' : '')
    }
    render(template:template, model: [features: features, effortFeature:effortFeature,linkedDoneStories:linkedDoneStories, id: id, typeSelect:typeSelect, rankSelect: rankSelect ,suiteSelect:suiteSelect],params:[product:params.product])
  }

  @Secured('productOwner()')
  def changeRank = {
    def featureMoved = Feature.get(params.long('idmoved'))

    if(!featureMoved) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.not.exist')]] as JSON)
      return
    }

    def position = params.int('position')
    if (featureMoved == null || position == null) {
      render(status: 400, contentType:'application/json',text: [notice: [text: message(code:'is.feature.rank.error')]] as JSON)
    }
    if (featureService.changeRank(Product.get(params.product), featureMoved, position)) {
      render(status: 200)
      pushOthers "${params.product}-${id}"
    } else {
      render(status: 400, contentType:'application/json',text: [notice: [text: message(code:'is.feature.rank.error')]] as JSON)
    }
  }

  @Secured('productOwner()')
  def add = {
    def currentProduct = Product.get(params.product)
    def valuesList = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

    def rankList = []
    def maxRank = currentProduct.features.size() + 1
    maxRank.times { rankList << it + 1 }



    render(template: 'window/manage', model: [valuesList: valuesList,
            rankList: rankList.asList(),
            colorsLabels:colorsSelect.values().collect { message(code:it) },
            colorsKeys:colorsSelect.keySet().asList(),
            id: id,
            currentPanel: 'add',
            typesNames: typesBundle.values().collect {v -> message(code: v)},
            typesId: typesBundle.keySet().asList()
    ])
  }

  @Secured('productOwner()')
  def edit = {

     if(!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.not.exist')]] as JSON)
      return
    }

    def currentProduct = Product.get(params.product.toLong())
    def valuesList = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

    def rankList = ''
    def maxRank = currentProduct.features.size()
    maxRank.times { rankList += "${it + 1}" }
    def feature = Feature.get(params.long('id'))

    if(!feature) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.feature.error.not.exist')]] as JSON)
      return
    }

    def next = Feature.findByBacklogAndRank(currentProduct, feature.rank + 1, [cache: true])
    render(template: 'window/manage', model: [valuesList: valuesList,
            rankList: rankList,
            id: id,
            nextFeatureId:next?.id?:'',
            colorsLabels:colorsSelect.values().collect { message(code:it) },
            colorsKeys:colorsSelect.keySet().asList(),
            currentPanel: 'edit',
            feature: feature,
            typesNames: typesBundle.values().collect {v -> message(code: v)},
            typesId: typesBundle.keySet().asList()
    ])
  }

  @Secured('productOwner()')
  def copyFeatureToProductBacklog = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.feature.error.not.exist')]] as JSON)
      return
    }

    try {
      featureService.copyFeatureToProductBacklog(params.long('id'), springSecurityService.principal.id)
      flash.notice = [text: message(code: 'is.feature.copy'), type: 'notice']
      redirect(action: 'list', params:[product:params.product])
      pushOthers "${params.product}-${id}"
      push "${params.product}-productBacklog"
    } catch(RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'story.name.unique')]] as JSON)
    }
  }

  def productParkingLotChart = {
    def currentProduct = Product.get(params.product)
    def values = featureService.productParkingLotValues(currentProduct)
    def indexF = 1
    def valueToDisplay = []
    values.value?.each{
      def value = []
      value << it.toString()
      value << indexF
      valueToDisplay << value
      indexF++
    }
    if (valueToDisplay.size() > 0)
      render(template:'charts/productParkinglot',model:[
              id:id,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              values:valueToDisplay as JSON,
              featuresNames:values.label as JSON])
    else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
    }
  }

  def print = {
    def user = User.load(springSecurityService.principal.id)

    def currentProduct = Product.get(params.product)
    def values = featureService.productParkingLotValues(currentProduct)
    def data = []
    def effortFeature = { feature ->
      feature.stories?.sum{it.effort ?: 0}
    }
    def linkedDoneStories = { feature ->
      feature.stories?.sum{(it.state == Story.STATE_DONE) ? 1 : 0}
    }
    if(!values){
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.report.error.no.data')]] as JSON)
      return
    } else if(params.get){
      currentProduct.features.eachWithIndex{ feature, index ->
        data << [
                name:feature.name,
                description:feature.description,
                notes:feature.notes?.replaceAll(/<.*?>/, ''),
                rank:feature.rank,
                type:feature.type,
                value:feature.value,
                effort:effortFeature(feature),
                associatedStories:feature.stories.size() ?: 0,
                associatedStoriesDone:linkedDoneStories(feature),
                parkingLotValue:values[index].value
        ]
      }
      try {
        session.progress = new ProgressSupport()
        session.progress.updateProgress(99,message(code:'is.report.processing'))
        def model = [[product:currentProduct.name,features:data?:null]]
        def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+'features'+'-'+(g.formatDate(value:new Date(),formatName:'is.date.file'))
        chain(controller: 'jasper',
                action: 'index',
                model: [data: model],
                params: [locale:user.preferences.language,_format:params.format,_file:'features',_name:fileName])
        session.progress?.completeProgress(message(code: 'is.report.complete'))
      } catch (Exception e) {
        e.printStackTrace()
        session.progress.progressError(message(code: 'is.report.error'))
      }
    } else if(params.status){
      render(status:200,contentType: 'application/json', text:session.progress as JSON)
    } else {
      render(template: 'dialogs/report', model: [id: id])
    }
  }

  private manageAttachments(def feature){
    def user = User.load(springSecurityService.principal.id)
    if (feature.id && !params.feature.list('attachments') && feature.attachments*.id.size() > 0){
      feature.removeAllAttachments()
    }else if (feature.attachments*.id.size() > 0){
      feature.attachments*.id.each {
        if (!params.feature.list('attachments').contains(it.toString()))
         feature.removeAttachment(it)
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
      feature.addAttachments(user,uploadedFiles)
    session.uploadedFiles = null
  }

  def download = {
    forward(action:'download',controller:'attachmentable',id:params.id)
    return
  }
}
