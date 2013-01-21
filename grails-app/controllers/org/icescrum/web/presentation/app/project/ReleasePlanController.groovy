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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.app.project

import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.PlanningPokerGame
import org.icescrum.core.domain.Story
import grails.converters.JSON
import grails.plugin.springcache.annotations.Cacheable
import grails.plugins.springsecurity.Secured
import java.text.DecimalFormat
import org.icescrum.core.domain.Task

@Secured('(isAuthenticated() and stakeHolder()) or inProduct()')
class ReleasePlanController {
    def storyService
    def springSecurityService
    def releaseService
    def featureService

    def titleBarContent = {
        def release
        if (!params.id) {
            release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
            if (release) {
                params.id = release.id
            }
        } else {
            release = Release.getInProduct(params.long('product'),params.long('id')).list()
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
        render(template: 'window/titleBarContent', model: [releases: releasesHtml, release: release])
    }

    def toolbar = {
        def release
        if (!params.id) {
            release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
            if (release) {
                params.id = release.id
            }
        } else {
            release = Release.getInProduct(params.long('product'),params.long('id')).list()
        }
        if (!release) {
            render(status: 200)
            return
        }
        render(template: 'window/toolbar', model: [release: release])
    }

    def index = {
        def release
        if (!params.id) {
            release = Release.findCurrentOrNextRelease(params.long('product')).list()[0]
            if (release) {
                params.id = release.id
            } else {
                render(template: 'window/blank')
                return
            }
        } else {
            release = Release.getInProduct(params.long('product'),params.long('id')).list()
        }
        if (!release || !(release instanceof Release)) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }
        def sprints = release?.sprints?.asList()
        def activeSprint = release?.sprints?.find { it.state == Sprint.STATE_INPROGRESS }

        if (!activeSprint){
             activeSprint = release?.sprints?.find { it.activable }
        }

        def suiteSelect = ''
        def currentSuite = PlanningPokerGame.getInteger(release.parentProduct.planningPokerGameType)

        currentSuite = currentSuite.eachWithIndex { t, i ->
            suiteSelect += "'${t}':'${t}'" + (i < currentSuite.size() - 1 ? ',' : '')
        }

        render(template: 'window/postitsView', model: [release: release, sprints: sprints,activeSprint: activeSprint, releaseId: release.id, suiteSelect: suiteSelect])
    }


    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def close = {
        withSprint{Sprint sprint ->
            def unDoneStories = sprint.stories.findAll {it.state != Story.STATE_DONE}
            if ((unDoneStories?.size() > 0 || !sprint.deliveredVersion) && !params.confirm) {
                def dialog = g.render(template: "dialogs/confirmCloseSprintWithUnDoneStories", model: [stories: unDoneStories, sprint: sprint])
                render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                return
            }
            if (unDoneStories?.size() > 0 && params.confirm) {
                params.story.id.each {
                    if (it.value.toInteger() == 1) {
                        storyService.done(Story.get(it.key.toLong()))
                    }
                }
            }

            if (params.sprint?.deliveredVersion){
                sprint.deliveredVersion = params.sprint.deliveredVersion
            }
            forward(action: 'close', controller: 'sprint', params: [product: params.product, id: sprint.id])
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def activate = {
        withSprint{Sprint sprint ->
            if (sprint.orderNumber == 1 && sprint.parentRelease.state == Release.STATE_WAIT && !params.confirm) {
                def dialog = g.render(template: "dialogs/confirmActivateSprintAndRelease", model: [sprint: sprint, release: sprint.parentRelease])
                render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                return
            }

            if (params.confirm) {
                def currentRelease = sprint.parentRelease.parentProduct.releases?.find {it.state == Release.STATE_INPROGRESS}
                if (currentRelease)
                    releaseService.close(currentRelease)
                releaseService.activate(sprint.parentRelease)
            }
            forward(action: 'activate', controller: 'sprint', params: [product: params.product, id: sprint.id])
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def delete = {
        withSprint{Sprint sprint ->
            if (sprint.orderNumber < sprint.parentRelease.sprints.size() && !params.confirm) {
                def dialog = g.render(template: "dialogs/confirmDeleteSprint", model: [sprint: sprint, release: sprint.parentRelease])
                render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
                return
            }
            forward(action: 'delete', controller: 'sprint', params: [product: params.product, id: sprint.id])
        }
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def autoPlan = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        if (!params.capacity) {
            def dialog = g.render(template: "dialogs/promptCapacityAutoPlan")
            render(status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON)
            return
        }
        forward(action: 'autoPlan', controller: 'release', params: [product: params.product, id: params.id])
    }


    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def add = {
        if (!params.id) {
            def msg = message(code: 'is.release.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def release = Release.getInProduct(params.long('product'),params.long('id')).list()

        if (!release) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.release.error.not.exist')]] as JSON)
            return
        }

        def previousSprint = release?.sprints?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}

        render(template: 'window/manage', model: [
                currentPanel: 'add',
                release: release,
                previousSprint: previousSprint,
                product: release.parentProduct
        ])
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def edit = {
        if (!params.subid) {
            def msg = message(code: 'is.sprint.error.not.exist')
            render(status: 400, contentType: 'application/json', text: [notice: [text: msg]] as JSON)
            return
        }
        def sprint = Sprint.getInProduct(params.long('product'),params.long('subid')).list()

        if (!sprint) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.sprint.error.not.exist')]] as JSON)
            return
        }

        def previousSprint = sprint.parentRelease.sprints?.max {s1, s2 -> s1.orderNumber <=> s2.orderNumber}
        def next = Sprint.findByOrderNumberAndParentRelease(sprint.orderNumber + 1, sprint.parentRelease)
        render(template: 'window/manage', model: [
                currentPanel: 'edit',
                release: sprint.parentRelease,
                next: next?.id ?: null,
                sprint: sprint,
                previousSprint: previousSprint,
                product: sprint.parentRelease.parentProduct
        ])
    }

    @Secured('(productOwner() or scrumMaster()) and !archivedProduct()')
    def editStory = {
        forward(action: 'edit', controller: 'story', params: [referrer: controllerName])
    }

    def vision = {
        withRelease{ Release release ->
            render(template: 'window/visionView', model: [release: release])
        }
    }

    @Secured('productOwner() and !archivedProduct()')
    def updateVision = {
        withRelease{ Release release ->
            release.vision = params.vision
            releaseService.updateVision(release)
            render(status: 200)
        }
    }

    @Cacheable(cache = "releaseCache", keyGenerator = 'releaseKeyGenerator')
    def releaseBurndownChart = {
        Release release = getRelease(false)
        if (release){
            def values = releaseService.releaseBurndownValues(release)
            if (values.size() > 0) {
                render(template: 'charts/releaseBurndownChart', model: [
                        userstories: values.userstories as JSON,
                        technicalstories: values.technicalstories as JSON,
                        defectstories: values.defectstories as JSON,
                        labels: values.label as JSON])
                return
            }
        }
        returnError(text:message(code: 'is.chart.error.no.values'))
    }

    @Cacheable(cache = "releaseCache", keyGenerator = 'releaseKeyGenerator')
    def releaseParkingLotChart = {
        Release release = getRelease(false)
        if (release){
            def values = featureService.releaseParkingLotValues(release)

            def valueToDisplay = []
            def indexF = 1
            values.value?.each {
                def value = []
                value << new DecimalFormat("#.##").format(it).toString()
                value << indexF
                valueToDisplay << value
                indexF++
            }
            if (valueToDisplay.size() > 0) {
                render(template: 'charts/releaseParkingLot', model: [values: valueToDisplay as JSON, featuresNames: values.label as JSON])
                return
            }
        }
        returnError(text:message(code: 'is.chart.error.no.values'))
    }

    @Cacheable(cache = "releaseCache", keyGenerator = 'releaseKeyGenerator')
    def notes = {
        withRelease{ Release release ->
            render(status:200,
                    template: 'window/notes',
                    model:[ release:release,
                            tasks:release.sprints*.tasks.flatten().findAll{ it.type == Task.TYPE_URGENT && it.state == Task.STATE_DONE },
                            technicalStories:release.sprints*.stories.flatten().findAll{ it.type == Story.TYPE_TECHNICAL_STORY && it.state == Story.STATE_DONE },
                            userStories:release.sprints*.stories.flatten().findAll{it.type == Story.TYPE_USER_STORY && it.state == Story.STATE_DONE},
                            defectStories:release.sprints*.stories.flatten().findAll{it.type == Story.TYPE_DEFECT && it.state == Story.STATE_DONE}])
        }
    }

    @Secured('inProduct()')
    def addDocument = {
        withRelease { Release release ->
            def dialog = g.render(template: '/attachment/dialogs/documents', model: [bean:release, destController:'release'])
            render status: 200, contentType: 'application/json', text: [dialog: dialog] as JSON
        }
    }

    private getRelease(withNext = true){
        def currentProduct = Product.load(params.product)
        def release
        if (!params.id) {
            release = withNext ? Release.findCurrentOrNextRelease(currentProduct.id).list()[0] : Release.findCurrentOrLastRelease(currentProduct.id).list()[0]
        } else {
            release = (Release)Release.getInProduct(params.long('product'),params.long('id')).list()
        }
        return release
    }
}
