/*
 * Copyright (c) 2015 Kagilum SAS
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

package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import org.icescrum.core.error.ControllerErrorHandler

@Secured('inProduct() or stakeHolder()')
class ActorController implements ControllerErrorHandler {

    def actorService
    def springSecurityService

    def index(long product) {
        render(status: 200, text: Actor.search(product, params.term) as JSON, contentType: 'application/json')
    }

    def show(long id, long product) {
        render(status: 200, text: Actor.withActor(product, id) as JSON, contentType: 'application/json')
    }

    @Secured('productOwner() and !archivedProduct()')
    def save(long product) {
        def actorParams = params.actor
        if (!actorParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        Actor.withTransaction {
            Actor actor = new Actor(name: actorParams.name);
            Product _product = Product.load(product)
            actorService.save(actor, _product)
            render(status: 201, contentType: 'application/json', text: actor as JSON)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update(long id, long product) {
        def actorParams = params.actor
        if (!actorParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        Actor actor = Actor.withActor(product, id)
        Actor.withTransaction {
            actor.name = actorParams.name
            actorService.update(actor)
        }
        render(status: 200, contentType: 'application/json', text: actor as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete() {
        List<Actor> actors = Actor.withActors(params)
        Actor.withTransaction {
            actors.each { actor ->
                actorService.delete(actor)
            }
            render(status: 200)
        }
    }
}
