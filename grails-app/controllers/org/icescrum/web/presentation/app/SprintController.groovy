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
import grails.plugin.springsecurity.annotation.Secured

class SprintController {

    def sprintService
    def storyService
    def springSecurityService

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def save(long product) {
        def sprintParams = params.sprint
        def releaseId = params.parentRelease?.id ?: sprintParams.parentRelease?.id
        if (!releaseId) {
            returnError(text: message(code: 'is.release.error.not.exist'))
            return
        }
        Release release = Release.withRelease(product, releaseId.toLong())
        if (sprintParams.startDate) {
            sprintParams.startDate = new Date().parse(message(code: 'is.date.format.short'), sprintParams.startDate)
        }
        if (sprintParams.endDate) {
            sprintParams.endDate = new Date().parse(message(code: 'is.date.format.short'), sprintParams.endDate)
        }
        Sprint sprint = new Sprint()
        try {
            Sprint.withTransaction {
                bindData(sprint, sprintParams, [include: ['resource', 'goal', 'startDate', 'endDate', 'deliveredVersion']])
                sprintService.save(sprint, release)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: sprint as JSON) }
                json { renderRESTJSON(text: sprint, status: 201) }
                xml { renderRESTXML(text: sprint, status: 201) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: sprint, exception: e)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def update() {
        def sprintParams = params.sprint
        withSprint { Sprint sprint ->
            def startDate = sprintParams.startDate ? new Date().parse(message(code: 'is.date.format.short'), sprintParams.startDate) : sprint.startDate
            def endDate = sprintParams.endDate ? new Date().parse(message(code: 'is.date.format.short'), sprintParams.endDate) : sprint.endDate
            Sprint.withTransaction {
                bindData(sprint, sprintParams, [include: ['resource', 'goal', 'deliveredVersion', 'retrospective', 'doneDefinition']])
                sprintService.update(sprint, startDate, endDate)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: sprint as JSON) }
                json { renderRESTJSON(text: sprint) }
                xml { renderRESTXML(text: sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete() {
        withSprint { Sprint sprint ->
            try {
                sprintService.delete(sprint)
                withFormat {
                    html { render(status: 200) }
                    json { render(status: 204) }
                    xml { render(status: 204) }
                }
            } catch (IllegalStateException e) {
                returnError(exception: e)
            } catch (RuntimeException e) {
                returnError(object: sprint, exception: e)
            }
        }
    }


    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan() {
        withSprint { Sprint sprint ->
            def unPlanAllStories = storyService.unPlanAll([sprint])
            withFormat {
                html {
                    render(status: 200, contentType: 'application/json', text: [stories: unPlanAllStories, sprint: sprint] as JSON)
                }
                json { renderRESTJSON(text: sprint) }
                xml { renderRESTXML(text: sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate() {
        withSprint { Sprint sprint ->
            sprintService.activate(sprint)
            withFormat {
                html {
                    render(status: 200, contentType: 'application/json', text: [sprint: sprint, stories: sprint.stories] as JSON)
                }
                json { renderRESTJSON(text: sprint) }
                xml { renderRESTXML(text: sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close() {
        withSprint { Sprint sprint ->
            def unDoneStories = sprint.stories.findAll { it.state != Story.STATE_DONE }
            sprintService.close(sprint)
            withFormat {
                html {
                    render(status: 200, contentType: 'application/json', text: [sprint: sprint, unDoneStories: unDoneStories, stories: sprint.stories] as JSON)
                }
                json { renderRESTJSON(text: sprint) }
                xml { renderRESTXML(text: sprint) }
            }
        }
    }

    @Secured('inProduct()')
    def index() {
        if (request?.format == 'html') {
            render(status: 404)
            return
        }
        withSprint { Sprint sprint ->
            withFormat {
                json { renderRESTJSON(text: sprint) }
                xml { renderRESTXML(text: sprint) }
            }
        }
    }

    @Secured('inProduct()')
    def show() {
        redirect(action: 'index', controller: controllerName, params: params)
    }

    @Secured('stakeHolder()')
    def list(long product, Long releaseId) {
        Release release = releaseId ? Release.withRelease(product, releaseId) : Release.findCurrentOrNextRelease(product).list()[0]
        def sprints = release?.sprints ?: []
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: sprints as JSON) }
            json { renderRESTJSON(text: sprints) }
            xml { renderRESTXML(text: sprints) }
        }
    }
}
