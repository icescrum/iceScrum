/*
 * Copyright (c) 2014 Kagilum SAS
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
 * Authors: Vincent Barrier (vbarrier@kagilum.com)
 *
 */

package org.icescrum.web.presentation

import grails.converters.JSON
import grails.util.Environment
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport

class ErrorsController implements ControllerErrorHandler {

    def grailsApplication
    def springSecurityService
    def notificationEmailService

    def error403() {
        if (springSecurityService.isAjax(request)) {
            render(status: 403, text: [error: message(code: 'is.error.denied')])
        } else {
            render(status: 403, view: '403.gsp', model: [homeUrl: ApplicationSupport.serverURL(request), supportEmail: grailsApplication.config.icescrum.alerts.errors.to])
        }
    }

    def error404() {
        if (springSecurityService.isAjax(request)) {
            render(status: 404)
        } else {
            render(status: 404, view: '404.gsp', model: [homeUrl: ApplicationSupport.serverURL(request), supportEmail: grailsApplication.config.icescrum.alerts.errors.to])
        }
    }

    def error401() {
        if (springSecurityService.isAjax(request)) {
            render(status: 401)
        } else {
            render(status: 401, view: '401.gsp', model: [homeUrl: ApplicationSupport.serverURL(request)])
        }
    }

    def browserNotSupported() {
        //render browserNotSupported.gsp
    }

    def database() {
        render(status: 500, contentType: 'application/json', text: [error: message(code: 'is.error.database')] as JSON)
    }

    def memory() {
        render(status: 500, contentType: 'application/json', text: [error: message(code: 'is.error.memory')] as JSON)
    }

    def error500() {
        Exception exception = request.exception
        if (Environment.current == Environment.PRODUCTION) {
            try {
                notificationEmailService.send([
                        from   : springSecurityService.currentUser?.email ?: null,
                        to     : grailsApplication.config.icescrum.alerts.errors.to,
                        subject: "[iceScrum][report] Error report",
                        view   : '/emails-templates/reportError',
                        model  : [params      : params,
                                  version     : g.meta(name: 'app.version'),
                                  stackTrace  : exception.stackTrace,
                                  message     : exception.message,
                                  appID       : grailsApplication.config.icescrum.appID,
                                  ip          : request.getHeader('X-Forwarded-For') ?: request.getRemoteAddr()],
                        async  : false
                ]);
                returnError(code: 'is.error.and.message.sent', exception: exception)
            } catch (Exception) {
                returnError(code: 'is.error.and.message.not.sent', exception: exception)
            }
        } else {
            returnError(text: "DEV ERROR: " + exception.message, exception: exception)
        }
    }
}
