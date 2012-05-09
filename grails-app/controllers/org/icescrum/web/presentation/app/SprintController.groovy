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
import org.icescrum.core.domain.Story

import grails.converters.JSON
import grails.converters.XML
import grails.plugins.springsecurity.Secured
import grails.plugin.springcache.annotations.Cacheable

@Secured('inProduct()')
class SprintController {

    def releaseService
    def sprintService
    def storyService
    def springSecurityService

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def update = {
        withSprint{ Sprint sprint ->
            // If the version is different, the sprint has been modified since the last loading
            if (params.long('sprint.version') != sprint.version) {
                def msg = message(code: 'is.stale.object', args: [message(code: 'is.sprint')])
                returnError(text:msg)
                return
            }

            sprint.properties = params.sprint
            def startDate = params.startDate ? new Date().parse(message(code: 'is.date.format.short'), params.startDate) : sprint.startDate
            def endDate = new Date().parse(message(code: 'is.date.format.short'), params.endDate)

            sprintService.update(sprint, startDate, endDate)
            def next = null
            if (params.continue) {
                next = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber + 1, sprint.parentRelease)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, next: next?.id ?: null] as JSON)  }
                json { renderRESTJSON(sprint) }
                xml  { renderRESTXML(sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
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
                json { renderRESTJSON(sprint, status:201) }
                xml  { renderRESTXML(sprint, status:201) }
            }
        } catch (IllegalStateException e) {
            returnError(exception:e)
        } catch (RuntimeException e) {
            returnError(object:sprint, exception:e)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete = {
        withSprint{ Sprint sprint ->
            try {
                def deletedSprints = sprintService.delete(sprint)
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: deletedSprints as JSON)  }
                    json { render(status: 204, contentType: 'application/json', text: '') }
                    xml { render(status: 204, contentType: 'text/xml', text: '') }
                }
            } catch (IllegalStateException e) {
                returnError(exception:e)
            } catch (RuntimeException e) {
                returnError(object:sprint, exception:e)
            }
        }
    }



    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan = {
        withSprint{ Sprint sprint ->
            def unPlanAllStories = storyService.unPlanAll([sprint])
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprint: sprint] as JSON)  }
                json { render(status: 204, contentType: 'application/json', text: '') }
                xml  { render(status: 204, contentType: 'text/xml', text: '') }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate = {
        withSprint{ Sprint sprint ->
            sprintService.activate(sprint)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, stories: sprint.stories] as JSON)  }
                json { renderRESTJSON(sprint) }
                xml  { renderRESTXML(sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close = {
        withSprint{ Sprint sprint ->
            def unDoneStories = sprint.stories.findAll {it.state != Story.STATE_DONE}
            sprintService.close(sprint)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, unDoneStories: unDoneStories, stories: sprint.stories] as JSON)  }
                json { renderRESTJSON(sprint) }
                xml  { renderRESTXML(sprint) }
            }
        }
    }

    @Cacheable(cache = 'sprintCache', keyGenerator='sprintKeyGenerator')
    def index = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }

        withSprint{ Sprint sprint ->
            withFormat {
                json { renderRESTJSON(sprint) }
                xml  { renderRESTXML(sprint) }
            }
        }
    }

    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }
}
