/*
 * Copyright (c) 2015 Kagilum.
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

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.*

class TaskController {

    def springSecurityService
    def taskService

    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def index() {
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
            html { render status: 200, contentType: 'application/json', text: tasks as JSON }
            json { renderRESTJSON(text: tasks) }
            xml { renderRESTXML(text: tasks) }
        }
    }

    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def show(long id, long product) {
        Task task = Task.withTask(product, id)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: task as JSON }
            json { renderRESTJSON text: task }
            xml { renderRESTXML text: task }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def save() {
        def taskParams = params.task
        if (!taskParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
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
    def update(long id, long product) {
        def taskParams = params.task
        if (!taskParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        Task task = Task.withTask(product, id)
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

    @Secured('inProduct() and !archivedProduct()')
    def delete() {
        List<Task> tasks = Task.withTasks(params)
        User user = (User) springSecurityService.currentUser
        Task.withTransaction {
            tasks.each {
                taskService.delete(it, user)
            }
        }
        def data = tasks.size() > 1 ? tasks.collect { [id: it.id] } : (tasks ? [id: tasks.first().id] : [:])
        withFormat {
            html { render(status: 200, text: data as JSON) }
            json { render(status: 204) }
            xml { render(status: 204) }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def take(long id, long product) {
        Task task = Task.withTask(product, id)
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

    @Secured('inProduct() and !archivedProduct()')
    def unassign(long id, long product) {
        Task task = Task.withTask(product, id)
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

    @Secured('inProduct() and !archivedProduct()')
    def copy(long id, long product) {
        Task task = Task.withTask(product, id)
        User user = (User) springSecurityService.currentUser
        def copiedTask = taskService.copy(task, user)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: copiedTask as JSON) }
            json { renderRESTJSON(text: copiedTask, status: 201) }
            xml { renderRESTXML(text: copiedTask, status: 201) }
        }
    }

    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def listByType(long id, long product, String type) {
        def tasks
        if (type == 'story') {
            tasks = Story.withStory(product, id).tasks
        } else if (type == 'sprint') {
            tasks = Sprint.withSprint(product, id).tasks
        }
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: tasks as JSON) }
            json { renderRESTJSON(text: tasks) }
            xml { renderRESTXML(text: tasks) }
        }
    }

    @Secured('isAuthenticated()')
    def listByUser(Long product) {
        def user = springSecurityService.currentUser
        def options = [max: 8]
        def taskStates = [Task.STATE_WAIT, Task.STATE_BUSY]
        def userTasks = product != null ? Task.findAllByResponsibleAndParentProductAndStateInList(user, Product.get(product), taskStates, options)
                                        : Task.findAllByResponsibleAndStateInListAndCreationDateBetween(user, taskStates, new Date() - 10, new Date(), options)
        def tasksByProject = userTasks.groupBy {
            it.parentProduct
        }.collect { project, tasks ->
            [project: project, tasks: tasks]
        }
        render(status: 200, contentType: 'application/json', text: tasksByProject as JSON)
    }

    // TODO fix permalink
    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def shortURL(long product, long id) {
        Product _product = Product.withProduct(product)
        def link = createLink(controller: 'scrumOS', action: 'index', params: [product: _product.pkey]) + '#task?uid=' + id
        if (!springSecurityService.isLoggedIn() && _product.preferences.hidden) {
            redirect(url: createLink(controller: 'login', action: 'auth') + '?ref=' + link)
            return
        }
        redirect(url: link)
    }
}