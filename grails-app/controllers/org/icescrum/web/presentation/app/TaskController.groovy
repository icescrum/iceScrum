/*
 * Copyright (c) 2011 Kagilum.
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

import org.icescrum.core.domain.Story
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Sprint
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class TaskController {

    def securityService
    def springSecurityService
    def taskService

    def toolbar() {
        def id = params.uid?.toInteger() ?: params.id?.toLong() ?: null
        withTask(id, params.uid ? true : false) { Task task ->
            def user = null
            if (springSecurityService.isLoggedIn()) {
                user = User.load(springSecurityService.principal.id)
            }
            def next = Task.findNextTaskInSprint(task).list()[0]
            def previous = Task.findPreviousTaskInSprint(task).list()[0]
            render(template: 'window/toolbar', model: [task: task, user: user, next: next, previous: previous])
        }
    }

    @Secured('permitAll()')
    def shortURL(long product, long id) {
        Product _product = Product.withProduct(product)
        if (!springSecurityService.isLoggedIn() && _product.preferences.hidden) {
            redirect(url: createLink(controller: 'login', action: 'auth') + '?ref=' + is.createScrumLink(controller: 'task', params: [uid: id]))
            return
        }
        redirect(url: is.createScrumLink(controller: 'task', params: [uid: id]))
    }

    def index() {
        def id = params.uid?.toInteger() ?: params.id?.toLong() ?: null
        withTask(id, params.uid ? true : false) { Task task ->
            def product = task.parentProduct
            def user = springSecurityService.currentUser
            if (product.preferences.hidden && !user) {
                redirect(controller: 'login', params: [ref: "p/${product.pkey}#task/$task.id"])
                return
            } else if (product.preferences.hidden && !securityService.inProduct(product, springSecurityService.authentication) && !securityService.stakeHolder(product, springSecurityService.authentication, false)) {
                render(status: 403)
                return
            } else {
                withFormat {
                    json { renderRESTJSON(text: task) }
                    xml { renderRESTXML(text: task) }
                    html {
                        def permalink = createLink(absolute: true, mapping: "shortURLTASK", params: [product: product.pkey], id: task.uid)
                        render(view: 'window/details', model: [
                                task: task,
                                permalink: permalink,
                                taskStateCode: BundleUtils.taskStates[task.state],
                                taskTypeCode: BundleUtils.taskTypes[task.type]
                        ])
                    }
                }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def save() {
        def taskParams = params.task
        if (!taskParams){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        if (taskParams?.estimation instanceof String) {
            try {
                taskParams.estimation = taskParams.estimation in ['?', ""] ? null : taskParams.estimation.replace(/,/, '.').toFloat()
            } catch (NumberFormatException e) {
                returnError(text: message(code: 'is.task.error.estimation.number'))
                return
            }
        }
        if (!taskParams.backlog) {
            taskParams.backlog = taskParams.sprint
        }
        Task task = new Task()
        try {
            Task.withTransaction {
                bindData(task, taskParams, [include: ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']])
                taskService.save(task, springSecurityService.currentUser)
                task.tags = taskParams.tags instanceof String ? taskParams.tags.split(',') : (taskParams.tags instanceof String[] || taskParams.tags instanceof List) ? taskParams.tags : null
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON) }
                json { renderRESTJSON(status: 201, text: task) }
                xml { renderRESTXML(status: 201, text: task) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def update() {
        def taskParams = params.task
        if (!taskParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        withTask { Task task ->
            User user = (User) springSecurityService.currentUser
            if (taskParams.estimation instanceof String) {
                try {
                    taskParams.estimation = taskParams.estimation in ['?', ""] ? null : taskParams.estimation.replace(/,/, '.').toFloat()
                } catch (NumberFormatException e) {
                    returnError(text: message(code: 'is.task.error.estimation.number'))
                    return
                }
            }
            if (!taskParams.backlog) {
                taskParams.backlog = taskParams.sprint
            }
            def props = [:]
            Integer rank = taskParams.rank instanceof String ? taskParams.rank.toInteger() : taskParams.rank
            if (rank != null) {
                props.rank = rank
            }
            Integer state = taskParams.state instanceof String ? taskParams.state.toInteger() : taskParams.state
            if (state != null) {
                props.state = state
            }
            Task.withTransaction {
                bindData(task, taskParams, [include: ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']])
                taskService.update(task, user, false, props)
                task.tags = taskParams.tags instanceof String ? taskParams.tags.split(',') : (taskParams.tags instanceof String[] || taskParams.tags instanceof List) ? taskParams.tags : null
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: task as JSON) }
                    json { renderRESTJSON(text: task) }
                    xml { renderRESTXML(text: task) }
                }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def take() {
        withTask { Task task ->
            User user = (User) springSecurityService.currentUser
            Task.withTransaction {
                task.responsible = user
                taskService.update(task, user)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON) }
                json { renderRESTJSON(text: task) }
                xml { renderRESTXML(text: task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def unassign() {
        withTask { Task task ->
            User user = (User) springSecurityService.currentUser
            if (task.responsible?.id != user.id) {
                returnError(text: message(code: 'is.task.error.unassign.not.responsible'))
                return
            }
            if (task.state == Task.STATE_DONE) {
                returnError(text: message(code: 'is.task.error.done'))
                return
            }
            Task.withTransaction {
                task.responsible = null
                task.state = Task.STATE_WAIT
                taskService.update(task, user)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON) }
                json { renderRESTJSON(text: task) }
                xml { renderRESTXML(text: task) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def delete() {
        withTasks { List<Task> tasks ->
            User user = (User) springSecurityService.currentUser
            def idj = []
            Task.withTransaction {
                tasks.each {
                    idj << [id: it.id]
                    taskService.delete(it, user)
                }
            }
            withFormat {
                html { render(status: 200) }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def copy() {
        withTask { Task task ->
            User user = (User) springSecurityService.currentUser
            def copiedTask = taskService.copy(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: copiedTask as JSON) }
                json { renderRESTJSON(text: copiedTask, status: 201) }
                xml { renderRESTXML(text: copiedTask, status: 201) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def attachments() {
        withTask { task ->
            manageAttachmentsNew(task)
        }
    }

    def show() {
        redirect(action: 'index', controller: controllerName, params: params)
    }

    def list() {
        if (request?.format == 'html') {
            render(status: 404)
            return
        }
        Sprint sprint = (Sprint) params.sprint ? Sprint.getInProduct(params.product.toLong(), params.sprint.toLong()).list() : Sprint.findCurrentOrNextSprint(params.product.toLong()).list()[0]
        if (!sprint) {
            returnError(text: message(code: 'is.sprint.error.not.exist'))
            return
        }
        def tasks = null
        if (params.filter == 'user') {
            tasks = Task.getUserTasks(sprint.id, springSecurityService.principal.id).list()
        } else if (params.filter == 'free') {
            tasks = Task.getFreeTasks(sprint.id).list()
        } else if (params.filter) {
            render(status: 400)
            return
        } else {
            tasks = Task.getAllTasksInSprint(sprint.id).list()
        }
        withFormat {
            json { renderRESTJSON(text: tasks) }
            xml { renderRESTXML(text: tasks) }
        }
    }

    @Secured('stakeHolder() and !archivedProduct()')
    def tasksStory(long id, long product) {
        def story = Story.withStory(product, id)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story.tasks as JSON) }
            json { renderRESTJSON(text:story.tasks) }
            xml  { renderRESTXML(text:story.tasks) }
        }
    }

    def summaryPanel() {
        withTask { Task task ->
            def summary = task.comments + task.activities
            summary = summary.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }
            render(template: "/backlogElement/summary",
                    model: [summary: summary,
                            backlogElement: task,
                            product: Product.get(params.long('product'))
                    ])
        }
    }

    def mylyn() {
        def sprint = (Sprint) params.id ? Sprint.getInProduct(params.product.toLong(), params.id.toLong()).list() : Sprint.findCurrentOrNextSprint(params.product.toLong()).list()
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
        render(status: 200, contentType: 'text/xml') {
            tasks {
                for (t in results) {
                    task(id: t.id) {
                        description(t.name)
                        responsible(t.responsible ? t.responsible.firstName + ' ' + t.responsible.lastName : ' ')
                        status(g.message(code: BundleUtils.taskStates.get(t.state)))
                        type(t.type == Task.TYPE_RECURRENT ? g.message(code: 'is.task.type.recurrent') : t.type == Task.TYPE_URGENT ? g.message(code: 'is.task.type.urgent') : t.parentStory.name)
                    }
                }
            }
        }
    }
}
