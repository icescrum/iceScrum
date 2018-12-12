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
    changeSet(author: "vbarrier", id: "update_type_meta_value_longtext_is_meta") {
        preConditions(onFail: 'MARK_RAN') {
            not {
                or {
                    dbms(type: 'mssql')
                    // No solution on Oracle apparently :( see https://community.oracle.com/ideas/21411
                    // We cannot change it to a varchar with greater size either as it would work on existing DBs but not on new ones (CLOB -> varchar)
                    dbms(type: 'oracle')
                }
            }
        }
        modifyDataType(tableName: 'is_metadata', columnName: 'meta_value', newDataType: 'longtext')
    }
    changeSet(author: "vbarrier", id: "update_type_meta_value_longtext_is_meta_mssql") {
        preConditions(onFail: 'MARK_RAN') {
            dbms(type: 'mssql')
        }
        modifyDataType(tableName: 'is_metadata', columnName: 'meta_value', newDataType: 'varchar(max)')
    }
}
