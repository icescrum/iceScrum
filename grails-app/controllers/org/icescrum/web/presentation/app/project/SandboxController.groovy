/*
 * Copyright (c) 2012/2014 Kagilum SAS
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

import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Product

@Secured('stakeHolder() or inProduct()')
class SandboxController {

    def springSecurityService

    def index = {
        withProduct { Product product ->
            render(template: "${params.type ?: 'window'}/view", model: [stories: Story.findAllByBacklogAndState(product,Story.STATE_SUGGESTED)])
        }
    }

    def print = {
        withProduct { Product product ->
            def data = []
            def stories = Story.findAllByBacklogAndState(product, Story.STATE_SUGGESTED, [sort: 'suggestedDate', order: 'desc'])
            if (!stories) {
                returnError(text:message(code: 'is.report.error.no.data'))
                return
            } else if (params.get) {
                stories.each {
                    data << [
                            uid: it.uid,
                            name: it.name,
                            description: it.description,
                            notes: it.notes?.replaceAll(/<.*?>/, ''),
                            type: message(code: BundleUtils.storyTypes[it.type]),
                            suggestedDate: it.suggestedDate,
                            creator: it.creator.firstName + ' ' + it.creator.lastName,
                            feature: it.feature?.name,
                    ]
                }
                outputJasperReport('sandbox', params.format, [[product: product.name, stories: data ?: null]], product.name)
            } else if (params.status) {
                render(status: 200, contentType: 'application/json', text: session.progress as JSON)
            } else {
                session.progress = new ProgressSupport()
                def dialog = g.render(template: '/scrumOS/report')
                render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
            }
        }
    }
}
