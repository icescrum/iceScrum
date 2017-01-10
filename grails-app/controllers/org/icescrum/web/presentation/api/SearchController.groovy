/*
 * Copyright (c) 2014 Kagilum SAS
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.api

import org.grails.taggable.Tag
import grails.converters.JSON
import org.icescrum.core.domain.BacklogElement
import org.icescrum.core.domain.Project
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.error.ControllerErrorHandler

@Secured('inProject() or (isAuthenticated() and stakeHolder())')
class SearchController implements ControllerErrorHandler {

    def springSecurityService

    def tag(long project) {
        Project _project = Project.withProject(project)
        if ((_project.preferences.hidden && !request.inProject) || (!_project.preferences.hidden && !springSecurityService.isLoggedIn())){
            render (status:403, text:'')
            return
        }
        String findTagsByTermAndProject = """SELECT DISTINCT tagLink.tag.name
                   FROM org.grails.taggable.TagLink tagLink
                   WHERE (
                            tagLink.tagRef IN (SELECT story.id From Story story where story.backlog.id = :project)
                          OR tagLink.tagRef IN (SELECT feature.id From Feature feature where feature.backlog.id = :project)
                   )
                   AND tagLink.tag.name LIKE :term
                   ORDER BY tagLink.tag.name"""

        String findTagsByTermAndProjectInTasks = """SELECT DISTINCT tagLink.tag.name
                   FROM Task task, org.grails.taggable.TagLink tagLink
                   WHERE task.id = tagLink.tagRef
                   AND tagLink.type = 'task'
                   AND task.backlog.id IN (select sprint.id from Sprint sprint, Release release WHERE sprint.parentRelease.id = release.id AND release.parentProject.id = :project)
                   AND tagLink.tag.name LIKE :term
                   ORDER BY tagLink.tag.name"""

        def term = params.term
        if (params.withKeyword) {
            if (BacklogElement.hasTagKeyword(term)) {
                term = BacklogElement.removeTagKeyword(term)
            }
        }

        if (term == null) {
            term = '%'
        }

        def tags = Tag.executeQuery(findTagsByTermAndProject, [term: term +'%', project: _project.id])
        tags.addAll(Tag.executeQuery(findTagsByTermAndProjectInTasks, [term: term +'%', project: _project.id]))
        tags.unique()

        if (params.withKeyword) {
            tags = tags.collect { BacklogElement.TAG_KEYWORD + it }
        }

        render(tags as JSON)
    }
}
