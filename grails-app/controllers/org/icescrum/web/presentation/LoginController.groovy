/*
 * Copyright (c) 2019 Kagilum SAS.
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
package org.icescrum.web.presentation

import grails.converters.JSON
import grails.plugin.springsecurity.SpringSecurityUtils
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport
import org.springframework.security.access.annotation.Secured
import org.springframework.security.authentication.AccountExpiredException
import org.springframework.security.authentication.CredentialsExpiredException
import org.springframework.security.authentication.DisabledException
import org.springframework.security.authentication.LockedException
import org.springframework.security.core.context.SecurityContextHolder as SCH
import org.springframework.security.web.WebAttributes
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter
import org.springframework.security.web.savedrequest.HttpSessionRequestCache
import org.springframework.security.web.savedrequest.RequestCache
import org.springframework.security.web.savedrequest.SavedRequest

import javax.servlet.http.HttpServletResponse

@Secured('permitAll')
class LoginController implements ControllerErrorHandler {

    def authenticationTrustResolver
    def springSecurityService
    RequestCache requestCache

    // Default action; redirects to 'defaultTargetUrl' if logged in, /login/auth otherwise
    def index() {
        if (springSecurityService.isLoggedIn()) {
            redirect(uri: SpringSecurityUtils.securityConfig.successHandler.defaultTargetUrl)
        } else {
            redirect(action: 'auth', params: params)
        }
    }

    // Show the login page
    def auth(String username, String redirectTo) {
        def config = SpringSecurityUtils.securityConfig
        if (springSecurityService.isLoggedIn()) {
            redirectTo = redirectTo ?: (session["redirectTo"] ?: null)
            if (redirectTo && !redirectTo.startsWith(ApplicationSupport.serverURL())) {
                redirectTo = null
            }
            session["redirectTo"] = null
            redirect(uri: redirectTo ?: config.successHandler.defaultTargetUrl)
            return
        } else {
            if (redirectTo) {
                session["redirectTo"] = redirectTo
            } else if (!redirectTo && params.login_error == null) {
                session["redirectTo"] = null
            } else {
                redirectTo = session["redirectTo"]
            }
        }
        render(view: 'auth', model: [noJS               : true,
                                     username           : username,
                                     redirectTo         : redirectTo,
                                     postUrl            : "${request.contextPath}${config.apf.filterProcessesUrl}",
                                     rememberMeParameter: config.rememberMe.parameter])
    }

    // The redirect action for Ajax requests
    def authAjax() {
        response.setHeader('Location', SpringSecurityUtils.securityConfig.auth.ajaxLoginFormUrl)
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED)
    }

    // Show denied page
    def denied() {
        if (springSecurityService.isLoggedIn() && authenticationTrustResolver.isRememberMe(SCH.context?.authentication)) {
            redirect(action: 'full', params: params) // have cookie but the page is guarded with IS_AUTHENTICATED_FULLY
        }
    }

    // Login page for users with a remember-me cookie but accessing a IS_AUTHENTICATED_FULLY page
    def full() {
        render(view: 'auth', params: params, model: [hasCookie: authenticationTrustResolver.isRememberMe(SCH.context?.authentication),
                                                     postUrl  : "${request.contextPath}${SpringSecurityUtils.securityConfig.apf.filterProcessesUrl}"])
    }

    // Callback after a failed login. Redirects to the auth page with a warning message
    def authfail() {
        String msg = ''
        def exception = session[WebAttributes.AUTHENTICATION_EXCEPTION]
        if (exception) {
            if (exception instanceof AccountExpiredException) {
                msg = 'is.login.error.account.expired'
            } else if (exception instanceof CredentialsExpiredException) {
                msg = 'is.login.error.credentials.expired'
            } else if (exception instanceof DisabledException) {
                msg = 'is.login.error.disabled'
            } else if (exception instanceof LockedException) {
                msg = 'is.login.error.locked'
            } else {
                msg = 'is.login.error'
            }
        }
        if (springSecurityService.isAjax(request)) {
            returnError(code: msg)
        } else {
            flash.message = g.message(code: msg)
            redirect(action: 'auth', params: params)
        }
    }

    // The Ajax success redirect url
    def ajaxSuccess() {
        render([success: true, username: springSecurityService.authentication.name] as JSON)
    }

    // The Ajax denied redirect url
    def ajaxDenied() {
        render([error: message(code: 'is.denied')] as JSON)
    }
}
