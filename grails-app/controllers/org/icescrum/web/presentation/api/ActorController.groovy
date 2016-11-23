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

import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.error.ControllerErrorHandler

@Secured('inProduct() or stakeHolder()')
class ActorController implements ControllerErrorHandler {

    def actorService
    def springSecurityService

    def index(long product) {
        def actors = Actor.searchAllByTermOrTag(product, params.term)
        render(status: 200, text: actors as JSON, contentType: 'application/json')
    }

    def show(long id, long product) {
        Actor actor = Actor.withActor(product, id)
        render(status: 200, text: actor as JSON, contentType: 'application/json')
    }

    @Secured('productOwner() and !archivedProduct()')
    def save(long product) {
        def actorParams = params.actor
        if (!actorParams){
            returnError(code:'todo.is.ui.no.data')
            return
        }
        def actor = new Actor()
        Actor.withTransaction {
            bindData(actor, actorParams, [include: ['name', 'description', 'notes', 'satisfactionCriteria', 'instances', 'expertnessLevel', 'useFrequency']])
            actor.tags = actorParams.tags instanceof String ? actorParams.tags.split(',') : (actorParams.tags instanceof String[] || actorParams.tags instanceof List) ? actorParams.tags : null
            Product _product = Product.load(product)
            actorService.save(actor, _product)
        }
        render(status: 201, contentType: 'application/json', text: actor as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def update() {
        def actorParams = params.actor
        List<Actor> actors = Actor.withActors(params)
        if (!actorParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        actors.each { Actor actor ->
            Actor.withTransaction {
                bindData(actor, actorParams, [include: ['name', 'description', 'notes', 'satisfactionCriteria', 'instances', 'expertnessLevel', 'useFrequency']])
                if (actorParams.tags != null) {
                    actor.tags = actorParams.tags instanceof String ? actorParams.tags.split(',') : (actorParams.tags instanceof String[] || actorParams.tags instanceof List) ? actorParams.tags : null
                }
                actorService.update(actor)
            }
        }
        def returnData = actors.size() > 1 ? actors : actors.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
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
