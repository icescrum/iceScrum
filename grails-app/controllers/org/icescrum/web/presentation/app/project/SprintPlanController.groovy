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

import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport

import org.icescrum.core.utils.BundleUtils

import grails.converters.JSON
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release

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
            sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        }

        def sprintsName = []
        def sprintsId = []
        currentProduct.releases?.sort({a, b -> a.orderNumber <=> b.orderNumber} as Comparator)?.each {
            sprintsName.addAll(it.sprints.collect {v -> "${it.name} - Sprint ${v.orderNumber}"})
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
            sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
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
        }else{
            sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        }
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
                        assignOnBeginTask:currentProduct.preferences.assignOnBeginTask,
                        urgentTasksLimited: (urgentTasks.findAll {it.state == Task.STATE_BUSY}.size() >= sprint.parentRelease.parentProduct.preferences.limitUrgentTasks),
                        user: user])
    }


    def updateTable = {

        withTask('task.id'){ Task task ->
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
                params.task.estimation = params.task?.estimation?.replace(/,/,'.')
                task.estimation = params.task?.estimation?.isNumber() ? params.task.estimation.toFloat() : null
            }

            User user = (User) springSecurityService.currentUser
            taskService.update(task, user)

            def returnValue
            if (params.name == 'notes') {
                returnValue = wikitext.renderHtml(markup: 'Textile', text: task."${params.name}")
                returnValue = returnValue ?: ''
            } else if (params.name == 'estimation') {
                returnValue = task.estimation != null ? task.estimation.toString() : '?'
            } else if (params.name == 'state') {
                returnValue = g.message(code: BundleUtils.taskStates.get(task.state))
                returnValue = returnValue ?: ''
            } else if (params.name == 'description') {
                returnValue = task.description?.encodeAsHTML()?.encodeAsNL2BR()
                returnValue = returnValue ?: ''
            } else {
                returnValue = task."${params.name}".encodeAsHTML()
                returnValue = returnValue ?: ''
            }

            def version = task.isDirty() ? task.version + 1 : task.version
            render(status: 200, text: [version: version, value: returnValue] as JSON)
        }
    }

    def add = {
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }
        def stories = sprint ? Story.findAllByParentSprintAndStateLessThanEquals(sprint, Story.STATE_INPROGRESS, [sort: 'rank']) : []

        def selected = null
        if (params.story?.id && !(params.story.id in ['recurrent', 'urgent']))
            selected = Story.getInProduct(params.long('product'),params.long('story.id')).list()[0]
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
        withTask('subid'){Task task ->
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
    }

    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: id, id: params.id, product: params.product])
    }

    def doneDefinition = {
        withSprint{ Sprint sprint ->
            render(template: 'window/doneDefinition', model: [sprint: sprint, id: id])
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def copyFromPreviousDoneDefinition = {
        withSprint{ Sprint sprint ->
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
            sprintService.updateDoneDefinition(sprint)
            redirect(action: 'doneDefinition', params: [product: params.product, id: sprint.id])
        }
    }

    def retrospective = {
        withSprint{ Sprint sprint ->
            render(template: 'window/retrospective', model: [sprint: sprint, id: id])
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def copyFromPreviousRetrospective = {
        withSprint{ Sprint sprint ->
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
            sprintService.updateRetrospective(sprint)
            redirect(action: 'retrospective', params: [product: params.product, id: sprint.id])
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def updateDoneDefinition = {
        withSprint{ Sprint sprint ->
            sprint.doneDefinition = params.doneDefinition
            sprintService.updateDoneDefinition(sprint)
            render(status: 200)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def updateRetrospective = {
        withSprint{ Sprint sprint ->
            sprint.retrospective = params.retrospective
            sprintService.updateRetrospective(sprint)
            render(status: 200)
        }
    }

    @Cacheable(cache = "sprintCache", keyGenerator = 'sprintKeyGenerator')
    def sprintBurndownHoursChart = {
        withSprint{ Sprint sprint ->
            def values = sprintService.sprintBurndownHoursValues(sprint)
            if (values.size() > 0) {
                render(template: 'charts/sprintBurndownHoursChart', model: [
                        id: id,
                        remainingHours: values.remainingHours as JSON,
                        idealHours: values.idealHours as JSON,
                        withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
                        labels: values.label as JSON])
            } else {
                renderErrors(text:message(code: 'is.chart.error.no.values'))
            }
        }
    }

    @Cacheable(cache = "sprintCache", keyGenerator = 'sprintKeyGenerator')
    def sprintBurnupTasksChart = {
        withSprint{ Sprint sprint ->
            def values = sprintService.sprintBurnupTasksValues(sprint)
            if (values.size() > 0) {
                render(template: 'charts/sprintBurnupTasksChart', model: [
                        id: id,
                        tasks: values.tasks as JSON,
                        withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
                        tasksDone: values.tasksDone as JSON,
                        labels: values.label as JSON])
            } else {
                renderErrors(text:message(code: 'is.chart.error.no.values'))
            }
        }
    }

    @Cacheable(cache = "sprintCache", keyGenerator = 'sprintKeyGenerator')
    def sprintBurnupStoriesChart = {
        withSprint{ Sprint sprint ->
            def values = sprintService.sprintBurnupStoriesValues(sprint)
            if (values.size() > 0) {
                render(template: 'charts/sprintBurnupStoriesChart', model: [
                        id: id,
                        stories: values.stories as JSON,
                        withButtonBar: (params.withButtonBar != null) ? params.boolean('withButtonBar') : true,
                        storiesDone: values.storiesDone as JSON,
                        labels: values.label as JSON])
            } else {
                renderErrors(text:message(code: 'is.chart.error.no.values'))
            }
        }
    }

    def changeFilterTasks = {
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
        User user = (User) springSecurityService.currentUser
        user.preferences.hideDoneState = !user.preferences.hideDoneState
        userService.update(user)
        redirect(action: 'index', params: [product: params.product, id: params.id])
    }

    def copyRecurrentTasksFromPreviousSprint = {
        withSprint{ Sprint sprint ->
            def tasks = sprintService.copyRecurrentTasksFromPreviousSprint(sprint)
            render(status: 200, contentType: 'application/json', text: tasks as JSON)
        }
    }

    /**
     * Export the sprint backlog elements in multiple format (PDF, DOCX, RTF, ODT)
     */
    def print = {
        def currentProduct = Product.load(params.product)
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        def data
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
                data = sprintService.sprintBurndownHoursValues(sprint)
                break
            case 'sprintBurnupTasksChart':
                data = sprintService.sprintBurnupTasksValues(sprint)
                break
            case 'sprintBurnupStoriesChart':
                data = sprintService.sprintBurnupStoriesValues(sprint)
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
                data = [
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

        if (data.size() <= 0) {
            returnError(text:message(code: 'is.report.error.no.data'))
        } else if (params.get) {
            outputJasperReport(chart ?: 'sprintPlan', params.format, data, currentProduct.name, ['labels.projectName': currentProduct.name])
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session?.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            render(template: 'dialogs/report', model: [id: id, sprint: sprint])
        }
    }

    def printPostits = {
        def currentProduct = Product.load(params.product)
        withSprint{ Sprint sprint ->
            def stories1 = []
            def stories2 = []
            def first = 0
            if (!sprint.stories) {
                returnError(text:message(code: 'is.report.error.no.data'))
                return
            } else if (params.get) {
                sprint.stories?.each {
                    def story = [name: it.name,
                            id: it.uid,
                            effort: it.effort,
                            state: message(code: BundleUtils.storyStates[it.state]),
                            description: is.storyTemplate([story: it, displayBR: true]),
                            notes: wikitext.renderHtml([markup: 'Textile'], it.notes).decodeHTML(),
                            type: message(code: BundleUtils.storyTypes[it.type]),
                            suggestedDate: it.suggestedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: currentProduct.preferences.timezone, date: it.suggestedDate]) : null,
                            acceptedDate: it.acceptedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: currentProduct.preferences.timezone, date: it.acceptedDate]) : null,
                            estimatedDate: it.estimatedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: currentProduct.preferences.timezone, date: it.estimatedDate]) : null,
                            plannedDate: it.plannedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: currentProduct.preferences.timezone, date: it.plannedDate]) : null,
                            inProgressDate: it.inProgressDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: currentProduct.preferences.timezone, date: it.inProgressDate]) : null,
                            doneDate: it.doneDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: currentProduct.preferences.timezone, date: it.doneDate ?: null]) : null,
                            rank: it.rank ?: null,
                            sprint: g.message(code: 'is.release') + " " + sprint.parentRelease.orderNumber + " - " + g.message(code: 'is.sprint') + " " + sprint.orderNumber,
                            creator: it.creator.firstName + ' ' + it.creator.lastName,
                            feature: it.feature?.name ?: null,
                            featureColor: it.feature?.color ?: null]
                    if (first == 0) {
                        stories1 << story
                        first = 1
                    } else {
                        stories2 << story
                        first = 0
                    }

                }
                outputJasperReport('stories', params.format, [[product: currentProduct.name, stories1: stories1 ?: null, stories2: stories2 ?: null]], currentProduct.name)
            } else if (params.status) {
                render(status: 200, contentType: 'application/json', text: session?.progress as JSON)
            } else {
                session.progress = new ProgressSupport()
                render(template: 'dialogs/report', model: [id: id, sprint: sprint])
            }
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