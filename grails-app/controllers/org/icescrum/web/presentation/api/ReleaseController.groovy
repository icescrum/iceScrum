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
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.utils.ServicesUtils

class ReleaseController implements ControllerErrorHandler {

    def releaseService
    def storyService
    def springSecurityService
    def featureService

    @Secured(['stakeHolder() or inProject()'])
    def index(long project) {
        Project _project = Project.withProject(project)
        def releases = _project.releases
        render(status: 200, contentType: 'application/json', text: releases as JSON)
    }

    @Secured('inProject()')
    def show(long project, long id) {
        Release release = Release.withRelease(project, id)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def save(long project) {
        Project _project = Project.withProject(project)
        def releaseParams = params.release
        if (releaseParams.startDate) {
            releaseParams.startDate = ServicesUtils.parseDateISO8601(releaseParams.startDate)
        }
        if (releaseParams.endDate) {
            releaseParams.endDate = ServicesUtils.parseDateISO8601(releaseParams.endDate)
        }
        def release = new Release()
        Release.withTransaction {
            bindData(release, releaseParams, [include: ['name', 'goal', 'startDate', 'endDate', 'firstSprintIndex']])
            releaseService.save(release, _project)
        }
        render(status: 201, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def update(long project, long id) {
        def releaseParams = params.release
        Release release = Release.withRelease(project, id)
        def startDate = releaseParams.startDate ? ServicesUtils.parseDateISO8601(releaseParams.startDate) : release.startDate
        def endDate = releaseParams.endDate ? ServicesUtils.parseDateISO8601(releaseParams.endDate) : release.endDate
        Release.withTransaction {
            bindData(release, releaseParams, [include: ['name', 'vision', 'firstSprintIndex']])
            releaseService.update(release, startDate, endDate)
        }
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def delete(long project, long id) {
        Release release = Release.withRelease(project, id)
        releaseService.delete(release)
        withFormat {
            html {
                render(status: 200, contentType: 'application/json', text: [id: id] as JSON)
            }
            json {
                render(status: 204)
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def close(long project, long id) {
        Release release = Release.withRelease(project, id)
        releaseService.close(release)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def activate(long project, long id) {
        Release release = Release.withRelease(project, id)
        releaseService.activate(release)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def reactivate(long project, long id) {
        Release release = Release.withRelease(project, id)
        releaseService.reactivate(release)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def autoPlan(long project, long id, Double capacity) {
        Release release = Release.withRelease(project, id)
        if (release.sprints) {
            def plannedStories = storyService.autoPlan(release.sprints.asList(), capacity)
            render(status: 200, contentType: 'application/json', text: plannedStories as JSON)
        } else {
            returnError(code: 'todo.is.ui.nosprint')
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProject()')
    def unPlan(long project, long id) {
        Release release = Release.withRelease(project, id)
        def sprints = Sprint.findAllByParentRelease(release)
        if (sprints) {
            def unPlanAllStories = storyService.unPlanAll(sprints, Sprint.STATE_WAIT)
            render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprints: sprints] as JSON)
        } else {
            returnError(code: 'todo.is.ui.nosprint')
        }
    }

    @Secured(['stakeHolder() or inProject()'])
    def burndown(long project, long id) {
        Release release = Release.withRelease(project, id)
        def values = releaseService.releaseBurndownValues(release)
        def computedValues = [[key   : message(code: 'is.chart.releaseBurnDown.series.userstories.name'),
                               values: values.collect { return [it.userstories] },
                               color : '#009900'],
                              [key   : message(code: 'is.chart.releaseBurnDown.series.technicalstories.name'),
                               values: values.collect { return [it.technicalstories] },
                               color : '#1F77B4'],
                              [key   : message(code: 'is.chart.releaseBurnDown.series.defectstories.name'),
                               values: values.collect { return [it.defectstories] },
                               color : '#CC3300']]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.releaseBurnDown.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.releaseBurnDown.xaxis.label')]],
                       title: [text: message(code: "is.chart.releaseBurnDown.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def parkingLot(long project, long id) {
        Release release = Release.withRelease(project, id)
        def values = featureService.releaseParkingLotValues(release)
        def colors = values.collect { return it.color }
        def computedValues = [[key   : message(code: "is.chart.releaseParkingLot.serie.name"),
                               values: values.collect { return [it.label, it.value] }]]
        def options = [chart: [yDomain : [0, 100],
                               yAxis   : [axisLabel: message(code: 'is.chart.releaseParkingLot.xaxis.label')],
                               barColor: colors],
                       title: [text: message(code: "is.chart.releaseParkingLot.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }
}
