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

class QuickLookController {

    static ui = true

    def springSecurityService

    static StoryStateBundle = [
            (Story.STATE_SUGGESTED):'is.story.state.suggested',
            (Story.STATE_ACCEPTED):'is.story.state.accepted',
            (Story.STATE_ESTIMATED):'is.story.state.estimated',
            (Story.STATE_PLANNED):'is.story.state.planned',
            (Story.STATE_INPROGRESS):'is.story.state.inprogress',
            (Story.STATE_DONE):'is.story.state.done'
    ]

    static StoryTypesBundle = [
            (Story.TYPE_USER_STORY): 'is.story.type.story',
            (Story.TYPE_DEFECT): 'is.story.type.defect',
            (Story.TYPE_TECHNICAL_STORY): 'is.story.type.technical'
    ]

    static FeatureTypesBundle = [
            (Feature.TYPE_FUNCTIONAL): 'is.feature.type.functional',
            (Feature.TYPE_ARCHITECTURAL): 'is.feature.type.architectural'
    ]

    static TaskStateBundle = [
          (Task.STATE_WAIT):'is.task.state.wait',
          (Task.STATE_BUSY):'is.task.state.inprogress',
          (Task.STATE_DONE):'is.task.state.done'
    ]

    static ActorInstancesBundle = [
          (Actor.NUMBER_INSTANCES_INTERVAL_1): '1',
          (Actor.NUMBER_INSTANCES_INTERVAL_2): '2-5',
          (Actor.NUMBER_INSTANCES_INTERVAL_3): '6-10',
          (Actor.NUMBER_INSTANCES_INTERVAL_4): '11-100',
          (Actor.NUMBER_INSTANCES_INTERVAL_5): '100+'
    ]

    static ActorLevelsBundle = [
            (Actor.EXPERTNESS_LEVEL_LOW): 'is.actor.it.low',
            (Actor.EXPERTNESS_LEVEL_MEDIUM): 'is.actor.it.medium',
            (Actor.EXPERTNESS_LEVEL_HIGH): 'is.actor.it.high'
    ]

    static ActorFrequenciesBundle = [
            (Actor.USE_FREQUENCY_HOUR): 'is.actor.use.frequency.hour',
            (Actor.USE_FREQUENCY_DAY): 'is.actor.use.frequency.day',
            (Actor.USE_FREQUENCY_WEEK): 'is.actor.use.frequency.week',
            (Actor.USE_FREQUENCY_MONTH): 'is.actor.use.frequency.month',
            (Actor.USE_FREQUENCY_TRIMESTER): 'is.actor.use.frequency.quarter'
    ]


    @Secured("stakeHolder() or inProduct()")
    def index = {
    if (params.story?.id) {
      def story = Story.get(params.long('story.id'))
      if(!story){
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.story.error.not.exist')]] as JSON)
        return
      }
      render(template:"story",model:[
              story:story,
              typeCode: StoryTypesBundle[story.type],
              user:springSecurityService.currentUser,
              locale: RequestContextUtils.getLocale(request)
      ])
    }

    else if (params.feature?.id) {
      def feature = Feature.get(params.long('feature.id'))
      if (!feature){
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code: 'is.feature.error.not.exist')]] as JSON)
        return
      }
      def sum = feature.stories?.sum { story -> story.effort ?: 0 }
      def effort = sum?:'?'
      def finished = feature.stories?.findAll { story -> story.state == Story.STATE_DONE }?.size() ?: 0

      render(template:"feature",model:[
              feature: feature,
              type: FeatureTypesBundle[feature.type],
              effort: effort,
              user:springSecurityService.currentUser,
              finishedStories: finished
      ])
    }

    else if (params.task?.id) {
      def task = Task.get(params.long('task.id'))

      if (!task) {
        render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: 'is.task.error.not.exist')]] as JSON)
        return
      }

      render(template: "task", model: [
              task: task,
              user:springSecurityService.currentUser,
              locale: RequestContextUtils.getLocale(request)
      ])
    }

    else if (params.actor?.id) {
     def actor = Actor.get(params.long('actor.id'))

      if(!actor) {
        render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.actor.error.not.exist')]] as JSON)
        return
      }

      render(template:"actor",model:[
              actor: actor,
              instancesCode: ActorInstancesBundle[actor.instances],
              useFrequencyCode: ActorFrequenciesBundle[actor.useFrequency],
              expertnessLevelCode: ActorLevelsBundle[actor.expertnessLevel],
              stories:Story.findAllByTextAsIlike(actor.name).size(),
              user:springSecurityService.currentUser
      ])
    }
  }
}
