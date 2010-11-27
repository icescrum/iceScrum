/*
 * Copyright (c) 2010 iceScrum Technologies.
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

import org.icescrum.core.domain.User

class UserPreferences {

    String language = "en"
    String activity
    String filterTask = "allTasks"
    boolean hideDoneState = false

    Map menu = ["project":"1", "sandbox":"2","productBacklog":"3","timeline":"4","releasePlan":"5","sprintBacklog":"6"]
    Map menuHidden = ["actor":"1","feature":"2"]

    static constraints = {
      activity nullable:true
    }


    static belongsTo = [
            user:User
    ]

    static mapping = {
      cache true
      table 'icescrum2_user_preferences'
    }
}
