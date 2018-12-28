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
import org.grails.comments.Comment
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.event.IceScrumEventType
import org.icescrum.core.support.ApplicationSupport

class CommentController implements ControllerErrorHandler {

    def springSecurityService
    def activityService

    @Secured('stakeHolder() or inProject()')
    def index() {
        def commentable = commentableObject
        if (commentable) {
            def comments = commentable.comments.collect { Comment comment -> ApplicationSupport.getRenderableComment(comment, commentable) }
            render(status: 200, contentType: 'application/json', text: comments as JSON)
        } else {
            returnError(code: 'is.ui.backlogelement.comment.error')
        }
    }

    @Secured('stakeHolder() or inProject()')
    def show() {
        if (!params.id) {
            returnError(code: 'is.comment.error.not.exist')
            return
        }
        def comment = Comment.get(params.long('id'))
        if (!comment) {
            returnError(code: 'is.comment.error.not.exist')
            return
        }
        render(status: 200, contentType: 'application/json', text: ApplicationSupport.getRenderableComment(comment) as JSON)
    }

    @Secured('((isAuthenticated() and stakeHolder()) or inProject()) and !archivedProject()')
    def save() {
        def poster = springSecurityService.currentUser
        def commentable = commentableObject
        if (params['comment'] instanceof Map) {
            Comment.withTransaction {
                grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, commentable, ['addComment': null])
                commentable.addComment(poster, params.comment.body)
                activityService.addActivity(commentable, poster, 'comment', commentable.name);
                Comment comment = commentable.comments.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }?.last()
                if (params.type == 'story') {
                    commentable.addToFollowers(poster)
                }
                if (commentable.hasProperty('comments_count')) {
                    commentable.comments_count = commentable.getTotalComments()
                }
                grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['addedComment': comment])
                render(status: 201, contentType: 'application/json', text: ApplicationSupport.getRenderableComment(comment, commentable) as JSON)
            }
        }
    }

    @Secured('isAuthenticated() and !archivedProject()')
    def update() {
        if (params.id == null) {
            returnError(code: 'is.ui.backlogelement.comment.error.not.exists')
            return
        }
        def comment = Comment.get(params.long('id'))
        if (!comment) {
            render(status: 404)
            return
        } else if (comment.posterId != springSecurityService.currentUser.id) {
            render(status: 403)
            return
        }
        def commentable = commentableObject
        comment.body = params.comment.body
        grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, commentable, ['updateComment': comment])
        comment.save()
        grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['updatedComment': comment])
        render(status: 200, contentType: 'application/json', text: ApplicationSupport.getRenderableComment(comment) as JSON)
    }

    @Secured('isAuthenticated() and !archivedProject()')
    def delete() {
        if (params.id == null) {
            returnError(code: 'is.ui.backlogelement.comment.error.not.exists')
            return
        }
        if (params.commentable == null) {
            returnError(code: 'is.backlogelement.error.not.exist')
            return
        }
        def comment = Comment.get(params.long('id'))
        if (!comment) {
            render(status: 404)
            return
        } else if (!request.productOwner && !request.scrumMaster && comment.posterId != springSecurityService.currentUser.id) {
            render(status: 403)
            return
        }
        def commentable = commentableObject
        grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['removeComment': comment])
        commentable.removeComment(comment)
        if (commentable.hasProperty('comments_count')) {
            commentable.comments_count = commentable.getTotalComments()
        }
        grailsApplication.mainContext[params.type + 'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['removedComment': comment])
        render(status: 204)
    }

    private getCommentableObject() {
        def commentable
        long project = params.long('project')
        long commentableId = params.long('commentable')
        switch (params.type) {
            case 'story':
                commentable = Story.getInProject(project, commentableId).list()
                break
            case 'task':
                commentable = Task.getInProject(project, commentableId)
                break
            default:
                commentable = null
        }
        commentable
    }
}
