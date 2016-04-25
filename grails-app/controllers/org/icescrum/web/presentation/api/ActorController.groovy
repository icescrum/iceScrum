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

@Secured('inProduct() or stakeHolder()')
class ActorController {

    def actorService
    def springSecurityService

    def index() {
        def actors = Actor.searchAllByTermOrTag(params.long('product'), params.term).sort { Actor actor -> actor.useFrequency }
        withFormat {
            html { render(status: 200, text: actors as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text: actors) }
            xml { renderRESTXML(text: actors) }
        }
    }

    def show(long id, long product) {
        Actor actor = Actor.withActor(product, id)
        withFormat {
            html { render(status: 200, text: actor as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text: actor) }
            xml { renderRESTXML(text: actor) }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def save() {
        def actorParams = params.actor
        if (!actorParams){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        def actor = new Actor()
        try {
            Actor.withTransaction {
                bindData(actor, actorParams, [include: ['name', 'description', 'notes', 'satisfactionCriteria', 'instances', 'expertnessLevel', 'useFrequency']])
                actor.tags = actorParams.tags instanceof String ? actorParams.tags.split(',') : (actorParams.tags instanceof String[] || actorParams.tags instanceof List) ? actorParams.tags : null
                def product = Product.load(params.long('product'))
                actorService.save(actor, product)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: actor as JSON) }
                json { renderRESTJSON(text: actor, status: 201) }
                xml { renderRESTXML(text: actor, status: 201) }
            }
        } catch (RuntimeException e) {
            returnError(exception: e, object: actor)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update() {
        def actorParams = params.actor
        List<Actor> actors = Actor.withActors(params)
        if (!actorParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
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
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: returnData as JSON) }
            json { renderRESTJSON(text: returnData) }
            xml { renderRESTXML(text: returnData) }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete() {
        List<Actor> actors = Actor.withActors(params)
        Actor.withTransaction {
            actors.each { actor ->
                actorService.delete(actor)
            }
            withFormat {
                html { render(status: 200)  }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }
}
