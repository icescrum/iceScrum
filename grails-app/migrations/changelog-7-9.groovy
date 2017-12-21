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
    changeSet(author: "vbarrier", id: "update_widget_parent_type_null") {
        grailsChange {
            change {
                sql.execute("UPDATE is_up_widgets SET parent_type = 'USER' WHERE parent_type IS NULL")
                sql.execute("UPDATE is_up_widgets SET parent_type = 'USER' WHERE parent_type = ''")
            }
        }
    }
    changeSet(author: "vbarrier", id: "drop_widget_up_not_null_constraint") {
        dropNotNullConstraint(tableName: "is_up_widgets", columnName: "user_preferences_id", columnDataType: "BIGINT")
    }
}

