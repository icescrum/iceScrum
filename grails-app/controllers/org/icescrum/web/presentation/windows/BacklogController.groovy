/*
 * Copyright (c) 2014 Kagilum SAS
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

package org.icescrum.web.presentation.windows

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Backlog
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Story
import org.icescrum.core.error.ControllerErrorHandler

@Secured(['stakeHolder() or inProject()'])
class BacklogController implements ControllerErrorHandler {

    def springSecurityService
    def grailsApplication

    @Secured(['stakeHolder() or inProject()'])
    def index(long project) {
        def backlogs = Backlog.findAllByProjectAndShared(Project.load(project), true).findAll { it.isDefault }.sort { it.id }
        render(status: 200, contentType: 'application/json', text: backlogs as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def show(long project, long id) {
        Backlog backlog = Backlog.withBacklog(project, id)
        if (!backlog.isDefault && backlog.owner != springSecurityService.currentUser && !backlog.shared && !request.admin) {
            render(status: 403)
            return
        }
        render(status: 200, contentType: 'application/json', text: backlog as JSON)
    }

    @Secured(['stakeHolder() or inProject()'])
    def chartByProperty(long id, long project, String chartType, String chartUnit) {
        if (chartType in grailsApplication.config.icescrum.resourceBundles.backlogChartTypes.keySet()) {
            Backlog backlog = Backlog.withBacklog(project, id)
            if (!backlog.isDefault && backlog.owner != springSecurityService.currentUser && !backlog.shared && !request.admin) {
                render(status: 403)
                return
            }
            Project _project = Project.withProject(project)
            def storyStateNames = _project.getStoryStateNames()
            def dataPoints = [], colors = [], total = 0
            def typei18n
            Story.search(project, JSON.parse(backlog.filter)).groupBy({ story -> story."$chartType" }).each {
                def dataPoint = []
                switch (chartType) {
                    case "feature":
                        dataPoint << it.key?.name ?: ""
                        colors << it.key?.color ?: "#f9f157"
                        typei18n = 'is.feature'
                        break
                    case "type":
                        dataPoint << message(code: grailsApplication.config.icescrum.resourceBundles.storyTypes[it.key])
                        colors << grailsApplication.config.icescrum.resourceBundles.storyTypesColor[it.key]
                        typei18n = 'is.story.' + chartType
                        break
                    case "state":
                        dataPoint << message(code: storyStateNames[it.key])
                        colors << grailsApplication.config.icescrum.resourceBundles.storyStatesColor[it.key]
                        typei18n = 'is.story.' + chartType
                        break
                    default:
                        dataPoint << it.key
                        typei18n = 'is.story.' + chartType
                        break
                }
                def number = (chartUnit == 'effort' ?  it.value.collect { it.effort ?: 0 }.sum() : it.value.size()) ?: 0
                dataPoint << number
                total += number
                dataPoints << dataPoint
            }
            def title = message(code: "is.chart.backlogByProperty.caption", args: [message(code: chartUnit == 'effort' ? 'is.story.effort' : 'todo.is.ui.stories'), message(code: typei18n)])
            def options = [
                    chart  : [
                            title: total
                    ],
                    title  : [
                            text: backlog.project.pkey + " - " + message(code: backlog.name)
                    ],
                    caption: [
                            text: title,
                            html: "<h4>$title</h4>"
                    ]
            ]
            if (colors) {
                options.chart.color = colors
            }
            render(status: 200, contentType: "application/json", text: [data: dataPoints, options: options] as JSON)
        } else {
            render(status: 400)
        }
    }
}