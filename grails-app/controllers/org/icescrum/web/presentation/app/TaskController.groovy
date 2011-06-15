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
 *
 */
package org.icescrum.web.presentation.app

import org.icescrum.core.domain.User
import grails.converters.JSON
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import grails.plugins.springsecurity.Secured
import grails.converters.XML

@Secured('inProduct()')
class TaskController {

    def sprintService
    def springSecurityService
    def taskService

    def allowedMethods = [
            ['save', 'take', 'unassign', 'copy', 'estimate', 'rank', 'block', 'unblock', 'state']: ['POST'],
            ['list', 'show', 'download']: ['GET'],
            ['update']: ['PUT', 'POST'],
            ['delete']: ['DELETE', 'POST']
    ]

    def save = {
        def story = !(params.story?.id in ['recurrent', 'urgent']) ? Story.getInProduct(params.long('product'), params.long('story.id')).list()[0] : null
        if (!story && !(params.story?.id in ['recurrent', 'urgent'])) {
            returnError(text: message(code: 'is.story.error.not.exist'))
            return
        }

        def task = new Task()
        task.properties = params.task

        User user = (User) springSecurityService.currentUser
        def sprint = Sprint.load(params.id)
        if (!sprint) {
            returnError(text: message(code: 'is.sprint.error.not.exist'))
            return
        }

        try {
            if (params.story.id == 'recurrent')
                taskService.saveRecurrentTask(task, sprint, user)
            else if (params.story.id == 'urgent')
                taskService.saveUrgentTask(task, sprint, user)
            else
                taskService.saveStoryTask(task, story, user)

            this.manageAttachments(task)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (AttachmentException e) {
            returnError(object: task, exception: e)
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    def update = {
        if (!params.task) return

        def story = !(params.story?.id in ['recurrent', 'urgent']) ? Story.getInProduct(params.long('product'), params.long('story.id')).list()[0] : null

        if (!story && !(params.story?.id in ['recurrent', 'urgent'])) {
            returnError(text: message(code: 'is.story.error.not.exist'))
            return
        }

        def sprintTask = (params.story.id in ['recurrent', 'urgent']) ? params.story.id == 'recurrent' ? Task.TYPE_RECURRENT : Task.TYPE_URGENT : null

        if (!params.task?.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
        }

        def task = Task.get(params.task.id.toLong())
        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }

        // If the version is different, the task has been modified since the last loading
        if (params.task.version && params.long('task.version') != task.version) {
            msg = message(code: 'is.stale.object', args: [message(code: 'is.task')])
            returnError(text: msg)
            return
        }

        task.properties = params.task
        User user = (User) springSecurityService.currentUser

        try {

            // If the task was moved to another story
            if (story && story.id != task.parentStory.id) {
                taskService.changeTaskStory(task, story, user)
                // If the Task was transformed to a Task

            } else if (!story && task.parentStory) {
                taskService.storyTaskToSprintTask(task, sprintTask, user)
                // If the Task was transformed to a Task

            } else if (story && !task.parentStory) {
                taskService.sprintTaskToStoryTask(task, story, user)
                // If the Task has changed its type (TYPE_RECURRENT/TYPE_URGENT)

            } else if (task && sprintTask != task.type) {
                taskService.changeType(task, sprintTask, user)

            } else {
                taskService.update(task, user)
            }
            this.manageAttachments(task)
            def next = null
            if (params.continue) {
                next = Task.findNextTask(task, user).list()[0]
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [task: task, next: next?.id] as JSON)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (AttachmentException e) {
            returnError(object: task, exception: e)
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    def take = {
        if (!params.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def task = Task.get(params.long('id'))
        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        User user = (User) springSecurityService.currentUser

        try {
            taskService.assign([task], user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    def unassign = {
        if (!params.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def task = Task.get(params.long('id'))
        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        User user = (User) springSecurityService.currentUser

        try {
            taskService.unassign([task], user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }


    def delete = {
        if (!params.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def tasks = Task.getAll(params.list('id'))
        User user = (User) springSecurityService.currentUser

        try {

            tasks.each {
                taskService.delete(it, user)
            }
            def ids = []
            params.list('id').each { ids << [id: it] }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: ids as JSON)  }
                json { render(status: 200, text: [result: 'success'] as JSON) }
                xml { render(status: 200, text: [result: 'success'] as JSON) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(exception: e)
        }
    }

    def copy = {
        if (!params.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def task = Task.get(params.long('id'))
        User user = (User) springSecurityService.currentUser

        try {
            def copiedTask = taskService.copy(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: copiedTask as JSON)  }
                json { render(status: 200, text: copiedTask as JSON) }
                xml { render(status: 200, text: copiedTask as XML) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(exception: e)
        }
    }

    def estimate = {
        if (!params.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def task = Task.get(params.long('id'))

        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        User user = (User) springSecurityService.currentUser
        task.estimation = params.int('value') ?: (params.int('value') == 0) ? 0 : null
        try {
            taskService.update(task, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    def block = {
        if (!params.id) {
            def msg = message(code: 'is.task.error.not.exist')
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def task = Task.get(params.long('id'))
        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        task.blocked = !task.blocked
        User user = (User) springSecurityService.currentUser
        try {
            taskService.update(task, user)
            withFormat {
                html { render(status: 200)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    def unblock = {
        forward(action: 'block', params: [id: params.id])
    }

    def rank = {
        def position = params.int('task.rank')
        if (position == 0) {
            render(status: 200)
            return
        }

        def movedItem = Task.get(params.long('id'))

        if (!movedItem) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        try {
            taskService.rank(movedItem, position)
            withFormat {
                html { render(status: 200)  }
                json { render(status: 200, text: movedItem as JSON) }
                xml { render(status: 200, text: movedItem as XML) }
            }
        } catch (RuntimeException e) {
            returnError(object: movedItem, exception: e)
        }
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }

    private manageAttachments(def task) {
        User user = (User) springSecurityService.currentUser
        if (params.task.attachments && task.id && !params.task.list('attachments') && task.attachments*.id.size() > 0) {
            task.removeAllAttachments()
        } else if (task.attachments*.id.size() > 0) {
            task.attachments*.id.each {
                if (!params.task.list('attachments').contains(it.toString()))
                    task.removeAttachment(it)
            }
        }
        def uploadedFiles = []
        params.list('attachments')?.each { attachment ->
            "${attachment}".split(":").with {
                if (session.uploadedFiles[it[0]])
                    uploadedFiles << [file: new File((String) session.uploadedFiles[it[0]]), name: it[1]]
            }
        }
        if (uploadedFiles)
            task.addAttachments(user, uploadedFiles)
        session.uploadedFiles = null
    }

    def state = {
        // params.id represent the targeted state (STATE_WAIT, STATE_INPROGRESS, STATE_DONE)
        if (!params.id) {
            returnError(text: message(code: 'is.ui.sprintPlan.state.no.exist'))
        }
        if (!params.task.id) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        def task = Task.get(params.long('task.id'))
        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }
        User user = (User) springSecurityService.currentUser

        try {

            // If the task was moved to another story
            if (params.story?.id && task.parentStory && params.story.id != task.parentStory.id) {
                def story = Story.get(params.long('story.id'))
                taskService.changeTaskStory(task, story, user)

                // If the Task was transformed to a Task
            } else if (params.task?.type && task.parentStory) {
                taskService.storyTaskToSprintTask(task, params.int('task.type'), user)

                // If the Task was transformed to a Task
            } else if (params.story?.id) {
                def story = Story.get(params.long('story.id'))
                taskService.sprintTaskToStoryTask(task, story, user)

                // If the Task has changed its type (TYPE_RECURRENT/TYPE_URGENT)
            } else if (params.task.type && params.int('task.type') != task.type) {
                taskService.changeType(task, params.int('task.type'), user)
            }
            taskService.state(task, params.int('id'), user)
            taskService.rank(task, params.int('position'))
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: task as JSON)  }
                json { render(status: 200, text: task as JSON) }
                xml { render(status: 200, text: task as XML) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }

    def show = {
        if (request?.format == 'html') {
            render(status: 404)
            return
        }

        if (!params.id) {
            returnError(text: message(code: 'is.story.error.not.exist'))
            return
        }

        def task = Task.get(params.long('id'))

        if (!task) {
            returnError(text: message(code: 'is.task.error.not.exist'))
            return
        }

        withFormat {
            json { render(status: 200, text: task as JSON) }
            xml { render(status: 200, text: task as XML) }
        }
    }

    def list = {

        if (request?.format == 'html') {
            render(status: 404)
            return
        }

        def sprint = Sprint.load(params.id)
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
            json { render(status: 200, text: tasks as JSON) }
            xml { render(status: 200, text: tasks as XML) }
        }
    }
}
