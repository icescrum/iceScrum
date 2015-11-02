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

package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import org.icescrum.core.domain.Backlog
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story

@Secured(['stakeHolder() or inProduct()'])
class BacklogController {

    def springSecurityService

    @Secured(['stakeHolder() or inProduct()'])
    def list(long product, boolean shared) {
        // Temporary stuff to make backlog work (default backlogs)
        def backlogs = Backlog.findAllByProductAndSharedOrOwner(product, shared, springSecurityService.currentUser?.id).list()
        def _product = Product.get(product)
        backlogs << new Backlog(product: _product, shared: true, filter: "{story:{}}", name: 'All')
        backlogs << new Backlog(product: _product, shared: true, filter: "{story:{state:[2,3]}}", name: 'backlog')
        backlogs << new Backlog(product: _product, shared: true, filter: "{story:{state:1}}", name: 'sandbox')
        backlogs << new Backlog(product: _product, shared: true, filter: "{story:{state:7}}", name: 'icebox')
        // End of temporary stuff
        withFormat {
            html { render(status: 200, contentType: 'application/json', text:backlogs as JSON) }
            json { renderRESTJSON(text: backlogs) }
            xml  { renderRESTXML(text: backlogs) }
        }
    }

    @Secured(['stakeHolder() or inProduct()'])
    def view(long product) {
        // Temporary stuff to make backlog work : load stories manually, here only estimated ones
        render(template: "view", model: [stories: Story.search(product, JSON.parse('{story:{state:3}}'))])
        // End of temporary stuff
    }
}