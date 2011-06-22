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

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import grails.util.GrailsNameUtils
import org.grails.comments.Comment
import org.grails.followable.FollowException
import org.grails.followable.FollowLink
import org.icescrum.core.event.IceScrumStoryEvent
import org.springframework.web.servlet.support.RequestContextUtils
import org.icescrum.core.domain.*
import org.icescrum.core.utils.BundleUtils

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
        if (!params.id) {
            if (springSecurityService.isAjax(request)) {
                def jqCode = jq.jquery(null, "\$.icescrum.renderNotice('${message(code: 'is.story.error.not.exist')}','error');");
                render(status: 400, text: jqCode);
            } else {
                render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            }
            return
        }

        def story = Story.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        def user = springSecurityService.currentUser

        Product product = (Product) story.backlog
        if (product.preferences.hidden && !user) {
            redirect(controller: 'login', params: [ref: "p/${product.pkey}@backlogElement/$story.id"])
            return
        } else if (product.preferences.hidden && !securityService.inProduct(story.backlog.id, springSecurityService.authentication)) {
            render(status: 403)
        } else {
            def activities = story.getActivities()
            // Retrieve the tasks activity links
            if (story.tasks) {
                story.tasks*.getActivities()*.each { activities << it }
            }
            activities = activities.sort { it1, it2 -> it2.dateCreated <=> it1.dateCreated }

            def summary = story.comments + activities
            def permalink = createLink(absolute: true, mapping: "shortURL", params: [product: product.pkey], id: story.id)

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

            summary = summary.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }
            render(view: 'details', model: [
                    story: story,
                    tasksDone: Task.countByParentStoryAndState(story, Task.STATE_DONE),
                    typeCode: BundleUtils.storyTypes[story.type],
                    storyStateCode: BundleUtils.storyStates[story.state],
                    taskStateBundle: BundleUtils.taskStates,
                    activities: activities,
                    comments: story.comments,
                    user: user,
                    summary: summary,
                    pkey: product.pkey,
                    permalink: permalink,
                    locale: RequestContextUtils.getLocale(request),
                    isFollower: isFollower,
                    id: id
            ])
        }
    }

    @Secured('isAuthenticated()')
    def addComment = {
        def poster = springSecurityService.currentUser
        try {
            if (params['comment'] instanceof Map) {
                Comment.withTransaction { status ->
                    try {
                        def story = Story.getInProduct(params.long('product'),params.long('comment.ref')).list()[0]
                        story.addComment(poster, params.comment.body)
                        story.addActivity(poster, 'comment', story.name)
                        story.addFollower(poster)
                    } catch (Exception e) {
                        status.setRollbackOnly()
                    }
                }
            }
        } catch (Exception e) {
            log.error "Error posting comment: ${e.message}"
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error')]] as JSON)
            return
        }
        // Reload the comments
        forward(controller: controllerName, action: 'activitiesPanel', id: params.comment.ref, params: ['tab': 'comments'])
    }

    /**
     * Render a editor for the specified comment.
     */
    @Secured('isAuthenticated()')
    def editCommentEditor = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def story = Story.getInProduct(params.long('product'),params.long('commentable')).list()[0]
        render(template: '/components/commentEditor', plugin: 'icescrum-core', model: [comment: comment, mode: 'edit', commentable: story])
    }

    /**
     * Update a comment content
     */
    def editComment = {
        if (params.comment.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('comment.id'))
        def commentable = Story.getInProduct(params.long('product'),params.long('comment.ref')).list()[0]
        comment.body = params.comment.body
        try {
            comment.save()
            forward(controller: controllerName, action: 'activitiesPanel', id: params.comment.ref, params: [product: params.product, 'tab': 'comments'])
            publishEvent(new IceScrumStoryEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumStoryEvent.EVENT_COMMENT_UPDATED))
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: id, referrerUrl:id+'/'+params.id, id: params.id, product: params.product])
    }

    /**
     * Remove a comment from the comment list of a story
     */
    @Secured('productOwner() or scrumMaster()')
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
        def commentable = Story.getInProduct(params.long('product'),params.long('backlogelement')).list()[0]
        try {
            commentable.removeComment(comment)
            render(text: include(controller: controllerName, action: 'activitiesPanel', id: params.backlogelement, params: [product: params.product, 'tab': 'comments']))
            publishEvent(new IceScrumStoryEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumStoryEvent.EVENT_COMMENT_DELETED))
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def shortURL = {
        redirect(url: is.createScrumLink(controller: 'backlogElement', id: params.id))
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

    /**
     * Content of the activities panel
     */

    def activitiesPanel = {
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
        def activities = story.getActivities()
        // Retrieve the tasks activity links
        if (story.tasks) {
            story.tasks*.getActivities()*.each { activities << it }
        }
        activities = activities.sort { it1, it2 -> it2.dateCreated <=> it1.dateCreated }

        def summary = story.comments + activities
        summary = summary.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }
        render(template: "window/activities",
                model: [activities: activities,
                        taskStateBundle: BundleUtils.taskStates,
                        summary: summary,
                        user: user,
                        comments: story.comments,
                        story: story,
                        id: id,
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
