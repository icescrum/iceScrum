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

import grails.util.GrailsNameUtils
import org.icescrum.core.domain.Release

import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story

import grails.converters.JSON
import grails.converters.XML
import grails.plugins.springsecurity.Secured
import grails.plugin.springcache.annotations.Cacheable
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User

@Secured('inProduct()')
class SprintController {

    def sprintService
    def storyService
    def springSecurityService

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def save = {
        def releaseId = params.remove('parentRelease.id') ?: params.sprint.remove('parentRelease.id')
        if (!releaseId){
            returnError(text:message(code:'is.release.error.not.exist'))
            return
        }
        withRelease(releaseId.toLong()){ Release release ->
            Sprint sprint = new Sprint()
            if (params.sprint.startDate)
                params.sprint.startDate = new Date().parse(message(code: 'is.date.format.short'), params.sprint.startDate).toTimestamp()
            if (params.sprint.endDate)
                params.sprint.endDate = new Date().parse(message(code: 'is.date.format.short'), params.sprint.endDate).toTimestamp()
            try {
                bindData(sprint, this.params, [include:['resource','goal','startDate','endDate','deliveredVersion']], "sprint")
                sprintService.save(sprint, release)
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: sprint as JSON)  }
                    json { renderRESTJSON(text:sprint, status:201) }
                    xml  { renderRESTXML(text:sprint, status:201) }
                }
            } catch (IllegalStateException e) {
                release.discard()
                returnError(exception:e)
            } catch (RuntimeException e) {
                release.discard()
                returnError(object:sprint, exception:e)
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def update = {
        withSprint{ Sprint sprint ->
            // If the version is different, the sprint has been modified since the last loading
            if (params.sprint.version && params.long('sprint.version') != sprint.version) {
                def msg = message(code: 'is.stale.object', args: [message(code: 'is.sprint')])
                returnError(text:msg)
                return
            }

            def startDate = params.sprint.startDate ? new Date().parse(message(code: 'is.date.format.short'), params.remove('sprint.startDate') ?: params.sprint.remove('startDate')).toTimestamp() : sprint.startDate
            def endDate = params.sprint.endDate ? new Date().parse(message(code: 'is.date.format.short'), params.remove('sprint.endDate') ?: params.sprint.remove('endDate')).toTimestamp() : sprint.endDate

            bindData(sprint, params, [include:['resource','goal','deliveredVersion']], "sprint")

            sprintService.update(sprint, startDate, endDate)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:sprint as JSON)  }
                json { renderRESTJSON(text:sprint) }
                xml  { renderRESTXML(text:sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete = {
        withSprint{ Sprint sprint ->
            try {
                def deletedSprints = sprintService.delete(sprint)
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: deletedSprints as JSON)  }
                    json { render(status: 204) }
                    xml { render(status: 204) }
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
                json { renderRESTJSON(text: sprint) }
                xml  { renderRESTXML(text: sprint) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate = {
        withSprint{ Sprint sprint ->
            sprintService.activate(sprint)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [sprint: sprint, stories: sprint.stories] as JSON)  }
                json { renderRESTJSON(text:sprint) }
                xml  { renderRESTXML(text:sprint) }
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
                json { renderRESTJSON(text:sprint) }
                xml  { renderRESTXML(text:sprint) }
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
                json { renderRESTJSON(text:sprint) }
                xml  { renderRESTXML(text:sprint) }
            }
        }
    }

    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

    def list = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        if (params.id){
            withRelease { Release release ->
                withFormat {
                    json { renderRESTJSON(text:release.sprints) }
                    xml  { renderRESTXML(text:release.sprints) }
                }
            }
        }else{
            def release = Release.findCurrentOrNextRelease(params.product).list()[0]
            withFormat {
                json { renderRESTJSON(text:release.sprints) }
                xml  { renderRESTXML(text:release.sprints) }
            }
        }
    }

    def attachments = {
        withSprint { Sprint sprint ->
            def keptAttachments = params.list('sprint.attachments')
            def addedAttachments = params.list('attachments')
            def attachments = manageAttachments(sprint, keptAttachments, addedAttachments)
            render status: 200, contentType: 'application/json', text: attachments as JSON
        }
    }
}
