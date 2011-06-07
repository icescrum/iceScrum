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

class ReleaseController {

    def releaseService
    def sprintService
    def storyService

    @Secured('productOwner() or scrumMaster()')
    def update = {
        if (!params.release.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }
        def release = Release.get(params.long('release.id'))

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
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
            render(status: 200, contentType: 'application/json', text: [release: release, next: next?.id ?: null] as JSON)
        } catch (IllegalStateException ise) {
            if (log.debugEnabled) ise.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)

        } catch (RuntimeException re) {
            if (log.debugEnabled) re.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: release)]] as JSON)
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
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)

        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: release)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def delete = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
        }
        def release = Release.get(params.long('id'))

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        try {
            releaseService.delete(release)
            render(status: 200, contentType: 'application/json', text: release as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: release)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def close = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
        }
        def release = Release.get(params.long('id'))

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        try {
            releaseService.close(release)
            render(status: 200, contentType: 'application/json', text: release as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: release)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def activate = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
        }
        def release = Release.get(params.long('id'))

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }
        try {
            releaseService.activate(release)
            render(status: 200, contentType: 'application/json', text: release as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: release)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def autoPlan = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def release = Release.get(params.long('id'))
        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        try {
            def plannedStories = storyService.autoPlan(release, params.double('capacity'))
            render(status: 200, contentType: 'application/json', text: plannedStories as JSON)
        } catch (Exception e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.autoplan')]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def unPlan = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprints = Sprint.findAllByParentRelease(Release.get(params.long('id')))
        try {
            def unPlanAllStories = storyService.unPlanAll(sprints, Sprint.STATE_WAIT)
            render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprints: sprints] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.stories.error.not.dissociate')]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def generateSprints = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def release = Release.get(params.long('id'))

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        try {
            def sprints = sprintService.generateSprints(release)
            render(status: 200, contentType: 'application/json', text: sprints as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }
}
