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
* Colin Bontemps (cbontemps@kagilum.com)
*
*/

databaseChangeLog = {
    changeSet(author: "vbarrier", id: "insert_in_is_story_actors_table") {
        preConditions(onFail: 'MARK_RAN') {
            // If story has actor col
            columnExists(columnName: "actor_id", tableName: "is_story")
        }
        grailsChange {
            change {
                log.info "migrating actor story relation"
                sql.execute("""INSERT INTO is_story_actors (story_id, actor_id)
                SELECT id, actor_id FROM is_story WHERE actor_id IS NOT NULL""")
            }
        }
    }
    changeSet(author: "vbarrier", id: "drop_is_story_actor_id_column_all") {
        preConditions(onFail: 'MARK_RAN') {
            // If story has actor col
            columnExists(columnName: "actor_id", tableName: "is_story")
            not {
                or {
                    dbms(type: 'postgresql')
                    dbms(type: 'oracle')
                }
            }
        }
        dropForeignKeyConstraint(baseTableName: "is_story", constraintName: "FK_awvhbkkfwdba0qmhrhm7iu840isactor")
        dropColumn(columnName: "actor_id", tableName: "is_story")
    }
    changeSet(author: "vbarrier", id: "drop_is_story_actor_id_column_postgresql") {
        preConditions(onFail: 'MARK_RAN') {
            columnExists(columnName: "actor_id", tableName: "is_story")
            dbms(type: 'postgresql')
        }
        dropForeignKeyConstraint(baseTableName: "is_story", constraintName: "fk_awvhbkkfwdba0qmhrhm7iu840isactor")
        dropColumn(columnName: "actor_id", tableName: "is_story")
    }
    changeSet(author: "vbarrier", id: "drop_is_story_actor_id_column_oracle") {
        preConditions(onFail: 'MARK_RAN') {
            columnExists(columnName: "actor_id", tableName: "is_story")
            dbms(type: 'oracle')
        }
        dropForeignKeyConstraint(baseTableName: "is_story", constraintName: "FKC13J9CRL77LNI740CSYNLAQY8")
        dropColumn(columnName: "actor_id", tableName: "is_story")
    }
}

