/*
 * Copyright (c) 2014 Kagilum SAS.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */
package org.icescrum.web.presentation

import grails.converters.JSON
import grails.plugin.springsecurity.SpringSecurityUtils
import org.icescrum.core.domain.User
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.CredentialsExpiredException
import org.springframework.security.authentication.DisabledException
import org.springframework.security.authentication.LockedException
import org.springframework.security.web.WebAttributes
import org.springframework.web.servlet.support.RequestContextUtils as RCU

import javax.security.auth.login.AccountExpiredException
import javax.servlet.http.HttpServletResponse

class LoginController implements ControllerErrorHandler {

    def securityService
    def grailsApplication
    def springSecurityService

    def auth() {
        def config = SpringSecurityUtils.securityConfig
        if (springSecurityService.isLoggedIn()) {
            redirect(uri: config.successHandler.defaultTargetUrl)
            return
        }
        session.invalidate()
        // required because locale is lost when session is invalidated
        def locale = params.lang ?: null
        try {
            def localeAccept = request?.getHeader("accept-language")?.split(",")[0]?.split("-")
            if (localeAccept?.size() > 0) {
                locale = params.lang ?: localeAccept[0].toString()
            }
        } catch (Exception e) {}
        if (locale) {
            RCU.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
        }
        render(status: 200, template: "dialogs/auth", model: [
                postUrl            : ApplicationSupport.serverURL() + config.apf.filterProcessesUrl,
                rememberMeParameter: config.rememberMe.parameter,
                activeLostPassword : ApplicationSupport.booleanValue(grailsApplication.config.icescrum.login.retrieve.enable),
                enableRegistration : ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)])
    }

    def authAjax() {
        if (request.xhr) {
            // Fix S194, see https://stackoverflow.com/questions/32777614/grails-spring-security-plugin-login-form-redirected-to-ajaxauth
            session["SPRING_SECURITY_SAVED_REQUEST"] = null
        }
        response.setHeader 'Location', SpringSecurityUtils.securityConfig.auth.ajaxLoginFormUrl
        response.sendError HttpServletResponse.SC_UNAUTHORIZED
    }

    /**
     * Callback after a failed username. Redirects to the auth page with a warning message.
     */
    def authfail() {
        String msg = ''
        def exception = session[WebAttributes.AUTHENTICATION_EXCEPTION]
        if (exception) {
            if (exception instanceof AccountExpiredException) {
                msg = 'is.dialog.login.error.account.expired'
            } else if (exception instanceof CredentialsExpiredException) {
                msg = 'is.dialog.login.error.credentials.expired'
            } else if (exception instanceof DisabledException) {
                msg = 'is.dialog.login.error.disabled'
            } else if (exception instanceof LockedException) {
                msg = 'is.dialog.login.error.locked'
            } else {
                if (log.isErrorEnabled() && !(exception instanceof BadCredentialsException)) {
                    log.error(exception)
                    log.error(exception.cause)
                    exception.stackTrace.each {
                        log.error(it)
                    }
                }
                msg = 'is.dialog.login.error'
            }
        }
        if (springSecurityService.isAjax(request)) {
            returnError(code: msg)
            return
        } else {
            flash.message = msg
            redirect(action: 'auth', params: params)
        }
    }

    def ajaxSuccess() {
        User u = (User) springSecurityService.currentUser
        entry.hook(id: "login-ajaxSuccess", model: [user: u])
        render(status: 200, contentType: 'application/json', text: [
                user : u,
                roles: securityService.getRolesRequest(true),
                url  : u.preferences.lastProjectOpened ? ApplicationSupport.serverURL() + '/p/' + u.preferences.lastProjectOpened + '/' : null
        ] as JSON)
    }

    def ajaxDenied() {
        render(status: 403, text: message(code: 'is.denied'))
    }
}
