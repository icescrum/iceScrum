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
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story
import org.icescrum.core.support.MenuBarSupport

@Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
class ReleasePlanController {
  def productBacklogService
  def springSecurityService
  def sprintService
  def releaseService
  def featureService

  static ui = true

  static final id = 'releasePlan'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.releasePlan', id, true, 4)
  static window =  [title:'is.ui.releasePlan',help:'is.ui.releasePlan.help',init:'index',toolbar:true,titleBarContent:true]

  static shortcuts = [
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],
          [code:'is.ui.shortcut.ctrln.code',text:'is.ui.shortcut.releasePlan.ctrln.text'],
          [code:'is.ui.shortcut.ctrlg.code',text:'is.ui.shortcut.releasePlan.ctrlg.text'],
          [code:'is.ui.shortcut.ctrlshifta.code',text:'is.ui.shortcut.releasePlan.ctrlshifta.text'],
          [code:'is.ui.shortcut.ctrlshiftv.code',text:'is.ui.shortcut.releasePlan.ctrlshiftv.text'],
          [code:'is.ui.shortcut.ctrlshiftd.code',text:'is.ui.shortcut.releasePlan.ctrlshiftd.text']
  ]

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


  static StoryStateBundle = [
          (Story.STATE_SUGGESTED):'is.story.state.suggested',
          (Story.STATE_ACCEPTED):'is.story.state.accepted',
          (Story.STATE_ESTIMATED):'is.story.state.estimated',
          (Story.STATE_PLANNED):'is.story.state.planned',
          (Story.STATE_INPROGRESS):'is.story.state.inprogress',
          (Story.STATE_DONE):'is.story.state.done'
  ]

  static StoryTypesBundle = [
          (Story.TYPE_USER_STORY): 'is.story.type.story',
          (Story.TYPE_DEFECT): 'is.story.type.defect',
          (Story.TYPE_TECHNICAL_STORY): 'is.story.type.technical'
  ]

  def titleBarContent = {
    def release = null
    def releases = null
    if (!params.id){
       release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
       if (release){
        params.id = release.id
       }
    }else{
     release = Release.get(params.long('id'))
    }
    releases = Release.findAllByParentProduct(Product.get(params.product), [sort:'startDate'])
    def releasesHtml = []
    releases.each{
      def u = [:]
      u.id = it.id
      u.name = it.name.encodeAsHTML()
      releasesHtml << u
    }
    render(template:'window/titleBarContent', model:[currentView:session.currentView, id:id, releases:releasesHtml,release:release])
  }

  def toolbar = {
    def release = null
    if (!params.id){
       release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
       if (release){
        params.id = release.id
       }
    }
    render(template:'window/toolbar', model:[currentView:session.currentView, id:id])
  }

  def index = {
    def release = null
    if (!params.id){
       release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
       if (release){
        params.id = release.id
       }else{
          render(template:'window/blank',model:[id:id])
          return
       }
    }else{
      release = Release.get(params.long('id'))
    }
    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.release.not.exist')]] as JSON)
      return
    }
    if (release.sprints.size()==0){
        render(template:'window/blankSprint',model:[id:id,release:release])
        return
    }
    def sprints = release?.sprints?.asList()
    def activeSprint = release?.sprints?.find { it.state == Sprint.STATE_INPROGRESS }
    def nextSprint = releaseService.nextSprintActivable(release)?:0

    render(template: 'window/planView', model: [sprints: sprints, id: id, activeSprint: activeSprint, nextSprint:nextSprint,releaseId:release.id])
  }

  @Secured('productOwner() or scrumMaster()')
  def save = {
    def sprint = new Sprint(params.sprint)
    def release = Release.get(params.long('id'))
    sprint.startDate = new Date().parse(message(code:'is.date.format.short'), params.startDate)
    sprint.endDate = new Date().parse(message(code:'is.date.format.short'), params.endDate)
    try {
      sprintService.saveSprint(sprint, release)
      flash.notice = [text:message(code: 'is.sprint.saved'), type:  'notice']
      if (params.continue) {
        redirect(action: 'add', params:[product:params.product,id:release.id])
      } else{
        redirect(action: 'index', params:[product:params.product,id:release.id])
      }
      pushOthers "${params.product}-${id}-${release.id}"
      push "${params.product}-timeline"

    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def update = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    sprint.properties = params.sprint
    def startDate = params.startDate ? new Date().parse(message(code:'is.date.format.short'), params.startDate) : sprint.startDate
    def endDate = new Date().parse(message(code:'is.date.format.short'), params.endDate)

    try {
      sprintService.updateSprint(sprint,startDate,endDate)
      flash.notice = [text:message(code: 'is.sprint.updated'), type:  'notice']
      if (params.continue) {
        def nextSprint = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber+1,sprint.parentRelease)
        if(nextSprint){
          redirect(action: 'edit', params:[product:params.product,id:nextSprint.id])
        }else{
          redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
        }
      }else{
        redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      }
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      push "${params.product}-productBacklog"
      push "${params.product}-sprintBacklog-${sprint.id}"

    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def delete = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    if(sprint.orderNumber < sprint.parentRelease.sprints.size() && !params.confirm){
        render include(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
        render(template:"dialogs/confirmDeleteSprint",model:[sprint:sprint,release:sprint.parentRelease,id:id])
        return
    }

    try {
      def releaseId = sprint.parentRelease.id
      def sprintId = sprint.id
      sprintService.deleteSprint(sprint)
      flash.notice = [text:message(code: 'is.sprint.deleted'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:releaseId])
      pushOthers "${params.product}-${id}-${releaseId}"
      push "${params.product}-productBacklog"
      push "${params.product}-timeline"
      push "${params.product}-sprintBacklog-${sprintId}"
      
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }

  }

  @Secured('productOwner() or scrumMaster()')
  def associateStory = {
    if (!params.sprint.id){
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    if (!params.story.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('sprint.id'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    def story = Story.get(params.long('story.id'))

    if (!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    if (story.parentSprint?.id == params.sprint.id) {
      render(status: 200)
      return
    }

    try {
      def oldSprint = story.parentSprint?.id ?: null
      productBacklogService.associateStory(sprint, story)

      if(params.position && params.int('position') != 0){
          sprintService.changeRank(sprint, story, params.int('position'))
      }
      redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      pushOthers "${params.product}-productBacklog"
      push "${params.product}-sprintBacklog-${sprint.id}"
      if (oldSprint)
        push "${params.product}-sprintBacklog-${oldSprint}"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def add = {
    if (!params.id){
       def msg = message(code: 'is.release.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }
    def release = Release.get(params.long('id'))
    def previousSprint = release?.sprints?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}

    render(template: 'window/manage', model: [
            id: id,
            currentPanel: 'add',
            release: release,
            previousSprint: previousSprint,
            product:release.parentProduct
    ])
  }

  @Secured('productOwner() or scrumMaster()')
  def edit = {
    if (!params.id){
       def msg = message(code: 'is.sprint.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    def previousSprint = sprint.parentRelease.sprints?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}
    def nextSprint = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber+1,sprint.parentRelease)
    render(template: 'window/manage', model: [
            id: id,
            currentPanel: 'edit',
            release: sprint.parentRelease,
            nextSprintId:nextSprint?.id?:'',
            sprint: sprint,
            previousSprint: previousSprint,
            product:sprint.parentRelease.parentProduct
    ])
  }

  def vision = {
     if (!params.id) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }
    def release = Release.get(params.long('id'))
    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }
    render(template: 'window/visionView', model: [release: release, id:id])
  }

  @Secured('productOwner()')
  def updateVision = {
    if (!params.id){
       def msg = message(code: 'is.release.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }
    def release = Release.get(params.long('id'))
    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }
    release.vision = params.vision

    try {
      releaseService.updateVision(release)
      pushOthers "${params.product}-${id}-vision-${release.id}"
      render(status:200)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:release)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def dissociate = {
    if (!params.story.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def story = Story.get(params.long('story.id'))

    if (!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

   try {
      def sprint = story.parentSprint
      productBacklogService.dissociateStory(sprint, story)
      redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      push "${params.product}-productBacklog"
      push "${params.product}-sprintBacklog-${sprint.id}"
    } catch (IllegalStateException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: e)]] as JSON)
    } catch (RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def dissociateAll = {
    if (!params.id){
       def msg = message(code: 'is.release.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }
    def sprints = Sprint.findAllByParentRelease(Release.get(params.long('id')))
    try {
      productBacklogService.dissociatedAllStories(sprints, Sprint.STATE_WAIT)
      flash.notice = [text:message(code: 'is.release.stories.dissociate'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:params.id])
      pushOthers "${params.product}-${id}-${sprints.first().id}"
      push "${params.product}-productBacklog"
      for(sprint in sprints){
        push "${params.product}-sprintBacklog-${sprint.id}"
      }
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.release.stories.error.not.dissociate')]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def dissociateAllSprint = {
    if (!params.id){
       def msg = message(code: 'is.sprint.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }

    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    try {
      productBacklogService.dissociatedAllStories([sprint])
      flash.notice = [text:message(code: 'is.sprint.stories.dissociate'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      push "${params.product}-productBacklog"
      push "${params.product}-sprintBacklog-${sprint.id}"
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.release.stories.error.not.dissociate')]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def generateSprints = {
    if (!params.id){
       def msg = message(code: 'is.sprint.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }
    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    try {
      sprintService.generateSprints(release)
      flash.notice = [text:message(code: 'is.release.sprints.generated'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:params.id])
      pushOthers "${params.product}-${id}-${release.id}"
      push "${params.product}-timeline"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def autoPlan = {
    if (!params.id){
       def msg = message(code: 'is.release.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }
    if(!params.capacity){
      render include(action: 'index', params:[product:params.product,id:params.id])
      render(template:"dialogs/promptCapacityAutoPlan",model:[id:id])
      return
    }
    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    try {
      productBacklogService.autoPlan(release,params.double('capacity'))
      flash.notice = [text:message(code: 'is.release.autoplan'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:params.id])
      pushOthers "${params.product}-${id}-${release.id}"
      push "${params.product}-productBacklog"
      for (sprint in release.sprints){
        push "${params.product}-sprintBacklog-${sprint.id}"
      }
    } catch (Exception e) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: 'is.release.error.not.autoplan')]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def activate = {
    if(!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    def product = Product.get(params.product)

    if(sprint.orderNumber == 1 && sprint.parentRelease.state == Release.STATE_WAIT && !params.confirm){
        render include(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
        render(template:"dialogs/confirmActivateSprintAndRelease",model:[sprint:sprint,release:sprint.parentRelease,id:id])
        return    
    }

    try {

      if(params.confirm){
        def currentRelease = product.releases?.find{it.state == Release.STATE_INPROGRESS}
        if (currentRelease)
          releaseService.closeRelease(currentRelease, product)
        releaseService.activeRelease(sprint.parentRelease,product)
      }

      sprintService.activeSprint(sprint)
      flash.notice = [text:message(code: 'is.sprint.activated'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      push "${params.product}-timeline"
      push "${params.product}-sprintBacklog-${sprint.id}"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: ise.getMessage())]] as JSON)
    } catch(RuntimeException  e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def close = {
    if(!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    def unDoneStories = sprint.stories.findAll{it.state != Story.STATE_DONE}
    if(unDoneStories?.size() > 0 && !params.confirm){
      render include(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      render(template:"dialogs/confirmCloseSprintWithUnDoneStories",model:[stories:unDoneStories, sprint:sprint, id:id])
      return
    }

    try {
      if (unDoneStories?.size() > 0 && params.confirm){
        params.story.id.each{
          if (it.value.toInteger() == 1){
            productBacklogService.declareAsDone(Story.get(it.key.toLong()))
          }
        }
      }
      sprintService.closeSprint(sprint)
      flash.notice = [text:message(code: 'is.sprint.closed'), type:  'notice']
      redirect(action: 'index', params:[product:params.product,id:sprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      push "${params.product}-productBacklog"
      push "${params.product}-sprintBacklog-${sprint.id}"
      push "${params.product}-timeline"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType:'application/json', text: [notice: [text:message(code: ise.getMessage())]] as JSON)
    } catch(RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def declareAsDone = {
    if(!params.story.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def story = Story.get(params.long('story.id'))

    if (!story) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    try {
      productBacklogService.declareAsDone(story)
      redirect(action: 'index', params:[product:params.product,id:story.parentSprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${story.parentSprint.parentRelease.id}"
      pushOthers "${params.product}-sprintBacklog-${story.parentSprint}"
    } catch (IllegalStateException ise) {
      if (log.debugEnabled) ise.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def declareAsUnDone = {
    if (!params.story.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def story = Story.get(params.long('story.id'))

    if (!story) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    try {
      productBacklogService.declareAsUnDone(story)
      flash.notice = [text: message(code: 'is.story.declaredAsUnDone'), type: 'notice']
      redirect(action: 'index', params:[product:params.product,id:story.parentSprint.parentRelease.id])
      pushOthers "${params.product}-${id}-${story.parentSprint.parentRelease.id}"
      pushOthers "${params.product}-sprintBacklog-${story.parentSprint}"
    } catch (IllegalStateException ise) {
      if (log.debugEnabled) ise.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      if (log.debugEnabled) e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def changeRank = {
    def position = params.int('position')
    if (position == 0){
      render(status: 200)
      return
    }

    def movedItem = Story.get(params.long('idmoved'))

    if (!movedItem) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    def sprint = Sprint.get(params.long('idsprint'))

    if (!sprint) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    if (sprintService.changeRank(sprint, movedItem, position)) {
      pushOthers "${params.product}-${id}-${sprint.parentRelease.id}"
      push "${params.product}-sprintBacklog-${sprint.id}"
      render(status: 200)
    } else {
      render(status: 500, text: '')
    }
  }

  def releaseBurndownChart = {
    if (!params.id){
       def msg = message(code: 'is.release.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }

    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def values = releaseService.releaseBurndownValues(release)
    if(values.size() > 0){
      render(template:'charts/releaseBurndownChart',model:[
              id:id,
              userstories:values.userstories as JSON,
              technicalstories:values.technicalstories as JSON,
              defectstories:values.defectstories as JSON,
              labels:values.label as JSON])
    }else{
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
    }
  }

  def releaseParkingLotChart = {
    if (!params.id){
       def msg = message(code: 'is.release.error.not.exist')
       render(status: 400, contentType:'application/json', text: [notice: [text: msg]] as JSON)
       return false
    }

    def release = Release.get(params.long('id'))

    if (!release) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
      return
    }

    def values = featureService.releaseParkingLotValues(release)

    def valueToDisplay = []
    def indexF = 1
    values.value?.each{
      def value = []
      value << it.toString()
      value << indexF
      valueToDisplay << value
      indexF++
    }
    if (valueToDisplay.size() > 0)
      render(template:'charts/releaseParkingLot',model:[id:id,values:valueToDisplay as JSON,featuresNames:values.label as JSON])
    else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType:'application/json',  text: [notice: [text: msg]] as JSON)
    }
  }
}
