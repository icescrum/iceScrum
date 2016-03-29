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
package org.icescrum.web.presentation.app.project

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.grails.comments.Comment
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.event.IceScrumEventType

class CommentController {

    def springSecurityService
    def activityService

    @Secured('stakeHolder() or inProduct()')
    def index() {
        def commentable = commentableObject
        if (commentable) {
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: commentable.comments as JSON) }
                json { renderRESTJSON(text:commentable.comments) }
                xml  { renderRESTXML(text:commentable.comments) }
            }
        } else {
            returnError(text:message(code: 'is.ui.backlogelement.comment.error'))
        }
    }

    @Secured('stakeHolder() or inProduct()')
    def show() {
        if (!params.id) {
            returnError(text:message(code: 'is.comment.error.not.exist'))
            return
        }
        def comment = Comment.get(params.long('id'))
        if (!comment) {
            returnError(text:message(code: 'is.comment.error.not.exist'))
            return
        }
        withFormat {
            html { render status: 200, contentType: 'application/json', text: comment as JSON }
            json { renderRESTJSON(text: comment) }
            xml  { renderRESTXML(text: comment) }
        }
    }

    @Secured('((isAuthenticated() and stakeHolder()) or inProduct()) and !archivedProduct()')
    def save() {
        def poster = springSecurityService.currentUser
        def commentable = commentableObject
        try {
            Comment comment
            if (params['comment'] instanceof Map) {
                Comment.withTransaction { status ->
                    try {
                        grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, commentable, ['addComment':null])
                        commentable.addComment(poster, params.comment.body)
                        activityService.addActivity(commentable, poster, 'comment', commentable.name);
                        comment = commentable.comments.sort{ it1, it2 -> it1.dateCreated <=> it2.dateCreated }?.last()
                        grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['addedComment':comment])
                        if (params.type == 'story') {
                            commentable.addToFollowers(poster)
                        }
                    } catch (Exception e) {
                        e.printStackTrace()
                        status.setRollbackOnly()
                    }
                }
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:comment as JSON)  }
                json { renderRESTJSON(text:comment) }
                xml  { renderRESTXML(text:comment) }
            }
        } catch (Exception e) {
            returnError(exception:e)
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def update() {
        if (params.id == null) {
            returnError(text:message(code: 'is.ui.backlogelement.comment.error.not.exists'))
            return
        }
        def comment = Comment.get(params.long('id'))
        if (!comment){
            render(status:404)
            return
        } else if (comment.posterId != springSecurityService.currentUser.id){
            render(status:403)
            return
        }
        def commentable = commentableObject
        try {
            comment.body = params.comment.body
            grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.BEFORE_UPDATE, commentable, ['updateComment':comment])
            comment.save()
            grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['updatedComment':comment])
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:comment as JSON)  }
                json { renderRESTJSON(text:comment) }
                xml  { renderRESTXML(text:comment) }
            }
        } catch (RuntimeException e) {
            returnError(exception: e)
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def delete() {
        if (params.id == null) {
            returnError(text:message(code: 'is.ui.backlogelement.comment.error.not.exists'))
            return
        }
        if (params.commentable == null) {
            returnError(text:message(code: 'is.backlogelement.error.not.exist'))
            return
        }
        def comment = Comment.get(params.long('id'))
        if (!comment){
            render(status:404)
            return
        } else if (!request.productOwner && !request.scrumMaster &&  comment.posterId != springSecurityService.currentUser.id){
            render(status:403)
            return
        }
        def commentable = commentableObject
        try {
            grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['removeComment':comment])
            commentable.removeComment(comment)
            grailsApplication.mainContext[params.type+'Service'].publishSynchronousEvent(IceScrumEventType.UPDATE, commentable, ['removedComment':comment])
            withFormat {
                html { render(status: 200)  }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        } catch (RuntimeException e) {
            returnError(exception:e)
        }
    }

    private getCommentableObject(){
        def commentable
        switch (params.type){
            case 'story':
                commentable = Story.getInProduct(params.long('product'),params.long('commentable')).list()
                break
            case 'task':
                commentable = Task.getInProduct(params.long('product'),params.long('commentable'))
                break
            default:
                commentable = null
        }
        commentable
    }
}
