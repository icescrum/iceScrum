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

import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils

import grails.converters.JSON
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class ActorController {
    def actorService
    def springSecurityService

    @Cacheable(cache = 'searchActors', keyGenerator = 'actorsKeyGenerator')
    def search = {
        def actors = Actor.searchAllByTermOrTag(params.long('product'), params.term)
        def result = actors.collect({ [name: it.name, uid: it.uid] })
        render(result as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def save = {
        // TODO error if no data
        // Transaction ?
        def actor = new Actor()
        bindData(actor, this.params, [include: ['name', 'description', 'notes', 'satisfactionCriteria', 'instances', 'expertnessLevel', 'useFrequency']], "actor")
        def product = Product.load(params.product)
        try {
            actorService.save(actor, product)
            actor.tags = params.actor.tags instanceof String ? params.actor.tags.split(',') : (params.actor.tags instanceof String[] || params.actor.tags instanceof List) ? params.actor.tags : null
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: actor as JSON) }
                json { renderRESTJSON(text: actor, status: 201) }
                xml { renderRESTXML(text: actor, status: 201) }
            }
        } catch (RuntimeException e) {
            returnError(exception: e, object: actor)
        } catch (AttachmentException e) {
            returnError(exception: e)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update = {
        // TODO error if no data
        // Transaction
        withActor { Actor actor ->
            bindData(actor, this.params, [include: ['name', 'description', 'notes', 'satisfactionCriteria', 'instances', 'expertnessLevel', 'useFrequency']], "actor")
            if (params.actor.tags != null) {
                actor.tags = params.actor.tags instanceof String ? params.actor.tags.split(',') : (params.actor.tags instanceof String[] || params.actor.tags instanceof List) ? params.actor.tags : null
            }
            actorService.update(actor)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: actor as JSON) }
                json { renderRESTJSON(text: actor) }
                xml { renderRESTXML(text: actor) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete = {
        // TODO Transaction ?
        withActors { List<Actor> actors ->
            actors.each { actor ->
                actorService.delete(actor)
            }
            def ids = []
            params.list('id').each { ids << [id: it] }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: ids as JSON) }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    // TODO cache
    def list = {
        def actors = Actor.searchAllByTermOrTag(params.long('product'), params.term).sort { Actor actor -> actor.useFrequency }
        withFormat {
            html { render(status: 200, text: actors as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text: actors) }
            xml { renderRESTXML(text: actors) }
        }
    }

    def show = {
        redirect(action: 'index', controller: controllerName, params: params)
    }

    @Cacheable(cache = 'actorCache', keyGenerator = 'actorKeyGenerator')
    def index = {
        if (request?.format == 'html') {
            render(status: 404)
            return
        }
        withActor { Actor actor ->
            withFormat {
                json { renderRESTJSON(text: actor) }
                xml { renderRESTXML(text: actor) }
            }
        }
    }

    // TODO cache
    def view = {
        render(template: "${params.type ?: 'window'}/view")
    }

    // TODO cache
    def right = {
        render template: "window/right", model: [exportFormats: getExportFormats()]
    }

    def print = {
        def currentProduct = Product.load(params.product)
        def data = []
        def actors = Actor.findAllByBacklog(currentProduct, [sort: 'useFrequency', order: 'asc']);
        if (!actors) {
            returnError(text: message(code: 'is.report.error.no.data'))
            return
        } else if (params.get) {
            actors.each {
                data << [
                        uid: it.uid,
                        name: it.name,
                        description: it.description,
                        notes: it.notes?.replaceAll(/<.*?>/, ''),
                        expertnessLevel: message(code: BundleUtils.actorLevels[it.expertnessLevel]),
                        satisfactionCriteria: it.satisfactionCriteria,
                        useFrequency: message(code: BundleUtils.actorFrequencies[it.useFrequency]),
                        instances: BundleUtils.actorInstances[it.instances],
                        associatedStories: Story.countByActor(it)
                ]
            }
            outputJasperReport('actors', params.format, [[product: currentProduct.name, actors: data ?: null]], currentProduct.name)
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            def dialog = g.render(template: '/scrumOS/report')
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def attachments = {
        withActor { actor ->
            manageAttachmentsNew(actor)
        }
    }
}
