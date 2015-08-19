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
 * Authors:Marwah Soltani (msoltani@kagilum.com)
 *
 *
 */



package org.icescrum.web.presentation.app.project
import org.icescrum.core.domain.Mood

class MoodController {

    def springSecurityService
    def MoodService
    def save() {
        Mood mood = new Mood()
        try {
            Mood.withTransaction {
                bindData(mood, [include: ['moodUser']])
                MoodService.save(mood)
            }

            withFormat {
                html { render(status: 200, contentType: 'application/json', text: mood as JSON) }
                json { renderRESTJSON(status: 201, text: mood) }
                xml { renderRESTXML(status: 201, text: mood) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: task, exception: e)
        }
    }
}