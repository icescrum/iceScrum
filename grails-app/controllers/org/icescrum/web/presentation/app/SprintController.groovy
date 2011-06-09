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
import grails.converters.XML

class SprintController {

    def releaseService
    def sprintService
    def storyService
    def springSecurityService

    @Secured('productOwner() or scrumMaster()')
    def update = {
        if (!params.id) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!sprint) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }

        // If the version is different, the sprint has been modified since the last loading
        if (params.long('sprint.version') != sprint.version) {
            msg = message(code: 'is.stale.object', args: [message(code: 'is.sprint')])
            returnError(text:msg)
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
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, next: next?.id ?: null] as JSON)  }
                json { render(status: 200, text: sprint as JSON) }
                xml { render(status: 200, text: sprint as XML) }
            }
        } catch (RuntimeException e) {
            returnError(object:sprint, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def save = {
        def sprint = new Sprint()
        sprint.properties = params.sprint
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            returnError(text:message(code: 'is.release.error.not.exist'))
            return
        }

        if (params.startDate)
            sprint.startDate = new Date().parse(message(code: 'is.date.format.short'), params.startDate)
        if (params.endDate)
            sprint.endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)
        try {
            sprintService.save(sprint, release)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: sprint as JSON)  }
                json { render(status: 200, text: sprint as JSON) }
                xml { render(status: 200, text: sprint as XML) }
            }
        } catch (RuntimeException e) {
            returnError(object:sprint, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def delete = {
        if (!params.id) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!sprint) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }

        try {
            def deletedSprints = sprintService.delete(sprint)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: deletedSprints as JSON)  }
                json { render(status: 200, text: 'success' as JSON) }
                xml { render(status: 200, text: 'success' as XML) }
            }
        } catch (RuntimeException e) {
            returnError(object:sprint, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }

    }



    @Secured('productOwner() or scrumMaster()')
    def unPlan = {
        if (!params.id) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }

        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!sprint) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }

        try {
            def unPlanAllStories = storyService.unPlanAll([sprint])
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprint: sprint] as JSON)  }
                json { render(status: 200, text: sprint as JSON) }
                xml { render(status: 200, text: sprint as XML) }
            }
        } catch (RuntimeException e) {
            returnError(text:message(code: 'is.release.stories.error.not.dissociate'), exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def activate = {
        if (!params.id) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!sprint) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }

        try {
            sprintService.activate(sprint)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, stories: sprint.stories] as JSON)  }
                json { render(status: 200, text: sprint as JSON) }
                xml { render(status: 200, text: sprint as XML) }
            }
        } catch (RuntimeException e) {
            returnError(object:sprint, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def close = {
        if (!params.id) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!sprint) {
            returnError(text:message(code: 'is.sprint.error.not.exist'))
            return
        }
        try {
            def unDoneStories = sprint.stories.findAll {it.state != Story.STATE_DONE}
            sprintService.close(sprint)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, unDoneStories: unDoneStories, stories: sprint.stories] as JSON)  }
                json { render(status: 200, text: sprint as JSON) }
                xml { render(status: 200, text: sprint as XML) }
            }
        } catch (RuntimeException e) {
            returnError(object:sprint, exception:e)
        } catch (IllegalStateException e) {
            returnError(exception:e)
        }
    }
}
