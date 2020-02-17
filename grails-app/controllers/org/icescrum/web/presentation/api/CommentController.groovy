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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import grails.util.GrailsNameUtils
import org.grails.comments.Comment
import org.icescrum.core.domain.*
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.security.WorkspaceSecurity

@Secured('permitAll()')
class CommentController implements ControllerErrorHandler, WorkspaceSecurity {

    def springSecurityService
    def commentService

    def index(long workspace, String workspaceType, Long commentable, String type) {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def comments
        def _commentable
        if (commentable) {
            _commentable = commentService.withCommentable(workspace, workspaceType, commentable, type)
            comments = _commentable.comments
        } else {
            if (type == 'feature') {
                if (workspaceType == WorkspaceType.PORTFOLIO) {
                    comments = Feature.recentCommentsInPortfolio(workspace)
                } else if (workspaceType == WorkspaceType.PROJECT) {
                    comments = Feature.recentCommentsInProject(workspace)
                }
            } else if (type == 'task') {
                comments = Task.recentCommentsInProject(workspace)
            } else {
                comments = Story.recentCommentsInProject(workspace)
            }
        }
        render(status: 200, contentType: 'application/json', text: comments.collect { Comment comment ->
            commentService.getRenderableComment(comment, _commentable)
        } as JSON)
    }

    def show(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'stakeHolder() or inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Comment comment = commentService.withComment(workspace, workspaceType, id)
        render(status: 200, contentType: 'application/json', text: commentService.getRenderableComment(comment) as JSON)
    }

    def save(long workspace, String workspaceType) {
        if (!checkPermission(
                project: '((isAuthenticated() and stakeHolder()) or inProject()) and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Comment.withTransaction {
            long commentableId = params.long('comment.commentable.id')
            String commentableType = GrailsNameUtils.getPropertyName(params.comment.commentable.class)
            def _commentable = commentService.withCommentable(workspace, workspaceType, commentableId, commentableType)
            Comment comment = commentService.save(_commentable, ((User) springSecurityService.currentUser), [body: params.comment.body])
            render(status: 201, contentType: 'application/json', text: commentService.getRenderableComment(comment, _commentable) as JSON)
        }
    }

    def update(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'isAuthenticated() and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Comment.withTransaction {
            def comment = commentService.withComment(workspace, workspaceType, id)
            if (comment.posterId != springSecurityService.currentUser.id) {
                render(status: 403)
                return
            }
            commentService.update(comment, [body: params.comment.body])
            render(status: 200, contentType: 'application/json', text: commentService.getRenderableComment(comment) as JSON)
        }
    }

    def delete(long id, long workspace, String workspaceType) {
        if (!checkPermission(
                project: 'isAuthenticated() and !archivedProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Comment.withTransaction {
            def comment = commentService.withComment(workspace, workspaceType, id)
            if ((workspaceType == WorkspaceType.PROJECT && !request.productOwner && !request.scrumMaster || workspaceType == WorkspaceType.PORTFOLIO && !request.businessOwner) && comment.posterId != springSecurityService.currentUser.id) {
                render(status: 403)
                return
            }
            commentService.delete(comment)
            render(status: 204)
        }
    }
}
