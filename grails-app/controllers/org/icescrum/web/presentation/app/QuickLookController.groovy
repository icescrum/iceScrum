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

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.springframework.web.servlet.support.RequestContextUtils
import org.icescrum.core.utils.BundleUtils

class QuickLookController {

    static ui = true

    def springSecurityService

    @Secured("stakeHolder() or inProduct()")
    def index = {
        if (params.story?.id) {

            def story = Story.getInProduct(params.long('product'),params.long('story.id')).list()[0]

            if (!story) {
                returnError(text:message(code: 'is.story.error.not.exist'))
                return
            }
            render(template: "/story/quicklook", model: [
                    story: story,
                    typeCode: BundleUtils.storyTypes[story.type],
                    user: springSecurityService.currentUser,
                    locale: RequestContextUtils.getLocale(request)
            ])
        }

        else if (params.feature?.id) {
            def feature = Feature.getInProduct(params.long('product'),params.long('feature.id')).list()[0]
            if (!feature) {
                returnError(text:message(code: 'is.feature.error.not.exist'))
                return
            }
            def sum = feature.stories?.sum { story -> story.effort ?: 0 }
            def effort = sum ?: '?'
            def finished = feature.stories?.findAll { story -> story.state == Story.STATE_DONE }?.size() ?: 0

            render(template: "/feature/quicklook", model: [
                    feature: feature,
                    type: BundleUtils.featureTypes[feature.type],
                    effort: effort,
                    user: springSecurityService.currentUser,
                    finishedStories: finished
            ])
        }

        else if (params.task?.id) {
            def task = Task.get(params.long('task.id'))

            if (!task) {
                returnError(text:message(code: 'is.task.error.not.exist'))
                return
            }

            render(template: "/task/quicklook", model: [
                    task: task,
                    user: springSecurityService.currentUser,
                    locale: RequestContextUtils.getLocale(request)
            ])
        }

        else if (params.actor?.id) {
            def actor = Actor.getInProduct(params.long('product'),params.long('actor.id')).list()[0]

            if (!actor) {
                returnError(text:message(code: 'is.actor.error.not.exist'))
                return
            }

            render(template: "/actor/quicklook", model: [
                    actor: actor,
                    instancesCode: BundleUtils.actorInstances[actor.instances],
                    useFrequencyCode: BundleUtils.actorFrequencies[actor.useFrequency],
                    expertnessLevelCode: BundleUtils.actorLevels[actor.expertnessLevel],
                    stories: Story.findAllByTextAsIlike(actor.name).size(),
                    user: springSecurityService.currentUser
            ])
        }
    }
}
