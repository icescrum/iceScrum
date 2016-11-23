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
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.*
import org.icescrum.core.error.ControllerErrorHandler

class TaskController implements ControllerErrorHandler {

    def springSecurityService
    def taskService

    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def index(long id, long product, String type) {
        def tasks
        if (type == 'story') {
            tasks = Story.withStory(product, id).tasks
        } else if (type == 'sprint') {
            tasks = Sprint.withSprint(product, id).tasks
            if (params.context) {
                tasks = tasks.findAll { Task task ->
                    if (params.context.type == 'tag') {
                        return task.tags.contains(params.context.id) || task.parentStory?.tags?.contains(params.context.id)
                    } else if (task.parentStory && params.context.type == 'feature') {
                        return task.parentStory?.feature?.id == params.context.id.toLong()
                    }
                    return true
                }
            }
        }
        render(status: 200, contentType: 'application/json', text: tasks as JSON)
    }


    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def show(long id, long product) {
        Task task = Task.withTask(product, id)
        render(status: 200, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProduct() and !archivedProduct()')
    def save() {
        def taskParams = params.task
        if (!taskParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        if (taskParams?.estimation instanceof String) {
            try {
                taskParams.estimation = taskParams.estimation in ['?', ""] ? null : taskParams.estimation.replace(/,/, '.').toFloat()
            } catch (NumberFormatException e) {
                returnError(code: 'is.task.error.estimation.number')
                return
            }
        }
        if (!taskParams.backlog) {
            taskParams.backlog = taskParams.sprint
        }
        Task task = new Task()
        Task.withTransaction {
            bindData(task, taskParams, [include: ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']])
            taskService.save(task, springSecurityService.currentUser)
            task.tags = taskParams.tags instanceof String ? taskParams.tags.split(',') : (taskParams.tags instanceof String[] || taskParams.tags instanceof List) ? taskParams.tags : null
        }
        render(status: 201, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProduct() and !archivedProduct()')
    def update(long id, long product) {
        def taskParams = params.task
        if (!taskParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        Task task = Task.withTask(product, id)
        User user = (User) springSecurityService.currentUser
        if (taskParams.estimation instanceof String) {
            try {
                taskParams.estimation = taskParams.estimation in ['?', ""] ? null : taskParams.estimation.replace(/,/, '.').toFloat()
            } catch (NumberFormatException e) {
                returnError(code: 'is.task.error.estimation.number')
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
            if (taskParams.parentStory && !taskParams.type) {
                task.type = null
            } else if (taskParams.type && !taskParams.parentStory) {
                task.parentStory = null
            }
            taskService.update(task, user, false, props)
            task.tags = taskParams.tags instanceof String ? taskParams.tags.split(',') : (taskParams.tags instanceof String[] || taskParams.tags instanceof List) ? taskParams.tags : null
            render(status: 200, contentType: 'application/json', text: task as JSON)
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
        def returnData = tasks.size() > 1 ? tasks.collect { [id: it.id] } : (tasks ? [id: tasks.first().id] : [:])
        render(status: 200, text: returnData as JSON)
    }

    @Secured('inProduct() and !archivedProduct()')
    def makeStory(long id, long product) {
        Task task = Task.withTask(product, id)
        taskService.makeStory(task)
        render(status: 204)
    }

    @Secured('inProduct() and !archivedProduct()')
    def take(long id, long product) {
        Task task = Task.withTask(product, id)
        User user = (User) springSecurityService.currentUser
        Task.withTransaction {
            task.responsible = user
            taskService.update(task, user)
        }
        render(status: 200, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProduct() and !archivedProduct()')
    def unassign(long id, long product) {
        Task task = Task.withTask(product, id)
        User user = (User) springSecurityService.currentUser
        if (task.responsible?.id != user.id) {
            returnError(code: 'is.task.error.unassign.not.responsible')
            return
        }
        if (task.state == Task.STATE_DONE) {
            returnError(code: 'is.task.error.done')
            return
        }
        Task.withTransaction {
            task.responsible = null
            task.state = Task.STATE_WAIT
            taskService.update(task, user)
        }
        render(status: 200, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProduct() and !archivedProduct()')
    def copy(long id, long product) {
        Task task = Task.withTask(product, id)
        User user = (User) springSecurityService.currentUser
        def copiedTask = taskService.copy(task, user)
        render(status: 200, contentType: 'application/json', text: copiedTask as JSON)
    }

    @Secured('isAuthenticated()')
    def listByUser(Long product) {
        def user = springSecurityService.currentUser
        def options = [max: 8]
        def taskStates = [Task.STATE_WAIT, Task.STATE_BUSY]
        def userTasks = product != null ? Task.findAllByResponsibleAndParentProductAndStateInList(user, Product.withProduct(product), taskStates, options)
                : Task.findAllByResponsibleAndStateInList(user, taskStates, options)
        def tasksByProject = userTasks.groupBy {
            it.parentProduct
        }.collect { project, tasks ->
            [project: project, tasks: tasks]
        }
        render(status: 200, contentType: 'application/json', text: tasksByProject as JSON)
    }

    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def permalink(int uid, long product) {
        Product _product = Product.withProduct(product)
        Task task = Task.findByParentProductAndUid(_product, uid)
        String uri = "/p/$_product.pkey/#/"
        if (task.backlog) {
            uri += "taskBoard/$task.backlog.id/task/$task.id"
        } else {
            uri += "backlog/$task.parentStory.id/tasks/task/$task.id"
        }
        redirect(uri: uri)
    }

    @Secured('inProduct() or (isAuthenticated() and stakeHolder())')
    def colors(long product) {
        def results = Task.createCriteria().list() {
            eq("parentProduct.id", product)
            projections {
                groupProperty "color"
                count "color", "colorSize"
            }
            order('colorSize', 'desc')
            maxResults(7)
        }?.collect{ it[0] }
        render(status: 200, contentType: 'application/json', text: results as JSON)
    }
}