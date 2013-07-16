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
import org.icescrum.core.domain.BacklogElement
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils

import grails.converters.JSON
import grails.converters.XML
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException

@Secured('inProduct() or (isAuthenticated() and stakeHolder())')
class ActorController {
    def actorService
    def springSecurityService

    @Cacheable(cache = 'searchActors', keyGenerator = 'actorsKeyGenerator')
    def search = {
        def actors = Actor.findAllByProductAndTerm(params.long('product'), '%' + params.term + '%').list()
        def result = []
        actors?.each {
            result << [label: it.name, value: it.name]
        }
        render(result as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def save = {
        if (!params.actor) return

        def actor = new Actor()
        bindData(actor, this.params, [include:['name','description','notes','satisfactionCriteria','instances','expertnessLevel','useFrequency']], "actor")

        def product = Product.load(params.product)
        try {
            actorService.save(actor, product)
            actor.tags = params.actor.tags instanceof String ? params.actor.tags.split(',') : (params.actor.tags instanceof String[] || params.actor.tags instanceof List) ? params.actor.tags : null
            def keptAttachments = params.list('actor.attachments')
            def addedAttachments = params.list('attachments')
            manageAttachments(actor, keptAttachments, addedAttachments)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: actor as JSON }
                json { renderRESTJSON(text:actor, status:201) }
                xml  { renderRESTXML(text:actor, status:201) }
            }
        } catch (RuntimeException e) {
            returnError(exception:e, object:actor)
        } catch (AttachmentException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update = {
        withActor{Actor actor ->

            bindData(actor, this.params, [include:['name','description','notes','satisfactionCriteria','instances','expertnessLevel','useFrequency']], "actor")
            if (params.boolean('manageTags')) {
                actor.tags = params.actor.tags instanceof String ? params.actor.tags.split(',') : (params.actor.tags instanceof String[] || params.actor.tags instanceof List) ? params.actor.tags : null
            }
            actorService.update(actor)
            if (params.boolean('manageAttachments')) {
                def keptAttachments = params.list('actor.attachments')
                def addedAttachments = params.list('attachments')
                manageAttachments(actor, keptAttachments, addedAttachments)
            }
            //if success for table view
            if (params.table && params.boolean('table')) {
                def returnValue
                if (params.name == 'instances')
                    returnValue = message(code: BundleUtils.actorInstances[actor.instances])
                else if (params.name == 'expertnessLevel')
                    returnValue = message(code: BundleUtils.actorLevels[actor.expertnessLevel])
                else if (params.name == 'useFrequency')
                    returnValue = message(code: BundleUtils.actorFrequencies[actor.useFrequency])
                else if (params.name == 'description' || params.name == 'satisfactionCriteria') {
                    returnValue = actor."${params.name}"?.encodeAsHTML()?.encodeAsNL2BR()
                }
                else
                    returnValue = actor."${params.name}".encodeAsHTML()
                def version = actor.isDirty() ? actor.version + 1 : actor.version
                render(status: 200, text: [version: version, value: returnValue ?: ''] as JSON)
                return
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text:actor as JSON }
                json { renderRESTJSON(text:actor) }
                xml  { renderRESTXML(text:actor) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete = {
        withActors{List<Actor> actors ->
            actors.each { actor ->
                actorService.delete(actor)
            }
            def ids = []
            params.list('id').each { ids << [id: it] }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: ids as JSON }
                json { render status: 204 }
                xml { render status: 204 }
            }
        }
    }

    def list = {
        def searchOptions = [actor: [empty:'']] // TODO FIX
        if (params.term) {
            if (params.term.startsWith(BacklogElement.TAG_KEYWORD)) {
                searchOptions.tag = params.term - BacklogElement.TAG_KEYWORD
            } else {
                searchOptions.term = params.term
            }
        }
        def actors = Actor.search(params.long('product'), searchOptions)
        withFormat{
            html {
                def template = params.windowType == 'widget' ? 'widget/widgetView' : params.viewType ? 'window/' + params.viewType : 'window/postitsView'
                def frequenciesSelect = BundleUtils.actorFrequencies.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                def instancesSelect = BundleUtils.actorInstances.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                def levelsSelect = BundleUtils.actorLevels.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                render(template: template, model: [
                        actors: actors,
                        frequenciesSelect: frequenciesSelect,
                        instancesSelect: instancesSelect,
                        levelsSelect: levelsSelect])
            }
            json { renderRESTJSON(text:actors) }
            xml  { renderRESTXML(text:actors) }
         }
    }

    @Secured('productOwner() and !archivedProduct()')
    def add = {
        render(template: 'window/manage', model: [
                instancesValues: BundleUtils.actorInstances.values().collect {v -> message(code: v)},
                instancesKeys: BundleUtils.actorInstances.keySet().asList(),
                levelsValues: BundleUtils.actorLevels.values().collect {v -> message(code: v)},
                levelsKeys: BundleUtils.actorLevels.keySet().asList(),
                frequenciesValues: BundleUtils.actorFrequencies.values().collect {v -> message(code: v)},
                frequenciesKeys: BundleUtils.actorFrequencies.keySet().asList(),
        ])
    }

    @Secured('productOwner() and !archivedProduct()')
    def edit = {
        withActor{ Actor actor ->
            def actors = Actor.findAllByBacklog(Product.load(params.product), [sort: 'useFrequency', order: 'asc']);
            def next = null
            def actorIndex = actors.indexOf(actor)
            if (actors.size() > actorIndex + 1)
                next = actors[actorIndex + 1].id

            render(template: 'window/manage', model: [
                    actor: actor,
                    next: next ?: '',
                    instancesValues: BundleUtils.actorInstances.values().collect {v -> message(code: v)},
                    instancesKeys: BundleUtils.actorInstances.keySet().asList(),
                    levelsValues: BundleUtils.actorLevels.values().collect {v -> message(code: v)},
                    levelsKeys: BundleUtils.actorLevels.keySet().asList(),
                    frequenciesValues: BundleUtils.actorFrequencies.values().collect {v -> message(code: v)},
                    frequenciesKeys: BundleUtils.actorFrequencies.keySet().asList(),
            ])
        }
    }

    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

    @Cacheable(cache = 'actorCache', keyGenerator='actorKeyGenerator')
    def index = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }

        withActor{ Actor actor ->
            withFormat {
                json { renderRESTJSON(text:actor) }
                xml  { renderRESTXML(text:actor) }
            }
        }
    }

    def print = {
        def currentProduct = Product.load(params.product)
        def data = []
        def actors = Actor.findAllByBacklog(currentProduct, [sort: 'useFrequency', order: 'asc']);
        if (!actors) {
            returnError(text:message(code: 'is.report.error.no.data'))
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
                        associatedStories: Story.findAllByTextAsIlike(it.name).size() ?: 0
                ]
            }
            outputJasperReport('actors', params.format, [[product: currentProduct.name, actors: data ?: null]], currentProduct.name)
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            session.progress = new ProgressSupport()
            def dialog = g.render(template: '/scrumOS/report')
            render(status: 200, contentType: 'application/json', text: [dialog:dialog] as JSON)
        }
    }
}
