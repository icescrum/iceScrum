import grails.util.Metadata

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
    if (Metadata.current['app.promoteVersion'] == 'true') {
        def version = Metadata.current['app.version'].replaceAll(' ', '')
        changeSet(id: 'user_preferences_reset_displayWhatsNew_' + version, author: 'vbarrier') {
            preConditions(onFail: "MARK_RAN") {
                not {
                    or {
                        dbms(type: 'mssql')
                        dbms(type: 'oracle')
                    }
                }
            }
            grailsChange {
                change {
                    sql.execute('UPDATE is_user_preferences set display_whats_new = true WHERE display_whats_new = false')
                }
            }
            addNotNullConstraint(tableName: "is_user_preferences", columnName: 'display_whats_new', columnDataType: 'BOOLEAN')
        }
        changeSet(id: 'user_preferences_reset_displayWhatsNew_mssql_' + version, author: 'vbarrier') {
            preConditions(onFail: "MARK_RAN") {
                dbms(type: 'mssql')
            }
            grailsChange {
                change {
                    sql.execute('UPDATE is_user_preferences set display_whats_new = 1 WHERE display_whats_new = 0')
                }
            }
            addNotNullConstraint(tableName: "is_user_preferences", columnName: 'display_whats_new', columnDataType: 'BIT')
        }
        changeSet(id: 'user_preferences_reset_displayWhatsNew_oracle_' + version, author: 'vbarrier') {
            preConditions(onFail: "MARK_RAN") {
                dbms(type: 'oracle')
            }
            grailsChange {
                change {
                    sql.execute('UPDATE is_u_pref set display_whats_new = 1 WHERE display_whats_new = 0')
                }
            }
        }
    }
}