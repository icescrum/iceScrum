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
    changeSet(author: "vbarrier", id: "add_notnull_constraint_backlog_chart_type_v2") {
        grailsChange {
            change {
                sql.execute("UPDATE is_backlog SET chart_type = 'type' WHERE chart_type IS NULL OR chart_type = ''")
                sql.execute("UPDATE is_backlog SET chart_type = 'state' WHERE code = 'backlog' OR code = 'all'")
            }
        }
        addNotNullConstraint(tableName: "is_backlog", columnName: "chart_type", columnDataType: "varchar(255)")
    }
    changeSet(author: "vbarrier", id: "drop_on_right_columnn") {
        preConditions(onFail: 'MARK_RAN') {
            columnExists(columnName: "on_right", tableName: "is_up_widgets")
            not {
                dbms(type: 'oracle')
            }
        }
        dropColumn(columnName: "on_right", tableName: "is_up_widgets")
    }
}
