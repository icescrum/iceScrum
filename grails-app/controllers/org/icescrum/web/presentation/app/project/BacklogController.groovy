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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.PlanningPokerGame

@Secured('stakeHolder() or inProduct()')
class BacklogController {
    def springSecurityService

    def list = {
        def currentProduct = Product.get(params.product)

        def stories = Story.searchByTermOrTagInBacklog(currentProduct, params.term).sort { Story story -> story.rank }
        stories = params.type == 'widget' ? stories.findAll {it.state == Story.STATE_ESTIMATED} : stories
        def suiteSelect = "'?':'?',"
        def currentSuite = PlanningPokerGame.getInteger(currentProduct.planningPokerGameType)

        currentSuite = currentSuite.eachWithIndex { t, i ->
            suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
        }
        render(template: "${params.type ?: 'window'}/view", model: [stories: stories, user: springSecurityService.currentUser])
    }


    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: controllerName, id: params.id, product: params.product])
    }

    def print = {
        def currentProduct = Product.get(params.product)
        def data = []
        def stories = Story.findAllByBacklogAndStateBetween(currentProduct, Story.STATE_ACCEPTED, Story.STATE_ESTIMATED, [cache: true, sort: 'rank'])
        if (!stories) {
            returnError(text:message(code: 'is.report.error.no.data'))
            return
        } else if (params.get) {
            stories.each {
                data << [
                        uid: it.uid,
                        name: it.name,
                        rank: it.rank,
                        effort: it.effort,
                        description: it.description,
                        notes: wikitext.renderHtml([markup: 'Textile', text: it.notes], null),
                        type: message(code: BundleUtils.storyTypes[it.type]),
                        acceptedDate: it.acceptedDate,
                        estimatedDate: it.estimatedDate,
                        creator: it.creator.firstName + ' ' + it.creator.lastName,
                        feature: it.feature?.name,
                ]
            }
            outputJasperReport('backlog', params.format, [[product: currentProduct.name, stories: data ?: null]], currentProduct.name)
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session?.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            def dialog = g.render(template: '/scrumOS/report')
            render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
        }
    }
}