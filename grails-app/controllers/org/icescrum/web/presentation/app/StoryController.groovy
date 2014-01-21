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

import org.apache.commons.io.FilenameUtils
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
import org.grails.followable.FollowException
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState
import org.icescrum.core.domain.Story.TestState

import javax.servlet.http.HttpServletResponse

class StoryController {

    def storyService
    def featureService
    def springSecurityService
    def securityService
    def acceptanceTestService
    def attachmentableService

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

        def story = new Story()
        bindData(story, this.params, [include:['name','description','notes','type','affectVersion']], "story")

        def featureId = params.remove('feature.id') ?: params.story.remove('feature.id')
        if (featureId) {
            def feature = Feature.getInProduct(params.long('product'),featureId.toLong()).list()
            if (!feature){
                returnError(text:message(code: 'is.feature.error.not.exist'))
                return
            }else{
                story.feature = feature
            }
        }

        def dependsOnId = params.remove('dependsOn.id') ?: params.story.remove('dependsOn.id')
        if (dependsOnId) {
            def dependsOn = (Story)Story.getInProduct(params.long('product'),dependsOnId.toLong()).list()
            if (!dependsOn){
                returnError(text:message(code: 'is.story.error.not.exist'))
                return
            }else{
                story.dependsOn = dependsOn
            }
        }

        def user = springSecurityService.currentUser
        def product = Product.get(params.product)

        try {
            storyService.save(story, product, (User)user)
            def keptAttachments = params.list('story.attachments')
            def addedAttachments = params.list('attachments')
            manageAttachments(story, keptAttachments, addedAttachments)
            story.tags = params.story.tags instanceof String ? params.story.tags.split(',') : (params.story.tags instanceof String[] || params.story.tags instanceof List) ? params.story.tags : null
            entry.hook(id:"${controllerName}-${actionName}", model:[story:story])

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

            if (!params.story){
                returnError(text:message(code:'is.ui.no.data'))
                return
            }

            def user = springSecurityService.currentUser
            if (story.backlog.preferences.archived){
                render(status: 403, contentType: 'application/json')
                return
            }
            def productOwner = securityService.productOwner(story.backlog.id, springSecurityService.authentication)
            def inProduct = securityService.inProduct(story.backlog.id, springSecurityService.authentication)

            if (story.state == Story.STATE_SUGGESTED && !(story.creator.id == user?.id) && !productOwner) {
                render(status: 403, contentType: 'application/json')
                return
            } else if (story.state > Story.STATE_SUGGESTED && !productOwner) {
                render(status: 403, contentType: 'application/json')
                return
            }

            if(params.story.effort && inProduct){
                try {
                    storyService.estimate(story,params.story.effort)
                }catch(IllegalStateException e){
                    returnError(text:message(code:e.message))
                    return
                }
            }

            bindData(story, this.params, [include:['name','description','notes','type','affectVersion']], "story")

            def featureId = params.story.remove('feature.id')
            if (featureId && story.feature?.id != featureId.toLong()) {
                def feature = Feature.getInProduct(params.long('product'),featureId.toLong()).list()
                if (!feature)
                    returnError(text:message(code: 'is.feature.error.not.exist'))
                storyService.associateFeature(feature, story)
            } else if (story.feature && featureId == '') {
                storyService.dissociateFeature(story)
            }

            def dependsOnId = params.story.remove('dependsOn.id')
            if (dependsOnId && story.dependsOn?.id != dependsOnId.toLong()) {
                def dependsOn = (Story) Story.getInProduct(params.long('product'),dependsOnId.toLong()).list()
                if (!dependsOn)
                    returnError(text:message(code: 'is.story.error.not.exist'))
                storyService.dependsOn(story, dependsOn)
            } else if (story.dependsOn && dependsOnId == '') {
                storyService.notDependsOn(story)
            }

            if (params.story.tags != null) {
                story.tags = params.story.tags instanceof String ? params.story.tags.split(',') : (params.story.tags instanceof String[] || params.story.tags instanceof List) ? params.story.tags : null
            }

            if (params.story.rank && story.rank != params.story.rank.toInteger()) {
                Integer rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.isNumber() ? params.story.rank.toInteger() : null
                storyService.rank(story, rank)
            }

            def sprintId = params.story.remove('sprint.id')
            if (sprintId && story.parentSprint?.id != sprintId.toLong()) {
                def sprint = (Sprint)Sprint.getInProduct(params.long('product'),sprintId.toLong()).list()
                if (!sprint){
                    returnError(text:message(code: 'is.sprint.error.not.exist'))
                }else{
                    storyService.plan(sprint, story)
                }
            }

            //TODO remove that hack as soon as soon as Nicolas makes good wook :)
            story.lastUpdated = new Date()

            withFormat {
                html { render status: 200, contentType: 'application/json', text: story as JSON }
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
            storyService.delete(stories, true, params.reason? params.reason.replaceAll("(\r\n|\n)", "<br/>") :null)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: ids as JSON)  }
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
        def currentProduct = Product.load(params.product)
        def stories = Story.searchAllByTermOrTag(currentProduct.id, params.term).sort { Story story -> story.id }
        withFormat {
            html { render(status:200, text:stories as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text:stories) }
            xml  { renderRESTXML(text:stories) }
        }
    }

    @Secured('isAuthenticated()')
    def openDialogDelete = {
        def state = Story.getInProduct(params.long('product'), params.list('id').first().toLong()).list()?.state
        def dialog = g.render(template: 'dialogs/delete', model:[back: params.back ? params.back : state >= Story.STATE_ACCEPTED ? '#backlog' : '#sandbox'])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }

    @Secured('productOwner() and !archivedProduct()')
    def rank = {
        withStory{ Story story ->
            Integer rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.isNumber() ? params.story.rank.toInteger() : null
            if (story == null || rank == null)
                returnError(text:message(code: 'is.story.rank.error'))
            if (storyService.rank(story, rank)) {
                withFormat {
                    html { render(status: 200, text: [story:story,message:(story.rank != rank) ? message(code:'is.story.dependsOn.constraints.warning', args:[]) : null ] as JSON, contentType: 'application/json')  }
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
                def nextSprint = Sprint.findByParentReleaseAndOrderNumber(story.parentSprint.parentRelease, story.parentSprint.orderNumber + 1) ?: Sprint.findByParentReleaseAndOrderNumber(Release.findByOrderNumberAndParentProduct(story.parentSprint.parentRelease.orderNumber + 1, story.parentSprint.parentProduct), 1)
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
    def accept = {
        def type = params.type instanceof Map ? params.type.value : params.type
        withStories{List<Story> stories ->
            stories = stories.reverse()
            def elements = []
            if (type == 'story') {
                elements = storyService.acceptToBacklog(stories)
                //case one story & d&d from sandbox to backlog
                if (params.rank){
                    storyService.rank(stories.first(), params.int('rank'));
                }
            } else if (type == 'feature') {
                elements = storyService.acceptToFeature(stories)
                //case one story & d&d from sandbox to backlog
                if (params.rank){
                    featureService.rank((Feature)elements.first(), params.int('rank'));
                }
            } else if (type == 'task') {
                elements = storyService.acceptToUrgentTask(stories)
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: elements as JSON }
                json { renderRESTJSON(text:elements) }
                xml  { renderRESTXML(text:elements) }
            }
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def returnToSandbox = {
        withStories{List<Story> stories ->
            storyService.returnToSandbox(stories)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: stories as JSON)  }
                json { renderRESTJSON(text:stories) }
                xml  { renderRESTXML(text:stories) }
            }
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

    @Secured('isAuthenticated() and !archivedProduct()')
    @Cacheable(cache = 'storyCache', keyGenerator='storiesKeyGenerator')
    def findDuplicate = {
        def stories = null
        withProduct{ product ->
            def terms = params.term?.tokenize()?.findAll{ it.size() >= 5 }
            if(terms){
                stories = Story.search(product.id, [term:terms,list:[max:3]]).collect {
                    is.scrumLink([controller:"story", id:it.id, title:it.description], it.name)
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

    def attachments = {
        withStory{ story ->
            if (request.method == 'POST'){
                def upfile = params.file ?: request.getFile('file')
                def filename = FilenameUtils.getBaseName(upfile.originalFilename?:upfile.name)
                def ext = FilenameUtils.getExtension(upfile.originalFilename?:upfile.name)
                def tmpF = null
                if(upfile.originalFilename){
                    tmpF = session.createTempFile(filename, '.' + ext)
                    request.getFile("file").transferTo(tmpF)
                }
                story.addAttachment(springSecurityService.currentUser, tmpF?: upfile, upfile.originalFilename?:upfile.name)
                def attachment = story.attachments.first()
                render(status:200, contentType: 'application/json', text:[
                        id:attachment.id,
                        filename:attachment.inputName,
                        ext:ext,
                        size:attachment.length,
                        provider:attachment.provider?:''] as JSON)
            } else if(request.method == 'DELETE'){
                def attachment = story.attachments?.find{ it.id == params.long('attachment.id') }
                if (attachment){
                    story.removeAttachment(attachment)
                    render(status:200)
                }
            } else if(request.method == 'GET'){
                def attachment = story.attachments?.find{ it.id == params.long('attachment.id') }
                if (attachment) {
                    if (attachment.url){
                        redirect(url: "${attachment.url}")
                        return
                    }else{
                        File file = attachmentableService.getFile(attachment)

                        if (file.exists()) {
                            String filename = attachment.filename
                            ['Content-disposition': "attachment;filename=\"$filename\"",'Cache-Control': 'private','Pragma': ''].each {k, v ->
                                response.setHeader(k, v)
                            }
                            response.contentType = attachment.contentType
                            response.outputStream << file.newInputStream()
                            return
                        }
                    }
                }
                response.status = HttpServletResponse.SC_NOT_FOUND
            }
        }
    }
}
