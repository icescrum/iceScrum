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
    // No easy way to check if the constraint exists or not
    // So we avoid running the migration if it is a fresh DB (we are sure the constraint is not here)
    changeSet(author: 'vbarrier', id: 'drop_widget_up_not_null_constraint') {
        preConditions(onFail: 'MARK_RAN') {
            not {
                dbms(type: 'mssql')
            }
            not {
                sqlCheck(expectedResult: '0', 'SELECT count(*) FROM authority')
            }
        }
        dropNotNullConstraint(tableName: 'is_up_widgets', columnName: 'user_preferences_id', columnDataType: 'BIGINT')
    }
    changeSet(author: 'vbarrier', id: 'drop_widget_up_not_null_constraint_mssql') {
        preConditions(onFail: 'MARK_RAN') {
            dbms(type: 'mssql')
            not {
                sqlCheck(expectedResult: '0', 'SELECT count(*) FROM authority')
            }
        }
        dropIndex(tableName: 'is_up_widgets', indexName: 'up_wdi_index')
        dropForeignKeyConstraint(baseTableName: 'is_up_widgets', constraintName: 'FK_ml7xvqvvhyvh0dyuc3xx7fe12isuserpreferences')
        dropForeignKeyConstraint(baseTableName: 'is_user', constraintName: 'FK_kexf01yt25seb8tn1fyso82sdisuserpreferences')
        dropNotNullConstraint(tableName: 'is_up_widgets', columnName: 'user_preferences_id', columnDataType: 'numeric(19,0)')
        createIndex(tableName: 'is_up_widgets', indexName: 'up_wdi_index') {
            column(name: 'user_preferences_id', type: 'numeric(19,0)')
            column(name: 'widget_definition_id', type: 'numeric(19,0)')
        }
        addForeignKeyConstraint(
                baseTableName: 'is_user', baseColumnNames: 'preferences_id',
                constraintName: 'FK_kexf01yt25seb8tn1fyso82sdisuserpreferences',
                referencedTableName: 'is_user_preferences', referencedColumnNames: 'id'
        )
        addForeignKeyConstraint(
                baseTableName: 'is_up_widgets', baseColumnNames: 'user_preferences_id',
                constraintName: 'FK_ml7xvqvvhyvh0dyuc3xx7fe12isuserpreferences',
                referencedTableName: 'is_user_preferences', referencedColumnNames: 'id'
        )
    }
}
