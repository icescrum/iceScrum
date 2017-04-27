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
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.utils.ServicesUtils
import org.icescrum.core.error.ControllerErrorHandler

class SprintController implements ControllerErrorHandler {

    def sprintService
    def storyService
    def springSecurityService

    @Secured(['stakeHolder() or inProject()'])
    def index(long project, Long releaseId) {
        Release release = releaseId ? Release.withRelease(project, releaseId) : Release.findCurrentOrNextRelease(project).list()[0]
        def sprints = release?.sprints ?: []
        render(status: 200, contentType: 'application/json', text: sprints as JSON)
    }

    @Secured('inProject()')
    def show(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        render(status: 200, contentType: 'application/json', text: sprint as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def save(long project) {
        def sprintParams = params.sprint
        def releaseId = params.parentRelease?.id ?: sprintParams.parentRelease?.id
        if (!releaseId) {
            returnError(code: 'is.release.error.not.exist')
            return
        }
        Release release = Release.withRelease(project, releaseId.toLong())
        if (sprintParams.startDate) {
            sprintParams.startDate = ServicesUtils.parseDateISO8601(sprintParams.startDate)
        }
        if (sprintParams.endDate) {
            sprintParams.endDate = ServicesUtils.parseDateISO8601(sprintParams.endDate)
        }
        Sprint sprint = new Sprint()
        Sprint.withTransaction {
            bindData(sprint, sprintParams, [include: ['goal', 'startDate', 'endDate', 'deliveredVersion']])
            sprintService.save(sprint, release)
        }
        render(status: 201, contentType: 'application/json', text: sprint as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def update(long project, long id) {
        def sprintParams = params.sprint
        Sprint sprint = Sprint.withSprint(project, id)
        def startDate = sprintParams.startDate ? ServicesUtils.parseDateISO8601(sprintParams.startDate) : sprint.startDate
        def endDate = sprintParams.endDate ? ServicesUtils.parseDateISO8601(sprintParams.endDate) : sprint.endDate
        Sprint.withTransaction {
            bindData(sprint, sprintParams, [include: ['goal', 'deliveredVersion', 'retrospective', 'doneDefinition']])
            sprintService.update(sprint, startDate, endDate)
        }
        render(status: 200, contentType: 'application/json', text: sprint as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def delete(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        sprintService.delete(sprint)
        render(status: 200, text: [id: id] as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def generateSprints(long project, long releaseId) {
        Release release = Release.withRelease(project, releaseId)
        def sprints = sprintService.generateSprints(release)
        render(status: 200, contentType: 'application/json', text: sprints as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def autoPlan(Double capacity) {
        def sprints = Sprint.withSprints(params)
        storyService.autoPlan(sprints, capacity)
        def returnData = sprints.size() > 1 ? sprints : sprints.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def unPlan() {
        def sprints = Sprint.withSprints(params)
        storyService.unPlanAll(sprints)
        def returnData = sprints.size() > 1 ? sprints : sprints.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def activate(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        sprintService.activate(sprint)
        render(status: 200, contentType: 'application/json', text: sprint as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def close(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        sprintService.close(sprint)
        render(status: 200, contentType: 'application/json', text: sprint as JSON)
    }

    @Secured('inProject() and !archivedProject()')
    def copyRecurrentTasks(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        sprintService.copyRecurrentTasks(sprint)
        render(status: 200, contentType: 'application/json', text: sprint as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def burndownRemaining(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        def values = sprintService.sprintBurndownRemainingValues(sprint)
        def computedValues = [[key: message(code: "is.chart.sprintBurndownRemainingChart.serie.task.name"),
                               values: values.findAll { it.remainingTime != null }.collect { return [it.label, it.remainingTime]},
                               color: '#1F77B4']]
        if (values && values.first().idealTime) {
            computedValues << [key: message(code: "is.chart.sprintBurndownRemainingChart.serie.task.ideal"),
                               values: values.findAll { it.idealTime != null }.collect { return [it.label, it.idealTime]},
                               color: '#009900']
        }
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurndownRemainingChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurndownRemainingChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurndownRemainingChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def burnupTasks(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        def values = sprintService.sprintBurnupTasksValues(sprint)
        def computedValues = [
                [key: message(code: "is.chart.sprintBurnupTasksChart.serie.tasksDone.name"),
                 values: values.findAll { it.tasksDone != null }.collect { return [it.label, it.tasksDone]},
                 color: '#009900'],
                [key: message(code: "is.chart.sprintBurnupTasksChart.serie.tasks.name"),
                 values: values.findAll { it.tasks != null }.collect { return [it.label, it.tasks]},
                 color: '#1C3660']
        ]
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurnupTasksChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurnupTasksChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurnupTasksChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def burnupPoints(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        def values = sprintService.sprintBurnupStoriesValues(sprint)
        def computedValues = [
                [key: message(code: "is.chart.sprintBurnupPointsChart.serie.points.name"),
                 values: values.findAll { it.totalPoints != null }.collect { return [it.label, it.totalPoints]},
                 color: '#1C3660'],
                [key: message(code: "is.chart.sprintBurnupPointsChart.serie.pointsDone.name"),
                 values: values.findAll { it.pointsDone != null }.collect { return [it.label, it.pointsDone]},
                 color: '#009900']
        ]
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurnupPointsChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurnupPointsChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurnupPointsChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def burnupStories(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        def values = sprintService.sprintBurnupStoriesValues(sprint)
        def computedValues = [
                [key: message(code: "is.chart.sprintBurnupStoriesChart.serie.stories.name"),
                 values: values.findAll { it.stories != null }.collect { return [it.label, it.stories]},
                 color: '#1C3660'],
                [key: message(code: "is.chart.sprintBurnupStoriesChart.serie.storiesDone.name"),
                 values: values.findAll { it.storiesDone != null }.collect { return [it.label, it.storiesDone]},
                 color: '#009900']
        ]
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurnupStoriesChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurnupStoriesChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurnupStoriesChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }
}
