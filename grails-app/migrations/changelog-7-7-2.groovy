import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Task

/*
* Copyright (c) 2017 Kagilum SAS
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
* Nicolas Noullet (nnoullet@kagilum.com)
* Vincent BARRIER (vbarrier@kagilum.com)
* Colin Bontemps (cbontemps@kagilum.com)
*
*/

databaseChangeLog = {
    changeSet(author: "vbarrier", id: "fix_tasks_state_in_sprint_done") {
        grailsChange {
            change {
                def urgentTasks = Task.executeQuery("""
                        SELECT task
                        FROM org.icescrum.core.domain.Task as task, org.icescrum.core.domain.Sprint as sprint
                        WHERE task.backlog.id = sprint.id
                        AND sprint.state = :doneSprint
                        AND task.state != :doneTask
                        AND task.type = :urgentTask""", [doneSprint: Sprint.STATE_DONE, doneTask: Task.STATE_DONE, urgentTask: Task.TYPE_URGENT])
                def storyTasks = Task.executeQuery("""
                        SELECT task
                        FROM org.icescrum.core.domain.Task as task, org.icescrum.core.domain.Sprint as sprint
                        WHERE task.backlog.id = sprint.id
                        AND sprint.state = :doneSprint
                        AND task.state != :doneTask
                        AND task.parentStory IS NOT NULL""", [doneSprint: Sprint.STATE_DONE, doneTask: Task.STATE_DONE])
                def tasks = urgentTasks + storyTasks
                if (tasks) {
                    log.info "Fixing task state in done sprint"
                    log.info "Urgent tasks to fix: ${urgentTasks.size()}"
                    log.info "Story tasks to fix: ${storyTasks.size()}"
                    tasks.eachWithIndex { task, index ->
                        task.estimation = 0
                        task.blocked = false
                        task.doneDate = ((Sprint) task.backlog).doneDate
                        task.state = Task.STATE_DONE
                        task.save(flush: index == tasks.size() -1)
                    }
                    log.info "End fixing tasks"
                }
            }
        }
    }
    changeSet(author: "vbarrier", id: "fix_tasks_wrong_sprint") {
        grailsChange {
            change {
                def storyTasks = Task.executeQuery("""
                        SELECT task
                        FROM org.icescrum.core.domain.Task as task, org.icescrum.core.domain.Sprint as sprint, org.icescrum.core.domain.Story as story
                        WHERE task.backlog.id = sprint.id
                        AND sprint.state = :inProgressSprint
                        AND task.state = :inProgressTask
                        AND task.parentStory.id = story.id
                        AND story.parentSprint.id != sprint.id""", [inProgressSprint: Sprint.STATE_INPROGRESS, inProgressTask: Task.STATE_BUSY])
                if (storyTasks) {
                    log.info "Fixing story task state in in progress sprint"
                    log.info "Tasks to fix: ${storyTasks.size()}"
                    storyTasks.eachWithIndex { task, index ->
                        task.state = Task.STATE_WAIT
                        task.inProgressDate = null
                        task.initial = null
                        task.backlog = task.parentStory.parentSprint
                        task.save(flush: index == storyTasks.size() -1)
                    }
                    log.info "End fixing tasks"
                }
            }
        }
    }
}

