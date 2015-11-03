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
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { renderRESTJSON(text: release, status: 201) }
                xml { renderRESTXML(text: release, status: 201) }
            }
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
        if (release.state == Release.STATE_DONE) {
            returnError(text: message(code: 'is.release.error.update.state.done'))
            return
        }
        def startDate = releaseParams.startDate ? ServicesUtils.parseDateISO8601(releaseParams.startDate) : release.startDate
        def endDate = releaseParams.endDate ? ServicesUtils.parseDateISO8601(releaseParams.endDate) : release.endDate
        Release.withTransaction {
            bindData(release, releaseParams, [include: ['name', 'goal', 'vision']])
            releaseService.update(release, startDate, endDate)
        }
        withFormat {
            html { render status: 200, contentType: 'application/json', text: release as JSON }
            json { renderRESTJSON(text: release) }
            xml { renderRESTXML(text: release) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete(long product, long id) {
        Release release = Release.withRelease(product, id)
        def jsonRelease = (release as JSON).toString()
        releaseService.delete(release)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: jsonRelease }
            json { render status: 204 }
            xml { render status: 204 }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close(long product, long id) {
        Release release = Release.withRelease(product, id)
        releaseService.close(release)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: release as JSON }
            json { renderRESTJSON(text: release) }
            xml { renderRESTXML(text: release) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate(long product, long id) {
        Release release = Release.withRelease(product, id)
        releaseService.activate(release)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: release as JSON }
            json { renderRESTJSON(text: release) }
            xml { renderRESTXML(text: release) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def autoPlan(long product, long id) {
        Release release = Release.withRelease(product, id)
        def capacity = params.capacity instanceof String ? params.capacity.replaceAll(',', '.').toBigDecimal() : params.capacity
        def plannedStories = storyService.autoPlan(release, capacity)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: plannedStories as JSON }
            json { renderRESTJSON(text: plannedStories, status: 201) }
            xml { renderRESTXML(text: plannedStories, status: 201) }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan(long product, long id) {
        Release release = Release.withRelease(product, id)
        def sprints = Sprint.findAllByParentRelease(release)
        def unPlanAllStories = []
        if (sprints) {
            unPlanAllStories = storyService.unPlanAll(sprints, Sprint.STATE_WAIT)
        }
        withFormat {
            html {
                render status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprints: sprints] as JSON
            }
            json { render status: 204, contentType: 'application/json', text: '' }
            xml { render status: 204, contentType: 'text/xml', text: '' }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def generateSprints(long product, long id) {
        Release release = Release.withRelease(product, id)
        def sprints = sprintService.generateSprints(release)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: sprints as JSON }
            json { renderRESTJSON(text: sprints, status: 201) }
            xml { renderRESTXML(text: sprints, status: 201) }
        }
    }

    @Secured('inProduct()')
    def index(long product, long id) {
        if (request?.format == 'html') {
            render(status: 404)
            return
        }
        Release release = Release.withRelease(product, id)
        withFormat {
            json { renderRESTJSON(text: release) }
            xml { renderRESTXML(text: release) }
        }
    }

    @Secured('inProduct()')
    def show() {
        redirect(action: 'index', controller: controllerName, params: params)
    }

    @Secured(['stakeHolder() or inProduct()'])
    def list(long product) {
        Product _product = Product.withProduct(product)
        def releases = _product.releases
        withFormat {
            html { render status: 200, contentType: 'application/json', text: releases as JSON }
            json { renderRESTJSON(text: releases) }
            xml { renderRESTXML(text: releases) }
        }
    }

    @Secured(['stakeHolder() or inProduct()'])
    def findCurrentOrNextRelease(long product) {
        def release = Release.findCurrentOrNextRelease(product).list()[0]
        withFormat {
            html { render status: 200, contentType: 'application/json', text: release as JSON }
            json { renderRESTJSON(text: release) }
            xml { renderRESTXML(text: release) }
        }
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
