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
import org.codehaus.groovy.grails.commons.DefaultGrailsDomainClass
import org.codehaus.groovy.grails.commons.GrailsDomainClass
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.Backlog
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Story
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.utils.ServicesUtils

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
    def chartByProperty(long id, long project, String property){
        if (property in ["effort", "feature", "state", "type", "state", "affectVersion"]){
            def backlog = Backlog.findByProjectAndId(Project.load(project), id)
            def stories = Story.search(project, JSON.parse(backlog.filter))
            def storiesByProperty = stories.groupBy({ story -> story."$property" })
            def data = [], colors = [], total = 0
            storiesByProperty.each{
                def color, name
                switch (property){
                    case "feature":
                        name = it.key?.name?:""
                        color = it.key?.color?:"#f9f157"
                        break
                    case "state":
                        name = message(code:grailsApplication.config.icescrum.resourceBundles.storyStates[it.key])
                        color = grailsApplication.config.icescrum.resourceBundles.storyStatesColor[it.key]
                        break
                    case "type":
                        name = message(code:grailsApplication.config.icescrum.resourceBundles.storyTypes[it.key])
                        color = grailsApplication.config.icescrum.resourceBundles.storyTypesColor[it.key]
                        break
                    default:
                        name = it.key
                        break
                }
                data << [name, it.value.size()]
                if(color)
                    colors << color
                total += it.value.size()
            }
            def options = [
                    chart:[
                            title:total
                    ],
                    title:[
                            enable:false
                    ],
                    caption:[
                            enable:true,
                            html:"<h4>${message(code: "is.chart.backlogByProperty.title", args: [message(code:backlog.name), message(code:'is.story.'+property)])}</h4>"
                    ]
            ]

            if(colors){
                options.chart.color = colors
            }
            render(status:200, contentType:"application/json", text:[data:data, options:options] as JSON)
        } else {
            render(status:400)
        }
    }
}