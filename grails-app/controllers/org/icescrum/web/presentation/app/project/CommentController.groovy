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
import grails.converters.XML
import grails.plugins.springsecurity.Secured
import grails.util.GrailsNameUtils
import org.grails.comments.Comment
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum.core.event.IceScrumBacklogElementEvent

class CommentController {

    def springSecurityService

    @Secured('inProduct()')
    def show = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
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
            json { renderRESTJSON(text:comment) }
            xml  { renderRESTXML(text:comment) }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def save = {
        def poster = springSecurityService.currentUser
        def commentable = commentableObject
        try {
            if (params['comment'] instanceof Map) {
                Comment.withTransaction { status ->
                    try {
                        commentable.addComment(poster, params.comment.body)
                        commentable.lastUpdated = new Date()
                        commentable.addActivity(poster, 'comment', commentable.name)
                        if (commentable instanceof Story)
                            commentable.addFollower(poster)
                    } catch (Exception e) {
                        status.setRollbackOnly()
                    }
                }
            }
            def comments = commentable.comments
            Comment comment = comments.sort{ it1, it2 -> it1.dateCreated <=> it2.dateCreated }.last()
            def myComment = [class:"Comment",
                    id:comment.id,
                    poster:[username:poster.username, firstName:poster.firstName, lastName:poster.lastName, id:poster.id, email:poster.email],
                    dateCreated:comment.dateCreated,
                    backlogElement:[id:commentable.id, type:GrailsNameUtils.getShortName(commentable.class).toLowerCase()],
                    lastUpdated:comment.lastUpdated,
                    body:comment.body]
            broadcast(function: 'update', message: commentable, channel:'product-'+params.product)
            broadcast(function: 'add', message: myComment, channel:'product-'+params.product)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:myComment as JSON)  }
                json { renderRESTJSON(text:comment) }
                xml  { renderRESTXML(text:comment) }
            }
        } catch (Exception e) {
            log.error "Error posting comment: ${e.message}"
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error')]] as JSON)
            return
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def edit = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def commentable = commentableObject
        render(template: '/components/commentEditor', plugin: 'icescrum-core', model: [comment: comment, mode: 'edit', commentable: commentable])
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def update = {
        if (params.comment.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('comment.id'))
        def commentable = commentableObject
        comment.body = params.comment.body
        try {
            comment.save()
            commentable.lastUpdated = new Date()
            publishEvent(new IceScrumBacklogElementEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumBacklogElementEvent.EVENT_COMMENT_UPDATED))
            def poster = comment.getPoster()
            def myComment = [class:"Comment",
                    id:comment.id,
                    poster:[username:poster.username, firstName:poster.firstName, lastName:poster.lastName, id:poster.id, email:poster.email],
                    dateCreated:comment.dateCreated,
                    backlogElement:[id:commentable.id, type:GrailsNameUtils.getShortName(commentable.class).toLowerCase()],
                    lastUpdated:comment.lastUpdated,
                    body:comment.body]
            broadcast(function: 'update', message: commentable, channel:'product-'+params.product)
            broadcast(function: 'update', message: myComment, channel:'product-'+params.product)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:myComment as JSON)  }
                json { renderRESTJSON(text:comment) }
                xml  { renderRESTXML(text:comment) }
            }
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        if (params.commentable == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.backlogelement.error.not.exist')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def commentable = commentableObject
        def id = commentable.id
        def idc = [id:comment.id,backlogElement:[id:id, type:GrailsNameUtils.getShortName(commentable.class).toLowerCase()]]
        try {
            commentable.removeComment(comment)
            commentable.lastUpdated = new Date()
            broadcast(function: 'update', message: commentable, channel:'product-'+params.product)
            broadcast(function: 'delete', message: [class: comment.class, id: comment.id], channel:'product-'+params.product)
            publishEvent(new IceScrumBacklogElementEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumBacklogElementEvent.EVENT_COMMENT_DELETED))
            withFormat {
                html { render status: 200, contentType: 'application/json', text: idc as JSON }
                json { render status: 200, contentType: 'application/json', text: [result:'success'] as JSON }
                xml { render status: 200, contentType: 'text/xml', text: [result:'success']  as XML }
            }
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def editor = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        render(template: '/components/commentEditor', plugin: 'icescrum-core', model: [comment: comment, mode: 'edit', commentable: commentableObject])
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
