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
import org.icescrum.core.domain.Story

class SprintController {

    def releaseService
    def sprintService
    def storyService
    def springSecurityService

    @Secured('productOwner() or scrumMaster()')
    def update = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.get(params.long('id'))
        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }
        sprint.properties = params.sprint
        def startDate = params.startDate ? new Date().parse(message(code: 'is.date.format.short'), params.startDate) : sprint.startDate
        def endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)

        try {
            sprintService.update(sprint, startDate, endDate)
            def next = null
            if (params.continue) {
                next = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber + 1, sprint.parentRelease)
            }
            render(status: 200, contentType: 'application/json', text: [sprint: sprint, next: next?.id ?: null] as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def save = {
        def sprint = new Sprint()
        sprint.properties = params.sprint
        def release = Release.get(params.long('id'))

        if (params.startDate)
            sprint.startDate = new Date().parse(message(code: 'is.date.format.short'), params.startDate)
        if (params.endDate)
            sprint.endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)
        try {
            sprintService.save(sprint, release)
            render(status: 200, contentType: 'application/json', text: sprint as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def delete = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.get(params.long('id'))

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        try {
            def deletedSprints = sprintService.delete(sprint)
            render(status: 200, contentType: 'application/json', text: deletedSprints as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }

    }



    @Secured('productOwner() or scrumMaster()')
    def unPlan = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def sprint = Sprint.get(params.long('id'))

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        try {
            def unPlanAllStories = storyService.unPlanAll([sprint])
            render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprint: sprint] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.stories.error.not.dissociate')]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def activate = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.get(params.long('id'))

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        try {
            sprintService.activate(sprint)
            render(status: 200, contentType: 'application/json', text: [sprint: sprint, stories: sprint.stories] as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def close = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.get(params.long('id'))
        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }
        try {
            def unDoneStories = sprint.stories.findAll {it.state != Story.STATE_DONE}
            sprintService.close(sprint)
            render(status: 200, contentType: 'application/json', text: [sprint: sprint, unDoneStories: unDoneStories, stories: sprint.stories] as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }
}
