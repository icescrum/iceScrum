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
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.support.ProgressSupport
import org.icescrum.core.utils.BundleUtils

import grails.converters.JSON
import grails.converters.XML
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException

@Secured('inProduct()')
class ActorController {
    def actorService
    def springSecurityService

    static ui = true

    static final id = 'actor'
    static menuBar = MenuBarSupport.productDynamicBar('is.ui.actor', id, false, 3)
    static window = [title: 'is.ui.actor', help: 'is.ui.actor.help', init: 'list', toolbar: true]
    static widget = [title: 'is.ui.actor', init: 'list', toolbar: true, height: 143]

    static shortcuts = [
            [code: 'is.ui.shortcut.ctrlf.code', text: 'is.ui.shortcut.ctrlf.text'],
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.del.code', text: 'is.ui.shortcut.actor.del.text'],
            [code: 'is.ui.shortcut.ctrla.code', text: 'is.ui.shortcut.actor.ctrla.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.actor.ctrln.text'],
            [code: 'is.ui.shortcut.space.code', text: 'is.ui.shortcut.actor.space.text']
    ]

    @Cacheable(cache = 'searchActors', keyGenerator = 'actorsKeyGenerator')
    def search = {
        def actors = Actor.findActorByProductAndTerm(params.long('product'), '%' + params.term + '%').list()
        def result = []
        actors?.each {
            result << [label: it.name, value: it.name]
        }
        render(result as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def save = {
        if (!params.actor) return

        def actor = new Actor(params.actor as Map)
        def product = Product.load(params.product)
        try {
            actorService.save(actor, product)
            this.manageAttachments(actor)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: actor as JSON }
                json { render status: 200, contentType: 'application/json', text: actor as JSON }
                xml { render status: 200, contentType: 'text/xml', text: actor  as XML }
            }
        } catch (RuntimeException e) {
            returnError(exception:e, object:actor)
        } catch (AttachmentException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def update = {
        if (!params.actor) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }
        def actor = Actor.getInProduct(params.long('product'),params.long('actor.id')).list()[0]
        if (!actor) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }

        actor.properties = params.actor
        try {
            actorService.update(actor)
            this.manageAttachments(actor)
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
            def next = null
            if (params.continue) {
                def actors = Actor.findAllByBacklog(Product.load(params.product), [sort: 'useFrequency', order: 'asc']);
                def actorIndex = actors.indexOf(actor)
                if (actors.size() > actorIndex + 1)
                    next = actors[actorIndex + 1].id
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: [actor: actor, next: next] as JSON }
                json { render status: 200, contentType: 'application/json', text: actor as JSON }
                xml { render status: 200, contentType: 'text/xml', text: actor  as XML }
            }
        } catch (RuntimeException e) {
            returnError(exception:e, object:actor)
        } catch (AttachmentException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def delete = {
        if (!params.id) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }
        def actors = Actor.getAll(params.list('id'))
        if (!actors) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }

        def msg
        try {
            actors.each { actor ->
                actorService.delete(actor)
            }
            def ids = []
            params.list('id').each { ids << [id: it] }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: ids as JSON }
                json { render status: 200, text: [result:'success'] as JSON }
                xml { render status: 200, text: [result:'success']  as XML }
            }
        } catch (RuntimeException e) {
            returnError(exception:e, text:message(code: 'is.actor.error.not.deleted'))
        } catch (AttachmentException e) {
            returnError(exception:e)
        }
    }

    def changeView = {
        if (!params.id) return
        session['currentView'] = params.id
        def view = include(action: 'list', controller: 'actor', id: params.id)
        render(text: view)
    }

    def list = {
        def actors = params.term ? Actor.findActorByProductAndTerm(params.long('product'), '%' + params.term + '%').list() : Actor.findAllByBacklog(Product.load(params.product), [sort: 'useFrequency', order: 'asc'])
        withFormat{
            html {
                def template = session.widgetsList?.contains(id) ? 'widget/widgetView' : session['currentView'] ? 'window/' + session['currentView'] : 'window/postitsView'
                def frequenciesSelect = BundleUtils.actorFrequencies.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                def instancesSelect = BundleUtils.actorInstances.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                def levelsSelect = BundleUtils.actorLevels.collect {k, v -> "'$k':'${message(code: v)}'" }.join(',')
                render(template: template, model: [
                        actors: actors,
                        id: id,
                        frequenciesSelect: frequenciesSelect,
                        instancesSelect: instancesSelect,
                        levelsSelect: levelsSelect])
            }
            json { render status: 200, contentType: 'application/json', text: actors as JSON }
            xml { render status: 200, contentType: 'text/xml', text: actors  as XML }
         }
    }

    @Secured('productOwner() and !archivedProduct()')
    @Cacheable(cache = 'addActor', keyGenerator = 'localeKeyGenerator')
    def add = {
        render(template: 'window/manage', model: [
                id: id,
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

        if (!params.id) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }

        def actor = Actor.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!actor) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }

        def actors = Actor.findAllByBacklog(Product.load(params.product), [sort: 'useFrequency', order: 'asc']);
        def next = null
        def actorIndex = actors.indexOf(actor)
        if (actors.size() > actorIndex + 1)
            next = actors[actorIndex + 1].id

        render(template: 'window/manage', model: [
                id: id,
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

    private manageAttachments(def actor) {
        def user = springSecurityService.currentUser
        def needPush = false
        if (actor.id && !params.actor.list('attachments') && actor.attachments*.id.size() > 0) {
            actor.removeAllAttachments()
            needPush = true
        } else if (actor.attachments*.id.size() > 0) {
            actor.attachments*.id.each {
                if (!params.actor.list('attachments').contains(it.toString()))
                    actor.removeAttachment(it)
                    needPush = true
            }
        }
        def uploadedFiles = []
        params.list('attachments')?.each { attachment ->
            "${attachment}".split(":").with {
                if (session.uploadedFiles[it[0]])
                    uploadedFiles << [file: new File((String) session.uploadedFiles[it[0]]), name: it[1]]
            }
        }
        if (uploadedFiles){
            actor.addAttachments(user, uploadedFiles)
            needPush = true
        }
        session.uploadedFiles = null
        if (needPush){
            actor.lastUpdated = new Date()
            broadcast(function: 'update', message: actor)
        }
    }

    @Cacheable(cache = 'actorCache', keyGenerator='actorKeyGenerator')
    def show = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }

        if (!params.id) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }

        def actor = Actor.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!actor) {
            returnError(text:message(code: 'is.actor.error.not.exist'))
            return
        }

        withFormat {
                json { render(status: 200, contentType: 'application/json', text: actor as JSON) }
                xml { render(status: 200, contentType: 'text/xml', text: actor as XML) }
            }
    }

    def print = {
        def user = springSecurityService.currentUser

        def currentProduct = Product.load(params.product)
        def data = []
        def actors = Actor.findAllByBacklog(currentProduct, [sort: 'useFrequency', order: 'asc']);
        if (!actors) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.report.error.no.data')]] as JSON)
            return
        } else if (params.get) {
            actors.each {
                data << [
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
            try {
                session.progress = new ProgressSupport()
                session.progress.updateProgress(99, message(code: 'is.report.processing'))
                def model = [[product: currentProduct.name, actors: data ?: null]]
                def fileName = currentProduct.name.replaceAll("[^a-zA-Z\\s]", "").replaceAll(" ", "") + '-' + 'actors' + '-' + (g.formatDate(formatName: 'is.date.file'))
                chain(controller: 'jasper',
                        action: 'index',
                        model: [data: model],
                        params: [locale: user.preferences.language,
                                _format: params.format,
                                _file: 'actors',
                                _name: fileName])

                session.progress?.completeProgress(message(code: 'is.report.complete'))
            } catch (Exception e) {
                if (log.debugEnabled) e.printStackTrace()
                session.progress.progressError(message(code: 'is.report.error'))
            }
        } else if (params.status) {
            render(status: 200, contentType: 'application/json', text: session.progress as JSON)
        } else {
            render(template: 'dialogs/report', model: [id: id])
        }
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }
}
