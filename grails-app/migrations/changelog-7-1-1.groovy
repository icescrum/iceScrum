import org.slf4j.LoggerFactory
import liquibase.statement.core.RawSqlStatement
import org.icescrum.core.domain.*

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
    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count_is_sprint") {
        grailsChange {
            change {
                sql.execute("UPDATE is_sprint SET attachments_count = 0  WHERE attachments_count IS NULL")
                def sprints = Sprint.getAll()
                log.info "Migrate sprints attachments count (please wait, can take a while..) ${sprints.size()} left"
                def count = 0d
                def percent = 0d
                def total = sprints.size().toDouble()
                sprints.each {
                    def attachments = it.getTotalAttachments()
                    if(attachments){
                        sqlStatement(new RawSqlStatement("UPDATE is_sprint SET attachments_count = ${attachments} WHERE id = ${it.id}"))
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Migrate sprints attachments count - $percent% done"
                    }
                }
            }
        }
        addNotNullConstraint(tableName: "is_sprint", columnName: "attachments_count", columnDataType: "integer")
    }

    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count_is_release") {
        grailsChange {
            change {
                sql.execute("UPDATE is_release SET attachments_count = 0  WHERE attachments_count IS NULL")
                def releases = Release.getAll()
                log.info "Migrate releases attachments count (please wait, can take a while..) ${releases.size()} left"
                def count = 0d
                def percent = 0d
                def total = releases.size().toDouble()
                releases.each {
                    def attachments = it.getTotalAttachments()
                    if(attachments){
                        sqlStatement(new RawSqlStatement("UPDATE is_release SET attachments_count = ${attachments} WHERE id = ${it.id}"))
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Migrate releases attachments count - $percent% done"
                    }
                }
            }
        }
        addNotNullConstraint(tableName: "is_release", columnName: "attachments_count", columnDataType: "integer")
    }

    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count_is_project") {
        grailsChange {
            change {
                sql.execute("UPDATE is_project SET attachments_count = 0  WHERE attachments_count IS NULL")
                def projects = Project.getAll()
                log.info "Migrate projects attachments count (please wait, can take a while..) ${projects.size()} left"
                def count = 0d
                def percent = 0d
                def total = projects.size().toDouble()
                projects.each {
                    def attachments = it.getTotalAttachments()
                    if(attachments){
                        sqlStatement(new RawSqlStatement("UPDATE is_project SET attachments_count = ${attachments} WHERE id = ${it.id}"))
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Migrate projects attachments count - $percent% done"
                    }
                }
            }
        }
        addNotNullConstraint(tableName: "is_project", columnName: "attachments_count", columnDataType: "integer")
    }

    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count_is_feature") {
        grailsChange {
            change {
                sql.execute("UPDATE is_feature SET comments_count = 0, attachments_count = 0  WHERE comments_count IS NULL OR attachments_count IS NULL")
                def features = Feature.getAll()
                log.info "Migrate features attachments / comments count (please wait, can take a while..) ${features.size()} left"
                def count = 0d
                def percent = 0d
                def total = features.size().toDouble()
                features.each {
                    def attachments = it.getTotalAttachments()
                    def comments = it.getTotalComments()
                    if(attachments || comments){
                        sqlStatement(new RawSqlStatement("UPDATE is_feature SET comments_count = ${comments}, attachments_count = ${attachments} WHERE id = ${it.id}"))
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Migrate features attachments / comments count - $percent% done"
                    }
                }
            }
        }
        addNotNullConstraint(tableName: "is_feature", columnName: "comments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_feature", columnName: "attachments_count", columnDataType: "integer")
    }

    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count_is_story") {
        grailsChange {
            change {
                sql.execute("UPDATE is_story SET comments_count = 0, attachments_count = 0  WHERE comments_count IS NULL OR attachments_count IS NULL")
                def stories = Story.getAll()
                log.info "Migrate stories attachments / comments count (please wait, can take a while..) ${stories.size()} left"
                def count = 0d
                def percent = 0d
                def total = stories.size().toDouble()
                stories.each {
                    def attachments = it.getTotalAttachments()
                    def comments = it.getTotalComments()
                    if(attachments || comments){
                        sqlStatement(new RawSqlStatement("UPDATE is_story SET comments_count = ${comments}, attachments_count = ${attachments} WHERE id = ${it.id}"))
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Migrate stories attachments / comments count - $percent% done"
                    }
                }
            }
        }
        addNotNullConstraint(tableName: "is_story", columnName: "comments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_story", columnName: "attachments_count", columnDataType: "integer")
    }

    changeSet(author: "vbarrier", id: "add_notnull_constraint_attachments_comments_count_is_task") {
        grailsChange {
            change {
                sql.execute("UPDATE is_task SET comments_count = 0, attachments_count = 0  WHERE comments_count IS NULL OR attachments_count IS NULL")
                def tasks = Task.getAll()
                log.info "Migrate tasks attachments / comments count (please wait, can take a while..) ${tasks.size()} left"
                def count = 0d
                def percent = 0d
                def total = tasks.size().toDouble()
                tasks.each {
                    def attachments = it.getTotalAttachments()
                    def comments = it.getTotalComments()
                    if(attachments || comments){
                        sqlStatement(new RawSqlStatement("UPDATE is_task SET comments_count = ${comments}, attachments_count = ${attachments} WHERE id = ${it.id}"))
                    }
                    count++
                    if(percent < (count*100/total).round()){
                        percent = (count*100/total).round()
                        log.info "Migrate tasks attachments / comments count - $percent% done"
                    }
                }
            }
        }
        addNotNullConstraint(tableName: "is_task", columnName: "comments_count", columnDataType: "integer")
        addNotNullConstraint(tableName: "is_task", columnName: "attachments_count", columnDataType: "integer")
    }
}
