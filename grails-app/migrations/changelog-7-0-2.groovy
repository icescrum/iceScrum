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
    changeSet(author: 'noullet', id: 'is_task-name-dropUniqueConstraint') {
        preConditions(onFail: 'MARK_RAN') {
            // There is no uniqueConstraintExists so we use indexExists
            not {
                dbms(type: 'oracle')
            }
            or {
                indexExists(indexName: 'unique_nameistask') // Index name is the same as unique key constraint on MySQL
                indexExists(indexName: 'unique_nameistask_index_a') // Index name is different on H2
            }
        }
        // Drop foreign keys on task backlog_id, required to drop unique constraint
        dropForeignKeyConstraint(
                baseTableName: 'is_task',
                constraintName: 'FK_qv2vf1ba7ouh3s81i95u2b7f1issprint'
        )
        dropForeignKeyConstraint(
                baseTableName: 'is_task',
                constraintName: 'FK_qv2vf1ba7ouh3s81i95u2b7f1istimebox'
        )
        // Drop unique constraint on task name
        dropUniqueConstraint(
                tableName: 'is_task',
                constraintName: 'unique_nameistask'
        )
        // Add back the foreign key constraints on backlog_id
        addForeignKeyConstraint(
                baseTableName: 'is_task',
                baseColumnNames: 'backlog_id',
                constraintName: 'FK_qv2vf1ba7ouh3s81i95u2b7f1istimebox',
                referencedTableName: 'is_timebox',
                referencedColumnNames: 'id'
        )
        addForeignKeyConstraint(
                baseTableName: 'is_task',
                baseColumnNames: 'backlog_id',
                constraintName: 'FK_qv2vf1ba7ouh3s81i95u2b7f1issprint',
                referencedTableName: 'is_sprint',
                referencedColumnNames: 'id'
        )
    }
}