/*
 * Copyright (c) 2017 Kagilum.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.TimeBoxNotesTemplate
import org.icescrum.core.error.ControllerErrorHandler

class TimeBoxNotesTemplateController implements ControllerErrorHandler {

    def timeBoxNotesTemplateService

    @Secured('inProject()')
    def index(long project, String term) {
        Project _project = Project.withProject(project)
        def searchTerm = term ? '%' + term.trim().toLowerCase() + '%' : '%%'
        def timeBoxNotesTemplates = TimeBoxNotesTemplate.findAllByParentProjectAndNameIlike(_project, searchTerm)
        render(status: 200, contentType: 'application/json', text: timeBoxNotesTemplates as JSON)
    }

    @Secured('inProject()')
    def show(long project, long id) {
        TimeBoxNotesTemplate template = TimeBoxNotesTemplate.withTimeBoxNotesTemplate(project, id)
        render(status: 200, contentType: 'application/json', text: template as JSON)
    }

    @Secured('inProject()')
    def save(long project) {
        Project _project = Project.withProject(project)
        def templateParams = params.timeBoxNotesTemplate
        if (templateParams.configsData) {
            templateParams.configs = JSON.parse(templateParams.configsData)
            templateParams.remove('configsData')
        }
        def template = new TimeBoxNotesTemplate()
        TimeBoxNotesTemplate.withTransaction {
            bindData(template, templateParams, [include: ['header', 'footer', 'name']])
            if (templateParams.configs) {
                template.setConfigs(templateParams.configs as List)
            }
            timeBoxNotesTemplateService.save(template, _project)
        }
        render(status: 201, contentType: 'application/json', text: template as JSON)
    }

    @Secured('inProject()')
    def update(long project, long id) {
        def templateParams = params.timeBoxNotesTemplate
        TimeBoxNotesTemplate template = TimeBoxNotesTemplate.withTimeBoxNotesTemplate(project, id)
        if (templateParams.configsData) {
            templateParams.configs = JSON.parse(templateParams.configsData)
            templateParams.remove('configsData')
        }
        TimeBoxNotesTemplate.withTransaction {
            bindData(template, templateParams, [include: ['header', 'footer', 'name']])
            if (templateParams.configs) {
                template.setConfigs(templateParams.configs as List)
            }
            timeBoxNotesTemplateService.update(template)
        }
        render(status: 200, contentType: 'application/json', text: template as JSON)
    }

    @Secured('inProject()')
    def delete(long project, long id) {
        TimeBoxNotesTemplate template = TimeBoxNotesTemplate.withTimeBoxNotesTemplate(project, id)
        timeBoxNotesTemplateService.delete(template)
        withFormat {
            html {
                render(status: 200, contentType: 'application/json', text: [id: id] as JSON)
            }
            json {
                render(status: 204)
            }
        }
    }

    @Secured('inProject()')
    def releaseNotes(long project, long id, long templateId) {
        Release release = Release.withRelease(project, id)
        TimeBoxNotesTemplate template = TimeBoxNotesTemplate.withTimeBoxNotesTemplate(project, templateId)
        def computedNotes = timeBoxNotesTemplateService.computeReleaseNotes(release, template)
        render(status: 200, contentType: 'text/plain', text: computedNotes)
    }

    @Secured('inProject()')
    def sprintNotes(long project, long id, long templateId) {
        Sprint sprint = Sprint.withSprint(project, id)
        TimeBoxNotesTemplate template = TimeBoxNotesTemplate.withTimeBoxNotesTemplate(project, templateId)
        def computedNotes = timeBoxNotesTemplateService.computeSprintNotes(sprint, template)
        render(status: 200, contentType: 'text/plain', text: computedNotes)
    }
}