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

package org.icescrum.core.domain.preferences

class UserPreferencesMigration {
		static migration = {
            changeSet(id:'user_preferences_constraint_hideDoneState', author:'vbarrier') {
                  sql('UPDATE icescrum2_user_preferences set hide_done_state = false WHERE hide_done_state is NULL')
                  addNotNullConstraint(tableName:"icescrum2_user_preferences",columnName:'hide_done_state',columnDataType:'BOOLEAN')
              }
		}
	}

