/*
 * Copyright (c) 2011 Kagilum.
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
package org.icescrum.web.presentation.app

import org.icescrum.core.domain.Story

import org.icescrum.core.utils.BundleUtils
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.User
import grails.converters.JSON
import grails.converters.XML
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import org.grails.followable.FollowLink
import grails.util.GrailsNameUtils
import org.icescrum.core.domain.Task
import org.springframework.web.servlet.support.RequestContextUtils
import org.grails.comments.Comment
import org.icescrum.core.event.IceScrumStoryEvent
import org.grails.followable.FollowException
import org.icescrum.core.domain.AcceptanceTest
import org.grails.taggable.Tag
import org.icescrum.core.domain.BacklogElement
import org.grails.taggable.TagLink

class StoryController {

    def storyService
    def springSecurityService
    def securityService
    def acceptanceTestService

    def toolbar = {
        def id = params.uid?.toInteger() ?: params.id?.toLong() ?: null
        withStory(id, params.uid?true:false) { Story story ->
            def user = null
            if (springSecurityService.isLoggedIn())
                user = User.load(springSecurityService.principal.id)
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
            def sprint = Sprint.findCurrentSprint(params.long('product')).list()
            render(template: 'window/toolbar', model: [story: story, user: user, next: next, previous: previous, sprint: sprint])
        }
    }

    def index = {
        def id = params.uid?.toInteger() ?: params.id?.toLong() ?: null
        withStory(id, params.uid?true:false) { Story story ->
            def user = springSecurityService.currentUser
            Product product = (Product) story.backlog
            if (product.preferences.hidden && !user) {
                redirect(controller: 'login', params: [ref: "p/${product.pkey}#story/$story.id"])
                return
            } else if (product.preferences.hidden && !securityService.inProduct(story.backlog, springSecurityService.authentication) && !securityService.stakeHolder(story.backlog,springSecurityService.authentication,false)) {
                render(status: 403)
            } else {
                 withFormat {
                    json { renderRESTJSON(text:story) }
                    xml  { renderRESTXML(text:story) }
                    html {
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
                        ])
                    }
                }
            }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def save = {

        def story = new Story()
        bindData(story, this.params, [include:['name','description','notes','type','textAs','textICan','textTo']], "story")

        withFormat {
            html {
                if (params.int('displayTemplate') != 1) {
                    story.textAs = null
                    story.textICan = null
                    story.textTo = null
                }
            }
        }

        if (params.feature?.id) {
            def feature = Feature.getInProduct(params.long('product'),params.long('feature.id')).list()
            if (!feature){
                returnError(text:message(code: 'is.feature.error.not.exist'))
                return
            }else{
                story.feature = feature
            }
        }
        def user = springSecurityService.currentUser
        def product = Product.get(params.product)

        try {
            storyService.save(story, product, (User)user)
            this.manageAttachments(story)
            story.tags = params.story.tags instanceof String[] ? params.story.tags : params.story.tags ? [params.story.tags] : null
            withFormat {
                html { render status: 200, contentType: 'application/json', text: story as JSON }
                json { renderRESTJSON(text:story, status:201) }
                xml  { renderRESTXML(text:story, status:201) }
            }
        } catch (AttachmentException e) {
            returnError(exception:e)
        } catch (RuntimeException e) {
            returnError(object:story, exception:e)
        }
    }

    @Secured('isAuthenticated()')
    def update = {
        withStory{ Story story ->
            def user = springSecurityService.currentUser
            if (story.backlog.preferences.archived){
                render(status: 403, contentType: 'application/json')
                return
            }
            def productOwner = securityService.productOwner(story.backlog.id, springSecurityService.authentication)
            if (story.state == Story.STATE_SUGGESTED && !(story.creator.id == user?.id) && !productOwner) {
                render(status: 403, contentType: 'application/json')
                return
            } else if (story.state > Story.STATE_SUGGESTED && !productOwner) {
                render(status: 403, contentType: 'application/json')
                return
            }

            if (params.boolean('loadrich')) {
                render(status: 200, text: story.notes ?: '')
                return
            }

            // If the version is different, the feature has been modified since the last loading
            if (params.story.version && params.story.version.toLong() != story.version) {
                returnError(text:message(code: 'is.stale.object', args: [message(code: 'is.story')]))
                return
            }
            def next = null
            if (params.continue) {
                if (story.state == Story.STATE_SUGGESTED)
                    next = Story.findNextSuggested(params.long('product'), story.suggestedDate, !productOwner ? user.id : null).list()[0]
                else if (story.state <= Story.STATE_ESTIMATED)
                    next = Story.findNextAcceptedOrEstimated(params.long('product'), story.rank).list()[0]
                else if (story.state < Story.STATE_DONE)
                    next = Story.findNextStoryBySprint(story.parentSprint.id, story.rank).list()[0]
            }

            else if(params.story.effort){
                try {
                    storyService.estimate(story,params.story.effort)
                }catch(IllegalStateException e){
                    retunError(text:message(code:e.message))
                    return
                }
            }

            def skipUpdate = false

            if (params.story.rank && story.rank != params.story.rank.toInteger()) {
                Integer rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.isNumber() ? params.story.rank.toInteger() : null
                storyService.rank(story, rank)
                if (params.table && params.boolean('table'))
                    skipUpdate = true
            }

            if (params.sprint?.id != null) {
                if (!params.sprint.id.isNumber() && story.parentSprint)
                    storyService.unPlan(story)
                else if (params.long('sprint.id') != story.parentSprint?.id){
                    def sprint = Sprint.getInProduct(params.long('product'),params.long('sprint.id')).list()
                    if (!sprint){
                        returnError(text:message(code: 'is.sprint.error.not.exist'))
                    }else{
                        storyService.plan(sprint, story)
                    }
                }
                params.story.rank = story.rank
            }

            bindData(story, this.params, [include:['name','description','notes','type','textAs','textICan','textTo']], "story")

            withFormat {
                html {
                    if (params.int('displayTemplate') != 1) {
                        story.textAs = null
                        story.textICan = null
                        story.textTo = null
                        story.actor = null
                    }
                }
            }

            if (params.feature?.id && story.feature?.id != params.long('feature.id')) {
                def feature = Feature.getInProduct(params.long('product'),params.long('feature.id')).list()
                if (!feature)
                    returnError(text:message(code: 'is.feature.error.not.exist'))
                storyService.associateFeature(feature, story)
                if (params.table && params.boolean('table'))
                    skipUpdate = true
            } else if (story.feature && params.feature?.id == '') {
                storyService.dissociateFeature(story)
                if (params.table && params.boolean('table'))
                    skipUpdate = true
            }

            story.tags = params.story.tags instanceof String[] ? params.story.tags : params.story.tags ? [params.story.tags] : request?.format == 'html' ? null : story.tags

            if (!skipUpdate){
                storyService.update(story)
                this.manageAttachments(story)
            }

            //if success for table view
            if (params.table && params.boolean('table')) {
                def returnValue
                if (params.name == 'type')
                    returnValue = message(code: BundleUtils.storyTypes[story.type])
                else if (params.name == 'feature.id')
                    returnValue = is.postitIcon(name: story.feature?.name?.encodeAsHTML() ?: message(code: message(code: 'is.ui.sandbox.manage.chooseFeature')), color: story.feature?.color ?: 'yellow') + (story.feature?.name?.encodeAsHTML() ?: message(code: message(code: 'is.ui.sandbox.manage.chooseFeature')))
                else if (params.name == 'notes') {
                    returnValue = wikitext.renderHtml(markup: 'Textile', text: story."${params.name}")
                }
                else if (params.name == 'description') {
                    returnValue = story.description?.encodeAsHTML()?.encodeAsNL2BR()
                }
                else {
                    if (params.name == 'effort' && story."${params.name}" == null)
                        returnValue = '?'
                    else
                        returnValue = story."${params.name}".encodeAsHTML()
                }
                def version = story.isDirty() ? story.version + 1 : story.version
                render(status: 200, text: [version: version, value: returnValue ?: '', object: story] as JSON)
                return
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: [story: story, next: next?.id ?: null] as JSON }
                json { renderRESTJSON(text:story) }
                xml  { renderRESTXML(text:story) }
            }
        }
    }

    @Secured('isAuthenticated()')
    def delete = {
        withStories{List<Story> stories ->
            def ids = []
            stories.each { ids << [id: it.id, state: it.state] }
            storyService.delete(stories)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: ids as JSON)  }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    @Secured('isAuthenticated()')
    def edit = {
        def id = params.long('subid') ? 'subid' : 'id'
        withStory(id){Story story ->
            if (story.state == Story.STATE_DONE) {
            returnError(text:message(code: 'is.story.error.done'))
                return
            }

            def user = springSecurityService.currentUser
            def productOwner = securityService.productOwner(story.backlog.id, springSecurityService.authentication)

            if (story.state == Story.STATE_SUGGESTED && !(story.creator.id == user.id) && !productOwner) {
                render(status: 403, contentType: 'application/json')
                return
            } else if (story.state > Story.STATE_SUGGESTED && !productOwner) {
                render(status: 403, contentType: 'application/json')
                return
            }

            def product = (Product) story.backlog

            def sprints = []
            def release = Release.findCurrentOrNextRelease(story.backlog.id).list()[0]
            if (story.state >= Story.STATE_ESTIMATED && release) {
                Sprint.findAllByStateNotEqualAndParentRelease(Sprint.STATE_DONE, release, [sort: "orderNumber", order: "asc"])?.each {
                    sprints << [id: it.id, name: message(code: 'is.sprint') + ' ' + it.orderNumber]
                }
            }

            def rankList = []
            def maxRank = 0
            if (story.state >= Story.STATE_ACCEPTED && story.state <= Story.STATE_ESTIMATED) {
                maxRank = Story.countByBacklogAndStateBetween(story.backlog, Story.STATE_ACCEPTED, Story.STATE_ESTIMATED)
            } else if (story.state >= Story.STATE_PLANNED && story.state < Story.STATE_DONE) {
                maxRank = Story.countByParentSprintAndStateNotEqual(story.parentSprint, Story.STATE_DONE)
            }
            maxRank.times { rankList << (it + 1) }

            def tempTxt = [story.textAs, story.textICan, story.textTo]*.trim()
            def isUsedTemplate = (tempTxt != ['null', 'null', 'null'] && tempTxt != ['', '', ''] && tempTxt != [null, null, null])

            def next = null
            if (story.state == Story.STATE_SUGGESTED)
                next = Story.findNextSuggested(params.long('product'), story.suggestedDate, !productOwner ? user.id : null).list()[0]
            else if (story.state <= Story.STATE_ESTIMATED)
                next = Story.findNextAcceptedOrEstimated(params.long('product'), story.rank).list()[0]
            else if (story.state < Story.STATE_DONE)
                next = Story.findNextStoryBySprint(story.parentSprint.id, story.rank).list()[0]

            render(template: '/story/manage', model: [
                    story: story,
                    isUsedTemplate: isUsedTemplate,
                    next: next?.id ?: null,
                    rankList: rankList ?: null,
                    sprints: sprints,
                    typesLabels: BundleUtils.storyTypes.values().collect {v -> message(code: v)},
                    typesKeys: BundleUtils.storyTypes.keySet().asList(),
                    featureSelect: product.features.asList(),
                    referrer: params.referrer,
                    referrerUrl: params.referrerUrl
            ])
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def rank = {
        withStory{ Story story ->
            Integer rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.isNumber() ? params.story.rank.toInteger() : null
            if (story == null || rank == null)
                returnError(text:message(code: 'is.story.rank.error'))
            if (storyService.rank(story, rank)) {
                withFormat {
                    html { render(status: 200)  }
                    json { renderRESTJSON(text:story) }
                    xml { renderRESTXML(text:story) }
                }
            } else {
                returnError(text:message(code: 'is.story.rank.error'))
            }

        }
    }

    @Secured('(teamMember() or scrumMaster()) and !archivedProduct()')
    def estimate = {
        withStory{ Story story ->
            try {
                storyService.estimate(story,params.story.effort)
                withFormat {
                    html { render(status: 200, text: story as JSON)  }
                    json { renderRESTJSON(text:story) }
                    xml  { renderRESTXML(text:story) }
                }
            }catch(IllegalStateException e){
                returnError(text:message(code:e.message))
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def unPlan = {
        withStory { Story story ->
            if (!story.parentSprint){
                returnError(text:message(code:'is.story.error.not.inSprint'))
                return
            }
            def capacity = (story.parentSprint.state == Sprint.STATE_WAIT) ? (story.parentSprint.capacity -= story.effort) : story.parentSprint.capacity
            def sprint = [id: story.parentSprint.id, class: Sprint.class, velocity: story.parentSprint.velocity, capacity: capacity, state: story.parentSprint.state]

            if (params.boolean('shiftToNext')) {
                def nextSprint = Sprint.findByParentReleaseAndOrderNumber(story.parentSprint.parentRelease, story.parentSprint.orderNumber + 1)
                if (nextSprint) {
                    storyService.plan(nextSprint, story)
                } else {
                    returnError(text:message(code: 'is.story.error.not.shiftedToNext'))
                    return
                }
            } else {
                storyService.unPlan(story)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [story: story, sprint: sprint] as JSON)  }
                json { renderRESTJSON(text:story) }
                xml  { renderRESTXML(text:story) }
            }
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def plan = {
        withStory{ Story story ->
            if (story.parentSprint?.id == params.sprint.id?.toLong()) {
                returnError(text:message(code:'is.story.error.same.sprint.planned'))
                return
            }
            withSprint(params.sprint.id.toLong()){ Sprint sprint ->
                def oldSprint = null;
                if (story.parentSprint) {
                    def capacity = (story.parentSprint.state == Sprint.STATE_WAIT) ? (story.parentSprint.capacity - story.effort) : story.parentSprint.capacity
                    oldSprint = [id: story.parentSprint.id, class: Sprint.class, velocity: story.parentSprint.velocity, capacity: capacity, state: story.parentSprint.state]
                }
                storyService.plan(sprint, story)
                if (params.position && params.int('position') != 0) {
                    storyService.rank(story, params.int('position'))
                }
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: [story: story, oldSprint: oldSprint] as JSON)  }
                    json { renderRESTJSON(text:story) }
                    xml  { renderRESTXML(text:story) }
                }
            }
        }
    }

    @Secured('(isAuthenticated()) and !archivedProduct()')
    def associateFeature = {
        withStory{ Story story ->
            withFeature(params.feature.id?.toLong()){ Feature feature ->
                storyService.associateFeature(feature, story)
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: story as JSON)  }
                    json { renderRESTJSON(text:story) }
                    xml  { renderRESTXML(text:story) }
                }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def done = {
        withStory {Story story ->
            storyService.done(story)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: story as JSON)  }
                json { renderRESTJSON(text:story) }
                xml  { renderRESTXML(text:story) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def unDone = {
        withStory {Story story ->
            storyService.unDone(story)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: story as JSON)  }
                json { renderRESTJSON(text:story) }
                xml  { renderRESTXML(text:story) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def accept = {
        def type = params.type instanceof Map ? params.type.value : params.type
        withStories{List<Story> stories ->
            stories = stories.reverse()
            def elements = []
            def storiesIds = stories*.id
            if (type == 'story') {
                elements = storyService.acceptToBacklog(stories)
            } else if (type == 'feature') {
                elements = storyService.acceptToFeature(stories)
            } else if (type == 'task') {
                elements = storyService.acceptToUrgentTask(stories)
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: [id: storiesIds, objects: elements] as JSON)  }
                json { renderRESTJSON(text:elements) }
                xml  { renderRESTXML(text:elements) }
            }
        }
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }

    @Secured('inProduct() and !archivedProduct()')
    def copy = {
        withStories{List<Story> stories ->
            def copiedStories = storyService.copy(stories)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: copiedStories as JSON)  }
                json { renderRESTJSON(text:copiedStories, status: 201) }
                xml  { renderRESTXML(text:copiedStories, status: 201) }
            }
        }
    }

    @Secured('inProduct()')
    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

    @Secured('inProduct()')
    @Cacheable(cache = 'storyCache', keyGenerator='storiesKeyGenerator')
    def list = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        def currentProduct = Product.load(params.product)
        def stories = (params.term) ? Story.findInStories(params.long('product'), '%' + params.term + '%').list() : Story.findAllByBacklog(currentProduct, [sort: 'id', order: 'asc'])
        withFormat {
            json { renderRESTJSON(text:stories) }
            xml  { renderRESTXML(text:stories) }
        }
    }


    private manageAttachments(def story) {
        def user = springSecurityService.currentUser
        def needPush = false
        if (params.story.attachments && story.id && !params.story.list('attachments') && story.attachments*.id.size() > 0) {
            story.removeAllAttachments()
            needPush = true
        } else if (story.attachments*.id.size() > 0) {
            story.attachments*.id.each {
                if (!params.story.list('attachments').contains(it.toString())){
                    story.removeAttachment(it)
                    needPush = true
                }
            }
        }
        def uploadedFiles = []
        params.list('attachments')?.each { attachment ->
            "${attachment}".split(":").with {
                if (session.uploadedFiles[it[0]])
                    uploadedFiles << [file: new File((String) session.uploadedFiles[it[0]]), name: it[1]]
            }
        }
        if (uploadedFiles){
            story.addAttachments(user, uploadedFiles)
            needPush = true
        }
        session.uploadedFiles = null

        if (needPush){
            story.lastUpdated = new Date()
            broadcast(function: 'update', message: story)
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
            json { renderRESTJSON(text:comment) }
            xml  { renderRESTXML(text:comment) }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def saveComment = {
        def poster = springSecurityService.currentUser
        def story = Story.getInProduct(params.long('product'),params.long('comment.ref')).list()
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
            def comments = story.getComments()
            Comment comment = comments.sort{ it1, it2 -> it1.dateCreated <=> it2.dateCreated }.last()
            def myComment = [class:"Comment",
                    id:comment.id,
                    poster:[username:poster.username, firstName:poster.firstName, lastName:poster.lastName, id:poster.id, email:poster.email],
                    dateCreated:comment.dateCreated,
                    backlogElement:story.id,
                    lastUpdated:comment.lastUpdated,
                    body:comment.body]
            broadcast(function: 'update', message: story)
            broadcast(function: 'add', message: myComment)
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
    def editCommentEditor = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def story = Story.getInProduct(params.long('product'),params.long('commentable')).list()
        render(template: '/components/commentEditor', plugin: 'icescrum-core', model: [comment: comment, mode: 'edit', commentable: story])
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def updateComment = {
        if (params.comment.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('comment.id'))
        def commentable = Story.getInProduct(params.long('product'),params.long('comment.ref')).list()
        comment.body = params.comment.body
        try {
            comment.save()
            commentable.lastUpdated = new Date()
            publishEvent(new IceScrumStoryEvent(commentable, comment, this.class, (User) springSecurityService.currentUser, IceScrumStoryEvent.EVENT_COMMENT_UPDATED))
            def poster = comment.getPoster()
            def myComment = [class:"Comment",
                    id:comment.id,
                    poster:[username:poster.username, firstName:poster.firstName, lastName:poster.lastName, id:poster.id, email:poster.email],
                    dateCreated:comment.dateCreated,
                    backlogElement:commentable.id,
                    lastUpdated:comment.lastUpdated,
                    body:comment.body]
            broadcast(function: 'update', message: commentable)
            broadcast(function: 'update', message: myComment)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text:myComment as JSON)  }
                json { renderRESTJSON(text:comment) }
                xml  { renderRESTXML(text:comment) }
            }
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: controllerName, referrerUrl:controllerName+'/'+params.id, id: params.id, product: params.product])
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def deleteComment = {
        if (params.id == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlogelement.comment.error.not.exists')]] as JSON)
            return
        }
        if (params.backlogElement == null) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }
        def comment = Comment.get(params.long('id'))
        def commentable = Story.getInProduct(params.long('product'),params.long('backlogElement')).list()
        def idc = [id:comment.id,backlogElement:commentable.id]
        try {
            commentable.removeComment(comment)
            commentable.lastUpdated = new Date()
            broadcast(function: 'update', message: commentable)
            broadcast(function: 'delete', message: [class: comment.class, id: comment.id])
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
        redirect(url: is.createScrumLink(controller: 'story', params:[uid: params.id]))
    }

    def idURL = {
        if (!params.id) {
            if (springSecurityService.isAjax(request)) {
                def jqCode = jq.jquery(null, "\$.icescrum.renderNotice('${message(code: 'is.story.error.not.exist')}','error');");
                render(status: 400, text: jqCode);
            }
            return
        }
        def story = Story.get(params.id)
        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        params.product = story.backlog.id
        redirect(url: is.createScrumLink(controller: 'story', id: params.id))
    }

    def summaryPanel = {
        withStory { Story story ->
            def activities = story.getActivities()
            if (story.tasks) {
                story.tasks*.getActivities()*.each { activities << it }
            }
            def summary = story.comments + activities
            summary = summary.sort { it1, it2 -> it1.dateCreated <=> it2.dateCreated }
            render(template: "/backlogElement/summary",
                    model: [summary: summary,
                            backlogElement: story,
                            product: Product.get(params.long('product'))
                    ])
        }
    }

    def taskPanel = {
        withStory { Story story ->
            render(template: "window/tasks",
                model: [taskStateBundle: BundleUtils.taskStates,
                        story: story,
                        product: params.product
                ])
        }
    }

    def testsPanel = {
        withStory { Story story ->
            render(template: "window/tests",
                model: [story: story,
                        product: params.product,
                        user: springSecurityService.currentUser
                ])
        }
    }

    def commentsPanel = {
        withStory { Story story ->
            render(template: "window/comments",
                model: [story: story,
                        product: params.product
                ])
        }
    }

    @Secured('isAuthenticated()')
    def follow = {
        withStory { Story story ->
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
    }

    @Secured('isAuthenticated()')
    def unfollow = {
        withStory { Story story ->
            try {
                story.removeLink(springSecurityService.principal.id)
                def followers = story.getTotalFollowers()
                render(status: 200, contentType: 'application/json', text: [followers: followers + " " + message(code: 'is.followable.followers', args: [followers > 1 ? 's' : ''])] as JSON)
            } catch (FollowException e) {
                if (log.debugEnabled) e.printStackTrace()
                render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.followable.unfollow.error')]] as JSON)
            }
        }
    }

    def followers = {
        withStory { Story story ->
            def followers = story.getTotalFollowers()
            render(status: 200, contentType: 'application/json', text: [followers: followers + " " + message(code: 'is.followable.followers', args: [followers > 1 ? 's' : ''])] as JSON)
        }
    }

    @Secured('inProduct()')
    def showAcceptanceTest = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        if (!params.id) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        AcceptanceTest acceptanceTest = AcceptanceTest.get(params.long('acceptanceTest.id'))
        if (!acceptanceTest) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        withFormat {
            json { renderRESTJSON(text:acceptanceTest) }
            xml  { renderRESTXML(text:acceptanceTest) }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def saveAcceptanceTest = {
        withStory { story ->
            def acceptanceTest = new AcceptanceTest()
            bindData(acceptanceTest, this.params, [include:['name','description']], "acceptanceTest")

            User user = (User)springSecurityService.currentUser
            try {
                acceptanceTestService.save(acceptanceTest, story, user)
                withFormat {
                    html { render(status: 200, contentType: 'application/json', text: acceptanceTest as JSON)  }
                    json { renderRESTJSON(text:acceptanceTest) }
                    xml  { renderRESTXML(text:acceptanceTest) }
                }
            }
            catch (RuntimeException e) {
                returnError(object: acceptanceTest, exception: e)
            }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def updateAcceptanceTest = {
        if (!params.acceptanceTest.id) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        AcceptanceTest acceptanceTest = AcceptanceTest.get(params.long('acceptanceTest.id'))
        if (!acceptanceTest) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        def productOwner = securityService.productOwner(acceptanceTest.parentStory.backlog.id, springSecurityService.authentication)
        if (!(acceptanceTest.creator.id == springSecurityService.currentUser.id) && !productOwner) {
            render(status: 403, contentType: 'application/json')
            return
        }
        try {
            acceptanceTest.properties = params.acceptanceTest
            User user = (User)springSecurityService.currentUser
            acceptanceTestService.update(acceptanceTest, user)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: acceptanceTest as JSON)  }
                json { renderRESTJSON(text:acceptanceTest) }
                xml  { renderRESTXML(text:acceptanceTest) }
            }
        } catch (RuntimeException e) {
            returnError(object: acceptanceTest, exception: e)
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def deleteAcceptanceTest = {
        if (params.id == null) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        AcceptanceTest acceptanceTest = AcceptanceTest.get(params.long('id'))
        if (!acceptanceTest) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        def productOwner = securityService.productOwner(acceptanceTest.parentStory.backlog.id, springSecurityService.authentication)
        if (!(acceptanceTest.creator.id == springSecurityService.currentUser.id) && !productOwner) {
            render(status: 403, contentType: 'application/json')
            return
        }
        try {
            def deleted = [id: acceptanceTest.id,parentStory: [id:acceptanceTest.parentStory.id]]
            acceptanceTestService.delete(acceptanceTest)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: deleted as JSON }
                json { render status: 200, contentType: 'application/json', text: [result:'success'] as JSON }
                xml { render status: 200, contentType: 'text/xml', text: [result:'success']  as XML }
            }
        } catch (RuntimeException e) {
            returnError(object: acceptanceTest, exception: e)
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def acceptanceTestEditor = {
        if (params.id == null) {
            returnError(text:message(code: 'is.ui.acceptanceTest.not.exists'))
            return
        }
        def acceptanceTest = AcceptanceTest.get(params.long('id'))
        render(template: '/acceptanceTest/acceptanceTestForm', model: [acceptanceTest: acceptanceTest, parentStory: acceptanceTest.parentStory])
    }
}
