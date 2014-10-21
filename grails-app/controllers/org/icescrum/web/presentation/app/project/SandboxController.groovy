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

import org.icescrum.core.utils.BundleUtils
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Product
import static grails.async.Promises.*

@Secured(['stakeHolder() or inProduct()'])
class SandboxController {

    def index(long product, String type) {
        type = type ?: 'window'
        render(template: "$type/view", model: [stories: Story.findAllByBacklogAndState(Product.load(product),Story.STATE_SUGGESTED)])
    }

    def print(long product, String format) {
        def _product = Product.get(product)
        def stories = Story.findAllByBacklogAndState(_product, Story.STATE_SUGGESTED, [sort: 'suggestedDate', order: 'desc'])
        if (!stories) {
            returnError(text:message(code: 'is.report.error.no.data'))
        } else {
            return task {
                def data = []
                stories.each {
                    data << [
                            uid        : it.uid,
                            name       : it.name,
                            description: it.description,
                            notes      : it.notes?.replaceAll(/<.*?>/, ''),
                            type       : message(code: BundleUtils.storyTypes[it.type]),
                            suggestedDate: it.suggestedDate,
                            creator    : it.creator.firstName + ' ' + it.creator.lastName,
                            feature    : it.feature?.name,
                    ]
                }
                renderReport('sandbox', format ? format.toUpperCase() : 'PDF', [[product: _product.name, stories: data ?: null]], _product.name)
            }
        }
    }

}
