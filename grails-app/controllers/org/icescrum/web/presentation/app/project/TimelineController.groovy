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
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport

@Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
class TimelineController {

  static ui = true

  static final id = 'timeline'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.timeline', id, false, 1)
  static window =  [title:'is.ui.timeline',help:'is.ui.timeline.help',toolbar:true, titleBarContent:true]

  static shortcuts = [
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],
          [code:'is.ui.shortcut.ctrln.code',text:'is.ui.shortcut.timeline.ctrln.text']
  ]

  def releaseService
  def productService
  def featureService
  def springSecurityService

  static SprintStateBundle = [
          (Sprint.STATE_WAIT):'is.sprint.state.wait',
          (Sprint.STATE_INPROGRESS):'is.sprint.state.inprogress',
          (Sprint.STATE_DONE):'is.sprint.state.done'
  ]

  static ReleaseStateBundle = [
          (Release.STATE_WAIT):'is.release.state.wait',
          (Release.STATE_INPROGRESS):'is.release.state.inprogress',
          (Release.STATE_DONE):'is.release.state.done'
  ]

  def titleBarContent = {
    def currentProduct = Product.get(params.product);
     def releasesName = []
     def releasesDate = []

     currentProduct.releases?.eachWithIndex{ itt, index ->
           releasesName << itt.name.encodeAsHTML()
           releasesDate << itt.startDate.getTime()
       itt.sprints?.eachWithIndex{ it2, index2 ->
           releasesName << "${itt.name.encodeAsHTML()} - ${message(code:'is.sprint')} ${index2 + 1}"
           releasesDate << it2.startDate.getTime()
       }
     }

    render(template:'window/titleBarContent', model:[id:id, releasesName:releasesName,releasesDate:releasesDate,currentRelease:params.long('id')])
  }

  def index = {

    def currentProduct = Product.get(params.product)
    if (!currentProduct.releases){
       render(template:'window/blank',model:[id:id])
       return
    }

    render(template:'window/timelineView',model:[id: id])
  }

  def timeLineList = {
    def currentProduct = Product.get(params.product)
    def list = []

    def date = new Date(currentProduct.startDate.getTime() - 1000)
    def startProject = [start:date,end:date,durationEvent:false,classname:"timeline-startproject"]

    list.add(startProject)

    currentProduct.releases.each{
      def color
      def textColor = "#444"
      switch(it.state){
        case Release.STATE_WAIT:
          color = "#BBBBBB"
          break
        case Release.STATE_INPROGRESS:
          color = "#C8E5FC"
          break
        case Release.STATE_DONE:
          color = "#C1FF89"
          break
      }

      def isClosable = false
      if (it.sprints.size() != 0){
        if(it.sprints.asList().last().state == Sprint.STATE_DONE)
          isClosable = true
      }
      def templateMenu = "<div class='dropmenu-action' onmouseover='if(jQuery(\"#dropmenu-rel-${it.id}\").dropMenuCreated() == false){jQuery(\"#dropmenu-rel-${it.id}\").dropmenu({top:10,showOnCreate:true});};'>"+is.menu(contentView:'window/menu', id:"rel-${it.id}" ,params:[release: it, isClosable:isClosable, id:id, activeRelease:currentProduct.releases.find {it.state == Release.STATE_INPROGRESS}])+"</div><span>${it.name.encodeAsJavaScript()}</span>"
      def templateTooltip = include(view: "$controllerName/tooltips/_tooltipReleaseDetails.gsp", model: [release: it])

      def tlR = [window:"releasePlan/${it.id}",
              start:it.startDate,
              end:it.endDate,
              durationEvent:true,
              title:templateMenu,
              color:color,
              textColor:textColor,
              classname:"timeline-release",
              eventID:it.id,
              tooltipContent:templateTooltip,
              tooltipTitle:"${it.name.encodeAsHTML()} (${message(code:ReleaseStateBundle[it.state])})"]

        list.add(tlR)
        it.sprints.eachWithIndex{ it2, index ->
        def colorS
        def textColorS = "#444"
        switch(it2.state){
          case Sprint.STATE_WAIT:
            colorS = "#BBBBBB"
            break
          case Sprint.STATE_INPROGRESS:
            colorS = "#C8E5FC"
            break
          case Sprint.STATE_DONE:
            colorS = "#C1FF89"
            break
        }
        templateTooltip = include(view: "$controllerName/tooltips/_tooltipSprintDetails.gsp", model: [sprint: it2, user:springSecurityService.currentUser])
        def tlS = [window:"sprintBacklog/${it2.id}",
                start:it2.startDate,
                end:it2.endDate,
                durationEvent:true,
                title:"#${index + 1}",
                color:colorS,
                textColor:textColorS,
                classname:"timeline-sprint",
                eventID:it2.id,
                tooltipContent:templateTooltip,
                tooltipTitle:"${message(code:'is.sprint')} ${index +1} (${message(code:SprintStateBundle[it2.state])})"]
        list.add(tlS)
      }
    }
    render ([dateTimeFormat:"iso8601",events:list] as JSON)
  }

  @Secured('productOwner() or scrumMaster()')
  def add = {
    def currentProduct = Product.get(params.product)
    def previousRelease = currentProduct.releases.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}
    def release = new Release()

    if (previousRelease) {
      release.name = release.name + (previousRelease.orderNumber+1)
      release.startDate = previousRelease.endDate + 1
      release.endDate = previousRelease.endDate + 1 + 30 * 3
    }else{
      release.startDate = currentProduct.startDate
      release.endDate = currentProduct.startDate + 1 + 30 * 3
    }
    
    render(template: 'window/manage', model: [
            id: id,
            product:currentProduct,
            release: release,
            previousRelease:previousRelease,
            currentPanel: 'add'
    ])
  }

  @Secured('productOwner() or scrumMaster()')
  def update = {
    if (!params.release.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }
    def release = Release.get(params.long('release.id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def currentProduct = Product.get(params.product)
    def startDate = params.startDate ? new Date().parse(message(code:'is.date.format.short'), params.startDate) : release.startDate
    def endDate = new Date().parse(message(code:'is.date.format.short'), params.endDate)
    release.properties = params.release

    try {
      releaseService.updateRelease(release,currentProduct, startDate, endDate)
      flash.notice = [text:message(code: 'is.release.updated'), type:  'notice']
      if (params.continue) {
        def next = Release.findByBacklogAndOrderNumber(currentProduct,release.orderNumber+1, [cache: true])
        if (next){
          redirect(action: 'edit', params:[product:params.product,id:next.id])
        }else{
          redirect(action: 'index', params:[product:params.product])
        }
      }else{
        redirect(action: 'index', params:[product:params.product])
      }
      pushOthers "${params.product}-${id}"
      push "${params.product}-releasePlan"

    } catch (IllegalStateException ise) {
      if (log.debugEnabled) ise.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)

    } catch (RuntimeException re) {
      if (log.debugEnabled) re.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:release)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def edit = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
    }
    def currentProduct = Product.get(params.product)
    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def previousRelease = currentProduct.releases.find{it.orderNumber == release.orderNumber - 1}
    def nextRelease = currentProduct.releases.find{it.orderNumber == release.orderNumber + 1}

    render(template: 'window/manage', model: [
            id: id,
            product:currentProduct,
            release: release,
            nextReleaseId:nextRelease?.id?:'',
            previousRelease:previousRelease,
            currentPanel: 'edit'
    ])
  }

  @Secured('productOwner() or scrumMaster()')
  def save = {
    def release = new Release(params.release)
    def currentProduct = Product.get(params.product)
    
    release.startDate = new Date().parse(message(code:'is.date.format.short'), params.startDate)
    release.endDate = new Date().parse(message(code:'is.date.format.short'), params.endDate)

    if (release.startDate == new Date().parse('yyyy-MM-dd', currentProduct.startDate.toString()) && currentProduct.releases?.size() == 0)
      release.startDate =  currentProduct.startDate

    try {

      releaseService.saveRelease(release,currentProduct)
      flash.notice = [text:message(code: 'is.release.saved'), type:  'notice']
      if (params.continue) {
        redirect(action: 'add', params:[product:params.product])
      } else
        redirect(action: 'index', params:[product:params.product])
      pushOthers "${params.product}-${id}"
      push "${params.product}-releasePlan"

    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)

    } catch (RuntimeException re) {
     render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:release)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def delete = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
    }
    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def currentProduct = Product.get(params.product)

    try {
      releaseService.deleteRelease(release,currentProduct)
      flash.notice = [text:message(code: 'is.release.deleted'), type:  'notice']
      redirect(action: 'index', params:[product:params.product])
      pushOthers "${params.product}-${id}"
      push "${params.product}-releasePlan"
      push "${params.product}-productBacklog"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:release)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def close = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
    }
    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def currentProduct = Product.get(params.product)

    try {
      releaseService.closeRelease(release,currentProduct)
      flash.notice = [text:message(code: 'is.release.closed'), type:  'notice']
      redirect(action: 'index', params:[product:params.product])
      pushOthers "${params.product}-${id}"
      push "${params.product}-releasePlan"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:release)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def activate = {
    if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
    }
    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def currentProduct = Product.get(params.product)

    try {
      releaseService.activeRelease(release,currentProduct)
      flash.notice = [text:message(code: 'is.release.activated'), type:  'notice']
      redirect(action: 'index', params:[product:params.product])
      pushOthers "${params.product}-${id}"
      push "${params.product}-releasePlan"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:release)]] as JSON)
    }
  }

  def productCumulativeFlowChart = {
      def currentProduct = Product.get(params.product)
      def values = productService.cumulativeFlowValues(currentProduct)
      if(values.size() > 0){
        render(template:'../project/charts/productCumulativeFlowChart',model:[
                id:id,
                withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
                suggested:values.suggested as JSON,
                accepted:values.accepted as JSON,
                estimated:values.estimated as JSON,
                planned:values.planned as JSON,
                inprogress:values.inprogress as JSON,
                done:values.done as JSON,
                labels:values.label as JSON])
      }else{
        def msg = message(code: 'is.chart.error.no.values')
        render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
      }
  }

  def productVelocityCapacityChart = {
      def currentProduct = Product.get(params.product)
      def values = productService.productVelocityCapacityValues(currentProduct)
      if(values.size() > 0){
        render(template:'../project/charts/productVelocityCapacityChart',model:[
                id:id,
                withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
                capacity:values.capacity as JSON,
                velocity:values.velocity as JSON,
                labels:values.label as JSON])
      }else{
        def msg = message(code: 'is.chart.error.no.values')
        render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
      }
  }

  def productBurnupChart = {
      def currentProduct = Product.get(params.product)
      def values = productService.productBurnupValues(currentProduct)
      if(values.size() > 0){
        render(template:'../project/charts/productBurnupChart',model:[
                id:id,
                withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
                all:values.all as JSON,
                done:values.done as JSON,
                labels:values.label as JSON])
      }else{
        def msg = message(code: 'is.chart.error.no.values')
        render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
      }
  }

  def productBurndownChart = {
      def currentProduct = Product.get(params.product)
      def values = productService.productBurndownValues(currentProduct)
      if(values.size() > 0){
        render(template:'../project/charts/productBurndownChart',model:[
                id:id,
                withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
                userstories:values.userstories as JSON,
                technicalstories:values.technicalstories as JSON,
                defectstories:values.defectstories as JSON,
                labels:values.label as JSON])
      }else{
        def msg = message(code: 'is.chart.error.no.values')
        render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
      }
  }

  def productVelocityChart = {
      def currentProduct = Product.get(params.product)
      def values = productService.productVelocityValues(currentProduct)
      if(values.size() > 0){
        render(template:'../project/charts/productVelocityChart',model:[
                id:id,
                withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
                userstories:values.userstories as JSON,
                technicalstories:values.technicalstories as JSON,
                defectstories:values.defectstories as JSON,
                labels:values.label as JSON])
      }else{
        def msg = message(code: 'is.chart.error.no.values')
        render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
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
      render(template:'../feature/charts/productParkinglot',model:[
              id:id,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              values:valueToDisplay as JSON,
              featuresNames:values.label as JSON])
    else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
    }
  }

  /**
   * Export the timeline elements in multiple format (PDF, DOCX, RTF, ODT)
   */
  def print = {
    def currentProduct = Product.get(params.product)
    def values
    def chart = null

    if(params.locationHash){
      chart = processLocationHash(params.locationHash.decodeURL()).action
    }

    switch(chart){
      case 'productCumulativeFlowChart':
        values = productService.cumulativeFlowValues(currentProduct)
        break
      case 'productBurnupChart':
        values = productService.productBurnupValues(currentProduct)
        break
      case 'productBurndownChart':
        values = productService.productBurndownValues(currentProduct)
        break
      case 'productParkingLotChart':
        values = featureService.productParkingLotValues(currentProduct)
        break
      case 'productVelocityChart':
        values = productService.productVelocityValues(currentProduct)
        break
      case 'productVelocityCapacityChart':
        values = productService.productVelocityCapacityValues(currentProduct)
        break
      default:
        chart='timeline'
        values = [
                [
                        releaseStateBundle:ReleaseStateBundle,
                        releases: currentProduct.releases,
                        productCumulativeFlowChart: productService.cumulativeFlowValues(currentProduct),
                        productBurnupChart: productService.productBurnupValues(currentProduct),
                        productBurndownChart: productService.productBurndownValues(currentProduct),
                        productParkingLotChart: featureService.productParkingLotValues(currentProduct),
                        productVelocityChart: productService.productVelocityValues(currentProduct),
                        productVelocityCapacityChart: productService.productVelocityCapacityValues(currentProduct)
                ]
        ]
        break
    }
    
    if (values.size() <= 0){
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    } else if(params.get) {
      session.progress = new ProgressSupport()
      session.progress.updateProgress(99,message(code:'is.report.processing'))
      try {
     def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+(chart ?: 'timeline')+'-'+(g.formatDate(formatName:'is.date.file'))
      chain(controller: 'jasper',
              action: 'index',
              model: [data: values],
              params: [
                      locale: User.get(springSecurityService.principal.id).preferences.language,
                      _format:params.format,
                      _file: chart ?: 'timeline',
                      _name: fileName,
                      'labels.projectName':currentProduct.name,
                      SUBREPORT_DIR: grailsApplication.config.jasper.dir.reports + File.separator + 'subreports' + File.separator
              ]
      )
      session.progress?.completeProgress(message(code: 'is.report.complete'))
      } catch(Exception e){
        if (log.debugEnabled) e.printStackTrace()
        session.progress.progressError(message(code: 'is.report.error'))
      }
    }  else if(params.status){
      render(status:200,contentType: 'application/json', text:session.progress as JSON)
    } else {
      render(template: 'dialogs/report', model: [id: id])
    }
  }

  /**
   * Parse the location hash string passed in argument
   * @param locationHash
   * @return A Map 
   */
  private processLocationHash(String locationHash){
    def data = locationHash.split('/')
    return [
            controller:data[0].replace('#', ''),
            action:data.size() > 1 ? data[1] : null
    ]
  }
}
