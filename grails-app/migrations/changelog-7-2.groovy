import grails.converters.JSON
import liquibase.statement.core.RawSqlStatement
import org.apache.commons.lang.StringEscapeUtils
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Story

/*
* Copyright (c) 2017 Kagilum SAS
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
* Vincent BARRIER (vbarrier@kagilum.com)
*
*/
databaseChangeLog = {
    changeSet(author: "vbarrier", id: "add_default_timeboxNote_template") {
        grailsChange {
            change {
                def projects = Project.getAll()

                def configsDataHtml = ([
                        [header      : "<h2>New Features</h2><ul>",
                         footer      : "</ul>",
                         storyType   : Story.TYPE_USER_STORY,
                         lineTemplate: '<li><a href=\'\'${baseUrl}-${story.id}\'\'>${story.name}</a></li>'
                        ],
                        [header      : "<h2>Bug Fixes</h2><ul>",
                         footer      : "</ul>",
                         storyType   : Story.TYPE_DEFECT, //defect
                         lineTemplate: '<li><a href=\'\'${baseUrl}-${story.id}\'\'>${story.name}</a></li>'
                        ]
                ] as JSON).toString()

                def configsDataMarkdown =  ([
                        [header      : "## New Features",
                         footer      : "",
                         storyType   : Story.TYPE_USER_STORY, //user
                         lineTemplate: '* [${story.name}](${baseUrl}-${story.id})'
                        ],
                        [header      : "## Bug Fixes",
                         footer      : "",
                         storyType   : Story.TYPE_DEFECT, //defect
                         lineTemplate: '* [${story.name}](${baseUrl}-${story.id})'
                        ]
                ] as JSON).toString()

                def query = "INSERT INTO is_tbn_tpls (`name`,`header`,`configs_data`,`parent_project_id`,`version`)  VALUES "
                log.info "Generate default timebox note templates for projects (please wait, can take a while..) ${projects.size()} left"
                def count = 0d
                def percent = 0d
                def total = projects.size().toDouble()
                projects.each{
                    query += "('HTML Release Note Template', '<h1> My HTML release Note </h1>', '$configsDataHtml', $it.id, 1),('Markdown Release Note Template', '# My Markdown release Note', '$configsDataMarkdown', $it.id, 1)"
                    if(it != projects.last()){
                        query += ","
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Generate default timebox note templates for projects - $percent% done"
                    }
                }
                if(total > 0)
                    sqlStatement(new RawSqlStatement(query))
            }
        }
    }
}

