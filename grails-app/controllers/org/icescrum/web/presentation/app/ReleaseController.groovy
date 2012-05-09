/*
 * Copyright (c) 2011 Kagilum / 2010 iceScrum Technlogies.
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
 *
 */
package org.icescrum.web.presentation.app

import org.icescrum.core.domain.Release

import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Product

import grails.converters.JSON
import grails.converters.XML
import grails.plugins.springsecurity.Secured
import grails.plugin.springcache.annotations.Cacheable

@Secured('inProduct()')
class ReleaseController {

    def releaseService
    def sprintService
    def storyService

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def update = {
        withRelease{ Release release ->
            // If the version is different, the release has been modified since the last loading
            if (params.long('release.version') != release.version) {
                returnError(text:message(code: 'is.stale.object', args: [message(code: 'is.release')]))
                return
            }

            def startDate = params.startDate ? new Date().parse(message(code: 'is.date.format.short'), params.startDate) : release.startDate
            def endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)
            release.properties = params.release

            try {
                releaseService.update(release, startDate, endDate)
                def next = null
                if (params.continue) {
                    next = release.parentProduct.releases.find {it.orderNumber == release.orderNumber + 1}
                }
                withFormat {
                    html { render status: 200, contentType: 'application/json', text: [release: release, next: next?.id ?: null] as JSON }
                    json { renderRESTJSON(release) }
                    xml  { renderRESTXML(release) }
                }
            } catch (IllegalStateException e) {
                returnError(exception:e)
            }catch (RuntimeException e) {
                returnError(object:release, exception:e)
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def save = {
        def release = new Release(params.release as Map)
        def currentProduct = Product.get(params.product)

        if (params.startDate)
            release.startDate = new Date().parse(message(code: 'is.date.format.short'), params.startDate)
        if (params.endDate)
            release.endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)

        try {
            releaseService.save(release, currentProduct)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { renderRESTJSON(release, status: 201) }
                xml  { renderRESTXML(release, status: 201) }
            }
        }catch (IllegalStateException e) {
            returnError(exception:e)
        } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete = {
        withRelease{ Release release ->
            releaseService.delete(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { render status: 204, contentType: 'application/json', text: '' }
                xml  { render status: 204, contentType: 'application/json', text: '' }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close = {
        withRelease{ Release release ->
            releaseService.close(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { renderRESTJSON(release) }
                xml  { renderRESTXML(release) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate = {
        withRelease{ Release release ->
            releaseService.activate(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { renderRESTJSON(release) }
                xml  { renderRESTXML(release) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def autoPlan = {
        withRelease{ Release release ->
            def plannedStories = storyService.autoPlan(release, params.double('capacity'))
            withFormat {
                html { render status: 200, contentType: 'application/json', text: plannedStories as JSON }
                json { renderRESTJSON(plannedStories, status: 201) }
                xml { renderRESTXML(plannedStories, status: 201) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan = {
        withRelease{ Release release ->
            def sprints = Sprint.findAllByParentRelease(release)
            def unPlanAllStories = storyService.unPlanAll(sprints, Sprint.STATE_WAIT)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprints: sprints] as JSON }
                json { render status: 204, contentType: 'application/json', text: '' }
                xml { render status: 204, contentType: 'text/xml', text: '' }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def generateSprints = {
        withRelease{ Release release ->
            def sprints = sprintService.generateSprints(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: sprints as JSON }
                json { renderRESTJSON(sprints, status: 201) }
                xml { renderRESTXML(sprints, status: 201) }
            }
        }
    }

    @Cacheable(cache = 'releaseCache', keyGenerator='releaseKeyGenerator')
    def index = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }

        withRelease{ Release release ->
            withFormat {
                json { renderRESTJSON(release) }
                xml  { renderRESTXML(release) }
            }
        }
    }

    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

}
