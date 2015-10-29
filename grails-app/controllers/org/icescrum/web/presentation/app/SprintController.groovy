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

import org.icescrum.core.domain.Release

import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.utils.ServicesUtils

class SprintController {

    def sprintService
    def storyService
    def springSecurityService

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def save(long product) {
        def sprintParams = params.sprint
        def releaseId = params.parentRelease?.id ?: sprintParams.parentRelease?.id
        if (!releaseId) {
            returnError(text: message(code: 'is.release.error.not.exist'))
            return
        }
        Release release = Release.withRelease(product, releaseId.toLong())
        if (sprintParams.startDate) {
            sprintParams.startDate = ServicesUtils.parseDateISO8601(sprintParams.startDate)
        }
        if (sprintParams.endDate) {
            sprintParams.endDate = ServicesUtils.parseDateISO8601(sprintParams.endDate)
        }
        Sprint sprint = new Sprint()
        try {
            Sprint.withTransaction {
                bindData(sprint, sprintParams, [include: ['goal', 'startDate', 'endDate', 'deliveredVersion']])
                sprintService.save(sprint, release)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: sprint as JSON) }
                json { renderRESTJSON(text: sprint, status: 201) }
                xml { renderRESTXML(text: sprint, status: 201) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: sprint, exception: e)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def update(long product, long id) {
        def sprintParams = params.sprint
        Sprint sprint = Sprint.withSprint(product, id)
        def startDate = sprintParams.startDate ? ServicesUtils.parseDateISO8601(sprintParams.startDate) : sprint.startDate
        def endDate = sprintParams.endDate ? ServicesUtils.parseDateISO8601(sprintParams.endDate) : sprint.endDate
        Sprint.withTransaction {
            bindData(sprint, sprintParams, [include: ['goal', 'deliveredVersion', 'retrospective', 'doneDefinition']])
            sprintService.update(sprint, startDate, endDate)
        }
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: sprint as JSON) }
            json { renderRESTJSON(text: sprint) }
            xml { renderRESTXML(text: sprint) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        try {
            sprintService.delete(sprint)
            withFormat {
                html { render(status: 200) }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: sprint, exception: e)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        def unPlanAllStories = storyService.unPlanAll([sprint])
        withFormat {
            html {
                render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprint: sprint] as JSON)
            }
            json { renderRESTJSON(text: sprint) }
            xml { renderRESTXML(text: sprint) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        sprintService.activate(sprint)
        withFormat {
            html {
                render(status: 200, contentType: 'application/json', text: [sprint: sprint, stories: sprint.stories] as JSON)
            }
            json { renderRESTJSON(text: sprint) }
            xml { renderRESTXML(text: sprint) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        def unDoneStories = sprint.stories.findAll { it.state != Story.STATE_DONE }
        sprintService.close(sprint)
        withFormat {
            html {
                render(status: 200, contentType: 'application/json', text: [sprint: sprint, unDoneStories: unDoneStories, stories: sprint.stories] as JSON)
            }
            json { renderRESTJSON(text: sprint) }
            xml { renderRESTXML(text: sprint) }
        }
    }

    @Secured('inProduct()')
    def index(long product, long id) {
        if (request?.format == 'html') {
            render(status: 404)
            return
        }
        Sprint sprint = Sprint.withSprint(product, id)
        withFormat {
            json { renderRESTJSON(text: sprint) }
            xml { renderRESTXML(text: sprint) }
        }
    }

    @Secured('inProduct()')
    def show() {
        redirect(action: 'index', controller: controllerName, params: params)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def list(long product, Long releaseId) {
        Release release = releaseId ? Release.withRelease(product, releaseId) : Release.findCurrentOrNextRelease(product).list()[0]
        def sprints = release?.sprints ?: []
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: sprints as JSON) }
            json { renderRESTJSON(text: sprints) }
            xml { renderRESTXML(text: sprints) }
        }
    }

    @Secured(['stakeHolder() or inProduct()'])
    def findCurrentOrLastSprint(long product) {
        def sprint = Sprint.findCurrentOrLastSprint(product).list()[0]
        withFormat {
            html { render status: 200, contentType: 'application/json', text: sprint as JSON }
            json { renderRESTJSON(text: sprint) }
            xml { renderRESTXML(text: sprint) }
        }
    }

    @Secured(['stakeHolder() or inProduct()'])
    def burndownRemaining(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        def values = sprintService.sprintBurndownRemainingValues(sprint)
        def computedValues = [[key: message(code: "is.chart.sprintBurndownRemainingChart.serie.task.name"),
                               values: values.findAll{ it.remainingTime != null }.collect { return [it.label, it.remainingTime]}]]
        if (values.first()?.idealTime) {
            computedValues << [key: message(code: "is.chart.sprintBurndownRemainingChart.serie.task.ideal"),
                               values: values.findAll{ it.idealTime != null }.collect { return [it.label, it.idealTime]}]
        }
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurndownRemainingChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurndownRemainingChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurndownRemainingChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def burnupTasks(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        def values = sprintService.sprintBurnupTasksValues(sprint)
        def computedValues = [
                [key: message(code: "is.chart.sprintBurnupTasksChart.serie.tasksDone.name"),
                 values: values.findAll{ it.tasksDone != null }.collect { return [it.label, it.tasksDone]}],
                [key: message(code: "is.chart.sprintBurnupTasksChart.serie.tasks.name"),
                 values: values.findAll{ it.tasks != null }.collect { return [it.label, it.tasks]}]
        ]
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurnupTasksChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurnupTasksChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurnupTasksChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def burnupPoints(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        def values = sprintService.sprintBurnupStoriesValues(sprint)
        def computedValues = [
                [key: message(code: "is.chart.sprintBurnupPointsChart.serie.points.name"),
                 values: values.findAll{ it.totalPoints != null }.collect { return [it.label, it.totalPoints]}],
                [key: message(code: "is.chart.sprintBurnupPointsChart.serie.pointsDone.name"),
                 values: values.findAll{ it.pointsDone != null }.collect { return [it.label, it.pointsDone]}]
        ]
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurnupPointsChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurnupPointsChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurnupPointsChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def burnupStories(long product, long id) {
        Sprint sprint = Sprint.withSprint(product, id)
        def values = sprintService.sprintBurnupStoriesValues(sprint)
        def computedValues = [
                [key: message(code: "is.chart.sprintBurnupStoriesChart.serie.stories.name"),
                 values: values.findAll{ it.stories != null }.collect { return [it.label, it.stories]}],
                [key: message(code: "is.chart.sprintBurnupStoriesChart.serie.storiesDone.name"),
                 values: values.findAll{ it.storiesDone != null }.collect { return [it.label, it.storiesDone]}]
        ]
        def options = [chart: [xDomain: [values.label.min(), values.label.max()],
                               yAxis: [axisLabel: message(code: 'is.chart.sprintBurnupStoriesChart.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintBurnupStoriesChart.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintBurnupStoriesChart.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }
}
