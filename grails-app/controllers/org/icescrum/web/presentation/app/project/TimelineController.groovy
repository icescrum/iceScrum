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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils

import grails.converters.JSON
import grails.plugin.cache.Cacheable
import grails.plugin.springsecurity.annotation.Secured

@Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
class TimelineController {

    def productService
    def featureService
    def springSecurityService

    def toolbar() {
        withProduct { Product product ->
            render template: "window/toolbar", model: [id: controllerName, product: product, exportFormats:getExportFormats()]
        }
    }

    @Cacheable('releaseCache') //, keyGenerator = 'releasesRoleKeyGenerator')
    def titleBarContent() {
        def currentProduct = Product.get(params.product);
        def releasesName = []
        def releasesDate = []
        def releasesIds = []
        currentProduct.releases?.sort({a, b -> a.orderNumber <=> b.orderNumber} as Comparator)?.eachWithIndex { itt, index ->
            releasesName << itt.name.encodeAsHTML()
            releasesDate << itt.startDate.getTime()
            releasesIds << itt.id
            itt.sprints?.eachWithIndex { it2, index2 ->
                releasesName << "${itt.name.encodeAsHTML()} - ${message(code: 'is.sprint')} ${index2 + 1}"
                releasesDate << it2.startDate.getTime()
                releasesIds << it2.id
            }
        }

        render(template: 'window/titleBarContent', model: [releasesName: releasesName, releasesDate: releasesDate, currentRelease: params.long('id'), releasesIds: releasesIds])
    }

    @Cacheable('releaseCache') //, keyGenerator = 'releasesKeyGenerator')
    def index() {

        def currentProduct = Product.get(params.product)
        if (!currentProduct.releases) {
            render(template: 'window/blank')
            return
        }

        render(template: 'window/timelineView')
    }

    @Cacheable('releaseCache') //, keyGenerator = 'releasesRoleKeyGenerator')
    def timeLineList() {
        def currentProduct = Product.get(params.product)
        def list = []

        def date = new Date(currentProduct.startDate.getTime() - 1000)
        def startProject = [start: date, end: date, durationEvent: false, classname: "timeline-startproject", trackNum:0]

        list.add(startProject)

        currentProduct.releases.each {
            def color
            def textColor = "#444"
            switch (it.state) {
                case Release.STATE_WAIT:
                    color = "#BBBBBB"
                    break
                case Release.STATE_INPROGRESS:
                    color = "#C8E5FC"
                    break
                case Release.STATE_DONE:
                    color = "#C1FF89"
                    break
            }

            def maxSize = it.duration > 14 ? it.duration - 11 : (it.duration / 3) as Integer
            def encodedName = it.name.encodeAsJavaScript()
            if (encodedName.size() > maxSize) {
                encodedName = encodedName[0..(maxSize-1)].trim() + '...'
            }

            def templateMenu = """<div class='dropmenu-action'>
                                      <div data-dropmenu="true" class="dropmenu" data-top="10" id="rel-${it.id}">
                                        <span class="dropmenu-arrow">!</span>
                                        <div class="dropmenu-content ui-corner-all">
                                            <ul class="small">
                                                ${g.render(template: '/release/menu', model: [release:it])}
                                            </ul>
                                        </div>
                                    </div>
                                  </div><span>${encodedName}</span>"""

            def templateTooltip = include(view: "$controllerName/tooltips/_tooltipReleaseDetails.gsp", model: [release: it])

            def tlR = [window: "releasePlan/${it.id}",
                    start: it.startDate,
                    end: it.endDate,
                    durationEvent: true,
                    title: templateMenu,
                    color: color,
                    textColor: textColor,
                    classname: "timeline-release",
                    eventID: it.id,
                    trackNum:1,
                    tooltipContent: templateTooltip,
                    tooltipTitle: "${it.name.encodeAsHTML()} (${message(code: BundleUtils.releaseStates[it.state])})"]

            list.add(tlR)
            it.sprints.eachWithIndex { it2, index ->
                def colorS
                def textColorS = "#444"
                switch (it2.state) {
                    case Sprint.STATE_WAIT:
                        colorS = "#BBBBBB"
                        break
                    case Sprint.STATE_INPROGRESS:
                        colorS = "#C8E5FC"
                        break
                    case Sprint.STATE_DONE:
                        colorS = "#C1FF89"
                        break
                }
                templateTooltip = include(view: "$controllerName/tooltips/_tooltipSprintDetails.gsp", model: [sprint: it2, user: springSecurityService.currentUser])
                def tlS = [window: "sprintPlan/${it2.id}",
                        start: it2.startDate,
                        end: it2.endDate,
                        durationEvent: true,
                        title: "#${index + 1}",
                        color: colorS,
                        textColor: textColorS,
                        classname: "timeline-sprint",
                        trackNum:2,
                        eventID: it2.id,
                        tooltipContent: templateTooltip,
                        tooltipTitle: "${message(code: 'is.sprint')} ${index + 1} (${message(code: BundleUtils.sprintStates[it2.state])})"]
                list.add(tlS)
                if (it2.deliveredVersion){
                    list.add([start: it2.effectiveEndDate, end: it2.effectiveEndDate, durationEvent: false, title:it2.deliveredVersion,trackNum:3])
                }
            }
        }
        render([dateTimeFormat: "iso8601", events: list] as JSON)
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def add() {
        def currentProduct = Product.get(params.product)
        def previousRelease = currentProduct.releases.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}
        def release = new Release()

        if (previousRelease) {
            release.name = release.name + (previousRelease.orderNumber + 1)
            release.startDate = previousRelease.endDate + 1
            release.endDate = previousRelease.endDate + 1 + 30 * 3
        } else {
            release.startDate = currentProduct.startDate
            release.endDate = currentProduct.startDate + 1 + 30 * 3
        }

        render(template: 'window/manage', model: [
                product: currentProduct,
                release: release,
                previousRelease: previousRelease,
        ])
    }



    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def edit() {
        withRelease{ Release release ->
            def product = release.parentProduct
            def previousRelease = release.previousRelease
            def nextRelease = release.nextRelease

            render(template: 'window/manage', model: [
                    product: product,
                    release: release,
                    next: nextRelease?.id ?: null,
                    previousRelease: previousRelease,
            ])
        }
    }

    def productCumulativeFlowChart() {
        forward controller: 'project', action: 'productCumulativeFlowChart', params: ['controllerName': controllerName]
    }

    def productVelocityCapacityChart() {
        forward controller: 'project', action: 'productVelocityCapacityChart', params: ['controllerName': controllerName]
    }

    def productBurnupChart() {
        forward controller: 'project', action: 'productBurnupChart', params: ['controllerName': controllerName]
    }

    def productBurndownChart() {
        forward controller: 'project', action: 'productBurndownChart', params: ['controllerName': controllerName]
    }

    def productVelocityChart() {
        forward controller: 'project', action: 'productVelocityChart', params: ['controllerName': controllerName]
    }

    def productParkingLotChart() {
        forward controller: 'project', action: 'productParkingLotChart', params: ['controllerName': controllerName]
    }

    /**
     * Export the timeline elements in multiple format (PDF, DOCX, RTF, ODT)
     */
    def print() {
        def currentProduct = Product.get(params.product)
        def data
        def chart = null

        switch (params.locationHash) {
            case 'productCumulativeFlowChart':
                data = productService.cumulativeFlowValues(currentProduct)
                break
            case 'productBurnupChart':
                data = productService.productBurnupValues(currentProduct)
                break
            case 'productBurndownChart':
                data = productService.productBurndownValues(currentProduct)
                break
            case 'productParkingLotChart':
                data = featureService.productParkingLotValues(currentProduct)
                break
            case 'productVelocityChart':
                data = productService.productVelocityValues(currentProduct)
                break
            case 'productVelocityCapacityChart':
                data = productService.productVelocityCapacityValues(currentProduct)
                break
            default:
                chart = 'timeline'
                data = [
                        [
                                releaseStateBundle: BundleUtils.releaseStates,
                                releases: currentProduct.releases,
                                productCumulativeFlowChart: productService.cumulativeFlowValues(currentProduct),
                                productBurnupChart: productService.productBurnupValues(currentProduct),
                                productBurndownChart: productService.productBurndownValues(currentProduct),
                                productParkingLotChart: featureService.productParkingLotValues(currentProduct),
                                productVelocityChart: productService.productVelocityValues(currentProduct),
                                productVelocityCapacityChart: productService.productVelocityCapacityValues(currentProduct)
                        ]
                ]
                break
        }

        if (data.size() <= 0) {
            returnError(text:message(code: 'is.report.error.no.data'))
        } else if (params.get) {
            outputJasperReport(chart ?: 'timeline', params.format, data, currentProduct.name, ['labels.projectName': currentProduct.name])
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            def dialog = g.render(template: '/scrumOS/report')
            render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
        }
    }
}
