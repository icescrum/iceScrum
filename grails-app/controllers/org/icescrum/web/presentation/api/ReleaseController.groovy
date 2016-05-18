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
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.utils.ServicesUtils

class ReleaseController {

    def releaseService
    def sprintService
    def storyService
    def springSecurityService
    def featureService

    @Secured(['stakeHolder() or inProduct()'])
    def index(long product) {
        Product _product = Product.withProduct(product)
        def releases = _product.releases
        render(status: 200, contentType: 'application/json', text: releases as JSON)
    }

    @Secured('inProduct()')
    def show(long product, long id) {
        Release release = Release.withRelease(product, id)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def save(long product) {
        Product _product = Product.withProduct(product)
        def releaseParams = params.release
        if (releaseParams.startDate) {
            releaseParams.startDate = ServicesUtils.parseDateISO8601(releaseParams.startDate)
        }
        if (releaseParams.endDate) {
            releaseParams.endDate = ServicesUtils.parseDateISO8601(releaseParams.endDate)
        }
        def release = new Release()
        try {
            Release.withTransaction {
                bindData(release, releaseParams, [include: ['name', 'goal', 'startDate', 'endDate']])
                releaseService.save(release, _product)
            }
            render(status: 201, contentType: 'application/json', text: release as JSON)
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: release, exception: e)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def update(long product, long id) {
        def releaseParams = params.release
        Release release = Release.withRelease(product, id)
        def startDate = releaseParams.startDate ? ServicesUtils.parseDateISO8601(releaseParams.startDate) : release.startDate
        def endDate = releaseParams.endDate ? ServicesUtils.parseDateISO8601(releaseParams.endDate) : release.endDate
        Release.withTransaction {
            bindData(release, releaseParams, [include: ['name', 'vision']])
            releaseService.update(release, startDate, endDate)
        }
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete(long product, long id) {
        Release release = Release.withRelease(product, id)
        releaseService.delete(release)
        render(status: 200, contentType: 'application/json', text: [id: id] as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close(long product, long id) {
        Release release = Release.withRelease(product, id)
        releaseService.close(release)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate(long product, long id) {
        Release release = Release.withRelease(product, id)
        releaseService.activate(release)
        render(status: 200, contentType: 'application/json', text: release as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def autoPlan(long product, long id, Double capacity) {
        Release release = Release.withRelease(product, id)
        def plannedStories = storyService.autoPlan(release.sprints.asList(), capacity)
        render(status: 200, contentType: 'application/json', text: plannedStories as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan(long product, long id) {
        Release release = Release.withRelease(product, id)
        def sprints = Sprint.findAllByParentRelease(release)
        def unPlanAllStories = []
        if (sprints) {
            unPlanAllStories = storyService.unPlanAll(sprints, Sprint.STATE_WAIT)
        }
        render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprints: sprints] as JSON)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def burndown(long product, long id) {
        Release release = Release.withRelease(product, id)
        def values = releaseService.releaseBurndownValues(release)
        def computedValues = [[key: message(code:'is.chart.releaseBurnDown.series.userstories.name'),
                               values: values.collect { return [it.userstories]}],
                              [key: message(code:'is.chart.releaseBurnDown.series.technicalstories.name'),
                               values: values.collect { return [it.technicalstories]}],
                              [key: message(code:'is.chart.releaseBurnDown.series.defectstories.name'),
                               values: values.collect { return [it.defectstories]}]]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.releaseBurnDown.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.releaseBurnDown.xaxis.label')]],
                       title: [text: message(code: "is.chart.releaseBurnDown.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: values.label, options: options] as JSON)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def parkingLot(long product, long id) {
        Release release = Release.withRelease(product, id)
        def values = featureService.releaseParkingLotValues(release)
        def computedValues = [[key: message(code:"is.chart.releaseParkingLot.serie.name"),
                               values: values.collect { return [it.label, it.value]}]]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.releaseParkingLot.xaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.releaseParkingLot.yaxis.label')]],
                       title: [text: message(code: "is.chart.releaseParkingLot.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }
}
