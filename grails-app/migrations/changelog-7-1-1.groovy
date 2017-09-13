import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task

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
* Nicolas Noullet (nnoullet@kagilum.com)
* Vincent BARRIER (vbarrier@kagilum.com)
*
*/
databaseChangeLog = {
    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count") {
        grailsChange {
            change {
                println "Startinng attachments / comments count migration (can take time!)"
                println "features..."
                def features = Feature.getAll()
                features.each {
                    it.attachments_count = it.getTotalAttachments()
                    it.comments_count = it.getTotalComments()
                    it.save(flush:it == features.last(), failOnError:true)
                }
                println "stories..."
                def stories = Story.getAll()
                stories.each {
                    it.attachments_count = it.getTotalAttachments()
                    it.comments_count = it.getTotalComments()
                    it.save(flush:it == stories.last(), failOnError:true)
                }
                println "tasks..."
                def tasks = Task.getAll()
                tasks.each {
                    it.attachments_count = it.getTotalAttachments()
                    it.comments_count = it.getTotalComments()
                    it.save(flush:it == tasks.last(), failOnError:true)
                }
                println "projects..."
                def projects = Project.getAll()
                projects.each {
                    it.attachments_count = it.getTotalAttachments()
                    it.save(flush:it == projects.last(), failOnError:true)
                }
                println "releases..."
                def releases = Release.getAll()
                releases.each {
                    it.attachments_count = it.getTotalAttachments()
                    it.save(flush:it == releases.last(), failOnError:true)
                }
                println "sprints..."
                def sprints = Sprint.getAll()
                sprints.each {
                    it.attachments_count = it.getTotalAttachments()
                    it.save(flush:it == sprints.last(), failOnError:true)
                }
                println "migration finished!"
            }
        }
        addNotNullConstraint(tableName: "is_task", columnName: "comments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_story", columnName: "comments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_feature", columnName: "comments_count", columnDataType: "integer")

        addNotNullConstraint(tableName: "is_task", columnName: "attachments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_story", columnName: "attachments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_feature", columnName: "attachments_count", columnDataType: "integer")

        addNotNullConstraint(tableName: "is_sprint", columnName: "attachments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_project", columnName: "attachments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_release", columnName: "attachments_count", columnDataType: "integer")
    }
}
