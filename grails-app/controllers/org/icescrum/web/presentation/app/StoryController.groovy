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

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.*
import org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState
import org.icescrum.core.utils.BundleUtils

import static grails.async.Promises.task

class StoryController {

    def storyService
    def taskService
    def acceptanceTestService
    def featureService
    def springSecurityService
    def activityService

    @Secured('stakeHolder() or inProduct()')
    def index(long product, long backlog) {
        def stories = backlog ? Story.search(product, JSON.parse(Backlog.get(backlog).filter)).sort { Story story -> story.id } : Story.findAllByBacklog(Product.load(product))
        withFormat {
            html { render(status: 200, text: stories as JSON, contentType: 'application/json') }
            json { renderRESTJSON(text: stories) }
            xml { renderRESTXML(text: stories) }
        }
    }

    @Secured(['inProduct()'])
    def show(long id, long product) {
        def story = Story.withStory(product, id)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: story as JSON }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def save() {
        def storyParams = params.story
        if (!storyParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        def tasks
        def acceptanceTests
        if (storyParams.template != null) {
            def template = Template.findByParentProductAndId(Product.get(params.long('product')), storyParams.template.id.toLong())
            def parsedTemplateData = JSON.parse(template.serializedData) as Map
            tasks = parsedTemplateData.remove('tasks')
            acceptanceTests = parsedTemplateData.remove('acceptanceTests')
            storyParams << parsedTemplateData
        }
        def story = new Story()
        try {
            Story.withTransaction {
                bindData(story, storyParams, [include: ['name', 'description', 'notes', 'type', 'affectVersion', 'feature', 'dependsOn', 'value']])
                def user = (User) springSecurityService.currentUser
                def product = Product.get(params.long('product'))
                storyService.save(story, product, user)
                story.tags = storyParams.tags instanceof String ? storyParams.tags.split(',') : (storyParams.tags instanceof String[] || storyParams.tags instanceof List) ? storyParams.tags : null
                tasks.each {
                    def task = new Task()
                    bindData(task, it, [include: ['color', 'description', 'estimation', 'name', 'notes', 'tags']])
                    story.addToTasks(task)
                    taskService.save(task, springSecurityService.currentUser)
                }
                acceptanceTests.each {
                    def acceptanceTest = new AcceptanceTest()
                    bindData(acceptanceTest, it, [include: ['description', 'name']])
                    acceptanceTestService.save(acceptanceTest, story, springSecurityService.currentUser)
                    story.addToAcceptanceTests(acceptanceTest) // required so the acceptance tests are returned with the story in JSON
                }
                entry.hook(id: "${controllerName}-${actionName}", model: [story: story])
                withFormat {
                    html { render status: 200, contentType: 'application/json', text: story as JSON }
                    json { renderRESTJSON(text: story, status: 201) }
                    xml { renderRESTXML(text: story, status: 201) }
                }
            }

        } catch (RuntimeException e) {
            returnError(object: story, exception: e)
        }
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def update() {
        def stories = Story.withStories(params)
        def storyParams = params.story
        if (!storyParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
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
            if (storyParams.effort != null) {
                if (storyParams.effort instanceof String) {
                    def effort = storyParams.effort.replaceAll(',', '.')
                    if (effort.isBigDecimal()) {
                        props.effort = effort.toBigDecimal()
                    } else if (effort == "" || effort == "?") {
                        props.effort = null
                    }
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
                bindData(story, storyParams, [include: ['name', 'description', 'notes', 'type', 'affectVersion', 'feature', 'dependsOn', 'value']])
                storyService.update(story, props)
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        withFormat {
            html {
                render status: 200, contentType: 'application/json', text: returnData as JSON
            }
            json { renderRESTJSON(text: returnData) }
            xml { renderRESTXML(text: returnData) }
        }
    }

    @Secured(['isAuthenticated()'])
    def delete() {
        def stories = Story.withStories(params)
        storyService.delete(stories, null, params.reason ? params.reason.replaceAll("(\r\n|\n)", "<br/>") : null)
        def data = stories.size() > 1 ? stories.collect { [id: it.id] } : (stories ? [id: stories.first().id] : [:])
        withFormat {
            html { render(status: 200, text: data as JSON) }
            json { render(status: 204) }
            xml { render(status: 204) }
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
            xml { renderRESTXML(text: returnData, status: 201) }
        }
    }

    @Secured(['permitAll()'])
    def permalink(Integer id, long product) { // it is not the id but the uid...
        def story = Story.getInProductByUid(product, id).list() // TODO replace by withStory when fix uid / id stuff
        def uri
        switch (story.state) {
            case Story.STATE_SUGGESTED:
                uri = "/p/$story.backlog.pkey/#/backlog/$story.id"
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
                uri: "/"
        }
        redirect(uri: uri)
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def plan(long id, long product) {
        def story = Story.withStory(product, id)
        def storyParams = params.story
        def sprintId = storyParams.'parentSprint.id'?.toLong() ?: storyParams.parentSprint?.id?.toLong()
        def sprint = Sprint.withSprint(product, sprintId)
        if (!sprint) {
            returnError(text: message(code: 'is.sprint.error.not.exist'))
            return
        }
        def rank
        if (storyParams?.rank) {
            rank = storyParams.rank instanceof Number ? storyParams.rank : storyParams.rank.toInteger()
        }
        storyService.plan(sprint, story, rank)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def unPlan(long id, long product) {
        def story = Story.withStory(product, id)
        storyService.unPlan(story)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def shiftToNextSprint(long id, long product) {
        def story = Story.withStory(product, id)
        def nextSprint = story.parentSprint.nextSprint
        if (!nextSprint) {
            returnError(text: message(code: 'is.sprint.error.not.exist'))
            return
        }
        storyService.plan(nextSprint, story, 1)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def acceptToBacklog(long id, long product) {
        def story = Story.withStory(product, id)
        def rank
        if (params.story?.rank) {
            rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.toInteger()
        }
        storyService.acceptToBacklog(story, rank)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def returnToSandbox(long id, long product) {
        def story = Story.withStory(product, id)
        def rank
        if (params.story?.rank) {
            rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.toInteger()
        }
        storyService.returnToSandbox(story, rank)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def done(long id, long product) {
        def story = Story.withStory(product, id)
        storyService.done(story)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def unDone(long id, long product) {
        def story = Story.withStory(product, id)
        storyService.unDone(story)
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: story as JSON) }
            json { renderRESTJSON(text: story) }
            xml { renderRESTXML(text: story) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def acceptAsFeature() {
        def stories = Story.withStories(params)?.reverse()
        def features = storyService.acceptToFeature(stories)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: features as JSON }
            json { renderRESTJSON(text: features) }
            xml { renderRESTXML(text: features) }
        }
    }

    @Secured(['productOwner() and !archivedProduct()'])
    def acceptAsTask() {
        def stories = Story.withStories(params)?.reverse()
        def elements = storyService.acceptToUrgentTask(stories)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: elements as JSON }
            json { renderRESTJSON(text: elements) }
            xml { renderRESTXML(text: elements) }
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def findDuplicates(long product) {
        def stories = null
        Product _product = Product.withProduct(product)
        def terms = params.term?.tokenize()?.findAll { it.size() >= 5 }
        if (terms) {
            stories = Story.search(_product.id, [term: terms, list: [max: 3]]).collect {
                "<a class='scrum-link' href='${createLink(absolute: true, mapping: "shortURL", params: [product: _product.pkey], id: it.uid, title: it.description)}'>${it.name}</a>"
            }
        }
        render(status: 200, text: stories ? "${message(code: 'is.ui.story.duplicate')} ${stories.join(" or ")}" : "")
    }

    def shortURL(long product, long id) {
        Product _product = Product.withProduct(product)
        if (!springSecurityService.isLoggedIn() && _product.preferences.hidden) {
            redirect(url: createLink(controller: 'login', action: 'auth') + '?ref=' + is.createScrumLink(controller: 'story', params: [uid: id]))
            return
        }
        redirect(url: is.createScrumLink(controller: 'story', params: [uid: id]))
    }

    @Secured('stakeHolder() and !archivedProduct()')
    def listByType(long id, long product, String type) {
        def stories
        if (type == 'actor') {
            stories = Actor.withActor(product, id).stories
        } else if (type == 'feature') {
            stories = Feature.withFeature(product, id).stories
        } else if (type == 'sprint') {
            stories = Sprint.withSprint(product, id).stories
        }
        withFormat {
            html { render(status: 200, contentType: 'application/json', text: stories as JSON) }
            json { renderRESTJSON(text: stories) }
            xml { renderRESTXML(text: stories) }
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
            xml { renderRESTXML(text: returnData) }
        }
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def follow() {
        def stories = Story.withStories(params)
        stories.each { Story story ->
            User user = (User) springSecurityService.currentUser
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
            xml { renderRESTXML(text: returnData) }
        }
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def dependenceEntries(long id, long product) {
        def story = Story.withStory(product, id)
        def stories = Story.findPossiblesDependences(story).list()?.sort { a -> a.feature == story.feature ? 0 : 1 }
        def storyEntries = stories.collect { [id: it.id, name: it.name, uid: it.uid] }
        render status: 200, contentType: 'application/json', text: storyEntries as JSON
    }

    @Secured(['isAuthenticated() and !archivedProduct()'])
    def sprintEntries(long product) {
        def sprintEntries = []
        Product _product = Product.withProduct(product)
        def releases = Release.findAllByParentProductAndStateNotEqual(_product, Release.STATE_DONE)
        if (releases) {
            Sprint.findAllByStateNotEqualAndParentReleaseInList(Sprint.STATE_DONE, releases).groupBy {
                it.parentRelease
            }.each { Release release, List<Sprint> sprints ->
                sprints.sort { it.orderNumber }.each { Sprint sprint ->
                    sprintEntries << [id: sprint.id, parentRelease: [name: release.name], orderNumber: sprint.orderNumber]
                }
            }
        }
        render status: 200, contentType: 'application/json', text: sprintEntries as JSON
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
            render(text: [id: template.id, text: template.name] as JSON, contentType: 'application/json', status: 200)
        } else {
            returnError(object: template, exception: new RuntimeException(template.errors.toString()))
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
            returnError(text: message(code: 'todo.is.ui.story.template.not.found'))
        }
    }

    @Secured('isAuthenticated() and !archivedProduct()')
    def templateEntries() {
        def templates = Template.findAllByParentProduct(Product.get(params.long('product')))
        render(text: templates.collect {[id: it.id, text: it.name]} as JSON, contentType: 'application/json', status: 200)
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

    @Secured('isAuthenticated() and !archivedProduct()')
    def listByField(long product, String field) {
        Product _product = Product.withProduct(product)
        def productStories = _product.stories;
        def groupedStories = [:]
        if (field == "effort") {
            groupedStories = productStories.groupBy { it.effort }
        } else if (field == "value") {
            groupedStories = productStories.groupBy { it.value }
        }
        def fieldValues = []
        def stories = []
        def count = []
        groupedStories.entrySet().sort { it.key }.each {
            count << it.value.size()
            fieldValues << it.key
            stories << it.value.sort { a, b -> b.lastUpdated <=> a.lastUpdated }.take(3).collect {
                [id: it.id, uid: it.uid, name: it.name, description: it.description, state: it.state]
            }
        }
        render(text: [fieldValues: fieldValues, stories: stories, count: count] as JSON, contentType: 'application/json', status: 200)
    }

    @Secured('isAuthenticated()')
    def openDialogDelete() {
        def dialog = g.render(template: 'dialogs/delete', model: [back: params.back ? params.back : '#backlog'])
        render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
    }
}

