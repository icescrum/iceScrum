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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.domain.*
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import org.icescrum.core.utils.BundleUtils
import grails.plugin.springcache.annotations.Cacheable

@Secured('inProduct()')
class SprintPlanController {

    static ui = true

    static final id = 'sprintPlan'
    static menuBar = MenuBarSupport.productDynamicBar('is.ui.sprintPlan', id, true, 5)
    static window = [title: 'is.ui.sprintPlan', help: 'is.ui.sprintPlan.help', toolbar: true, titleBarContent: true]

    static shortcuts = [
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.sprintPlan.del.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.sprintPlan.ctrln.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.sprintPlan.ctrla.text'],
            [code: 'is.ui.shortcut.ctrlshifta.code', text: 'is.ui.shortcut.sprintPlan.ctrlshifta.text'],
            [code: 'is.ui.shortcut.ctrlshiftc.code', text: 'is.ui.shortcut.sprintPlan.ctrlshiftc.text'],
            [code: 'is.ui.shortcut.ctrlshiftd.code', text: 'is.ui.shortcut.sprintPlan.ctrlshiftd.text'],
            [code: 'is.ui.shortcut.ctrlshiftr.code', text: 'is.ui.shortcut.sprintPlan.ctrlshiftr.text']
    ]

    def springSecurityService
    def storyService
    def sprintService
    def taskService
    def releaseService
    def userService


    def titleBarContent = {
        def currentProduct = Product.load(params.product)
        def sprint
        if (!params.id) {
            sprint = Sprint.findCurrentOrNextSprint(currentProduct.id).list()[0]
        } else {
            sprint = Sprint.load(params.long('id'))
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
                        sprint: sprint,
                        sprintsName: sprintsName])
    }

    def toolbar = {
        def sprint
        def currentProduct = Product.load(params.product)
        if (!params.id) {
            sprint = Sprint.findCurrentOrNextSprint(currentProduct.id).list()[0]
            if (sprint)
                params.id = sprint.id
        } else {
            sprint = Sprint.get(params.long('id'))
        }

        User user = (User) springSecurityService.currentUser

        render(template: 'window/toolbar',
                model: [id: id,
                        currentView: session.currentView,
                        hideDoneState: user.preferences.hideDoneState,
                        currentFilter: user.preferences.filterTask,
                        sprint: sprint ?: null])
    }

    def index = {
        def sprint
        User user = (User) springSecurityService.currentUser
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

        def stateSelect = BundleUtils.taskStates.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')

        def stories
        def recurrentTasks
        def urgentTasks

        if (params.term && params.term != '') {
            stories = Story.findStoriesFilter(sprint, '%' + params.term + '%', user).listDistinct()
            recurrentTasks = Task.findRecurrentTasksFilter(sprint, '%' + params.term + '%', user).listDistinct()
            urgentTasks = Task.findUrgentTasksFilter(sprint, '%' + params.term + '%', user).listDistinct()
        } else {
            stories = Story.findStoriesFilter(sprint, null, user).listDistinct()
            recurrentTasks = Task.findRecurrentTasksFilter(sprint, null, user).listDistinct()
            urgentTasks = Task.findUrgentTasksFilter(sprint, null, user).listDistinct()
        }

        def suiteSelect = ''
        def currentSuite = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

        currentSuite = currentSuite.eachWithIndex { t, i ->
            suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
        }
        def template = session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
        render(template: template,
                model: [id: id,
                        sprint: sprint,
                        stories: stories,
                        recurrentTasks: recurrentTasks,
                        urgentTasks: urgentTasks,
                        columns: columns,
                        stateSelect: stateSelect,
                        suiteSelect: suiteSelect,
                        hideDoneState: user.preferences.hideDoneState,
                        previousSprintExist: (sprint.orderNumber > 1) ?: false,
                        nextSprintExist: sprint.hasNextSprint,
                        displayUrgentTasks: sprint.parentRelease.parentProduct.preferences.displayUrgentTasks,
                        displayRecurrentTasks: sprint.parentRelease.parentProduct.preferences.displayRecurrentTasks,
                        limitValueUrgentTasks: sprint.parentRelease.parentProduct.preferences.limitUrgentTasks,
                        urgentTasksLimited: (urgentTasks.findAll {it.state == Task.STATE_BUSY}.size() >= sprint.parentRelease.parentProduct.preferences.limitUrgentTasks),
                        user: user])
    }


    def updateTable = {

        def task = Task.get(params.long('task.id'))
        if (!task) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
            return
        }

        if (params.boolean('loadrich')) {
            render(status: 200, text: task.notes ?: '')
            return
        }

        if (!params.table) {
            return
        }

        if (params.name != 'estimation') {
            if (task.state == Task.STATE_WAIT && params.name == "state" && params.task.state >= Task.STATE_BUSY) {
                task.inProgressDate = new Date()
            } else if (task.state == Task.STATE_BUSY && params.name == "state" && params.task.state == Task.STATE_WAIT) {
                task.inProgressDate = null
            }
            task.properties = params.task
        }
        else {
            task.estimation = params.int('task.estimation') ?: (params.int('task.estimation') == 0) ? 0 : null
        }

        User user = (User) springSecurityService.currentUser
        try {
            taskService.update(task, user)

            def returnValue
            if (params.name == 'notes') {
                returnValue = wikitext.renderHtml(markup: 'Textile', text: task."${params.name}")
            } else if (params.name == 'estimation') {
                returnValue = task.estimation ?: '?'
            } else if (params.name == 'state') {
                returnValue = g.message(code: BundleUtils.taskStates.get(task.state))
            } else if (params.name == 'description') {
                returnValue = task.description?.encodeAsHTML()?.encodeAsNL2BR()
            } else {
                returnValue = task."${params.name}".encodeAsHTML()
            }

            def version = task.isDirty() ? task.version + 1 : task.version
            render(status: 200, text: [version: version, value: returnValue ?: ''] as JSON)

        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: task)]] as JSON)
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
                sprint: sprint,
                stories: selectList,
                selected: selected,
                params: [product: params.product, id: sprint.id]
        ])
    }


    def edit = {
        if (!params.subid) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
            return
        }

        def task = Task.get(params.long('subid'))
        if (!task) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
            return
        }

        def selected = (task.type == Task.TYPE_RECURRENT) ? [id: 'recurrent'] : (task.type == Task.TYPE_URGENT) ? [id: 'urgent'] : task.parentStory
        def sprint = task.backlog
        def stories = Story.findAllByParentSprintAndStateLessThanEquals((Sprint) sprint, Story.STATE_INPROGRESS, [sort: 'rank'])

        def selectList = []
        if (sprint.parentRelease.parentProduct.preferences.displayRecurrentTasks)
            selectList << [id: 'recurrent', name: ' ** ' + message(code: 'is.task.type.recurrent') + ' ** ']
        if (sprint.parentRelease.parentProduct.preferences.displayUrgentTasks)
            selectList << [id: 'urgent', name: ' ** ' + message(code: 'is.task.type.urgent') + ' ** ']
        selectList = selectList + stories

        User user = (User) springSecurityService.currentUser
        def next = Task.findNextTask(task, user).list()[0]

        render(template: 'window/manage', model: [
                id: id,
                task: task,
                stories: selectList,
                selected: selected,
                next: next?.id ?: '',
                sprint: task.backlog,
                params: [product: params.product, id: task.id]
        ])
    }

    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: id, id: params.id, product: params.product])
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
    def copyFromPreviousDoneDefinition = {
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

        if (sprint.orderNumber > 1 || sprint.parentRelease.orderNumber > 1) {
            def previous
            if (sprint.orderNumber > 1) {
                previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease, sprint.orderNumber - 1)
            } else {
                previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease, sprint.parentRelease.sprints.size())
            }
            sprint.doneDefinition = previous.doneDefinition
        } else {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.doneDefinition.no.previous')]] as JSON)
        }

        try {
            sprintService.updateDoneDefinition(sprint)
            redirect(action: 'doneDefinition', params: [product: params.product, id: sprint.id])
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
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
    def copyFromPreviousRetrospective = {
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

        if (sprint.orderNumber > 1 || sprint.parentRelease.orderNumber > 1) {
            def previous
            if (sprint.orderNumber > 1) {
                previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease, sprint.orderNumber - 1)
            } else {
                previous = Sprint.findByParentReleaseAndOrderNumber(sprint.parentRelease, sprint.parentRelease.sprints.size())
            }
            sprint.retrospective = previous.retrospective
        } else {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.retrospective.no.previous')]] as JSON)
        }

        try {
            sprintService.updateRetrospective(sprint)
            redirect(action: 'retrospective', params: [product: params.product, id: sprint.id])
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def updateDoneDefinition = {
        def sprint = Sprint.get(params.long('id'))
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
        }
        else if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
        } else {
            sprint.doneDefinition = params.doneDefinition
            try {
                sprintService.updateDoneDefinition(sprint)
                render(status: 200)
            } catch (RuntimeException re) {
                render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
            }
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def updateRetrospective = {
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
        sprint.retrospective = params.retrospective

        try {
            sprintService.updateRetrospective(sprint)
            render(status: 200)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
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
                    withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
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
                    withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
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
                    withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
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
        if (!params.filter || !params.filter in ['allTasks', 'myTasks', 'freeTasks']) {
            def msg = message(code: 'is.user.preferences.error.not.filter')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        User user = (User) springSecurityService.currentUser
        user.preferences.filterTask = params.filter
        userService.update(user)
        redirect(action: 'index', params: [product: params.product, id: params.id])
    }

    def changeHideDoneState = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        User user = (User) springSecurityService.currentUser
        user.preferences.hideDoneState = !user.preferences.hideDoneState
        userService.update(user)
        redirect(action: 'index', params: [product: params.product, id: params.id])
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
            def tasks = sprintService.copyRecurrentTasksFromPreviousSprint(sprint)
            render(status: 200, contentType: 'application/json', text: tasks as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
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

        if (params.locationHash) {
            chart = processLocationHash(params.locationHash.decodeURL()).action
        }

        switch (chart) {
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
                chart = 'sprintPlan'

                // Retrieve all the tasks associated to the sprint
                def stories = Story.findStoriesFilter(sprint, null, null).listDistinct()
                def tasks = Task.findRecurrentTasksFilter(sprint, null, null).listDistinct() + Task.findUrgentTasksFilter(sprint, null, null).listDistinct()
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
                                taskStateBundle: BundleUtils.taskStates,
                                tasks: tasks,
                                sprintBurndownHoursChart: sprintService.sprintBurndownHoursValues(sprint),
                                sprintBurnupTasksChart: sprintService.sprintBurnupTasksValues(sprint),
                                sprintBurnupStoriesChart: sprintService.sprintBurnupStoriesValues(sprint)
                        ]
                ]
                break
        }

        if (values.size() <= 0) {
            def msg = message(code: 'is.chart.error.no.values')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
        } else if (params.get) {
            session.progress = new ProgressSupport()
            session.progress.updateProgress(99, message(code: 'is.report.processing'))
            def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "") + '-' + (chart ?: 'sprintPlan') + '-' + (g.formatDate(formatName: 'is.date.file'))

            try {
                chain(controller: 'jasper',
                        action: 'index',
                        model: [data: values],
                        params: [
                                _format: params.format,
                                _file: chart ?: 'sprintPlan',
                                'labels.projectName': currentProduct.name,
                                _name: fileName,
                                SUBREPORT_DIR: grailsApplication.config.jasper.dir.reports + './subreports/'
                        ]
                )
                session.progress?.completeProgress(message(code: 'is.report.complete'))
            } catch (Exception e) {
                if (log.debugEnabled) e.printStackTrace()
                session.progress.progressError(message(code: 'is.report.error'))
            }
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            render(template: 'dialogs/report', model: [id: id, sprint: sprint])
        }
    }

    /**
     * Parse the location hash string passed in argument
     * @param locationHash
     * @return A Map
     */
    private processLocationHash(String locationHash) {
        def data = locationHash.split('/')
        return [
                controller: data[0].replace('#', ''),
                action: data.size() > 1 ? data[1] : null
        ]
    }
}