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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */

package org.icescrum.web.presentation.app.team

import grails.converters.JSON
import grails.plugins.springsecurity.Secured

import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Team
import org.icescrum.web.support.MenuBarSupport
import grails.plugin.springcache.annotations.Cacheable

@Secured('inTeam()')
class TimelinesController {

  static ui = true

  static final id = 'timelines'
  static menuBar = MenuBarSupport.teamDynamicBar('is.ui.timeline', id, true, 102)
  static window = [title: 'is.ui.timeline',help:'is.ui.timeline.help', toolbar: true]

  def releaseService
  def productService
  def featureService

  static SprintStateBundle = [
          (Sprint.STATE_WAIT):'is.sprint.state.wait',
          (Sprint.STATE_INPROGRESS):'is.sprint.state.inprogress',
          (Sprint.STATE_DONE):'is.sprint.state.done'
  ]

  def index = {
    render(template: 'window/timelineView', model: [id: id])
  }

  def toolbar = {
    render(template:'window/toolbar')
  }

  def timeLineList = {

    def list = []
    def team = Team.get(params.long('team'))

    for (currentProduct in team.products) {

      def date = new Date(currentProduct.startDate.getTime() - 1000)
      def startProject = [start: date, end: date, durationEvent: false, classname: "timeline-startproject"]

      list.add(startProject)

      currentProduct.releases.each {
        def templateTooltip = include(view: "$controllerName/tooltips/_tooltipReleaseDetails.gsp", model: [release: it])


        it.sprints.eachWithIndex { it2, index ->
          def colorS
          def textColorS = "#444"
          switch (it2.state) {
            case Sprint.STATE_WAIT:
              colorS = "#BBBBBB"
              break
            case Sprint.STATE_INPROGRESS:
              colorS = "#C8E5FC"
              break
            case Sprint.STATE_DONE:
              colorS = "#C1FF89"
              break
          }
          templateTooltip = include(view: "$controllerName/tooltips/_tooltipSprintDetails.gsp", model: [sprint: it2])
          def tlS = [url: createLink(controller:'scrumOS',params:[product:it.parentProduct.id])+"#sprintBacklog/${it2.id}",
                  start: it2.startDate,
                  end: it2.endDate,
                  durationEvent: true,
                  title: "#${index + 1}",
                  color: colorS,
                  textColor: textColorS,
                  classname: "timeline-sprint",
                  eventID: it2.id,
                  tooltipContent: templateTooltip,
                  tooltipTitle: "${message(code: 'is.sprint')} ${index + 1} (${message(code: SprintStateBundle[it2.state])})"]
          list.add(tlS)
        }
      }
    }
    render([dateTimeFormat: "iso8601", events: list] as JSON)
  }


}
