/*
 * Copyright (c) 2015 Kagilum.
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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task

class ActivityController {

    def springSecurityService

    @Secured('stakeHolder() or inProduct()')
    def index(long fluxiableId, boolean all, long product, String type) {
        def fluxiable = type == 'story' ? Story.withStory(product, fluxiableId) : Task.withTask(product, fluxiableId)
        withFormat {
            def activities = fluxiable.activity
            if (!all) {
                def selectedActivities = activities.findAll { it.important }
                def remainingActivities = activities - selectedActivities
                activities = selectedActivities + remainingActivities.take(10 - selectedActivities.size())
                activities.sort { a, b -> b.dateCreated <=> a.dateCreated }
            }
            html { render(status: 200, contentType: 'application/json', text: activities as JSON) }
            json { renderRESTJSON(text: activities) }
            xml { renderRESTXML(text: activities) }
        }
    }
}

