/*
 * Copyright (c) 2011 Kagilum / 2010 iceScrum Technlogies.
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
package org.icescrum.web.presentation.app

import org.icescrum.core.domain.User
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import org.icescrum.core.domain.Product

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class TaskController {

    def securityService
    def springSecurityService
    def taskService

    def toolbar = {
        def id = params.uid?.toInteger() ?: params.id?.toLong() ?: null
        withTask(id, params.uid?true:false){ Task task ->
            def user = null
            if (springSecurityService.isLoggedIn())
                user = User.load(springSecurityService.principal.id)

            def next = Task.findNextTaskInSprint(task).list()[0]
            def previous = Task.findPreviousTaskInSprint(task).list()[0]

            render(template: 'window/toolbar', model: [task: task, user: user, next: next, previous: previous])
        }
    }

    @Secured('permitAll()')
    def shortURL = {
        withProduct{ Product product ->
            if (!springSecurityService.isLoggedIn() && product.preferences.hidden){
                redirect(url:createLink(controller:'login', action: 'auth')+'?ref='+is.createScrumLink(controller: 'task', params:[uid: params.id]))
                return
            }
            redirect(url: is.createScrumLink(controller: 'task', params:[uid: params.id]))
        }
    }

    def index = {
        def id = params.uid?.toInteger() ?: params.id?.toLong() ?: null
        withTask(id, params.uid?true:false) { Task task ->
            def product = task.parentProduct
            def user = springSecurityService.currentUser
            if (product.preferences.hidden && !user) {
                redirect(controller: 'login', params: [ref: "p/${product.pkey}#task/$task.id"])
                return
            } else if (product.preferences.hidden && !securityService.inProduct(product, springSecurityService.authentication) && !securityService.stakeHolder(product,springSecurityService.authentication,false)) {
                render(status: 403)
                return
            } else {
                 withFormat {
                    json { renderRESTJSON(text:task) }
                    xml  { renderRESTXML(text:task) }
                    html {
                        def permalink = createLink(absolute: true, mapping: "shortURLTASK", params: [product: product.pkey], id: task.uid)
                        render(view: 'window/details', model: [
                            task: task,
                            permalink:permalink,
                            taskStateCode: BundleUtils.taskStates[task.state],
                            taskTypeCode: BundleUtils.taskTypes[task.type]
                        ])
                    }
                 }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def save = {
        def type = params.remove('parentStory.id') ?: params.task.remove('parentStory.id')
        if (!type){
            type = params.remove('task.type') ?: params.task.remove('type')
            if (type in [Task.TYPE_RECURRENT,Task.TYPE_URGENT]){
                type = type == Task.TYPE_RECURRENT ? 'recurrent' : 'urgent'
            } else if (!(type in ['recurrent', 'urgent'])){
                type = type instanceof Integer ? type : type instanceof String && type.isNumber() ? type.toInteger() : null
            }
        }

        if (!type){
            returnError(text: message(code: 'is.task.error.not.saved'))
            return
        }

        def story = !(type in ['recurrent', 'urgent'] && type) ? Story.getInProduct(params.long('product'), type?.toLong()).list() : null
        if (!story && !(type in ['recurrent', 'urgent'])) {
            returnError(text: message(code: 'is.story.error.not.exist'))
            return
        }

        def sprint = params.remove('sprint.id') ?: params.task.remove('sprint.id')

        if (params.task?.estimation instanceof String) {
            try {
                params.task.estimation = params.task.estimation in ['?', ""] ? null : params.task.estimation.replace(/,/, '.').toFloat()
            } catch (NumberFormatException e) {
                returnError(text: message(code: 'is.task.error.estimation.number'))
                return
            }
        }
        def task
        try {
            Task.withTransaction {
                task = new Task()
                bindData(task, this.params, [include:['name','estimation','description','notes', 'color']], "task")

                User user = (User) springSecurityService.currentUser

                sprint = sprint ? Sprint.getInProduct(params.product.toLong(), sprint.toLong()).list() : sprint
                if (!sprint) {
                    returnError(text: message(code: 'is.sprint.error.not.exist'))
                    return
                }


                if (type == 'recurrent')
                    taskService.saveRecurrentTask(task, sprint, user)
                else if (type == 'urgent')
                    taskService.saveUrgentTask(task, sprint, user)
                else
                    taskService.saveStoryTask(task, story, user)

                task.tags = params.task.tags instanceof String ? params.task.tags.split(',') : (params.task.tags instanceof String[] || params.task.tags instanceof List) ? params.task.tags : null
                def keptAttachments = params.list('task.attachments')
                def addedAttachments = params.list('attachments')
                manageAttachments(task, keptAttachments, addedAttachments)
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                    json { renderRESTJSON(status:201, text:task) }
                    xml  { renderRESTXML(status:201, text:task) }
                }
            }
        } catch (AttachmentException e) {
            returnError(object: task, exception: e)
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def update = {
        withTask{Task task ->
            // If the version is different, the task has been modified since the last loading
            if (params.task.version && params.long('task.version') != task.version) {
                returnError(text: message(code: 'is.stale.object', args: [message(code: 'is.task')]))
                return
            }

            User user = (User) springSecurityService.currentUser

            if (params.task?.estimation instanceof String) {
                try {
                    params.task.estimation = params.task.estimation in ['?', ""] ? null : params.task.estimation.replace(/,/, '.').toFloat()
                } catch (NumberFormatException e) {
                    returnError(text: message(code: 'is.task.error.estimation.number'))
                    return
                }
            }

            // must be done before bindData in order to remove parentStory params
            // if it isn't removed, bindData creates a transient empty BacklogElement if no story is provided
            def storyOrType = parseTaskTypeOrStory()

            bindData(task, this.params, [include: ['name', 'estimation', 'description', 'notes', 'color']], "task")

            if (storyOrType) {
                taskService.update(task, user, false, storyOrType.type, storyOrType.story)
            } else {
                taskService.update(task, user)
            }

            if (params.boolean('manageTags')) {
                task.tags = params.task.tags instanceof String ? params.task.tags.split(',') : (params.task.tags instanceof String[] || params.task.tags instanceof List) ? params.task.tags : null
            }

            if (params.boolean('manageAttachments')) {
                def keptAttachments = params.list('task.attachments')
                def addedAttachments = params.list('attachments')
                manageAttachments(task, keptAttachments, addedAttachments)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON) }
                json { renderRESTJSON(text: task) }
                xml { renderRESTXML(text: task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def take = {
        withTask{Task task ->
            User user = (User) springSecurityService.currentUser
            taskService.assign(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { renderRESTJSON(text:task) }
                xml  { renderRESTXML(text:task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def unassign = {
        withTask{Task task ->
            User user = (User) springSecurityService.currentUser
            taskService.unassign(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { renderRESTJSON(text:task) }
                xml  { renderRESTXML(text:task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def delete = {
        withTasks{List<Task> tasks ->
            User user = (User) springSecurityService.currentUser
            def idj = []
            tasks.each {
                idj << [id:it.id]
                taskService.delete(it, user)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: idj as JSON)  }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def copy = {
        withTask{Task task ->
            User user = (User) springSecurityService.currentUser
            def copiedTask = taskService.copy(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: copiedTask as JSON)  }
                json { renderRESTJSON(text:copiedTask,status:201) }
                xml { renderRESTXML(text:copiedTask,status:201) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def estimate = {
        withTask{Task task ->
            User user = (User) springSecurityService.currentUser
            try {
                if (params.task?.estimation) {
                    params.task.estimation = params.task.estimation instanceof String ? params.task.estimation.replace(/,/, '.') : params.task.estimation
                    params.task.estimation = params.task.estimation == '?' ? null : params.task.estimation
                }
                task.estimation = params.task?.estimation?.toFloat() ?: (params.task?.estimation?.toFloat() == 0) ? 0 : null
            } catch (NumberFormatException e) {
                returnError(text: message(code: 'is.task.error.estimation.number'))
                return
            }
            taskService.update(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { renderRESTJSON(text:task) }
                xml  { renderRESTXML(text:task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def block = {
        withTask{Task task ->
            if(task.backlog.state == Sprint.STATE_WAIT){
                throw new IllegalStateException('is.sprint.error.state.not.inProgress')
            }
            task.blocked = !task.blocked
            User user = (User) springSecurityService.currentUser
            taskService.update(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:task as JSON)  }
                json { renderRESTJSON(text:task) }
                xml  { renderRESTXML(text:task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def unblock = {
        withTask{Task task ->
            if(task.backlog.state == Sprint.STATE_WAIT){
                throw new IllegalStateException('is.sprint.error.state.not.inProgress')
            }
            if (task.blocked)
                forward(action: 'block', params: [id: params.id])
            else
                throw new IllegalStateException('is.task.error.not.blocked')
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def rank = {
        def position = params.int('task.rank')
        if (position == 0) {
            render(status: 200)
            return
        }

        withTask{Task task ->
            taskService.rank(task, position)
            withFormat {
                html { render(status: 200)  }
                json { renderRESTJSON(text:task) }
                xml  { renderRESTXML(text:task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def state = {
        Integer state = params.task?.state instanceof String && params.task.state.isNumber() ? params.task.state.toInteger() : params.task?.state instanceof Integer ? params.task.state : null
        if (!(state in [Task.STATE_WAIT,Task.STATE_BUSY,Task.STATE_DONE])){
            returnError(text: message(code: 'is.ui.sprintPlan.state.no.exist'))
            return
        }
        withTask{ Task task ->
            User user = (User) springSecurityService.currentUser
            def storyOrType = parseTaskTypeOrStory()
            if (storyOrType) {
                taskService.state(task, state, user, storyOrType.type, storyOrType.story)
            } else {
                taskService.state(task, state, user)
            }
            if (params.task.rank) {
                Integer rank = params.task.rank instanceof String && params.task.rank.isNumber() ? params.task.rank.toInteger() : params.task.rank instanceof Integer ? params.task.rank : null
                if (rank)
                    taskService.rank(task, rank)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [task: task, story: task.parentStory?.state == Story.STATE_DONE ? task.parentStory : null] as JSON) }
                json { renderRESTJSON(text: task) }
                xml { renderRESTXML(text: task) }
            }
        }
    }

    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

    @Cacheable(cache = 'taskCache', keyGenerator='tasksKeyGenerator')
    def list = {

        if (request?.format == 'html') {
            render(status: 404)
            return
        }

        Sprint sprint
        if (params.sprint)
            sprint = (Sprint)Sprint.getInProduct(params.product.toLong(),params.sprint.toLong()).list()
        else
            sprint = Sprint.findCurrentOrNextSprint(params.product.toLong()).list()[0]

        if (!sprint) {
            returnError(text: message(code: 'is.sprint.error.not.exist'))
            return
        }

        def tasks = null
        if (params.filter == 'user') {
            tasks = Task.getUserTasks(sprint.id, springSecurityService.principal.id).list()
        } else if (params.filter == 'free') {
            tasks = Task.getFreeTasks(sprint.id).list()
        } else {
            tasks = Task.getAllTasksInSprint(sprint.id).list()
        }

        withFormat {
            json { renderRESTJSON(text:tasks) }
            xml  { renderRESTXML(text:tasks) }
        }
    }

    def summaryPanel = {
        withTask { Task task ->
            def summary = task.comments + task.getActivities()
            summary = summary.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }
            render(template: "/backlogElement/summary",
                    model: [summary: summary,
                            backlogElement: task,
                            product: Product.get(params.long('product'))
                    ])
        }
    }

    @Cacheable(cache = 'taskCache', keyGenerator = 'tasksKeyGenerator')
    def mylyn = {

        def sprint
        if (params.id)
            sprint = (Sprint)Sprint.getInProduct(params.product.toLong(),params.id.toLong()).list()
        else
            sprint = (Sprint)Sprint.findCurrentOrNextSprint(params.product.toLong()).list()

        if (!sprint) {
            returnError(text: message(code: 'is.sprint.error.not.exist'))
            return
        }

        def results
        if (params.filter == 'user') {
            results = Task.getUserTasks(sprint.id, springSecurityService.principal.id).list()
        } else if (params.filter == 'free') {
            results = Task.getFreeTasks(sprint.id).list()
        } else {
            results = Task.getAllTasksInSprint(sprint.id).list()
        }
        render(status: 200, contentType: 'text/xml'){
            tasks {
                for(t in results) {
                    task(id:t.id){
                        description(t.name)
                        responsible(t.responsible? t.responsible.firstName + ' '+ t.responsible.lastName :' ')
                        status(g.message(code:BundleUtils.taskStates.get(t.state)))
                        type(t.type == Task.TYPE_RECURRENT ? g.message(code:'is.task.type.recurrent') : t.type == Task.TYPE_URGENT ? g.message(code:'is.task.type.urgent') : t.parentStory.name)
                    }
                }
            }
        }
    }

    // very strange behavior in there to support both dropdown that mixes stories and types and API support
    private Map parseTaskTypeOrStory() {
        def type = params.remove('parentStory.id') ?: params.task.remove('parentStory.id')
        if (!type){
            type = params.remove('task.type') ?: params.task.remove('type')
            type = type instanceof Integer ? type : type instanceof String && type.isNumber() ? type.toInteger() : null
            if (type in [Task.TYPE_RECURRENT,Task.TYPE_URGENT]){
                type = type == Task.TYPE_RECURRENT ? 'recurrent' : 'urgent'
            }else{
                type = null
            }
        }
        if (type) {
            if (type in ['recurrent', 'urgent']) {
                type = type == 'recurrent' ? Task.TYPE_RECURRENT : Task.TYPE_URGENT
                return [story: null, type: type]
            } else {
                return [story: type.toLong(), type: null]
            }
        } else {
            return [:]
        }
    }
}
