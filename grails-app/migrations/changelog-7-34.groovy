/*
* Copyright (c) 2019 Kagilum SAS
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
    changeSet(author: "vbarrier", id: "drop_tag_name_unique_constraint") {
        preConditions(onFail: 'MARK_RAN') {
            // There is no uniqueConstraintExists so we use indexExists
            indexExists(indexName: 'UK_t48xdq560gs3gap9g7jg36kgc') // Index name is the same as unique key constraint
            not {
                dbms(type: 'postgresql')
            }
        }
        // Drop unique constraint on tag name
        dropUniqueConstraint(tableName: 'tags', constraintName: 'UK_t48xdq560gs3gap9g7jg36kgc')
    }
    changeSet(author: "vbarrier", id: "drop_tag_name_unique_constraint_pg") {
        preConditions(onFail: 'MARK_RAN') {
            // There is no uniqueConstraintExists so we use indexExists
            indexExists(indexName: 'uk_t48xdq560gs3gap9g7jg36kgc') // Postgre is case sensitive regarding index keys GRR
            dbms(type: 'postgresql')
        }
        // Drop unique constraint on tag name
        dropUniqueConstraint(tableName: 'tags', constraintName: 'uk_t48xdq560gs3gap9g7jg36kgc')
    }
}
