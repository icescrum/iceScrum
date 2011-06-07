/*
 * Copyright (c) 2011 Kagilum / 2010 iceScrum Technlogies.
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

import grails.converters.JSON
import org.icescrum.core.domain.Story
import grails.plugins.springsecurity.Secured
import org.icescrum.plugins.attachmentable.interfaces.AttachmentException
import org.icescrum.core.utils.BundleUtils
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Product
import grails.converters.XML
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Release

class StoryController {

    def storyService
    def springSecurityService
    def securityService

    @Secured('isAuthenticated()')
    def save = {
        def story = new Story(params.story as Map)
        if (params.int('displayTemplate') != 1) {
            story.textAs = null
            story.textICan = null
            story.textTo = null
        }

        if (params.feature?.id) {
            story.feature = Feature.get(params.long('feature.id'))
        }
        def user = User.get(springSecurityService.principal.id)
        def product = Product.get(params.product)

        try {
            storyService.save(story, product, user)
            this.manageAttachments(story)
            withFormat {
                html { render status: 200, contentType: 'application/json', text: story as JSON }
                json { render story as JSON }
                xml { render story as XML }
            }
        } catch (AttachmentException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    @Secured('productOwner(#p) or scrumMaster(#p)')
    def update = {
        if (!params.long('story.id')) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        def story = Story.get(params.long('story.id'))

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        if (params.boolean('loadrich')) {
            render(status: 200, text: story.notes ?: '')
            return
        }

        // If the version is different, the feature has been modified since the last loading
        if (params.long('story.version') != story.version) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.stale.object', args: [message(code: 'is.story')])]] as JSON)
            return
        }
        try {

            def next = null
            if (params.continue) {
                if (story.state == Story.STATE_SUGGESTED)
                    next = Story.findNextSuggested(params.long('product'), story.suggestedDate).list()[0]
                else if (story.state <= Story.STATE_ESTIMATED)
                    next = Story.findNextAcceptedOrEstimated(params.long('product'), story.rank).list()[0]
                else if (story.state < Story.STATE_DONE)
                    next = Story.findNextStoryBySprint(story.parentSprint.id, story.rank).list()[0]
            }

            if (params.story.effort && !params.story.effort.isNumber())
                params.story.effort = null


            if (params.story.rank && story.rank != params.int('story.rank')) {
                storyService.rank(story, params.int('story.rank'))
            }

            if (params.sprint?.id != null) {
                if (!params.sprint.id.isNumber() && story.parentSprint)
                    storyService.unPlan(story)
                else if (params.long('sprint.id') != story.parentSprint?.id)
                    storyService.plan(Sprint.get(params.long('sprint.id')), story)
                params.story.rank = story.rank
            }



            story.properties = params.story

            if (params.int('displayTemplate') && params.int('displayTemplate') != 1) {
                story.textAs = null
                story.textICan = null
                story.textTo = null
                story.actor = null
            }

            if (params.feature?.id && story.feature?.id != params.long('feature.id')) {
                storyService.associateFeature(Feature.get(params.long('feature.id')), story)
            } else if (story.feature && params.feature?.id == '') {
                storyService.dissociateFeature(story)
            }

            storyService.update(story)
            this.manageAttachments(story)

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
                render(status: 200, text: [version: version, value: returnValue ?: ''] as JSON)
                return
            }
            withFormat {
                html { render status: 200, contentType: 'application/json', text: [story: story, next: next?.id ?: null] as JSON }
                json { render story as JSON }
                xml { render story as XML }
            }
        } catch (AttachmentException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        } catch (IllegalStateException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    @Secured('productOwner()')
    def delete = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def stories = Story.getAll(params.list('id'))

        if (!stories) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }
        try {
            def ids = []
            stories.each { ids << [id: it.id, state: it.state] }
            storyService.delete(stories)
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: ids as JSON)  }
                json { render(status: 200, text: [result: 'success'] as JSON) }
                xml { render(status: 200, text: [result: 'success'] as XML) }
            }
        } catch (Exception e) {
            render(status: 400, contentType: 'application/json', text: message(code: 'is.story.error.not.deleted'))
        }
    }

    def edit = {
        def id = params.long('subid') ?: params.long('id')
        if (!id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }

        def story = Story.get(id)

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        if (story.state == Story.STATE_DONE) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.done')]] as JSON)
            return
        }

        def user = springSecurityService.currentUser
        if (story.state == Story.STATE_SUGGESTED && !(story.creator.id == user.id) && !securityService.productOwner(story.backlog.id, springSecurityService.authentication)) {
            render(status: 403, contentType: 'application/json')
            return
        } else if (story.state > Story.STATE_SUGGESTED && !securityService.productOwner(story.backlog.id, springSecurityService.authentication)) {
            render(status: 403, contentType: 'application/json')
            return
        }

        def product = (Product) story.backlog

        def sprints = []
        def release = Release.findCurrentOrNextRelease(story.backlog.id).list()[0];
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
            next = Story.findNextSuggested(params.long('product'), story.suggestedDate).list()[0]
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
                referrer: params.referrer
        ])
    }

    @Secured('productOwner()')
    def rank = {

        if (!params.idmoved) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        def movedItem = Story.get(params.long('idmoved'))

        if (!movedItem) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        def position = params.int('position')
        if (movedItem == null || position == null)
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.rank.error')]] as JSON)
        if (storyService.rank(movedItem, position)) {
            render(status: 200)
        } else {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.rank.error')]] as JSON)
        }
    }

    @Secured('teamMember() or scrumMaster()')
    def estimate = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: 'is.story.error.not.exist']] as JSON)
            return
        }
        def story = Story.get(params.long('id'))

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        try {
            storyService.estimate(story, params.value)
        } catch (IllegalStateException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e)]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
        render(status: 200, text: params.value)
    }

    @Secured('productOwner() or scrumMaster()')
    def unPlan = {
        if (!params.id) {
            def msg = message(code: 'is.story.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def story = Story.get(params.long('id'))

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        try {
            def capacity = (story.parentSprint.state == Sprint.STATE_WAIT) ? (story.parentSprint.capacity -= story.effort) : story.parentSprint.capacity
            def sprint = [id: story.parentSprint.id, class: Sprint.class, velocity: story.parentSprint.velocity, capacity: capacity, state: story.parentSprint.state]

            if (params.boolean('shiftToNext')) {
                def nextSprint = Sprint.findByParentReleaseAndOrderNumber(story.parentSprint.parentRelease, story.parentSprint.orderNumber + 1)
                if (nextSprint) {
                    storyService.plan(nextSprint, story)
                } else {
                    render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.shiftedToNext')]] as JSON)
                    return
                }
            } else {
                storyService.unPlan(story)
            }
            render(status: 200, contentType: 'application/json', text: [story: story, sprint: sprint] as JSON)
        } catch (IllegalStateException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e)]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def plan = {
        if (!params.sprint.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        if (!params.id) {
            def msg = message(code: 'is.story.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.get(params.long('sprint.id'))

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        def story = Story.get(params.long('id'))

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        if (story.parentSprint?.id == params.sprint.id) {
            render(status: 200)
            return
        }

        try {
            def oldSprint = null;
            if (story.parentSprint) {
                def capacity = (story.parentSprint.state == Sprint.STATE_WAIT) ? (story.parentSprint.capacity -= story.effort) : story.parentSprint.capacity
                oldSprint = [id: story.parentSprint.id, class: Sprint.class, velocity: story.parentSprint.velocity, capacity: capacity, state: story.parentSprint.state]
            }
            storyService.plan(sprint, story)
            if (params.position && params.int('position') != 0) {
                storyService.rank(story, params.int('position'))
            }
            render(status: 200, contentType: 'application/json', text: [story: story, oldSprint: oldSprint] as JSON)
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def associateFeature = {
        if (!params.feature || !params.story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlog.associateFeature.error')]] as JSON)
            return
        }
        def feature = Feature.get(params.long('feature.id'))
        def story = Story.get(params.long('story.id'))

        if (!feature || !story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.backlog.associateFeature.error')]] as JSON)
            return
        }
        try {
            storyService.associateFeature(feature, story)
            render(status: 200, contentType: 'application/json', text: story as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    @Secured('productOwner()')
    def done = {
        if (!params.id) {
            def msg = message(code: 'is.story.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def story = Story.get(params.long('id'))

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        try {
            storyService.done(story)
            render(status: 200, contentType: 'application/json', text: story as JSON)
        } catch (IllegalStateException ise) {
            if (log.debugEnabled) ise.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    @Secured('productOwner()')
    def unDone = {
        if (!params.id) {
            def msg = message(code: 'is.story.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def story = Story.get(params.long('id'))

        if (!story) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
            return
        }

        try {
            storyService.unDone(story)
            render(status: 200, contentType: 'application/json', text: story as JSON)
        } catch (IllegalStateException ise) {
            if (log.debugEnabled) ise.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: story)]] as JSON)
        }
    }

    @Secured('productOwner()')
    def accept = {
        if (params.list('id').size() == 0) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.sandbox.menu.accept.error.no.selection')]] as JSON)
            return
        }
        def stories = Story.getAll(params.list('id'))
        def storiesJ = []
        def storiesIds = stories*.id
        try {
            if (params.type == 'story') {
                storiesJ = storyService.acceptToBacklog(stories)
            } else if (params.type == 'feature') {
                storiesJ = storyService.acceptToFeature(stories)
            } else if (params.type == 'task') {
                storiesJ = storyService.acceptToUrgentTask(stories)
            }
            render(status: 200, contentType: 'application/json', text: [id: storiesIds, objects: storiesJ] as JSON)
        } catch (IllegalStateException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: e.getMessage())]] as JSON)
        }
    }

    def download = {
        forward(action: 'download', controller: 'attachmentable', id: params.id)
        return
    }

    @Secured('inProduct()')
    def copy = {

        if (params.list('id').size() == 0) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.ui.sandbox.menu.accept.error.no.selection')]] as JSON)
            return
        }
        def stories = Story.getAll(params.list('id'))
        try {
            def copiedStories = storyService.copy(stories)
            render(status: 200, contentType: 'application/json', text: copiedStories as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.story.error.not.cloned')]] as JSON)
        }
    }

    private manageAttachments(def story) {
        def user = User.load(springSecurityService.principal.id)
        if (params.story.attachments && story.id && !params.story.list('attachments') && story.attachments*.id.size() > 0) {
            story.removeAllAttachments()
        } else if (story.attachments*.id.size() > 0) {
            story.attachments*.id.each {
                if (!params.story.list('attachments').contains(it.toString()))
                    story.removeAttachment(it)
            }
        }
        def uploadedFiles = []
        params.list('attachments')?.each { attachment ->
            "${attachment}".split(":").with {
                if (session.uploadedFiles[it[0]])
                    uploadedFiles << [file: new File((String) session.uploadedFiles[it[0]]), name: it[1]]
            }
        }
        if (uploadedFiles)
            story.addAttachments(user, uploadedFiles)
        session.uploadedFiles = null
    }
}
