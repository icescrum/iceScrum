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
 * Nicolas Noullet (nnoullet@kagilum.com)
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
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import org.grails.followable.FollowLink
import grails.util.GrailsNameUtils
import org.icescrum.core.domain.Task
import org.springframework.web.servlet.support.RequestContextUtils
import org.grails.followable.FollowException
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState

class StoryController {

    def storyService
    def featureService
    def springSecurityService
    def securityService

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

                        render(view: 'window/details', model: [
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
        if (!params.story){
            returnError(text:message(code:'is.ui.no.data'))
            return
        }
        if (templates[params.template]){
            params.story << templates[params.template]
        }
        if (params.story.'feature.id' == '') {
            params.story.'feature.id' = 'null'
        }
        if (params.story.'dependsOn.id' == '') {
            params.story.'dependsOn.id' = 'null'
        }
        def story = new Story()
        try {
            Story.withTransaction {
                bindData(story, this.params, [include:['name','description','notes','type','affectVersion','feature','dependsOn']], "story")
                def user = (User) springSecurityService.currentUser
                def product = Product.get(params.long('product'))
                storyService.save(story, product, user)
                story.tags = params.story.tags instanceof String ? params.story.tags.split(',') : (params.story.tags instanceof String[] || params.story.tags instanceof List) ? params.story.tags : null
                entry.hook(id:"${controllerName}-${actionName}", model:[story:story])
                withFormat {
                    html { render status: 200, contentType: 'application/json', text: story as JSON }
                    json { renderRESTJSON(text:story, status:201) }
                    xml  { renderRESTXML(text:story, status:201) }
                }
            }

        } catch (AttachmentException e) {
            returnError(exception:e)
        } catch (RuntimeException e) {
            returnError(object:story, exception:e)
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def update = {

        withStories{ List<Story> stories ->

            if (!params.story){
                returnError(text:message(code:'is.ui.no.data'))
                return
            }

            stories.each { Story story ->
                if (!story.canUpdate(request.productOwner, springSecurityService.currentUser)) {
                    render(status: 403)
                    return
                }
                if (params.story.'feature.id' == '') {
                    params.story.'feature.id' = 'null'
                }
                if (params.story.'dependsOn.id' == '') {
                    params.story.'dependsOn.id' = 'null'
                }
                Map props = [:]
                if (params.story.rank != null) {
                    props.rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.toInteger()
                }
                if (params.story.state != null) {
                    props.state = params.story.state instanceof Number ? params.story.state : params.story.state.toInteger()
                }
                if (params.story.effort != null && request.inProduct) {
                    props.effort = params.story.effort // not parsed because it can be a string or a number
                }
                Story.withTransaction {
                    if (params.story.tags != null) {
                        story.tags = params.story.tags instanceof String ? params.story.tags.split(',') : (params.story.tags instanceof String[] || params.story.tags instanceof List) ? params.story.tags : null
                    }
                    if (params.story.'parentSprint.id' == '') {
                        props.parentSprint = null
                    } else {
                        def sprintId = params.story.'parentSprint.id'?.toLong()
                        if (sprintId != null && story.parentSprint?.id != sprintId) {
                            def sprint = Sprint.getInProduct(params.long('product'), sprintId).list()
                            if (sprint) {
                                props.parentSprint = sprint
                            } else {
                                returnError(text:message(code: 'is.sprint.error.not.exist'))
                                return
                            }
                        } else if (params.boolean('shiftToNext')) {
                            def nextSprint = Sprint.findByParentReleaseAndOrderNumber(story.parentSprint.parentRelease, story.parentSprint.orderNumber + 1) ?: Sprint.findByParentReleaseAndOrderNumber(Release.findByOrderNumberAndParentProduct(story.parentSprint.parentRelease.orderNumber + 1, story.parentSprint.parentProduct), 1)
                            if (nextSprint) {
                                props.parentSprint = nextSprint
                            } else {
                                returnError(text:message(code: 'is.sprint.error.not.exist'))
                                return
                            }
                        }
                    }
                    bindData(story, this.params, [include:['name','description','notes','type','affectVersion', 'feature', 'dependsOn']], "story")
                    storyService.update(story, props)
                }
            }

            withFormat {
                html { render status: 200, contentType: 'application/json', text: stories as JSON }
                // TODO find a proper solution for multiple elements (A rest API should probably not require to manipulate arrays of resources)
                json { renderRESTJSON(text: stories.first()) }
                xml  { renderRESTXML(text:stories.first()) }
            }
        }
    }

    @Secured('isAuthenticated()')
    def delete = {
        withStories{List<Story> stories ->
            storyService.delete(stories, true, params.reason? params.reason.replaceAll("(\r\n|\n)", "<br/>") :null)
            withFormat {
                html { render(status: 200)  }
                json { render(status: 204) }
                xml { render(status: 204) }
            }
        }
    }

    @Secured('inProduct()')
    def show = {
        redirect(action:'index', controller: controllerName, params:params)
    }

    @Secured('stakeHolder() or inProduct()')
    @Cacheable(cache = 'storyCache', keyGenerator='storiesKeyGenerator')
    def list = {
        def currentProduct = Product.load(params.long('product'))
        def stories = Story.searchAllByTermOrTag(currentProduct.id, params.term).sort { Story story -> story.id }
        withFormat {
            html { render(status:200, text:stories as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text:stories) }
            xml  { renderRESTXML(text:stories) }
        }
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

    @Secured('isAuthenticated()')
    def openDialogDelete = {
        def state = Story.getInProduct(params.long('product'), params.list('id').first().toLong()).list()?.state
        def dialog = g.render(template: 'dialogs/delete', model:[back: params.back ? params.back : state >= Story.STATE_ACCEPTED ? '#backlog' : '#sandbox'])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def done = {
        withStory {Story story ->
            def testsNotSuccess = story.acceptanceTests.findAll { AcceptanceTest test -> test.stateEnum != AcceptanceTestState.SUCCESS }
            if (testsNotSuccess.size() > 0 && !params.boolean('confirm')) {
                def dialog = g.render(template: 'dialogs/confirmDone', model: [testsNotSuccess: testsNotSuccess.sort {it.uid}])
                render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                return
            }
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
    def acceptAsFeature = {
        withStories{List<Story> stories ->
            stories = stories.reverse()
            def elements = storyService.acceptToFeature(stories)
            //case one story & d&d from sandbox to backlog
            //todo replace with new update feature method
            if (params.rank){
                featureService.rank((Feature)elements.first(), params.int('rank'));
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: elements as JSON }
                json { renderRESTJSON(text:elements) }
                xml  { renderRESTXML(text:elements) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def acceptAsTask = {
        withStories{List<Story> stories ->
            stories = stories.reverse()
            def elements = storyService.acceptToUrgentTask(stories)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: elements as JSON }
                json { renderRESTJSON(text:elements) }
                xml  { renderRESTXML(text:elements) }
            }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    @Cacheable(cache = 'storyCache', keyGenerator='storiesKeyGenerator')
    def findDuplicate = {
        def stories = null
        withProduct{ product ->
            def terms = params.term?.tokenize()?.findAll{ it.size() >= 5 }
            if(terms){
                stories = Story.search(product.id, [term:terms,list:[max:3]]).collect {
                    "<a class='scrum-link' href='${createLink(absolute: true, mapping: "shortURL", params: [product: product.pkey], id: it.uid, title:it.description)}'>${it.name}</a>"
                }
            }
            render(status:200, text: stories ? "${message(code:'is.ui.story.duplicate')} ${stories.join(" or ")}" : "")
        }
    }

    def shortURL = {
        withProduct{ Product product ->
            if (!springSecurityService.isLoggedIn() && product.preferences.hidden){
                redirect(url:createLink(controller:'login', action: 'auth')+'?ref='+is.createScrumLink(controller: 'story', params:[uid: params.id]))
                return
            }
            redirect(url: is.createScrumLink(controller: 'story', params:[uid: params.id]))
        }
    }

    def summaryPanel = {
        withStory { Story story ->
            def summary = story.comments +
                    story.getActivities().findAll{it.code != 'comment'} +
                    story.tasks*.getActivities().flatten().findAll{it.code != 'comment'} +
                    story.acceptanceTests*.getActivities().flatten()
            render template: "/backlogElement/summary",
                    model: [summary: summary.sort { it.dateCreated },
                            backlogElement: story,
                            product: Product.get(params.long('product'))
                    ]
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

    @Secured('stakeHolder() or inProduct()')
    @Cacheable(cache = 'storyCache', keyGenerator='storiesKeyGenerator')
    def dependenceEntries = {
        withStory { story ->
            def stories = Story.findPossiblesDependences(story).list()?.sort{ a -> a.feature == story.feature ? 0 : 1}
            def storyEntries = stories.collect { [id: it.id, text: it.name + ' (' + it.uid + ')'] }
            if (params.term) {
                storyEntries = storyEntries.findAll { it.text.contains(params.term) }
            }
            render status: 200, contentType: 'application/json', text: storyEntries as JSON
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def attachments = {
        withStory{ story ->
            if (!story.canUpdate(request.productOwner, springSecurityService.currentUser)) {
                render(status: 403)
                return
            }
            manageAttachmentsNew(story)
        }
    }

    def templateEntries = {
        if (params.template){
            render text:templates[params.template] as JSON, contentType: 'application/json', status:200
        } else {
            render text:templates.collect{ key, val -> [id:key, text:key]} as JSON, contentType: 'application/json', status:200
        }
    }

    //TODO replace with real action to save template
    static templates = ['Functional template':[tags:'tag1,tag2,tag3',
            description:'this is a description  for template 1',
            notes:'Custom notes from a template',
            feature:[id:2, name:'La feature 2'],
            id:666],
            'Defect template':[tags:'tag1,tag2,tag3',
                    type:2,
                    description:'this is a description for template 2',
                    notes:'Custom notes from a template',
                    feature:[id:3, name:'La feature 3'], dependsOn:[id:5,uid:5]],
            'Other template':[type:3,
                    description:'this is a description for template 3',
                    notes:'Custom notes from a template',
                    dependsOn:[id:16, uid:16]]]
}
