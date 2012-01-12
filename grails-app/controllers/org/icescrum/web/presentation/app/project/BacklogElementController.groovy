/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.event.IceScrumStoryEvent

import org.icescrum.core.utils.BundleUtils

import grails.converters.JSON
import grails.converters.XML
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import grails.util.GrailsNameUtils
import org.grails.comments.Comment
import org.grails.followable.FollowException
import org.grails.followable.FollowLink
import org.springframework.web.servlet.support.RequestContextUtils
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Task

class BacklogElementController {

    static ui = true

    static final id = 'backlogElement'
    static menuBar = [title: 'is.ui.backlogelement', show: {false}]
    static window = [title: 'is.ui.backlogelement', toolbar: true, init: 'details']

    def storyService
    def commentService
    def springSecurityService
    def securityService

    /**
     * Render the toolbar of the window
     */
    def toolbar = {
        if (!params.id) {
            render(text: '')
            return
        }
        def user = null
        if (springSecurityService.isLoggedIn())
            user = User.load(springSecurityService.principal.id)
        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        // Cannot proceed if we don't have a story
        if (!story) {
            render(text: '')
            return
        }

        def next
        def previous

        switch (story.state) {
            case Story.STATE_SUGGESTED:
                next = Story.findNextSuggested(story.backlog.id, story.suggestedDate).list()[0] ?: null
                previous = Story.findPreviousSuggested(story.backlog.id, story.suggestedDate).list()[0] ?: null
                break
            case Story.STATE_ACCEPTED:
            case Story.STATE_ESTIMATED:
                next = Story.findNextAcceptedOrEstimated(story.backlog.id, story.rank).list()[0] ?: null
                previous = Story.findPreviousAcceptedOrEstimated(story.backlog.id, story.rank).list()[0] ?: null
                break
            case Story.STATE_PLANNED:
            case Story.STATE_INPROGRESS:
            case Story.STATE_DONE:
                previous = Story.findByParentSprintAndRank(story.parentSprint, story.rank - 1) ?: null
                next = Story.findByParentSprintAndRank(story.parentSprint, story.rank + 1) ?: null
                break
        }
        def sprint = Sprint.findCurrentSprint(params.long('product')).list()[0]
        render(template: 'window/toolbar', model: [id: id, story: story, user: user, next: next, previous: previous, sprint: sprint])
    }

    /**
     * Display the story's information, activities & comments
     */
    def details = {
        if (!params.id && !params.uid) {
            if (springSecurityService.isAjax(request)) {
                def jqCode = jq.jquery(null, "\$.icescrum.renderNotice('${message(code: 'is.story.error.not.exist')}','error');");
                render(status: 400, text: jqCode);
            } else {
                render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            }
            return
        }

        def story = params.id ? Story.getInProduct(params.long("product"), params.long('id')).list()[0] : Story.getInProductUid(params.long("product"), params.int('uid')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        def user = springSecurityService.currentUser

        Product product = (Product) story.backlog
        if (product.preferences.hidden && !user) {
            redirect(controller: 'login', params: [ref: "p/${product.pkey}@backlogElement/$story.id"])
            return
        } else if (product.preferences.hidden && !securityService.inProduct(story.backlog, springSecurityService.authentication) && !securityService.stakeHolder(story.backlog,springSecurityService.authentication,false)) {
            render(status: 403)
        } else {
            def permalink = createLink(absolute: true, mapping: "shortURL", params: [product: product.pkey], id: story.uid)
            def criteria = FollowLink.createCriteria()
            def isFollower = false
            if (user) {
                isFollower = criteria.get {
                    projections {
                        rowCount()
                    }
                    eq 'followRef', story.id
                    eq 'followerId', user.id
                    eq 'type', GrailsNameUtils.getPropertyName(Story.class)
                    cache true
                }
                isFollower = isFollower == 1
            }

            render(view: 'details', model: [
                    story: story,
                    tasksDone: Task.countByParentStoryAndState(story, Task.STATE_DONE),
                    typeCode: BundleUtils.storyTypes[story.type],
                    storyStateCode: BundleUtils.storyStates[story.state],
                    taskStateBundle: BundleUtils.taskStates,
                    user: user,
                    pkey: product.pkey,
                    permalink: permalink,
                    locale: RequestContextUtils.getLocale(request),
                    isFollower: isFollower,
                    id: id
            ])
        }
    }

    @Secured('inProduct()')
    def showComment = {
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
            json { render(status: 200, contentType: 'application/json', text: comment as JSON) }
            xml { render(status: 200, contentType: 'text/xml', text: comment as XML) }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def saveComment = {
        def poster = springSecurityService.currentUser
        def story = Story.getInProduct(params.long('product'),params.long('comment.ref')).list()[0]
        try {
            if (params['comment'] instanceof Map) {
                Comment.withTransaction { status ->
                    try {
                        story.addComment(poster, params.comment.body)
                        story.addActivity(poster, 'comment', story.name)
                        story.addFollower(poster)
                        story.lastUpdated = new Date()
                    } catch (Exception e) {
                        status.setRollbackOnly()
                    }
                }
            }
            broadcast(function: 'update', message: story)
            def comments = story.getComments()
            Comment comment = comments.sort{ it1, it2 -> it1.dateCreated <=> it2.dateCreated }.last()
            def myComment = [id:comment.id,
                             poster:[username:poster.username, firstName:poster.firstName, lastName:poster.lastName, id:poster.id, email:poster.email],
                             dateCreated:comment.dateCreated,
                             backlogElement:story.id,
                             lastUpdated:comment.lastUpdated,
                             body:comment.body]
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:myComment as JSON)  }
                json { render(status: 200, contentType: 'application/json', text: comment as JSON) }
                xml { render(status: 200, contentType: 'text/xml', text: comment as XML) }
            }
        } catch (Exception e) {
            log.error "Error posting comment: ${e.message}"
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error')]] as JSON)
            return
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def editCommentEditor = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def story = Story.getInProduct(params.long('product'),params.long('commentable')).list()[0]
        render(template: '/components/commentEditor', plugin: 'icescrum-core', model: [comment: comment, mode: 'edit', commentable: story])
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def updateComment = {
        if (params.comment.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('comment.id'))
        def commentable = Story.getInProduct(params.long('product'),params.long('comment.ref')).list()[0]
        comment.body = params.comment.body
        try {
            comment.save()
            commentable.lastUpdated = new Date()
            broadcast(function: 'update', message: commentable)
            publishEvent(new IceScrumStoryEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumStoryEvent.EVENT_COMMENT_UPDATED))
            def poster = comment.getPoster()
            def myComment = [id:comment.id,
                             poster:[username:poster.username, firstName:poster.firstName, lastName:poster.lastName, id:poster.id, email:poster.email],
                             dateCreated:comment.dateCreated,
                             backlogElement:commentable.id,
                             lastUpdated:comment.lastUpdated,
                             body:comment.body]
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:myComment as JSON)  }
                json { render(status: 200, contentType: 'application/json', text: comment as JSON) }
                xml { render(status: 200, contentType: 'text/xml', text: comment as XML) }
            }
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: id, referrerUrl:id+'/'+params.id, id: params.id, product: params.product])
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def deleteComment = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        if (params.backlogelement == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def idc = [id:comment.id]
        def commentable = Story.getInProduct(params.long('product'),params.long('backlogelement')).list()[0]
        try {
            commentable.removeComment(comment)
            commentable.lastUpdated = new Date()
            broadcast(function: 'update', message: commentable)
            publishEvent(new IceScrumStoryEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumStoryEvent.EVENT_COMMENT_DELETED))
            withFormat {
                html { render status: 200, contentType: 'application/json', text: idc as JSON }
                json { render status: 200, contentType: 'application/json', text: [result:'success'] as JSON }
                xml { render status: 200, contentType: 'text/xml', text: [result:'success']  as XML }
            }
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def shortURL = {
        redirect(url: is.createScrumLink(controller: 'backlogElement', params:[uid: params.id]))
    }


    def idURL = {

        if (!params.id) {
            if (springSecurityService.isAjax(request)) {
                def jqCode = jq.jquery(null, "\$.icescrum.renderNotice('${message(code: 'is.story.error.not.exist')}','error');");
                render(status: 400, text: jqCode);
            }
            return
        }

        def story = Story.getInProduct(params.long('product'),params.id).list()[0]

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        params.product = story.backlog.id

        redirect(url: is.createScrumLink(controller: 'backlogElement', id: params.id))
    }

    def summaryPanel = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def activities = story.getActivities()
        // Retrieve the tasks activity links
        if (story.tasks) {
            story.tasks*.getActivities()*.each { activities << it }
        }
        def summary = story.comments + activities
        summary = summary.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }
        render(template: "window/summary",
                model: [summary: summary,
                        story: story,
                        product: params.product
                ])
    }

    def taskPanel = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        render(template: "window/tasks",
                model: [taskStateBundle: BundleUtils.taskStates,
                        story: story,
                        product: params.product
                ])
    }

    def testsPanel = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        render(template: "window/tests",
                model: [story: story,
                        product: params.product
                ])
    }

    def commentsPanel = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        render(template: "window/comments",
                model: [story: story,
                        product: params.product
                ])
    }

    @Secured('isAuthenticated()')
    def follow = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        def user = springSecurityService.currentUser

        try {
            story.addFollower(user)
            def followers = story.getTotalFollowers()
            render(status: 200, contentType: 'application/json', text: [followers: followers + " " + message(code: 'is.followable.followers', args: [followers > 1 ? 's' : ''])] as JSON)
        } catch (FollowException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.followable.follow.error')]] as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def unfollow = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        try {
            story.removeLink(springSecurityService.principal.id)
            def followers = story.getTotalFollowers()
            render(status: 200, contentType: 'application/json', text: [followers: followers + " " + message(code: 'is.followable.followers', args: [followers > 1 ? 's' : ''])] as JSON)
        } catch (FollowException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.followable.unfollow.error')]] as JSON)
        }
    }

    def followers = {
        if (params.id == null) {
            return
        }
        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            return
        }
        def followers = story.getTotalFollowers()
        render(status: 200, contentType: 'application/json', text: [followers: followers + " " + message(code: 'is.followable.followers', args: [followers > 1 ? 's' : ''])] as JSON)
    }
}
