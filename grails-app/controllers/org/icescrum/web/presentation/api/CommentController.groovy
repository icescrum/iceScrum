/*
 * Copyright (c) 2013 Kagilum.
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
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import grails.util.GrailsNameUtils
import org.grails.comments.Comment
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.error.ControllerErrorHandler

class CommentController implements ControllerErrorHandler {

    def springSecurityService
    def commentService

    @Secured('stakeHolder() or inProject()')
    def index(long project, Long commentable, String type) {
        def comments
        def _commentable
        if (commentable) {
            _commentable = commentService.withCommentable(project, commentable, type)
            comments = _commentable.comments
        } else {
            if (type == 'feature') {
                comments = Feature.recentCommentsInProject(project)
            } else if (type == 'task') {
                comments = Task.recentCommentsInProject(project)
            } else {
                comments = Story.recentCommentsInProject(project)
            }
        }
        render(status: 200, contentType: 'application/json', text: comments.collect { Comment comment ->
            commentService.getRenderableComment(comment, _commentable)
        } as JSON)
    }

    @Secured('stakeHolder() or inProject()')
    def show(long id, long project) {
        Comment comment = commentService.withComment(project, id)
        render(status: 200, contentType: 'application/json', text: commentService.getRenderableComment(comment) as JSON)
    }

    @Secured('((isAuthenticated() and stakeHolder()) or inProject()) and !archivedProject()')
    def save(long project) {
        Comment.withTransaction {
            long commentableId = params.long('comment.commentable.id')
            String commentableType = GrailsNameUtils.getPropertyName(params.comment.commentable.class)
            def _commentable = commentService.withCommentable(project, commentableId, commentableType)
            Comment comment = commentService.save(_commentable, ((User) springSecurityService.currentUser), [body: params.comment.body])
            render(status: 201, contentType: 'application/json', text: commentService.getRenderableComment(comment, _commentable) as JSON)
        }
    }

    @Secured('isAuthenticated() and !archivedProject()')
    def update(long id, long project) {
        Comment.withTransaction {
            def comment = commentService.withComment(project, id)
            if (comment.posterId != springSecurityService.currentUser.id) {
                render(status: 403)
                return
            }
            commentService.update(comment, [body: params.comment.body])
            render(status: 200, contentType: 'application/json', text: commentService.getRenderableComment(comment) as JSON)
        }
    }

    @Secured('isAuthenticated() and !archivedProject()')
    def delete(long id, long project) {
        Comment.withTransaction {
            def comment = commentService.withComment(project, id)
            if (!request.productOwner && !request.scrumMaster && comment.posterId != springSecurityService.currentUser.id) {
                render(status: 403)
                return
            }
            commentService.delete(comment)
            render(status: 204)
        }
    }
}
