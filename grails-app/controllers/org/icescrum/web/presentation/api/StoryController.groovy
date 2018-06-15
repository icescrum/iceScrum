/*
 * Copyright (c) 2015 Kagilum.
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
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.*
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.utils.ServicesUtils

class StoryController implements ControllerErrorHandler {

    def storyService
    def taskService
    def acceptanceTestService
    def springSecurityService
    def activityService

    @Secured('stakeHolder() or inProject()')
    def index(long project, long typeId, String type) {
        def options
        if (params.filter) {
            options = params.filter
        } else {
            options = [story: [:]]
            if (type) {
                if (type == 'backlog') {
                    options = JSON.parse(Backlog.get(typeId).filter)
                } else if (type == 'actor') {
                    options.story.actor = typeId
                } else if (type == 'feature') {
                    options.story.feature = typeId
                } else if (type == 'sprint') {
                    options.story.parentSprint = typeId
                }
            }
            if (params.context) {
                if (params.context.type == 'tag') {
                    options.story.tag = params.context.id
                } else if (params.context.type == 'feature') {
                    if (!options.story.feature) {
                        options.story.feature = params.context.id
                    } else if (options.story.feature != params.context.id) { // If it tries to load the stories of another feature, return nothing!
                        options.story = null
                    }
                } else if (params.context.type == 'actor') {
                    options.story.actor = params.context.id
                }
            }
        }
        def stories
        try {
            stories = Story.search(project, options).sort { Story story -> story.id }
        } catch (RuntimeException e) {
            returnError(code: 'todo.is.ui.search.error', exception: e)
            return
        }
        render(status: 200, text: stories as JSON, contentType: 'application/json')
    }

    @Secured(['stakeHolder() or inProject()'])
    def show() {
        def stories = Story.withStories(params)
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def save(long project) {
        def storyParams = params.story
        if (!storyParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        Story story = new Story()
        Story.withTransaction {
            cleanBeforeBindData(storyParams, ['feature', 'dependsOn'])
            def propertiesToBind = ['name', 'description', 'notes', 'type', 'affectVersion', 'feature', 'dependsOn', 'value']
            Project _project = Project.withProject(project)
            entry.hook(id: 'story-before-save', model: [story: story, propertiesToBind: propertiesToBind, project: _project])
            def tasks = storyParams.remove('tasks')
            def acceptanceTests = storyParams.remove('acceptanceTests')
            bindData(story, storyParams, [include: propertiesToBind])
            User user = (User) springSecurityService.currentUser
            storyService.save(story, _project, user)
            story.tags = storyParams.tags instanceof String ? storyParams.tags.split(',') : (storyParams.tags instanceof String[] || storyParams.tags instanceof List) ? storyParams.tags : null
            tasks.each {
                def task = new Task()
                bindData(task, it, [include: ['color', 'description', 'estimation', 'name', 'notes', 'tags']])
                story.addToTasks(task)
                taskService.save(task, user)
            }
            acceptanceTests.each {
                def acceptanceTest = new AcceptanceTest()
                bindData(acceptanceTest, it, [include: ['description', 'name']])
                acceptanceTestService.save(acceptanceTest, story, user)
            }
            if (storyParams.state && storyParams.state.toInteger() == Story.STATE_ACCEPTED && request.productOwner) {
                storyService.acceptToBacklog(story)
            }
            render(status: 201, contentType: 'application/json', text: story as JSON)
        }
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def update(long project) {
        def stories = Story.withStories(params)
        def storyParams = params.story
        if (!storyParams) {
            returnError(code: 'todo.is.ui.no.data')
            return
        }
        def tagParams = storyParams.tags instanceof String ? storyParams.tags.split(',') : (storyParams.tags instanceof String[] || storyParams.tags instanceof List) ? storyParams.tags : null
        tagParams = tagParams?.findAll { it } // remove empty tags
        def commonTags
        if (stories.size() > 1) {
            stories.each { Story story ->
                commonTags = commonTags == null ? story.tags : commonTags.intersect(story.tags)
            }
        }
        stories.each { Story story ->
            def user = springSecurityService.currentUser
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
                if (request.productOwner || (story.state == Story.STATE_SUGGESTED && user == story.creator)) {
                    if (storyParams.tags != null) {
                        def oldTags = story.tags
                        if (stories.size() > 1) {
                            (tagParams - oldTags).each { tag ->
                                story.addTag(tag)
                            }
                            (commonTags - tagParams).each { tag ->
                                if (oldTags.contains(tag)) {
                                    story.removeTag(tag)
                                }
                            }
                        } else {
                            story.tags = tagParams
                        }
                        if (oldTags != story.tags) {
                            activityService.addActivity(story, user, Activity.CODE_UPDATE, story.name, 'tags', oldTags?.sort()?.join(','), story.tags?.sort()?.join(','))
                        }
                    }
                    cleanBeforeBindData(storyParams, ['feature', 'dependsOn', 'creator'])
                    bindData(story, storyParams, [include: ['name', 'description', 'notes', 'type', 'affectVersion', 'feature', 'dependsOn', 'value', 'creator']])
                }
                storyService.update(story, props)
                // Independently manage the sprint change, manage the "null" value manually
                def sprintId = storyParams.parentSprint == 'null' ? storyParams.parentSprint : storyParams.parentSprint?.id?.toLong()
                if (sprintId instanceof Long && story.parentSprint?.id != sprintId) {
                    def sprint = Sprint.withSprint(project, sprintId)
                    storyService.plan(sprint, story)
                } else if (sprintId == "null") {
                    storyService.unPlan(story)
                }
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def delete() {
        def stories = Story.withStories(params)
        storyService.delete(stories, null, params.reason ? params.reason.replaceAll("(\r\n|\n)", "<br/>") : null)
        def returnData = stories.size() > 1 ? stories.collect { [id: it.id] } : (stories ? [id: stories.first().id] : [:])
        withFormat {
            html {
                render(status: 200, text: returnData as JSON)
            }
            json {
                render(status: 204)
            }
        }
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def copy() {
        def stories = Story.withStories(params)
        def copiedStories = storyService.copy(stories, stories.first().backlog)
        def returnData = copiedStories.size() > 1 ? copiedStories : copiedStories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    private String getStoryHash(Story story) {
        String url
        switch (story.state) {
            case Story.STATE_SUGGESTED:
                url = "backlog/sandbox/story/$story.id"
                break
            case [Story.STATE_ACCEPTED, Story.STATE_ESTIMATED]:
                url = "backlog/backlog/story/$story.id"
                break
            case [Story.STATE_PLANNED, Story.STATE_DONE]:
                url = "planning/$story.parentSprint.parentRelease.id/sprint/$story.parentSprint.id/story/$story.id"
                break
            case Story.STATE_INPROGRESS:
                url = "taskBoard/$story.parentSprint.id/story/$story.id"
                break
            default:
                url = "backlog/all/story/$story.id"
        }
        return url
    }

    @Secured(['permitAll()'])
    def permalink(int uid, long project) {
        Project _project = Project.withProject(project)
        Story story = Story.findByBacklogAndUid(_project, uid)
        if (story) {
            redirect(uri: "/p/$_project.pkey/#/" + getStoryHash(story))
        } else {
            redirect(controller: 'errors', action: 'error404')
        }
    }

    @Secured(['permitAll()'])
    def url(long id, long project) {
        Project _project = Project.withProject(project)
        Story story = Story.withStory(_project.id, id)
        if (story) {
            render(status: 200, contentType: 'application/json', text: [relativeUrl: getStoryHash(story)] as JSON)
        } else {
            redirect(controller: 'errors', action: 'error404')
        }
    }

    @Secured(['(productOwner() or scrumMaster()) and !archivedProject()'])
    def plan(long id, long project) {
        // Separate method to manage changing the rank and the state at the same time (too complicated to manage them properly in the update method)
        def story = Story.withStory(project, id)
        def storyParams = params.story
        def sprintId = storyParams.'parentSprint.id'?.toLong() ?: storyParams.parentSprint?.id?.toLong()
        def sprint = Sprint.withSprint(project, sprintId)
        if (!sprint) {
            returnError(code: 'is.sprint.error.not.exist')
            return
        }
        def rank
        if (storyParams?.rank) {
            rank = storyParams.rank instanceof Number ? storyParams.rank : storyParams.rank.toInteger()
        }
        storyService.plan(sprint, story, rank)
        render(status: 200, contentType: 'application/json', text: story as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def planMultiple(long project) {
        def stories = Story.withStories(params)
        def sprintId = params.'parentSprint.id'?.toLong() ?: params.parentSprint?.id?.toLong()
        def sprint = Sprint.withSprint(project, sprintId)
        storyService.planMultiple(sprint, stories)
        render(status: 200, contentType: 'application/json', text: stories as JSON)
    }

    @Secured(['(productOwner() or scrumMaster()) and !archivedProject()'])
    def unPlan(long id, long project) {
        def story = Story.withStory(project, id)
        storyService.unPlan(story)
        render(status: 200, contentType: 'application/json', text: story as JSON)
    }

    @Secured(['(productOwner() or scrumMaster()) and !archivedProject()'])
    def shiftToNextSprint(long id, long project) {
        def story = Story.withStory(project, id)
        def nextSprint = story.parentSprint?.nextSprint
        if (!nextSprint) {
            returnError(code: 'is.sprint.error.not.exist')
            return
        }
        storyService.plan(nextSprint, story, 1)
        render(status: 200, contentType: 'application/json', text: story as JSON)
    }

    @Secured(['productOwner() and !archivedProject()'])
    def accept() {
        def stories = Story.withStories(params)
        def rank
        if (stories.size() == 1 && params.story?.rank) {
            rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.toInteger()
        }
        Story.withTransaction {
            stories.each { Story story ->
                storyService.acceptToBacklog(story, rank)
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['productOwner() and !archivedProject()'])
    def returnToSandbox() {
        def stories = Story.withStories(params)
        def rank
        if (stories.size() == 1 && params.story?.rank) {
            rank = params.story.rank instanceof Number ? params.story.rank : params.story.rank.toInteger()
        }
        Story.withTransaction {
            stories.each { Story story ->
                storyService.returnToSandbox(story, rank)
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['(productOwner() or scrumMaster()) and !archivedProject()'])
    def done() {
        def stories = Story.withStories(params)
        storyService.done(stories)
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['(productOwner() or scrumMaster()) and !archivedProject()'])
    def unDone() {
        def stories = Story.withStories(params)
        storyService.unDone(stories)
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['productOwner() and !archivedProject()'])
    def turnIntoFeature() {
        def stories = Story.withStories(params)?.reverse()
        def features = storyService.acceptToFeature(stories)
        def returnData = features.size() > 1 ? features : features.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['productOwner() and !archivedProject()'])
    def turnIntoTask() {
        def stories = Story.withStories(params)?.reverse()
        def tasks = storyService.acceptToUrgentTask(stories)
        def returnData = tasks.size() > 1 ? tasks : tasks.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def findDuplicates(long project) {
        Project _project = Project.withProject(project)
        def stories
        def terms = params.term?.tokenize()?.findAll { it.size() >= 5 }
        if (terms) {
            stories = Story.search(_project.id, [story: [term: terms], list: [max: 3]]).collect {
                "<a href='${createLink(absolute: true, action: 'permalink', params: [project: _project.pkey, uid: it.uid])}'>$it.name</a>"
            }
        }
        render(status: 200, text: stories ? message(code: 'is.ui.story.duplicate') + ' ' + stories.join(" or ") : "")
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def follow() {
        def stories = Story.withStories(params)
        stories.each { Story story ->
            User user = (User) springSecurityService.currentUser
            def isFollowed = story.followers.contains(user)
            if (params.follow == null || params.boolean('follow') != isFollowed) {
                if (isFollowed) {
                    story.removeFromFollowers(user)
                } else {
                    story.addToFollowers(user)
                }
                storyService.update(story)
            }
        }
        def returnData = stories.size() > 1 ? stories : stories.first()
        render(status: 200, contentType: 'application/json', text: returnData as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def dependenceEntries(long id, long project) {
        def story = Story.withStory(project, id)
        def stories = Story.findPossiblesDependences(story).list()?.sort { a -> a.feature == story.feature ? 0 : 1 }
        def storyEntries = stories.collect { Story dependencyStory ->
            def entry = [id: dependencyStory.id, name: dependencyStory.name, uid: dependencyStory.uid]
            if (dependencyStory.feature) {
                entry.feature = [color: dependencyStory.feature.color]
            }
            return entry
        }
        render(status: 200, contentType: 'application/json', text: storyEntries as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def sprintEntries(long project) {
        def sprintEntries = []
        Project _project = Project.withProject(project)
        def releases = Release.findAllByParentProjectAndStateNotEqual(_project, Release.STATE_DONE)
        if (releases) {
            Sprint.findAllByStateNotEqualAndParentReleaseInList(Sprint.STATE_DONE, releases).groupBy {
                it.parentRelease
            }.each { Release release, List<Sprint> sprints ->
                sprints.sort { it.orderNumber }.each { Sprint sprint ->
                    sprintEntries << [id: sprint.id, parentReleaseName: release.name, index: sprint.index, state: sprint.state]
                }
            }
        }
        render(status: 200, contentType: 'application/json', text: sprintEntries as JSON)
    }

    @Secured(['isAuthenticated() && (stakeHolder() or inProject()) and !archivedProject()'])
    def listByField(long project, String field) {
        Project _project = Project.withProject(project)
        def projectStories = _project.stories;
        def groupedStories = [:]
        if (field == "effort") {
            groupedStories = projectStories.groupBy { it.effort }
        } else if (field == "value") {
            groupedStories = projectStories.groupBy { it.value }
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

    @Secured('stakeHolder() or inProject()')
    def printByBacklog(long project, long id, String format) {
        Backlog backlog = Backlog.withBacklog(project, id)
        Project _project = backlog.project
        def outputFileName = _project.name + '-' + message(code: backlog.name)
        def stories = Story.search(project, JSON.parse(backlog.filter)).sort { Story story -> story.rank }
        if (!stories) {
            returnError(code: 'is.report.error.no.data')
        } else {
            def data = []
            stories.each {
                data << [
                        uid          : it.uid,
                        name         : it.name,
                        description  : it.description,
                        notes        : it.notes?.replaceAll(/<.*?>/, ''),
                        type         : message(code: grailsApplication.config.icescrum.resourceBundles.storyTypes[it.type]),
                        suggestedDate: it.suggestedDate,
                        creator      : it.creator.firstName + ' ' + it.creator.lastName,
                        feature      : it.feature?.name,
                ]
            }
            renderReport('backlog', format ? format.toUpperCase() : 'PDF', [[project: _project.name, stories: data ?: null]], outputFileName)
        }
    }

    @Secured('stakeHolder() or inProject()')
    def printPostitsByBacklog(long project, long id) {
        Backlog backlog = Backlog.withBacklog(project, id)
        Project _project = backlog.project
        def stories1 = []
        def stories2 = []
        def first = 0
        def stories = Story.search(project, JSON.parse(backlog.filter)).sort { Story story -> story.rank }
        if (!stories) {
            returnError(code: 'is.report.error.no.data')
        } else {
            stories.each {
                def testsByState = it.countTestsByState()
                def story = [
                        name          : it.name,
                        id            : it.uid,
                        effort        : it.effort,
                        state         : message(code: grailsApplication.config.icescrum.resourceBundles.storyStates[it.state]),
                        description   : is.storyDescription([story: it, displayBR: true]),
                        notes         : ServicesUtils.textileToHtml(it.notes),
                        type          : message(code: grailsApplication.config.icescrum.resourceBundles.storyTypes[it.type]),
                        suggestedDate : it.suggestedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.suggestedDate]) : null,
                        acceptedDate  : it.acceptedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.acceptedDate]) : null,
                        estimatedDate : it.estimatedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.estimatedDate]) : null,
                        plannedDate   : it.plannedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.plannedDate]) : null,
                        inProgressDate: it.inProgressDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.inProgressDate]) : null,
                        doneDate      : it.doneDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.doneDate ?: null]) : null,
                        rank          : it.rank ?: null,
                        sprint        : it.parentSprint?.index ? g.message(code: 'is.release') + " " + it.parentSprint.parentRelease.name + " - " + g.message(code: 'is.sprint') + " " + it.parentSprint.index : null,
                        creator       : it.creator.firstName + ' ' + it.creator.lastName,
                        feature       : it.feature?.name ?: null,
                        dependsOn     : it.dependsOn?.name ? it.dependsOn.uid + " " + it.dependsOn.name : null,
                        permalink     : createLink(absolute: true, uri: '/' + _project.pkey + '-' + it.uid),
                        featureColor  : it.feature?.color ?: null,
                        nbTestsTocheck: testsByState[AcceptanceTest.AcceptanceTestState.TOCHECK],
                        nbTestsFailed : testsByState[AcceptanceTest.AcceptanceTestState.FAILED],
                        nbTestsSuccess: testsByState[AcceptanceTest.AcceptanceTestState.SUCCESS]
                ]
                if (first == 0) {
                    stories1 << story
                    first = 1
                } else {
                    stories2 << story
                    first = 0
                }

            }
            renderReport('stories', 'PDF', [[project: _project.name, stories1: stories1 ?: null, stories2: stories2 ?: null]], _project.name)
        }
    }

    @Secured('inProject() or (isAuthenticated() and stakeHolder())')
    def printPostitsBySprint(long project, long id) {
        Sprint sprint = Sprint.withSprint(project, id)
        Project _project = sprint.parentRelease.parentProject
        def stories1 = []
        def stories2 = []
        def first = 0
        def stories = sprint.stories.sort { Story story -> story.rank }
        if (!stories) {
            returnError(code: 'is.report.error.no.data')
        } else {
            stories.each {
                def testsByState = it.countTestsByState()
                def story = [
                        name          : it.name,
                        id            : it.uid,
                        effort        : it.effort,
                        state         : message(code: grailsApplication.config.icescrum.resourceBundles.storyStates[it.state]),
                        description   : is.storyDescription([story: it, displayBR: true]),
                        notes         : ServicesUtils.textileToHtml(it.notes),
                        type          : message(code: grailsApplication.config.icescrum.resourceBundles.storyTypes[it.type]),
                        suggestedDate : it.suggestedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.suggestedDate]) : null,
                        acceptedDate  : it.acceptedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.acceptedDate]) : null,
                        estimatedDate : it.estimatedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.estimatedDate]) : null,
                        plannedDate   : it.plannedDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.plannedDate]) : null,
                        inProgressDate: it.inProgressDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.inProgressDate]) : null,
                        doneDate      : it.doneDate ? g.formatDate([formatName: 'is.date.format.short', timeZone: _project.preferences.timezone, date: it.doneDate ?: null]) : null,
                        rank          : it.rank ?: null,
                        sprint        : it.parentSprint?.index ? g.message(code: 'is.release') + " " + it.parentSprint.parentRelease.name + " - " + g.message(code: 'is.sprint') + " " + it.parentSprint.index : null,
                        creator       : it.creator.firstName + ' ' + it.creator.lastName,
                        feature       : it.feature?.name ?: null,
                        dependsOn     : it.dependsOn?.name ? it.dependsOn.uid + " " + it.dependsOn.name : null,
                        permalink     : createLink(absolute: true, uri: '/' + _project.pkey + '-' + it.uid),
                        featureColor  : it.feature?.color ?: null,
                        nbTestsTocheck: testsByState[AcceptanceTest.AcceptanceTestState.TOCHECK],
                        nbTestsFailed : testsByState[AcceptanceTest.AcceptanceTestState.FAILED],
                        nbTestsSuccess: testsByState[AcceptanceTest.AcceptanceTestState.SUCCESS]
                ]
                if (first == 0) {
                    stories1 << story
                    first = 1
                } else {
                    stories2 << story
                    first = 0
                }

            }
            renderReport('stories', 'PDF', [[project: _project.name, stories1: stories1 ?: null, stories2: stories2 ?: null]], _project.name + '-' + g.message(code: 'is.sprint') + "-" + sprint.index)
        }
    }
}
