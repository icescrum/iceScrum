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
import org.apache.commons.lang.exception.ExceptionUtils
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.domain.security.UserAuthority
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport

class ErrorsController implements ControllerErrorHandler {

    def grailsApplication
    def springSecurityService
    def notificationEmailService

    def error401() {
        if (springSecurityService.isAjax(request)) {
            render(status: 401)
        } else {
            withFormat {
                html {
                    render(status: 401, view: '401.gsp', model: [homeUrl: ApplicationSupport.serverURL()])
                }
                json {
                    render(status: 401)
                }
            }
        }
    }

    def error403() {
        if (springSecurityService.isAjax(request)) {
            render(status: 403, text: [error: message(code: 'is.error.denied')])
        } else {
            withFormat {
                html {
                    render(status: 403, view: '403.gsp', model: [homeUrl: ApplicationSupport.serverURL(), supportEmail: grailsApplication.config.icescrum.alerts.errors.to])
                }
                json {
                    render(status: 403)
                }
            }
        }
    }

    def error404() {
        if (springSecurityService.isAjax(request)) {
            render(status: 404)
        } else {
            withFormat {
                html {
                    render(status: 404, view: '404.gsp', model: [homeUrl: ApplicationSupport.serverURL(), supportEmail: grailsApplication.config.icescrum.alerts.errors.to])
                }
                json {
                    render(status: 404)
                }
            }
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
        try {
            Exception exception = request.exception
            if (exception.message.contains("This indicates a configuration error because the rejectPublicInvocations property is set to")) {
                redirect(mapping: '404')
            } else if (Environment.current == Environment.PRODUCTION) {
                if (exception.message.contains('Row was updated or deleted by another transaction')) {
                    returnError(code: 'is.error.row.updated.another.transaction', exception: exception)
                } else {
                    try {
                        if (grailsApplication.config.icescrum.alerts.enable) {
                            User user = (User) springSecurityService.currentUser
                            def admins = UserAuthority.findAllByAuthority(Authority.findByAuthority(Authority.ROLE_ADMIN)).collect { it.user }
                            log.debug("Error 500 report")
                            notificationEmailService.send([
                                    from   : grailsApplication.config.icescrum.alerts.default.from,
                                    replyTo: user?.email ?: null,
                                    to     : grailsApplication.config.icescrum.alerts.errors.to,
                                    bcc    : admins*.email.toArray(),
                                    subject: "[iceScrum][report] Error report v7",
                                    view   : '/emails-templates/reportError',
                                    model  : [uriParams : params,
                                              uri       : request.forwardURI,
                                              version   : g.meta(name: 'app.version'),
                                              stackTrace: ExceptionUtils.getStackTrace(exception),
                                              message   : exception.message,
                                              appID     : grailsApplication.config.icescrum.appID,
                                              ip        : request.getHeader('X-Forwarded-For') ?: request.getRemoteAddr(),
                                              user      : user ? user.username + ' - ' + user.firstName + ' ' + user.lastName + ' - ' + user.email : 'Not logged in'],
                                    async  : false
                            ]);
                            returnError(code: 'is.error.and.message.sent', exception: exception)
                        } else {
                            log.debug("Error 500 - no report")
                            returnError(code: 'is.error.and.message.not.sent', exception: exception)
                        }
                    } catch (Exception e) {
                        log.debug("Error 500 - report failed")
                        log.debug(e.message)
                        returnError(code: 'is.error.and.message.not.sent', exception: exception)
                    }
                }
            } else {
                returnError(text: "DEV ERROR: " + exception.message, exception: exception)
            }
        } catch (Throwable t) {
            returnError(status: 400)
        }
    }
}
