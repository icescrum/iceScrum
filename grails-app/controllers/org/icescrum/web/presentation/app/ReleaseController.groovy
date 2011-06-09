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

import grails.converters.JSON
import org.icescrum.core.domain.Release
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Product
import grails.converters.XML

class ReleaseController {

    def releaseService
    def sprintService
    def storyService

    @Secured('productOwner() or scrumMaster()')
    def update = {
        if (!params.release?.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }
        def release = Release.getInProduct(params.long('product'),params.long('release.id')).list()[0]

        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        // If the version is different, the release has been modified since the last loading
        if (params.long('release.version') != release.version) {
            msg = message(code: 'is.release.object', args: [message(code: 'is.release')])
            returnError(text:msg)
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
                json { render status: 200, text: release as JSON }
                xml { render status: 200, text: release as XML }
            }
        } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def save = {
        def release = new Release(params.release as Map)
        def currentProduct = Product.get(params.product)

        if (params.startDate)
            release.startDate = new Date().parse(message(code: 'is.date.format.short'), params.startDate)
        if (params.endDate)
            release.endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)

        try {
            releaseService.save(release, currentProduct)
            render(status: 200, contentType: 'application/json', text: release as JSON)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { render status: 200, text: release as JSON }
                xml { render status: 200, text: release as XML }
            }
        } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def delete = {
        if (!params.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        try {
            releaseService.delete(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { render status: 200, text: release as JSON }
                xml { render status: 200, text: release as XML }
            }
        } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def close = {
        if (!params.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        try {
            releaseService.close(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { render status: 200, text: release as JSON }
                xml { render status: 200, text: release as XML }
            }
        } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def activate = {
        if (!params.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }
        try {
            releaseService.activate(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: release as JSON }
                json { render status: 200, text: release as JSON }
                xml { render status: 200, text: release as XML }
            }
        } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def autoPlan = {
        if (!params.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        try {
            def plannedStories = storyService.autoPlan(release, params.double('capacity'))
            withFormat {
                html { render status: 200, contentType: 'application/json', text: plannedStories as JSON }
                json { render status: 200, text: [result: 'success'] as JSON }
                xml { render status: 200, text: [result: 'success'] as XML }
            }
        } catch (Exception e) {
            returnError(exception:e,text:message(code: 'is.release.error.not.autoplan'))
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def unPlan = {
        if (!params.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        def sprints = Sprint.findAllByParentRelease(release)
        try {
            def unPlanAllStories = storyService.unPlanAll(sprints, Sprint.STATE_WAIT)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprints: sprints] as JSON }
                json { render status: 200, text: [result: 'success'] as JSON }
                xml { render status: 200, text: [result: 'success'] as XML }
            }
        } catch (RuntimeException e) {
            returnError(exception:e,text:message(code: 'is.release.stories.error.not.dissociate'))
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def generateSprints = {
        if (!params.id) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        try {
            def sprints = sprintService.generateSprints(release)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: sprints as JSON }
                json { render status: 200, text: [result: 'success'] as JSON }
                xml { render status: 200, text: [result: 'success'] as XML }
            }
         } catch (RuntimeException e) {
            returnError(object:release, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }
}
