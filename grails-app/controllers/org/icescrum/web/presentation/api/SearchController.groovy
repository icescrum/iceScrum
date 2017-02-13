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

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.grails.taggable.Tag
import org.icescrum.core.domain.Project
import org.icescrum.core.error.ControllerErrorHandler

@Secured('inProject() or (isAuthenticated() and stakeHolder())')
class SearchController implements ControllerErrorHandler {

    def springSecurityService

    def tag(long project, String term) {
        Project _project = Project.withProject(project)
        if ((_project.preferences.hidden && !request.inProject) || (!_project.preferences.hidden && !springSecurityService.isLoggedIn())) {
            render(status: 403, text: '')
            return
        }
        def tags = Tag.executeQuery("""
            SELECT DISTINCT tagLink.tag.name
            FROM org.grails.taggable.TagLink tagLink
            WHERE (
                (
                    tagLink.tagRef IN (
                        SELECT story.id
                        FROM Story story
                        WHERE story.backlog.id = :project
                    )
                    AND tagLink.type = 'story'
                )
                OR (
                    tagLink.tagRef IN (
                        SELECT feature.id
                        FROM Feature feature
                        WHERE feature.backlog.id = :project
                    )
                    AND tagLink.type = 'feature'
                )
                OR (
                    tagLink.tagRef IN (
                        SELECT task.id
                        FROM Task task
                        WHERE task.parentProject.id = :project
                    )
                    AND tagLink.type = 'task'
                )
            )
            AND tagLink.tag.name LIKE :term
            ORDER BY tagLink.tag.name
        """, [term: (term ?: '%') + '%', project: _project.id])
        render(tags as JSON)
    }
}