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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.UserToken
import org.icescrum.core.error.ControllerErrorHandler

@Secured('isAuthenticated()')
class UserTokenController implements ControllerErrorHandler {

    def userTokenService
    def springSecurityService

    def index() {
        User user = (User)springSecurityService.currentUser
        render(status: 200, contentType: 'application/json', text: user.tokens as JSON)
    }

    def save() {
        User user = (User)springSecurityService.currentUser
        UserToken userToken = new UserToken()
        bindData(userToken, params.userToken, [include: ['name']])
        userTokenService.save(user, userToken)
        render(status: 200, contentType: 'application/json', text: userToken as JSON)
    }

    /*def update(String value) {
        User user = (User)springSecurityService.currentUser
        UserToken userToken = UserToken.findByUserAndValue(user, value)
        bindData(userToken, params.userToken, [include: ['name']])
        userTokenService.update(userToken)
        render(status: 200, contentType: 'application/json', text: userToken as JSON)
    }*/

    def delete(String id) {
        User user = (User)springSecurityService.currentUser
        UserToken userToken = UserToken.findByIdAndUser(id, user)
        def deleted = [id: userToken.id, user: [id: userToken.user.id]]
        userTokenService.delete(userToken)
        withFormat {
            html {
                render(status: 200, contentType: 'application/json', text: deleted as JSON)
            }
            json {
                render(status: 204)
            }
        }
    }
}
