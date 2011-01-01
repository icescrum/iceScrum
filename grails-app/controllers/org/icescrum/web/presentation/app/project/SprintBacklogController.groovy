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
import org.icescrum.web.support.MenuBarSupport

import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User

@Secured('inProduct()')
class SprintBacklogController {

  static ui = true

  static final id = 'sprintBacklog'
  static menuBar = MenuBarSupport.productDynamicBar('is.ui.sprintBacklog', id, true, 5)
  static window = [title: 'is.ui.sprintBacklog',help:'is.ui.sprintBacklog.help', toolbar: true, titleBarContent:true]

  static shortcuts = [
          [code:'is.ui.shortcut.escape.code',text:'is.ui.shortcut.escape.text'],
          [code:'is.ui.shortcut.del.code',text:'is.ui.shortcut.sprintBacklog.del.text'],
          [code:'is.ui.shortcut.ctrln.code',text:'is.ui.shortcut.sprintBacklog.ctrln.text'],
          [code:'is.ui.shortcut.ctrla.code',text:'is.ui.shortcut.sprintBacklog.ctrla.text'],
          [code:'is.ui.shortcut.ctrlshiftc.code',text:'is.ui.shortcut.sprintBacklog.ctrlshiftc.text'],
          [code:'is.ui.shortcut.ctrlshiftd.code',text:'is.ui.shortcut.sprintBacklog.ctrlshiftd.text'],
          [code:'is.ui.shortcut.ctrlshiftr.code',text:'is.ui.shortcut.sprintBacklog.ctrlshiftr.text']
  ]

  static stateBundle = [
          (Story.STATE_PLANNED): 'is.story.state.planned',
          (Story.STATE_INPROGRESS): 'is.story.state.inprogress',
          (Story.STATE_DONE): 'is.story.state.done'
  ]

  static SprintStateBundle = [
          (Sprint.STATE_WAIT):'is.sprint.state.wait',
          (Sprint.STATE_INPROGRESS):'is.sprint.state.inprogress',
          (Sprint.STATE_DONE):'is.sprint.state.done'
  ]

  static taskStateBundle = [
          (Task.STATE_WAIT):'is.task.state.wait',
          (Task.STATE_BUSY):'is.task.state.inprogress',
          (Task.STATE_DONE):'is.task.state.done'
  ]

  static storyTypesBundle = [
          (Story.TYPE_USER_STORY): 'is.story.type.story',
          (Story.TYPE_DEFECT): 'is.story.type.defect',
          (Story.TYPE_TECHNICAL_STORY): 'is.story.type.technical'
  ]

  def springSecurityService
  def productBacklogService
  def sprintService
  def taskService
  def releaseService
  def userService


  def titleBarContent = {
    def sprint = null
    def currentProduct = Product.load(params.product)
    if (!params.id) {
      sprint = Sprint.findCurrentOrNextSprint(currentProduct.id).list()[0]
      if (sprint)
        params.id = sprint.id
    }

    def sprintsName = []
    def sprintsId = []
    currentProduct.releases?.each {
      sprintsName.addAll(it.sprints.collect {v -> "R${it.orderNumber}S${v.orderNumber}"})
      sprintsId.addAll(it.sprints.id)
    }
    render(template: 'window/titleBarContent',
            model: [id: id,
                    sprintsId: sprintsId,
                    sprintsName: sprintsName])
  }

  def toolbar = {
    def sprint = null
    def currentProduct = Product.load(params.product)
    if (!params.id) {
      sprint = Sprint.findCurrentOrNextSprint(currentProduct.id).list()[0]
      if (sprint)
        params.id = sprint.id
    } else {
      sprint = Sprint.get(params.long('id'))
    }

    def activable = false
    if (sprint){
      def nextSprint = releaseService.nextSprintActivable(sprint.parentRelease)
      activable = (nextSprint == sprint.orderNumber)

    }

    def user = User.load(springSecurityService.principal.id)

    render(template: 'window/toolbar',
            model: [id: id,
                    currentView: session.currentView,
                    activable:activable,
                    hideDoneState:user.preferences.hideDoneState,
                    currentFilter:user.preferences.filterTask,
                    sprint: sprint ?: null])
  }

  def index = {
    def sprint = null
    def user = User.load(springSecurityService.principal.id)
    def currentProduct = Product.load(params.product)
    if (!params.id) {
      sprint = Sprint.findCurrentOrNextSprint(currentProduct.id).list()[0]
      if (sprint)
        params.id = sprint.id
      else {
        def release = currentProduct.releases.find {it.state == Release.STATE_WAIT}
        render(template: 'window/blank', model: [id: id, release: release ?: null])
        return
      }
    }
    sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.not.exist')]] as JSON)
      return
    }
    def columns = [
            [key: (Task.STATE_WAIT), name: 'is.task.state.wait'],
            [key: (Task.STATE_BUSY), name: 'is.task.state.inprogress'],
            [key: (Task.STATE_DONE), name: 'is.task.state.done']
    ]

    def stateSelect = taskStateBundle.collect{k, v -> "'$k':'${message(code:v)}'" }.join(',')

    def stories
    def recurrentTasks
    def urgentTasks

    if(params.term && params.term != ''){
      stories = Story.findStoriesFilter(sprint,'%' + params.term + '%',user).listDistinct()
      recurrentTasks = Task.findRecurrentTasksFilter(sprint,'%' + params.term + '%',user).listDistinct()
      urgentTasks = Task.findUrgentTasksFilter(sprint,'%' + params.term + '%',user).listDistinct()
    }else{
      stories = Story.findStoriesFilter(sprint,null,user).listDistinct()
      recurrentTasks = Task.findRecurrentTasksFilter(sprint,null,user).listDistinct()
      urgentTasks = Task.findUrgentTasksFilter(sprint,null,user).listDistinct()
    }
    def template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
    render(template: template,
            model: [id: id,
                    sprint: sprint,
                    stories: stories,
                    recurrentTasks:recurrentTasks,
                    urgentTasks:urgentTasks,
                    columns: columns,
                    stateSelect:stateSelect,
                    hideDoneState:user.preferences.hideDoneState,
                    previousSprintExist:(sprint.orderNumber > 1)?:false,
                    nextSprintExist:Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease,sprint.orderNumber + 1)?:false,
                    displayUrgentTasks: sprint.parentRelease.parentProduct.preferences.displayUrgentTasks,
                    displayRecurrentTasks: sprint.parentRelease.parentProduct.preferences.displayRecurrentTasks,
                    limitValueUrgentTasks:sprint.parentRelease.parentProduct.preferences.limitUrgentTasks,
                    urgentTasksLimited:(urgentTasks.findAll {it.state == Task.STATE_BUSY}.size() >= sprint.parentRelease.parentProduct.preferences.limitUrgentTasks),
                    user: user])
  }


  def save = {
    def story = !(params.story.id in ['recurrent', 'urgent']) ? Story.get(params.long('story.id')) : null
    if (!story && !(params.story.id in ['recurrent', 'urgent'])) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    def task = new Task(params.task)

    def currentUserInstance = User.get(springSecurityService.principal.id)
    def sprint = Sprint.load(params.id)
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    try {
      if (params.story.id == 'recurrent')
        taskService.saveRecurrentTask(task, sprint, currentUserInstance)
      else if (params.story.id == 'urgent')
        taskService.saveUrgentTask(task, sprint, currentUserInstance)
      else
        taskService.saveStoryTask(task, story, currentUserInstance)

      this.manageAttachments(task)
      flash.notice = [text: message(code: 'is.task.saved'), type: 'notice']
      if (params.continue) {
        redirect(action: 'add', params: [product: params.product, id: sprint.id, 'story.id': params.story.id])
      } else {
        redirect(action: 'index', params: [product: params.product, id: sprint.id])
      }
      pushOthers "${params.product}-${id}-${sprint.id}"

    } catch (IllegalStateException ise) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
  }

  def updateTable = {

    def task = Task.get(params.long('task.id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }

    if (params.boolean('loadrich')){
      render(status: 200, text: task.notes?:'')
      return
    }

    if (!params.table){
      return
    }

    if (params.name != 'estimation'){
      if (task.state == Task.STATE_WAIT && params.name == "state" && params.task.state >= Task.STATE_BUSY){
        task.inProgressDate = new Date()
      }else if (task.state == Task.STATE_BUSY && params.name == "state" && params.task.state == Task.STATE_WAIT){
        task.inProgressDate = null
      }
      task.properties = params.task
    }
    else {
      task.estimation = params.int('task.estimation')?:(params.int('task.estimation') == 0)?0:null
    }

    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.load(params.product)

    try {
      taskService.updateTask(task, currentUserInstance, product)

      def returnValue
      if (params.name == 'notes'){
        returnValue = wikitext.renderHtml(markup:'Textile',text:task."${params.name}")
      }else if(params.name == 'estimation'){
        returnValue = task.estimation?:'?'
      }else if (params.name == 'state'){
        returnValue = g.message(code:taskStateBundle.get(task.state))
      }else if (params.name == 'description'){
        returnValue = task.description?.encodeAsHTML()?.encodeAsNL2BR()
      }else{
        returnValue = task."${params.name}".encodeAsHTML()
      }

      def version = task.isDirty() ? task.version + 1 : task.version
      render(status: 200, text: [version:version,value:returnValue?:''] as JSON)

      if ((params.name == 'estimation' && task.state == Task.STATE_DONE) || params.name == 'state'){
        push "${params.product}-${id}-${task.backlog.id}"
      }else{
        pushOthers "${params.product}-${id}-${task.backlog.id}"
      }

    } catch (IllegalStateException ise) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
  }


  def update = {
      if (!params.task) return

    def story = !(params.story.id in ['recurrent', 'urgent']) ? Story.get(params.long('story.id')) : null

    if (!story && !(params.story?.id in ['recurrent', 'urgent'])) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    def sprintTask = (params.story.id in ['recurrent', 'urgent']) ? params.story.id == 'recurrent' ? Task.TYPE_RECURRENT : Task.TYPE_URGENT : null

    def task = Task.get(params.long('task.id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    task.properties = params.task
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.load(params.product)

    try {

      // If the task was moved to another story
      if (story && story.id != task.parentStory.id) {
        taskService.changeTaskStory(task, story, currentUserInstance, product)
        // If the Task was transformed to a Task

      } else if (!story && task.parentStory) {
        task = taskService.storyTaskToSprintTask(task, sprintTask, currentUserInstance)
        // If the Task was transformed to a Task

      } else if (story && !task.parentStory) {
        task = taskService.sprintTaskToStoryTask(task, story, currentUserInstance)
        // If the Task has changed its type (TYPE_RECURRENT/TYPE_URGENT)

      } else if (task && sprintTask != task.type) {
        taskService.changeTaskType(task, sprintTask, currentUserInstance, product)

      }else{
        taskService.updateTask(task, currentUserInstance, product)
      }
      this.manageAttachments(task)
      flash.notice = [text: message(code: 'is.task.updated'), type: 'notice']
      if (params.continue) {
        def nextTask = null
        nextTask = Task.findNextTask(task, currentUserInstance).list()[0]
        if (nextTask) {
          redirect(action: 'edit', params: [product: params.product, id: nextTask.id])
        } else {
          redirect(action: 'index', params: [product: params.product, id: task.backlog.id])
        }
      } else {
        redirect(action: 'index', params: [product: params.product, id: task.backlog.id])
      }
      pushOthers "${params.product}-${id}-${task.backlog.id}"
    } catch (IllegalStateException ise) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
  }


  def add = {
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    def stories = sprint ? Story.findAllByParentSprintAndStateLessThanEquals(sprint, Story.STATE_INPROGRESS, [sort: 'rank']) : []

    def selected = null
    if (params.story?.id && !(params.story.id in ['recurrent', 'urgent']))
      selected = Story.get(params.long('story.id'))
    else if (params.story?.id && (params.story.id in ['recurrent', 'urgent']))
      selected = [id: params.story?.id]

    def selectList = []
    if (sprint.parentRelease.parentProduct.preferences.displayRecurrentTasks)
      selectList << [id: 'recurrent', name: ' ** ' + message(code: 'is.task.type.recurrent') + ' ** ']
    if (sprint.parentRelease.parentProduct.preferences.displayUrgentTasks)
      selectList << [id: 'urgent', name: ' ** ' + message(code: 'is.task.type.urgent') + ' ** ']
    selectList = selectList + stories

    render(template: 'window/manage', model: [
            id: id,
            currentPanel: 'add',
            sprint: sprint,
            stories: selectList,
            selected: selected,
            params: [product: params.product, id: sprint.id]
    ])
  }


  def edit = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }

    def task = Task.get(params.long('id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }

    def selected = null
    if (task.type == Task.TYPE_RECURRENT)
      selected = [id: 'recurrent']
    else if (task.type == Task.TYPE_URGENT)
      selected = [id: 'urgent']
    else
      selected = task.parentStory

    def sprint = task.backlog
    def stories = Story.findAllByParentSprintAndStateLessThanEquals(sprint, Story.STATE_INPROGRESS, [sort: 'rank'])

    def selectList = []
    if (sprint.parentRelease.parentProduct.preferences.displayRecurrentTasks)
      selectList << [id: 'recurrent', name: ' ** ' + message(code: 'is.task.type.recurrent') + ' ** ']
    if (sprint.parentRelease.parentProduct.preferences.displayUrgentTasks)
      selectList << [id: 'urgent', name: ' ** ' + message(code: 'is.task.type.urgent') + ' ** ']
    selectList = selectList + stories

    def nextTask = null
    def currentUserInstance = User.load(springSecurityService.principal.id)
    nextTask = Task.findNextTask(task, currentUserInstance).list()[0]

    render(template: 'window/manage', model: [
            id: id,
            currentPanel: 'edit',
            task: task,
            stories: selectList,
            selected: selected,
            nextTaskId: nextTask?.id ?: '',
            sprint: task.backlog,
            params: [product: params.product, id: task.id]
    ])
  }

  def take = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def task = Task.get(params.long('id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.get(params.product)

    try {
      taskService.assignToTasks([task], currentUserInstance, product)
      flash.notice = [text: message(code: 'is.task.taken'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: task.backlog.id])
      pushOthers "${params.product}-${id}-${task.backlog.id}"
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
  }

  def unassign = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def task = Task.get(params.long('id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.get(params.product)

    try {
      taskService.unAssignToTasks([task], currentUserInstance, product)
      flash.notice = [text: message(code: 'is.task.unassigned'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: task.backlog.id])
      pushOthers "${params.product}-${id}-${task.backlog.id}"
    } catch (IllegalStateException ise) {
      ise.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
  }


  def delete = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def tasks = Task.getAll(params.list('id'))
    def currentUserInstance = User.load(springSecurityService.principal.id)
    def product = Product.get(params.product)

    try {
      def parentSprintId = tasks.first().backlog.id
      tasks.each {
        taskService.deleteTask(it, currentUserInstance, product)
      }
      flash.notice = [text: message(code: 'is.task.deleted'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: parentSprintId])
      pushOthers "${params.product}-${id}-${parentSprintId}"
      } catch (IllegalStateException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: e.message]] as JSON)
    }
   }

  def cloneTask = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def task = Task.get(params.long('id'))
    def currentUserInstance = User.load(springSecurityService.principal.id)
    def product = Product.get(params.product)

    try {
      taskService.cloneTask(task, currentUserInstance, product)
      flash.notice = [text: message(code: 'is.task.recreated'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: task.backlog.id])
      pushOthers "${params.product}-${id}-${task.backlog.id}"
      } catch (IllegalStateException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:e.getMessage())]] as JSON)
    }
   }

  def changeState = {
    // params.id represent the targeted state (STATE_WAIT, STATE_INPROGRESS, STATE_DONE)
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.sprintBacklog.state.no.exist')]] as JSON)
    }
    if (!params.task.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def task = Task.get(params.long('task.id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.get(params.product)

    try {

      // If the task was moved to another story
      if (params.story?.id && task.parentStory && params.story.id != task.parentStory.id) {
        def story = Story.get(params.long('story.id'))
        taskService.changeTaskStory(task, story, currentUserInstance, product)

        // If the Task was transformed to a Task
      } else if (params.task?.type && task.parentStory) {
        task = taskService.storyTaskToSprintTask(task, params.int('task.type'), currentUserInstance)

        // If the Task was transformed to a Task
      } else if (params.story?.id) {
        def story = Story.get(params.long('story.id'))
        task = taskService.sprintTaskToStoryTask(task, story, currentUserInstance)

        // If the Task has changed its type (TYPE_RECURRENT/TYPE_URGENT)
      } else if (params.task.type && params.int('task.type') != task.type) {
        taskService.changeTaskType(task, params.int('task.type'), currentUserInstance, product)
      }

      taskService.changeState(task, params.int('id'), currentUserInstance, product)
      taskService.changeRank(task,params.int('position'))      
      redirect(action: 'index', params: [product: params.product, id: task.backlog.id])
      pushOthers "${params.product}-${id}-${task.backlog.id}"

    } catch (IllegalStateException ise) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def activate = {          
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    def product = Product.get(params.product)

    if (sprint.orderNumber == 1 && sprint.parentRelease.state == Release.STATE_WAIT && !params.confirm) {
      render include(action: 'index', params: [product: params.product, id: sprint.id])
      render(template: "../releasePlan/dialogs/confirmActivateSprintAndRelease", model: [sprint: sprint, release: sprint.parentRelease, id: id])
      return
    }

    try {

      if (params.confirm) {
        def currentRelease = product.releases?.find {it.state == Release.STATE_INPROGRESS}
        if (currentRelease)
          releaseService.closeRelease(currentRelease, product)
        releaseService.activeRelease(sprint.parentRelease, product)
      }

      sprintService.activeSprint(sprint)
      flash.notice = [text: message(code: 'is.sprint.activated'), type: 'notice']
      flash.javascript = "\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
      redirect(action: 'index', params: [product: params.product, id: sprint.id])
      pushOthers "${params.product}-${id}-${sprint.id}"
      push "${params.product}-timeline"
      push "${params.product}-releasePlan-${sprint.parentRelease.id}"
    } catch (IllegalStateException ise) {
      ise.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def close = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    def unDoneStories = sprint.stories.findAll {it.state != Story.STATE_DONE}
    if (unDoneStories?.size() > 0 && !params.confirm) {
      render include(action: 'index', params: [product: params.product, id: sprint.id])
      render(template: "../releasePlan/dialogs/confirmCloseSprintWithUnDoneStories", model: [stories: unDoneStories, sprint: sprint, id: id])
      return
    }

    try {
      if (unDoneStories?.size() > 0 && params.confirm) {
        params.story.id.each {
          if (it.value.toInteger() == 1) {
            productBacklogService.declareAsDone(Story.get(it.key.toLong()))
          }
        }
      }
      sprintService.closeSprint(sprint)
      flash.notice = [text: message(code: 'is.sprint.closed'), type: 'notice']
      flash.javascript = "\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
      redirect(action: 'index', params: [product: params.product])
      pushOthers "${params.product}-${id}-${sprint.id}"
      push "${params.product}-timeline"
      push "${params.product}-releasePlan-${sprint.parentRelease.id}"
    } catch (IllegalStateException ise) {
      ise.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  def doneDefinition = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    render(template: 'window/doneDefinitionView', model: [sprint: sprint, id: id])
  }

  @Secured('productOwner() or scrumMaster()')
  def updateDoneDefinition = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return false
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    sprint.doneDefinition = params.doneDefinition

    try {
      sprintService.updateDoneDefinition(sprint)
      pushOthers "${params.product}-${id}-doneDefinition-${sprint.id}"
      render(status: 200)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def copyFromPreviousDoneDefinition = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return false
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    if (sprint.orderNumber > 1 || sprint.parentRelease.orderNumber > 1) {
      def previous = null
      if (sprint.orderNumber > 1) {
        previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease, sprint.orderNumber - 1)
      } else {
        previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease.orderNumber, sprint.parentRelease.sprints.size())
      }
      sprint.doneDefinition = previous.doneDefinition
    } else {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.doneDefinition.no.previous')]] as JSON)
    }

    try {
      sprintService.updateDoneDefinition(sprint)
      flash.notice = [text: message(code: 'is.sprint.doneDefinition.copied'), type: 'notice']
      redirect(action: 'doneDefinition', params: [product: params.product, id: sprint.id])
      pushOthers "${params.product}-${id}-doneDefinition-${sprint.id}"
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  def retrospective = {
    if (!params.id) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    render(template: 'window/retrospectiveView', model: [sprint: sprint, id: id])
  }

  @Secured('productOwner() or scrumMaster()')
  def updateRetrospective = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return false
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    sprint.retrospective = params.retrospective

    try {
      sprintService.updateRetrospective(sprint)
      pushOthers "${params.product}-${id}-retrospective-${sprint.id}"
      render(status: 200)
    } catch (RuntimeException re) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def copyFromPreviousRetrospective = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return false
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    if (sprint.orderNumber > 1 || sprint.parentRelease.orderNumber > 1) {
      def previous = null
      if (sprint.orderNumber > 1) {
        previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease, sprint.orderNumber - 1)
      } else {
        previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease.orderNumber, sprint.parentRelease.sprints.size())
      }
      sprint.retrospective = previous.retrospective
    } else {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.retrospective.no.previous')]] as JSON)
    }

    try {
      sprintService.updateRetrospective(sprint)
      flash.notice = [text: message(code: 'is.sprint.retrospective.copied'), type: 'notice']
      redirect(action: 'retrospective', params: [product: params.product, id: sprint.id])
      pushOthers "${params.product}-${id}-retrospective-${sprint.id}"
    } catch (RuntimeException e) {
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  @Secured('productOwner() or scrumMaster()')
  def dissociate = {
    if (!params.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }

    def story = Story.get(params.long('id'))

    if (!story) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    try {
      def parentSprint = story.parentSprint
      if (params.boolean('shiftToNext')){
        def sprint = Sprint.findByParentReleaseAndOrderNumber(story.parentSprint.parentRelease,story.parentSprint.orderNumber + 1)
        if (sprint){
          productBacklogService.associateStory(sprint,story)
          flash.notice = [text: message(code: 'is.story.shiftedToNext'), type: 'notice']
        }else{
          render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.shiftedToNext')]] as JSON)
          return
        }
      }else{
        productBacklogService.dissociateStory(story.parentSprint, story)
        flash.notice = [text: message(code: 'is.story.dissociated'), type: 'notice']
      }
      redirect(action: 'index', params: [product: params.product, id: parentSprint.id])
      if (params.boolean('shiftToNext'))
        pushOthers "${params.product}-${id}-${story.parentSprint.id}"
      pushOthers "${params.product}-${id}-${parentSprint.id}"
      push "${params.product}-productBacklog"
      push "${params.product}-releasePlan-${parentSprint.parentRelease.id}"
    } catch (IllegalStateException e) {
      e.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e)]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def declareAsDone = {
    if (!params.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def story = Story.get(params.long('id'))

    if (!story) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    try {
      productBacklogService.declareAsDone(story)
      flash.notice = [text: message(code: 'is.story.declaredAsDone'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: story.parentSprint.id])
      pushOthers "${params.product}-${id}-${story.parentSprint.id}"
      pushOthers "${params.product}-releasePlan-${story.parentSprint.parentRelease.id}"
    } catch (IllegalStateException ise) {
      ise.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  @Secured('productOwner()')
  def DeclareAsUnDone = {
    if (!params.id) {
      def msg = message(code: 'is.story.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def story = Story.get(params.long('id'))

    if (!story) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
      return
    }

    try {
      productBacklogService.declareAsUnDone(story)
      flash.notice = [text: message(code: 'is.story.declaredAsUnDone'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: story.parentSprint.id])
      pushOthers "${params.product}-${id}-${story.parentSprint.id}"
      pushOthers "${params.product}-releasePlan-${story.parentSprint.parentRelease.id}"
    } catch (IllegalStateException ise) {
      ise.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:story)]] as JSON)
    }
  }

  def estimateTask = {
    if(!params.id) {
      render (status: 400, contentType:'application/json', text:[notice:[text:'is.task.error.not.exist']] as JSON)
      return
    }
    def task = Task.get(params.long('id'))

    if(!task) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.task.error.not.exist')]] as JSON)
      return
    }
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.load(params.product)
    task.estimation = params.int('value')?:(params.int('value') == 0)?0:null
    try {
      taskService.updateTask(task,currentUserInstance,product)
    }catch(RuntimeException e){
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)  
    }
    render(status: 200,text:task.estimation?:'?')
    if(task.state == Task.STATE_DONE){
      push "${params.product}-${id}-${task.backlog.id}"
    }
    pushOthers "${params.product}-${id}-${task.backlog.id}"
  }

  def sprintBurndownHoursChart = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    def values = sprintService.sprintBurndownHoursValues(sprint)
    if (values.size() > 0) {
      render(template: 'charts/sprintBurndownHoursChart', model: [
              id: id,
              remainingHours: values.remainingHours as JSON,
              idealHours: values.idealHours as JSON,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def sprintBurnupTasksChart = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    def values = sprintService.sprintBurnupTasksValues(sprint)
    if (values.size() > 0) {
      render(template: 'charts/sprintBurnupTasksChart', model: [
              id: id,
              tasks: values.tasks as JSON,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              tasksDone: values.tasksDone as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def sprintBurnupStoriesChart = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))

    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    def values = sprintService.sprintBurnupStoriesValues(sprint)
    if (values.size() > 0) {
      render(template: 'charts/sprintBurnupStoriesChart', model: [
              id: id,
              stories: values.stories as JSON,
              withButtonBar:(params.withButtonBar != null)?params.boolean('withButtonBar'):true,
              storiesDone: values.storiesDone as JSON,
              labels: values.label as JSON])
    } else {
      def msg = message(code: 'is.chart.error.no.values')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
    }
  }

  def changeFilterTasks = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    if (!params.filter || !params.filter in ['allTasks', 'myTasks','freeTasks']) {
      def msg = message(code: 'is.user.preferences.error.not.filter')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def user = User.load(springSecurityService.principal.id)
    user.preferences.filterTask = params.filter
    userService.updateUser(user)
    redirect(action: 'index', params: [product: params.product, id: params.id])
  }

  def changeHideDoneState = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def user = User.load(springSecurityService.principal.id)
    if (user.preferences.hideDoneState)
      user.preferences.hideDoneState = false
    else
      user.preferences.hideDoneState = true
    userService.updateUser(user)
    redirect(action: 'index', params: [product: params.product, id: params.id])
  }

  def changeBlockedTask = {
    if (!params.id) {
      def msg = message(code: 'is.task.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def task = Task.get(params.long('id'))
    if (!task) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    task.blocked = !task.blocked
    def currentUserInstance = User.get(springSecurityService.principal.id)
    def product = Product.load(params.product)
    try {
      taskService.updateTask(task, currentUserInstance, product)
    } catch (IllegalStateException ise) {
      ise.printStackTrace()
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    } catch (RuntimeException e) {
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:task)]] as JSON)
    }
    pushOthers "${params.product}-${id}-${task.backlog.id}"
    render(status:200)
  }

  def changeRank = {
    def position = params.int('position')
    if (position == 0){
      render(status: 200)
      return
    }

    def movedItem = Task.get(params.long('idmoved'))

    if (!movedItem) {
      render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
      return
    }
    try{
      taskService.changeRank(movedItem, position)
    }catch(Exception e){
      render(status: 500, text: e.getMessage())
    }
      pushOthers "${params.product}-${id}-${movedItem.backlog.id}"
      render(status: 200)
  }

  def copyRecurrentTasksFromPreviousSprint = {
    if (!params.id) {
      def msg = message(code: 'is.sprint.error.not.exist')
      render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
      return
    }
    def sprint = Sprint.get(params.long('id'))
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }
    try {
      sprintService.copyRecurrentTasksFromPreviousSprint(sprint)
      flash.notice = [text: message(code: 'is.sprint.copyRecurrentTasks.copied'), type: 'notice']
      redirect(action: 'index', params: [product: params.product, id: params.id])
      pushOthers "${params.product}-${id}-${params.id}"
    }catch(IllegalStateException ise){
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
    }catch(RuntimeException e){
      e.printStackTrace()
      render(status: 400, contentType:'application/json', text: [notice: [text: renderErrors(bean:sprint)]] as JSON)
    }
  }

  private manageAttachments(def task){
    def user = User.load(springSecurityService.principal.id)
    if (task.id && !params.task.list('attachments') && task.attachments*.id.size() > 0){
      task.removeAllAttachments()
    }else if (task.attachments*.id.size() > 0){
      task.attachments*.id.each {
        if (!params.task.list('attachments').contains(it.toString()))
         task.removeAttachment(it)
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
      task.addAttachments(user,uploadedFiles)
    session.uploadedFiles = null
  }

  def download = {
    forward(action:'download',controller:'attachmentable',id:params.id)
    return
  }

  /**
   * Export the sprint backlog elements in multiple format (PDF, DOCX, RTF, ODT)
   */
  def print = {
    def currentProduct = Product.load(params.product)
    def sprint = Sprint.get(params.long('id'))
    def values
    def chart = null
    
    if (!sprint) {
      render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
      return
    }

    if(params.locationHash){
      chart = processLocationHash(params.locationHash.decodeURL()).action
    }

    switch(chart){
      case 'sprintBurndownHoursChart':
        values = sprintService.sprintBurndownHoursValues(sprint)
        break
      case 'sprintBurnupTasksChart':
        values = sprintService.sprintBurnupTasksValues(sprint)
        break
      case 'sprintBurnupStoriesChart':
        values = sprintService.sprintBurnupStoriesValues(sprint)
        break
      default:
        chart='sprintBacklog'

        // Retrieve all the tasks associated to the sprint
        def stories = Story.findStoriesFilter(sprint,null,null).listDistinct()
        def tasks = Task.findRecurrentTasksFilter(sprint,null,null).listDistinct() + Task.findUrgentTasksFilter(sprint,null,null).listDistinct()
        stories.each {
          tasks = tasks + it.tasks
        }
        // Workaround to force gorm to fetch the associated data (required for jasper to access the data)
        tasks.each {
          it.parentStory?.name
          it.responsible?.lastName
          it.creator?.lastName
        }
        values = [
                [
                        taskStateBundle:taskStateBundle,
                        tasks: tasks,
                        sprintBurndownHoursChart: sprintService.sprintBurndownHoursValues(sprint),
                        sprintBurnupTasksChart: sprintService.sprintBurnupTasksValues(sprint),
                        sprintBurnupStoriesChart: sprintService.sprintBurnupStoriesValues(sprint)
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
      def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "")+'-'+(chart ?: 'sprintBacklog')+'-'+(g.formatDate(value:new Date(),formatName:'is.date.file'))

      try {
      chain(controller: 'jasper',
              action: 'index',
              model: [data: values],
              params: [
                      _format:params.format,
                      _file: chart ?: 'sprintBacklog',
                      'labels.projectName':currentProduct.name,
                      _name: fileName,
                      SUBREPORT_DIR: grailsApplication.config.jasper.dir.reports + './subreports/'
              ]
      )
      session.progress?.completeProgress(message(code: 'is.report.complete'))
      } catch(Exception e){
        e.printStackTrace()
        session.progress.progressError(message(code: 'is.report.error'))
      }
    }  else if(params.status){
      render(status:200,contentType: 'application/json', text:session.progress as JSON)
    } else {
      render(template: 'dialogs/report', model: [id: id, sprint:sprint])
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