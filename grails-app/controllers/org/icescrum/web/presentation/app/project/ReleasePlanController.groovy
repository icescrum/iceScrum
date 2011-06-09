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
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint

import org.icescrum.core.support.MenuBarSupport
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Story

@Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
class ReleasePlanController {
    def storyService
    def springSecurityService
    def sprintService
    def releaseService
    def featureService

    static ui = true

    static final id = 'releasePlan'
    static menuBar = MenuBarSupport.productDynamicBar('is.ui.releasePlan', id, true, 4)
    static window = [title: 'is.ui.releasePlan', help: 'is.ui.releasePlan.help', init: 'index', toolbar: true, titleBarContent: true]

    static shortcuts = [
            [code: 'is.ui.shortcut.escape.code', text: 'is.ui.shortcut.escape.text'],
            [code: 'is.ui.shortcut.ctrln.code', text: 'is.ui.shortcut.releasePlan.ctrln.text'],
            [code: 'is.ui.shortcut.ctrlg.code', text: 'is.ui.shortcut.releasePlan.ctrlg.text'],
            [code: 'is.ui.shortcut.ctrlshifta.code', text: 'is.ui.shortcut.releasePlan.ctrlshifta.text'],
            [code: 'is.ui.shortcut.ctrlshiftv.code', text: 'is.ui.shortcut.releasePlan.ctrlshiftv.text'],
            [code: 'is.ui.shortcut.ctrlshiftd.code', text: 'is.ui.shortcut.releasePlan.ctrlshiftd.text']
    ]

    def titleBarContent = {
        def release
        if (!params.id) {
            release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
            if (release) {
                params.id = release.id
            }
        } else {
            release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        }
        def releases
        if (!release) {
            releases = Release.findAllByParentProduct(Product.get(params.product), [sort: 'startDate'])
        } else {
            releases = Release.findAllByParentProduct(release.parentProduct, [sort: 'startDate'])
        }
        def releasesHtml = []
        releases.each {
            def u = [:]
            u.id = it.id
            u.name = it.name.encodeAsHTML()
            releasesHtml << u
        }
        render(template: 'window/titleBarContent', model: [currentView: session.currentView, id: id, releases: releasesHtml, release: release])
    }

    def toolbar = {
        def release
        if (!params.id) {
            release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
            if (release) {
                params.id = release.id
            }
        } else {
            release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        }
        if (!release) {
            render(status: 200)
            return
        }
        render(template: 'window/toolbar', model: [currentView: session.currentView, id: id, release: release])
    }

    def index = {
        def release
        if (!params.id) {
            release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
            if (release) {
                params.id = release.id
            } else {
                render(template: 'window/blank', model: [id: id])
                return
            }
        } else {
            release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        }
        if (!release || !(release instanceof Release)) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.release.not.exist')]] as JSON)
            return
        }
        def sprints = release?.sprints?.asList()
        def activeSprint = release?.sprints?.find { it.state == Sprint.STATE_INPROGRESS }

        def suiteSelect = ''
        def currentSuite = PlanningPokerGame.getInteger(release.parentProduct.planningPokerGameType)

        currentSuite = currentSuite.eachWithIndex { t, i ->
            suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
        }

        render(template: 'window/postitsView', model: [release: release, sprints: sprints, id: id, activeSprint: activeSprint, releaseId: release.id, suiteSelect: suiteSelect])
    }


    @Secured('productOwner() or scrumMaster()')
    def close = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        def unDoneStories = sprint.stories.findAll {it.state != Story.STATE_DONE}
        if (unDoneStories?.size() > 0 && !params.confirm) {
            def dialog = g.render(template: "dialogs/confirmCloseSprintWithUnDoneStories", model: [stories: unDoneStories, sprint: sprint, id: id])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
            return
        }
        try {
            if (unDoneStories?.size() > 0 && params.confirm) {
                params.story.id.each {
                    if (it.value.toInteger() == 1) {
                        storyService.done(Story.get(it.key.toLong()))
                    }
                }
            }
            forward(action: 'close', controller: 'sprint', params: [product: params.product, id: sprint.id])
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            if (log.debugEnabled) e.printStackTrace()
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def activate = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        if (sprint.orderNumber == 1 && sprint.parentRelease.state == Release.STATE_WAIT && !params.confirm) {
            def dialog = g.render(template: "dialogs/confirmActivateSprintAndRelease", model: [sprint: sprint, release: sprint.parentRelease, id: id])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
            return
        }

        try {
            if (params.confirm) {
                def currentRelease = sprint.parentRelease.parentProduct.releases?.find {it.state == Release.STATE_INPROGRESS}
                if (currentRelease)
                    releaseService.close(currentRelease)
                releaseService.activate(sprint.parentRelease)
            }
            forward(action: 'activate', controller: 'sprint', params: [product: params.product, id: sprint.id])
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException e) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }
    }

    @Secured('productOwner() or scrumMaster()')
    def delete = {
        if (!params.id) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        if (sprint.orderNumber < sprint.parentRelease.sprints.size() && !params.confirm) {
            def dialog = g.render(template: "dialogs/confirmDeleteSprint", model: [sprint: sprint, release: sprint.parentRelease, id: id])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
            return
        }

        try {
            forward(action: 'delete', controller: 'sprint', params: [product: params.product, id: sprint.id])
        } catch (IllegalStateException ise) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: ise.getMessage())]] as JSON)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: sprint)]] as JSON)
        }

    }

    @Secured('productOwner() or scrumMaster()')
    def autoPlan = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        if (!params.capacity) {
            def dialog = g.render(template: "dialogs/promptCapacityAutoPlan", model: [id: id])
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
            return
        }
        forward(action: 'autoPlan', controller: 'release', params: [product: params.product, id: params.id])
    }


    @Secured('productOwner() or scrumMaster()')
    def add = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        def previousSprint = release?.sprints?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}

        render(template: 'window/manage', model: [
                id: id,
                currentPanel: 'add',
                release: release,
                previousSprint: previousSprint,
                product: release.parentProduct
        ])
    }

    @Secured('productOwner() or scrumMaster()')
    def edit = {
        if (!params.subid) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('subid')).list()[0]

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        def previousSprint = sprint.parentRelease.sprints?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}
        def next = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber + 1, sprint.parentRelease)
        render(template: 'window/manage', model: [
                id: id,
                currentPanel: 'edit',
                release: sprint.parentRelease,
                next: next?.id ?: null,
                sprint: sprint,
                previousSprint: previousSprint,
                product: sprint.parentRelease.parentProduct
        ])
    }

    @Secured('productOwner() or scrumMaster()')
    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: id])
    }

    def vision = {
        if (!params.id) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }
        render(template: 'window/visionView', model: [release: release, id: id])
    }

    @Secured('productOwner()')
    def updateVision = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]
        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }
        release.vision = params.vision

        try {
            releaseService.updateVision(release)
            render(status: 200)
        } catch (RuntimeException re) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: renderErrors(bean: release)]] as JSON)
        }
    }

    def releaseBurndownChart = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        def values = releaseService.releaseBurndownValues(release)
        if (values.size() > 0) {
            render(template: 'charts/releaseBurndownChart', model: [
                    id: id,
                    userstories: values.userstories as JSON,
                    technicalstories: values.technicalstories as JSON,
                    defectstories: values.defectstories as JSON,
                    labels: values.label as JSON])
        } else {
            def msg = message(code: 'is.chart.error.no.values')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
        }
    }

    def releaseParkingLotChart = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }

        def release = Release.getInProduct(params.long('product'),params.long('id')).list()[0]

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        def values = featureService.releaseParkingLotValues(release)

        def valueToDisplay = []
        def indexF = 1
        values.value?.each {
            def value = []
            value << it.toString()
            value << indexF
            valueToDisplay << value
            indexF++
        }
        if (valueToDisplay.size() > 0)
            render(template: 'charts/releaseParkingLot', model: [id: id, values: valueToDisplay as JSON, featuresNames: values.label as JSON])
        else {
            def msg = message(code: 'is.chart.error.no.values')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
        }
    }
}
