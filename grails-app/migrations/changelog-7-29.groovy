import liquibase.statement.core.RawSqlStatement
import org.icescrum.core.domain.*

/*
* Copyright (c) 2018 Kagilum SAS
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
    changeSet(author: "vbarrier", id: "update_attachments_count_is_story") {
        grailsChange {
            change {
                def stories = Story.findAllByOriginIsNotNull()
                log.info "Migrate stories attachments count, ${stories.size()} left"
                stories.each { story ->
                    def attachments = story.getTotalAttachments()
                    if (attachments) {
                        sqlStatement(new RawSqlStatement("UPDATE is_story SET attachments_count = ${attachments} WHERE id = ${story.id}"))
                    }
                }
            }
        }
    }
}
