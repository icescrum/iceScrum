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
 *
 */

package org.icescrum.web.presentation.app

import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.springframework.web.servlet.support.RequestContextUtils
import org.icescrum.core.utils.BundleUtils
import grails.converters.JSON

@Secured("stakeHolder() or inProduct()")
class QuickLookController {

    def springSecurityService

    def index() {
        if (params.story?.id) {
            forward(action:'story', params:['story.id':params.story.id])
        }

        else if (params.feature?.id) {
            forward(action:'feature', params:['feature.id':params.feature.id])
        }

        else if (params.task?.id) {
            forward(action:'task', params:['task.id':params.task.id])
        }

        else if (params.actor?.id) {
            forward(action:'actor', params:['actor.id':params.actor.id])
        }
    }

    def story() {
        withStory('story.id'){ Story story ->
            def dialog = g.render(template: "/story/quicklook", model: [
                    story: story,
                    typeCode: BundleUtils.storyTypes[story.type],
                    user: springSecurityService.currentUser,
                    locale: RequestContextUtils.getLocale(request)
            ])
            render(status:200, contentType:'application/json', text:[dialog:dialog] as JSON)
        }
    }

    def task() {
        withTask('task.id'){ Task task ->
            def dialog = g.render(template: "/task/quicklook", model: [
                    task: task,
                    user: springSecurityService.currentUser,
                    locale: RequestContextUtils.getLocale(request)
            ])
            render(status:200, contentType:'application/json', text:[dialog:dialog] as JSON)
        }
    }

    def feature() {
        withFeature('feature.id'){ Feature feature ->
            def sum = feature.stories?.sum { story -> story.effort ?: 0 }
            def effort = sum ?: '?'
            def finished = feature.stories?.findAll { story -> story.state == Story.STATE_DONE }?.size() ?: 0

            def dialog = g.render(template: "/feature/quicklook", model: [
                    feature: feature,
                    type: BundleUtils.featureTypes[feature.type],
                    effort: effort,
                    user: springSecurityService.currentUser,
                    finishedStories: finished
            ])
            render(status:200, contentType:'application/json', text:[dialog:dialog] as JSON)
        }
    }

    def actor() {
        withActor('actor.id'){ Actor actor ->
            def dialog = g.render(template: "/actor/quicklook", model: [
                    actor: actor,
                    instancesCode: BundleUtils.actorInstances[actor.instances],
                    useFrequencyCode: BundleUtils.actorFrequencies[actor.useFrequency],
                    expertnessLevelCode: BundleUtils.actorLevels[actor.expertnessLevel],
                    stories: Story.countByActor(actor),
                    user: springSecurityService.currentUser
            ])
            render(status:200, contentType:'application/json', text:[dialog:dialog] as JSON)
        }
    }
}
