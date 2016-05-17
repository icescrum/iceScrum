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
import org.icescrum.core.domain.Backlog
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story

import static grails.async.Promises.task

@Secured(['stakeHolder() or inProduct()'])
class BacklogController {

    def springSecurityService
    def grailsApplication

    @Secured(['stakeHolder() or inProduct()'])
    def index(long product) {
        def backlogs = Backlog.findAllByProductAndShared(Product.load(product), true).findAll { it.isDefault }
        render(status: 200, contentType: 'application/json', text: backlogs as JSON)
    }

    @Secured('stakeHolder() or inProduct()')
    def print(long product, long id, String format) {
        def _product = Product.get(product)
        def backlog = Backlog.get(id)
        def outputFileName = _product.name + '-' + backlog.name
        def stories = Story.search(product, JSON.parse(backlog.filter)).sort { Story story -> story.id }
        if (!stories) {
            returnError(text: message(code: 'is.report.error.no.data'))
        } else {
            return task {
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
    }
}