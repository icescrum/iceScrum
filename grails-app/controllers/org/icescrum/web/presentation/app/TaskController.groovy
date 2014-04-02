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
import org.icescrum.core.domain.Sprint
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class TaskController {

    def securityService
    def springSecurityService
    def taskService

    def toolbar = {
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
    def shortURL = {
        withProduct { Product product ->
            if (!springSecurityService.isLoggedIn() && product.preferences.hidden) {
                redirect(url: createLink(controller: 'login', action: 'auth') + '?ref=' + is.createScrumLink(controller: 'task', params: [uid: params.id]))
                return
            }
            redirect(url: is.createScrumLink(controller: 'task', params: [uid: params.id]))
        }
    }

    def index = {
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
    def save = {
        if (params.task?.estimation instanceof String) {
            try {
                params.task.estimation = params.task.estimation in ['?', ""] ? null : params.task.estimation.replace(/,/, '.').toFloat()
            } catch (NumberFormatException e) {
                returnError(text: message(code: 'is.task.error.estimation.number'))
                return
            }
        }
        if (params.task.sprint?.id) {
            params.task.'backlog.id' = params.task.sprint.id // Bind "sprint" parameter to "backlog" property
        } else if (params.task.'sprint.id') {
            params.task.'backlog.id'= params.task.remove('sprint.id') // Bind "sprint" parameter to "backlog" property
        }
        params.task.remove('sprint') //For REST XML..
        if (params.task.parentStory?.id) {
            params.task.'parentStory.id' = params.task.parentStory.id
        }
        params.task.remove('parentStory') //For REST XML..
        Task task = new Task()
        try {
            Task.withTransaction {
                bindData(task, this.params, [include: ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']], "task")
                taskService.save(task, springSecurityService.currentUser)
                task.tags = params.task.tags instanceof String ? params.task.tags.split(',') : (params.task.tags instanceof String[] || params.task.tags instanceof List) ? params.task.tags : null
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
    def update = {
        withTask { Task task ->
            User user = (User) springSecurityService.currentUser
            if (params.task.estimation instanceof String) {
                try {
                    params.task.estimation = params.task.estimation in ['?', ""] ? null : params.task.estimation.replace(/,/, '.').toFloat()
                } catch (NumberFormatException e) {
                    returnError(text: message(code: 'is.task.error.estimation.number'))
                    return
                }
            }
            if ((request.format == 'xml' && params.task.parentStory == '') || params.task.parentStory?.id == '') {
                params.task.'parentStory.id' = 'null'
            } else if (params.task.parentStory?.id) {
                params.task.'parentStory.id' = params.task.parentStory.id
            }
            params.task.remove('parentStory') //For REST XML..
            if (params.task.'parentStory.id' && params.task.'parentStory.id' != 'null') {
                params.task.type = ''
            }
            if (params.task.type && params.task.type != 'null') {
                params.task.'parentStory.id' = 'null'
            }
            if (params.task.sprint?.id) {
                params.task.'backlog.id' = params.task.sprint.id // Bind "sprint" parameter to "backlog" property
            } else if (params.task.'sprint.id') {
                params.task.'backlog.id'= params.task.remove('sprint.id') // Bind "sprint" parameter to "backlog" property
            }

            def props = [:]
            Integer rank = params.task.rank instanceof String ? params.task.rank.toInteger() : params.task.rank
            if (rank != null) {
                props.rank = rank
            }
            Integer state = params.task.state instanceof String ? params.task.state.toInteger() : params.task.state
            if (state != null) {
                props.state = state
            }

            params.task.remove('sprint') //For REST XML..
            Task.withTransaction {
                bindData(task, this.params, [include: ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']], "task")
                taskService.update(task, user, false, props)
                task.tags = params.task.tags instanceof String ? params.task.tags.split(',') : (params.task.tags instanceof String[] || params.task.tags instanceof List) ? params.task.tags : null
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: task as JSON) }
                    json { renderRESTJSON(text: task) }
                    xml { renderRESTXML(text: task) }
                }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def take = {
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
    def unassign = {
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
    def delete = {
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
                html { render(status: 200, contentType: 'application/json', text: idj as JSON) }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def copy = {
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
    def attachments = {
        withTask { task ->
            manageAttachmentsNew(task)
        }
    }

    def show = {
        redirect(action: 'index', controller: controllerName, params: params)
    }

    @Cacheable(cache = 'taskCache', keyGenerator = 'tasksKeyGenerator')
    def list = {
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
