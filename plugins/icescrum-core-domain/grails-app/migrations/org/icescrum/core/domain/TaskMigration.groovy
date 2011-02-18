/*
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 */
package org.icescrum.core.domain

class TaskMigration {

    static migration = {
            // List of changesets
            changeSet(id:'task_constraint_block_column', author:'vbarrier') {
                sql('UPDATE icescrum2_task set blocked = false WHERE blocked is NULL')
                addNotNullConstraint(tableName:"icescrum2_task",columnName:'blocked',columnDataType:'BOOLEAN')
            }
    }
}

