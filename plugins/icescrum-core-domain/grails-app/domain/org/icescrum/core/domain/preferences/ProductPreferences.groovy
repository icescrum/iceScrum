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

import org.icescrum.core.domain.Product

class ProductPreferences {

    //Project
    boolean newTeams = false
    boolean lockPo = true
    boolean hidden = false
    boolean hideWeekend = false
    String url

    //Planification
    boolean noEstimation = false

    //Sprint preferences
    boolean autoDoneStory = false
    boolean displayRecurrentTasks = true
    boolean displayUrgentTasks = true
    boolean assignOnCreateTask = false
    boolean assignOnBeginTask = true
    boolean autoCreateTaskOnEmptyStory = false
    int estimatedSprintsDuration = 14
    int limitUrgentTasks = 0

    // Meeting hours
    String releasePlanningHour = "9:00"
    String sprintPlanningHour = "9:00"
    String dailyMeetingHour = "11:00"
    String sprintReviewHour = "14:00"
    String sprintRetrospectiveHour = "16:00"

    static constraints = {
      url(nullable:true,url:true)
    }

    static belongsTo = [
            product:Product
    ]

    static mapping = {
      cache true
      table 'icescrum2_product_preferences'
    }
}
