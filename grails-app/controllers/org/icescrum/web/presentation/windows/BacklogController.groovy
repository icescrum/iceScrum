/*
 * Copyright (c) 2014 Kagilum SAS
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

package org.icescrum.web.presentation.windows

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.Backlog
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.utils.ServicesUtils

@Secured(['stakeHolder() or inProduct()'])
class BacklogController implements ControllerErrorHandler {

    def springSecurityService
    def grailsApplication

    @Secured(['stakeHolder() or inProduct()'])
    def index(long product) {
        def backlogs = Backlog.findAllByProductAndShared(Product.load(product), true).findAll { it.isDefault }.sort { it.id }
        render(status: 200, contentType: 'application/json', text: backlogs as JSON)
    }

    @Secured('stakeHolder() or inProduct()')
    def print(long product, long id, String format) {
        def _product = Product.withProduct(product)
        def backlog = Backlog.get(id)
        def outputFileName = _product.name + '-' + message(code: backlog.name)
        def stories = Story.search(product, JSON.parse(backlog.filter)).sort { Story story -> story.rank }
        if (!stories) {
            returnError(code: 'is.report.error.no.data')
        } else {
            def data = []
            stories.each {
                data << [
                        uid          : it.uid,
                        name         : it.name,
                        description  : it.description,
                        notes        : it.notes?.replaceAll(/<.*?>/, ''),
                        type         : message(code: grailsApplication.config.icescrum.resourceBundles.storyTypes[it.type]),
                        suggestedDate: it.suggestedDate,
                        creator      : it.creator.firstName + ' ' + it.creator.lastName,
                        feature      : it.feature?.name,
                ]
            }
            renderReport('backlog', format ? format.toUpperCase() : 'PDF', [[product: _product.name, stories: data ?: null]], outputFileName)
        }
    }

    @Secured('stakeHolder() or inProduct()')
    def printPostits(long product, long id) {
        Product _product = Product.withProduct(product)
        def backlog = Backlog.get(id)
        def stories1 = []
        def stories2 = []
        def first = 0
        def stories = Story.search(product, JSON.parse(backlog.filter)).sort { Story story -> story.rank }
        if (!stories) {
            returnError(code: 'is.report.error.no.data')
        } else {
            stories.each {
                def testsByState = it.countTestsByState()
                def story = [
                        name          : it.name,
                        id            : it.uid,
                        effort        : it.effort,
                        state         : message(code: grailsApplication.config.icescrum.resourceBundles.storyStates[it.state]),
                        description   : is.storyDescription([story: it, displayBR: true]),
                        notes         : ServicesUtils.textileToHtml(it.notes),
                        type          : message(code: grailsApplication.config.icescrum.resourceBundles.storyTypes[it.type]),
                        suggestedDate : it.suggestedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _product.preferences.timezone, date: it.suggestedDate]) : null,
                        acceptedDate  : it.acceptedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _product.preferences.timezone, date: it.acceptedDate]) : null,
                        estimatedDate : it.estimatedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _product.preferences.timezone, date: it.estimatedDate]) : null,
                        plannedDate   : it.plannedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _product.preferences.timezone, date: it.plannedDate]) : null,
                        inProgressDate: it.inProgressDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _product.preferences.timezone, date: it.inProgressDate]) : null,
                        doneDate      : it.doneDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _product.preferences.timezone, date: it.doneDate ?: null]) : null,
                        rank          : it.rank ?: null,
                        sprint        : it.parentSprint?.index ? g.message(code: 'is.release') + " " + it.parentSprint.parentRelease.orderNumber + " - " + g.message(code: 'is.sprint') + " " + it.parentSprint.index : null,
                        creator       : it.creator.firstName + ' ' + it.creator.lastName,
                        feature       : it.feature?.name ?: null,
                        dependsOn     : it.dependsOn?.name ? it.dependsOn.uid + " " + it.dependsOn.name : null,
                        permalink     : createLink(absolute: true, uri: '/' + _product.pkey + '-' + it.uid),
                        featureColor  : it.feature?.color ?: null,
                        nbTestsTocheck: testsByState[AcceptanceTest.AcceptanceTestState.TOCHECK],
                        nbTestsFailed : testsByState[AcceptanceTest.AcceptanceTestState.FAILED],
                        nbTestsSuccess: testsByState[AcceptanceTest.AcceptanceTestState.SUCCESS]
                ]
                if (first == 0) {
                    stories1 << story
                    first = 1
                } else {
                    stories2 << story
                    first = 0
                }

            }
            renderReport('stories', 'PDF', [[product: _product.name, stories1: stories1 ?: null, stories2: stories2 ?: null]], _product.name)
        }
    }
}