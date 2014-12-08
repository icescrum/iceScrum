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

import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Activity
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Template
import org.icescrum.core.domain.User
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState

class StoryController {

    def storyService
    def taskService
    def acceptanceTestService
    def featureService
    def springSecurityService
    def activityService

    @Secured(['inProduct()'])
    def show(long id, long product) {
        def story = Story.withStory(product, id)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: story as JSON }
            json { renderRESTJSON(text:story) }
            xml  { renderRESTXML(text:story) }
        }
    }

    @Secured(['inProduct()'])
    def index() {
        forward(action: 'show', params: params)
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def save() {
        def storyParams = params.story
        if (!storyParams){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        def tasks
        def acceptanceTests
        if (storyParams.template?.id != null) {
            def template = Template.findByParentProductAndId(Product.get(params.long('product')), storyParams.template.id.toLong())
            def parsedTemplateData = JSON.parse(template.serializedData) as Map
            tasks = parsedTemplateData.remove('tasks')
            acceptanceTests = parsedTemplateData.remove('acceptanceTests')
            storyParams << parsedTemplateData
        }
        def story = new Story()
        try {
            Story.withTransaction {
                bindData(story, storyParams, [include:['name','description','notes','type','affectVersion','feature','dependsOn', 'value']])
                def user = (User) springSecurityService.currentUser
                def product = Product.get(params.long('product'))
                storyService.save(story, product, user)
                story.tags = storyParams.tags instanceof String ? storyParams.tags.split(',') : (storyParams.tags instanceof String[] || storyParams.tags instanceof List) ? storyParams.tags : null
                tasks.each {
                    def task = new Task()
                    bindData(task, it, [include:['color', 'description', 'estimation', 'name', 'notes', 'tags']])
                    story.addToTasks(task)
                    taskService.save(task, springSecurityService.currentUser)
                }
                acceptanceTests.each {
                    def acceptanceTest = new AcceptanceTest()
                    bindData(acceptanceTest, it, [include:['description', 'name']])
                    acceptanceTestService.save(acceptanceTest, story, springSecurityService.currentUser)
                    story.addToAcceptanceTests(acceptanceTest) // required so the acceptance tests are returned with the story in JSON
                }
                entry.hook(id:"${controllerName}-${actionName}", model:[story:story])
                withFormat {
                    html { render status: 200, contentType: 'application/json', text: story as JSON }
                    json { renderRESTJSON(text:story, status:201) }
                    xml  { renderRESTXML(text:story, status:201) }
                }
            }

        } catch (RuntimeException e) {
            returnError(object:story, exception:e)
        }
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def update() {
        def stories = Story.withStories(params)
        def storyParams = params.story
        if (!storyParams){
            returnError(text:message(code:'todo.is.ui.no.data'))
            return
        }
        stories.each { Story story ->
            def user = springSecurityService.currentUser
            if (!story.canUpdate(request.productOwner, user)) {
                render(status: 403)
                return
            }
            Map props = [:]
            if (storyParams.rank != null) {
                props.rank = storyParams.rank instanceof Number ? storyParams.rank : storyParams.rank.toInteger()
            }
            if (storyParams.state != null) {
                props.state = storyParams.state instanceof Number ? storyParams.state : storyParams.state.toInteger()
            }
            if (storyParams.effort != null) {
                if (storyParams.effort instanceof String) {
                    def effort = storyParams.effort.replaceAll(',', '.')
                    props.effort = effort.isBigDecimal() ? effort.toBigDecimal() : effort // can be a "?"
                } else {
                    props.effort = storyParams.effort
                }
            }
            Story.withTransaction {
                if (storyParams.tags != null) {
                    def oldTags = story.tags
                    story.tags = storyParams.tags instanceof String ? storyParams.tags.split(',') : (storyParams.tags instanceof String[] || storyParams.tags instanceof List) ? storyParams.tags : null
                    if (oldTags != story.tags) {
                        activityService.addActivity(story, user, Activity.CODE_UPDATE, story.name, 'tags', oldTags?.sort()?.join(','), story.tags?.sort()?.join(','))
                    }
                }
                //for rest support
                if ((request.format == 'xml' && storyParams.parentSprint == '') || storyParams.parentSprint?.id == '') {
                    props.parentSprint = null
                } else {
                    def sprintId = storyParams.'parentSprint.id'?.toLong() ?: storyParams.parentSprint?.id?.toLong()
                    if (sprintId != null && story.parentSprint?.id != sprintId) {
                        def sprint = Sprint.getInProduct(params.long('product'), sprintId).list()
                        if (sprint) {
                            props.parentSprint = sprint
                        } else {
                            returnError(text:message(code: 'is.sprint.error.not.exist'))
                            return
                        }
                    } else if (params.boolean('shiftToNext')) {
                        def nextSprint = story.parentSprint.nextSprint
                        if (nextSprint) {
                            props.parentSprint = nextSprint
                        } else {
                            returnError(text:message(code: 'is.sprint.error.not.exist'))
                            return
                        }
                    }
                }
                bindData(story, storyParams, [include:['name','description','notes','type','affectVersion', 'feature', 'dependsOn', 'value']])
                storyService.update(story, props)
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        withFormat {
            html {
                render status: 200, contentType: 'application/json', text: returnData as JSON
            }
            json { renderRESTJSON(text: returnData) }
            xml  { renderRESTXML(text: returnData) }
        }
    }

    @Secured(['isAuthenticated()'])
    def delete() {
        def stories = Story.withStories(params)
        storyService.delete(stories, null, params.reason? params.reason.replaceAll("(\r\n|\n)", "<br/>") :null)
        withFormat {
            html { render(status: 200)  }
            json { render(status: 204) }
            xml { render(status: 204) }
        }
    }

    @Secured('stakeHolder() or inProduct()')
    def list() {
        def currentProduct = Product.load(params.long('product'))
        def stories = Story.searchAllByTermOrTag(currentProduct.id, params.term).sort { Story story -> story.id }
        withFormat {
            html { render(status:200, text:stories as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text:stories) }
            xml  { renderRESTXML(text:stories) }
        }
    }

    @Secured(['inProduct() and !archivedProduct()'])
    def copy() {
        def stories = Story.withStories(params)
        def copiedStories = storyService.copy(stories)
        withFormat {
            def returnData = copiedStories.size() > 1 ? copiedStories : copiedStories.first()
            html { render(status: 200, contentType: 'application/json', text: returnData as JSON) }
            json { renderRESTJSON(text: returnData, status: 201) }
            xml  { renderRESTXML(text: returnData, status: 201) }
        }
    }

    @Secured(['permitAll()'])
    def permalink(Integer id, long product) { // it is not the id but the uid...
        def story = Story.getInProductByUid(product, id).list() // TODO replace by withStory when fix uid / id stuff
        def uri
        switch(story.state){
            case Story.STATE_SUGGESTED:
                uri = "/p/$story.backlog.pkey/#/sandbox/$story.id"
                break
            case Story.STATE_ACCEPTED:
            case Story.STATE_ESTIMATED:
                uri = "/p/$story.backlog.pkey/#/backlog/$story.id"
                break
            case Story.STATE_PLANNED:
            case Story.STATE_INPROGRESS:
            case Story.STATE_DONE:
                //TODO need to be fixed
                "/p/$story.backlog.pkey/#/sprint/$story.id"
                break
            default:
                uri:"/"
        }
        redirect(uri:uri)
    }

    @Secured('isAuthenticated()')
    def openDialogDelete() {
        def state = Story.getInProduct(params.long('product'), params.list('id').first().toLong()).list()?.state
        def dialog = g.render(template: 'dialogs/delete', model:[back: params.back ? params.back : state >= Story.STATE_ACCEPTED ? '#backlog' : '#sandbox'])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def done(long id, long product) {
        def story = Story.withStory(product, id)
        withFormat {
            html {
                def testsNotSuccess = story.acceptanceTests.findAll { AcceptanceTest test -> test.stateEnum != AcceptanceTestState.SUCCESS }
                if (testsNotSuccess.size() > 0 && !params.boolean('confirm')) {
                    def dialog = g.render(template: 'dialogs/confirmDone', model: [testsNotSuccess: testsNotSuccess.sort {it.uid}])
                    render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                    return
                }
                storyService.done(story)
                render(status: 200, contentType: 'application/json', text: story as JSON)
            }
            json {
                storyService.done(story)
                renderRESTJSON(text:story)
            }
            xml  {
                storyService.done(story)
                renderRESTXML(text:story)
            }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def unDone(long id, long product) {
        def story = Story.withStory(product, id)
        storyService.unDone(story)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON)  }
            json { renderRESTJSON(text:story) }
            xml  { renderRESTXML(text:story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def acceptAsFeature() {
        def stories = Story.withStories(params)?.reverse()
        def features = storyService.acceptToFeature(stories)
        //case one story & d&d from sandbox to backlog
        if (params.rank?.isInteger()){
            Feature feature = (Feature) features.first()
            feature.rank = params.int('rank')
            featureService.update(feature)
        }
        withFormat {
            html { render status: 200, contentType: 'application/json', text: features as JSON }
            json { renderRESTJSON(text:features) }
            xml  { renderRESTXML(text:features) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def acceptAsTask() {
        def stories = Story.withStories(params)?.reverse()
        def elements = storyService.acceptToUrgentTask(stories)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: elements as JSON }
            json { renderRESTJSON(text:elements) }
            xml  { renderRESTXML(text:elements) }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def findDuplicate(long product) {
        def stories = null
        Product _product = Product.withProduct(product)
        def terms = params.term?.tokenize()?.findAll{ it.size() >= 5 }
        if(terms){
            stories = Story.search(_product.id, [term:terms,list:[max:3]]).collect {
                "<a class='scrum-link' href='${createLink(absolute: true, mapping: "shortURL", params: [product: _product.pkey], id: it.uid, title:it.description)}'>${it.name}</a>"
            }
        }
        render(status:200, text: stories ? "${message(code:'is.ui.story.duplicate')} ${stories.join(" or ")}" : "")
    }

    def shortURL(long product, long id) {
        Product _product = Product.withProduct(product)
        if (!springSecurityService.isLoggedIn() && _product.preferences.hidden){
            redirect(url:createLink(controller:'login', action: 'auth')+'?ref='+is.createScrumLink(controller: 'story', params:[uid: id]))
            return
        }
        redirect(url: is.createScrumLink(controller: 'story', params:[uid: id]))
    }

    @Secured('stakeHolder()')
    def activities(long id, boolean all, long product) {
        def story = Story.withStory(product, id)
        withFormat {
            def activities = story.activity
            if (!all) {
                def selectedActivities = activities.findAll { it.important }
                def remainingActivities = activities - selectedActivities
                activities = selectedActivities + remainingActivities.take(10 - selectedActivities.size())
                activities.sort { a, b -> b.dateCreated <=> a.dateCreated }
            }
            html { render(status: 200, contentType: 'application/json', text: activities as JSON) }
            json { renderRESTJSON(text: activities) }
            xml  { renderRESTXML(text: activities) }
        }
    }

    @Secured('stakeHolder() and !archivedProduct()')
    def listByType(long id, long product) {
        def stories
        if (params.type == 'actor') {
            stories = Actor.withActor(product, id).stories
        } else if (params.type == 'feature') {
            stories = Feature.withFeature(product, id).stories
        }
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: stories as JSON) }
            json { renderRESTJSON(text: stories) }
            xml  { renderRESTXML(text: stories) }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def like() {
        def stories = Story.withStories(params)
        stories.each { Story story ->
            User user = springSecurityService.currentUser
            if (story.liked) {
                story.removeFromLikers(user)
            } else {
                story.addToLikers(user)
            }
            storyService.update(story)
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        withFormat {
            html {
                render status: 200, contentType: 'application/json', text: returnData as JSON
            }
            json { renderRESTJSON(text: returnData) }
            xml  { renderRESTXML(text: returnData) }
        }
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def follow() {
        def stories = Story.withStories(params)
        stories.each { Story story ->
            User user = (User)springSecurityService.currentUser
            if (params.follow == null || params.boolean('follow') != story.followed) {
                if (story.followed) {
                    story.removeFromFollowers(user)
                } else {
                    story.addToFollowers(user)
                }
                storyService.update(story)
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        withFormat {
            html {
                render status: 200, contentType: 'application/json', text: returnData as JSON
            }
            json { renderRESTJSON(text: returnData) }
            xml  { renderRESTXML(text: returnData) }
        }
    }

    @Secured(['stakeHolder() or inProduct()'])
    def dependenceEntries(long id, long product) {
        def story = Story.withStory(product, id)
        def stories = Story.findPossiblesDependences(story).list()?.sort{ a -> a.feature == story.feature ? 0 : 1}
        def storyEntries = stories.collect { [id: it.id, text: it.name + ' (' + it.uid + ')'] }
        if (params.term) {
            storyEntries = storyEntries.findAll { it.text.contains(params.term) }
        }
        render status: 200, contentType: 'application/json', text: storyEntries as JSON
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def saveTemplate(long id, long product) {
        Story story = Story.withStory(product, id)
        Product _product = Product.withProduct(product)
        def templateName = params.template.name
        // Custom marshalling
        def copyFields = { source, fieldNames ->
            def copy = [:]
            fieldNames.each { fieldName ->
                def fieldValue = source."$fieldName"
                if (fieldValue != null) {
                    copy[fieldName] = fieldValue.hasProperty('id') ? [id: fieldValue.id] : fieldValue
                }
            }
            return copy
        }
        def storyData = copyFields(story, ['affectVersion', 'description', 'notes', 'tags', 'type', 'dependsOn', 'feature'])
        if (story.tasks) {
            storyData.tasks = story.tasks.collect { task ->
                copyFields(task, ['color', 'description', 'estimation', 'name', 'notes', 'tags', 'type'])
            }
        }
        if (story.acceptanceTests) {
            storyData.acceptanceTests = story.acceptanceTests.collect { acceptanceTest ->
                copyFields(acceptanceTest, ['description', 'name'])
            }
        }
        def template = new Template(name: templateName, itemClass: story.class.name, serializedData: (storyData as JSON).toString(), parentProduct: _product)
        if (template.save()) {
            render(status: 200)
        } else {
            throw new RuntimeException(template.errors?.toString())
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def deleteTemplate() {
        def product = Product.get(params.long('product'))
        def template = Template.findByIdAndParentProduct(params.long('template.id'), product)
        if (template) {
            template.delete()
            render(status: 204)
        } else {
            returnError(text:message(code:'todo.is.ui.story.template.not.found'))
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def templateEntries() {
        def templates = Template.findAllByParentProduct(Product.get(params.long('product')))
        render(text: templates.collect{[id:it.id, text:it.name]} as JSON, contentType: 'application/json', status: 200)
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def templatePreview() {
        if (params.template) {
            def product = Product.get(params.long('product'))
            def template = Template.findByParentProductAndId(product, params.long('template'))
            def parsedData = JSON.parse(template.serializedData) as Map
            if (parsedData.feature) {
                def feature = Feature.getInProduct(product.id, parsedData.feature.id.toLong()).list()
                if (feature) {
                    parsedData.feature.color = feature.color
                }
            }
            if (parsedData.tasks) {
                parsedData.tasks_count = parsedData.tasks.size()
            }
            if (parsedData.acceptanceTests) {
                parsedData.acceptanceTests_count = parsedData.acceptanceTests.size()
            }
            render(text: parsedData as JSON, contentType: 'application/json', status: 200)
        }
    }
}
