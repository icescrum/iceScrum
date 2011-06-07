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

class TaskController {

    def sprintService
    def springSecurityService
    def taskService

    def save = {
        def story = !(params.story.id in ['recurrent', 'urgent']) ? Story.get(params.long('story.id')) : null
        if (!story && !(params.story.id in ['recurrent', 'urgent'])) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        def task = new Task()
        task.properties = params.task

        User user = (User) springSecurityService.currentUser
        def sprint = Sprint.load(params.id)
        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
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
            render(status: 200, contentType: 'application/json', text: task as JSON)
        } catch (AttachmentException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
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
            render(status: 200, contentType: 'application/json', text: [task: task, next: next?.id] as JSON)
        } catch (AttachmentException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
        }
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
        User user = (User) springSecurityService.currentUser

        try {
            taskService.assign([task], user)
            render(status: 200, contentType: 'application/json', text: task as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
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
        User user = (User) springSecurityService.currentUser

        try {
            taskService.unassign([task], user)
            render(status: 200, contentType: 'application/json', text: task as JSON)
        } catch (IllegalStateException ise) {
            if (log.debugEnabled) ise.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
        }
    }


    def delete = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
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
            render(status: 200, contentType: 'application/json', text: ids as JSON)
        } catch (IllegalStateException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: e.message]] as JSON)
        }
    }

    def copy = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
            return
        }
        def task = Task.get(params.long('id'))
        User user = (User) springSecurityService.currentUser

        try {
            def copiedTask = taskService.copy(task, user)
            render(status: 200, contentType: 'application/json', text: copiedTask as JSON)
        } catch (IllegalStateException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def estimateTask = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.task.error.not.exist']] as JSON)
            return
        }
        def task = Task.get(params.long('id'))

        if (!task) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
            return
        }
        User user = (User) springSecurityService.currentUser
        task.estimation = params.int('value') ?: (params.int('value') == 0) ? 0 : null
        try {
            taskService.update(task, user)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
        }
        render(status: 200, text: task.estimation ?: '?')
    }

    def changeBlockState = {
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
        User user = (User) springSecurityService.currentUser
        try {
            taskService.update(task, user)
        } catch (IllegalStateException ise) {
            if (log.debugEnabled) ise.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
        }
        render(status: 200)
    }

    def rank = {
        def position = params.int('position')
        if (position == 0) {
            render(status: 200)
            return
        }

        def movedItem = Task.get(params.long('idmoved'))

        if (!movedItem) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
            return
        }
        try {
            taskService.rank(movedItem, position)
        } catch (Exception e) {
            render(status: 500, text: e.getMessage())
        }
        render(status: 200)
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }

    private manageAttachments(def task) {
        User user = (User) springSecurityService.currentUser
        if (task.id && !params.task.list('attachments') && task.attachments*.id.size() > 0) {
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
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.sprintPlan.state.no.exist')]] as JSON)
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
            render(status: 200, contentType: 'application/json', text: task as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
        }
    }
}
