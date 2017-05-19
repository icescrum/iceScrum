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

    @Secured('inProject() or (isAuthenticated() and stakeHolder())')
    def index(long id, long project, String type) {
        def tasks
        if (type == 'story') {
            tasks = Story.withStory(project, id).tasks
        } else if (type == 'sprint') {
            tasks = Sprint.withSprint(project, id).tasks
            if (params.context) {
                tasks = tasks.findAll { Task task ->
                    if (params.context.type == 'tag') {
                        return task.tags.contains(params.context.id) || task.parentStory?.tags?.contains(params.context.id)
                    } else if (task.parentStory) {
                        if (params.context.type == 'feature') {
                            return task.parentStory.feature?.id == params.context.id.toLong()
                        } else if (params.context.type == 'actor') {
                            return task.parentStory.actor?.id == params.context.id.toLong()
                        }
                    }
                    return true
                }
            }
        }
        render(status: 200, contentType: 'application/json', text: tasks as JSON)
    }


    @Secured('inProject() or (isAuthenticated() and stakeHolder())')
    def show(long id, long project) {
        Task task = Task.withTask(project, id)
        render(status: 200, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProject() and !archivedProject()')
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
            cleanBeforeBindData(taskParams, ['parentStory', 'backlog', 'responsible'])
            def propertiesToBind = ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']
            if (request.scrumMaster) {
                propertiesToBind << 'responsible'
            }
            bindData(task, taskParams, [include: propertiesToBind])
            taskService.save(task, springSecurityService.currentUser)
            task.tags = taskParams.tags instanceof String ? taskParams.tags.split(',') : (taskParams.tags instanceof String[] || taskParams.tags instanceof List) ? taskParams.tags : null
        }
        render(status: 201, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProject() and !archivedProject()')
    def update(long id, long project) {
        def taskParams = params.task
        if (!taskParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        Task task = Task.withTask(project, id)
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
            cleanBeforeBindData(taskParams, ['parentStory', 'backlog', 'responsible'])
            def propertiesToBind = ['name', 'estimation', 'description', 'notes', 'color', 'parentStory', 'type', 'backlog', 'blocked']
            if (request.scrumMaster) {
                propertiesToBind << 'responsible'
            }
            bindData(task, taskParams, [include: propertiesToBind])
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

    @Secured('inProject() and !archivedProject()')
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

    @Secured('inProject() and !archivedProject()')
    def makeStory(long id, long project) {
        Task task = Task.withTask(project, id)
        taskService.makeStory(task)
        render(status: 204)
    }

    @Secured('inProject() and !archivedProject()')
    def take(long id, long project) {
        Task task = Task.withTask(project, id)
        User user = (User) springSecurityService.currentUser
        Task.withTransaction {
            task.responsible = user
            taskService.update(task, user)
        }
        render(status: 200, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProject() and !archivedProject()')
    def unassign(long id, long project) {
        Task task = Task.withTask(project, id)
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
            def props = [state: Task.STATE_WAIT]
            taskService.update(task, user, false, props)
        }
        render(status: 200, contentType: 'application/json', text: task as JSON)
    }

    @Secured('inProject() and !archivedProject()')
    def copy(long id, long project) {
        Task task = Task.withTask(project, id)
        User user = (User) springSecurityService.currentUser
        def copiedTask = taskService.copy(task, user)
        render(status: 200, contentType: 'application/json', text: copiedTask as JSON)
    }

    @Secured('isAuthenticated()')
    def listByUser(Long projectId) {
        def user = springSecurityService.currentUser
        def options = [max: 8]
        def taskStates = [Task.STATE_WAIT, Task.STATE_BUSY]
        def userTasks = projectId != null ? Task.findAllByResponsibleAndParentProjectAndStateInList(user, Project.withProject(projectId), taskStates, options)
                : Task.findAllByResponsibleAndStateInList(user, taskStates, options)
        def tasksByProject = userTasks.groupBy {
            it.parentProject
        }.collect { project, tasks ->
            [project: project, tasks: tasks]
        }
        render(status: 200, contentType: 'application/json', text: tasksByProject as JSON)
    }

    @Secured('inProject() or (isAuthenticated() and stakeHolder())')
    def permalink(int uid, long project) {
        Project _project = Project.withProject(project)
        Task task = Task.findByParentProjectAndUid(_project, uid)
        String uri = "/p/$_project.pkey/#/"
        if (task.backlog) {
            uri += "taskBoard/$task.backlog.id/task/$task.id"
        } else {
            uri += "backlog/$task.parentStory.id/tasks/task/$task.id"
        }
        redirect(uri: uri)
    }

    @Secured('inProject() or (isAuthenticated() and stakeHolder())')
    def colors(long project) {
        def results = Task.createCriteria().list() {
            eq("parentProject.id", project)
            projections {
                groupProperty "color"
                count "color", "colorSize"
            }
            order('colorSize', 'desc')
            maxResults(7)
        }?.collect { it[0] }
        render(status: 200, contentType: 'application/json', text: results as JSON)
    }
}
