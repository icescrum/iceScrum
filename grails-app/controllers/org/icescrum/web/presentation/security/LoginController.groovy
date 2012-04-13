/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */
package org.icescrum.web.presentation.security

import org.springframework.web.servlet.support.RequestContextUtils as RCU

import grails.converters.JSON
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.icescrum.core.domain.User
import org.icescrum.core.support.ApplicationSupport
import org.springframework.security.authentication.AccountExpiredException
import org.springframework.security.authentication.CredentialsExpiredException
import org.springframework.security.authentication.DisabledException
import org.springframework.security.authentication.LockedException
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.icescrum.core.domain.Product

class LoginController {

    /**
     * Dependency injection for the authenticationTrustResolver.
     */
    def authenticationTrustResolver

    /**
     * Dependency injection for the springSecurityService.
     */
    def springSecurityService

    /**
     * Dependency injection to look in config options
     */
    def grailsApplication

    /**
     * Default action; redirects to 'defaultTargetUrl' if logged in, /username/auth otherwise.
     */
    def index = {
        if (springSecurityService.isLoggedIn()) {
            redirect uri: SpringSecurityUtils.securityConfig.successHandler.defaultTargetUrl
        }
        else {
            redirect action: auth, params: params
        }
    }

    /**
     * Show the username page.
     */
    def auth = {

        def config = SpringSecurityUtils.securityConfig

        if (springSecurityService.isLoggedIn()) {
            cache false
            redirect uri: config.successHandler.defaultTargetUrl
            return
        }
        session.invalidate()

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

        String view = 'auth'
        String postUrl = "${config.apf.filterProcessesUrl}"
        render view: view, model: [postUrl: postUrl, rememberMeParameter: config.rememberMe.parameter, activeLostPassword: ApplicationSupport.booleanValue(grailsApplication.config.icescrum.login.retrieve.enable), enableRegistration: ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)]
    }

    /**
     * Show denied page.
     */
    def denied = {
        if (springSecurityService.isLoggedIn() &&
                authenticationTrustResolver.isRememberMe(SecurityContextHolder.context?.authentication)) {
            // have cookie but the page is guarded with IS_AUTHENTICATED_FULLY
            redirect action: full, params: params
        }
    }

    /**
     * Login page for users with a remember-me cookie but accessing a IS_AUTHENTICATED_FULLY page.
     */
    def full = {
        def config = SpringSecurityUtils.securityConfig
        render view: 'auth', params: params,
                model: [hasCookie: authenticationTrustResolver.isRememberMe(SecurityContextHolder.context?.authentication),
                        postUrl: "${request.contextPath}${config.apf.filterProcessesUrl}"]
    }

    def authAjax = {
        render(status: 401, text: [error: message(code: 'is.denied')] as JSON)
    }

    /**
     * Callback after a failed username. Redirects to the auth page with a warning message.
     */
    def authfail = {

        //IF the password is encode in MD5 (like an user imported
        // from IS2, on first connect it changes is password to SHA)
        def username = session[UsernamePasswordAuthenticationFilter.SPRING_SECURITY_LAST_USERNAME_KEY]
        def password = session[UsernamePasswordAuthenticationFilter.SPRING_SECURITY_FORM_PASSWORD_KEY]
        def u = User.findByUsernameAndPasswordExpired(username.toString(), true)
        if (u && u.password == password.toString().encodeAsMD5()) {
            u.passwordExpired = false
            u.password = springSecurityService.encodePassword(password.toString())
            u.save()
            springSecurityService.reauthenticate(username.toString(), password.toString())
            if (springSecurityService.isLoggedIn()) {
                redirect(action: 'ajaxSuccess')
            }
        }

        String msg = ''
        def exception = session[AbstractAuthenticationProcessingFilter.SPRING_SECURITY_LAST_EXCEPTION_KEY]
        if (exception) {
            if (exception instanceof AccountExpiredException) {
                msg = 'is.dialog.login.error.account.expired'
            }
            else if (exception instanceof CredentialsExpiredException) {
                msg = 'is.dialog.login.error.credentials.expired'
            }
            else if (exception instanceof DisabledException) {
                msg = 'is.dialog.login.error.disabled'
            }
            else if (exception instanceof LockedException) {
                msg = 'is.dialog.login.error.locked'
            }
            else {
                msg = 'is.dialog.login.error'
            }
        }

        if (springSecurityService.isAjax(request)) {
            render(status: 400, contentType: 'application/json', text: [notice: [text: message(code: msg)]] as JSON)
            return
        }
        else {
            flash.message = msg
            redirect action: auth, params: params
        }
    }

    /**
     * The Ajax success redirect url.
     */
    def ajaxSuccess = {
        User u = springSecurityService.currentUser
        if (u.preferences.lastProductOpened){
            render(status:200, contentType: 'application/json', text:[url:grailsApplication.config.grails.serverURL+'/p/'+u.preferences.lastProductOpened+'#project'] as JSON)
        }else{
            render(status:200, text:'')
        }
    }

    /**
     * The Ajax denied redirect url.
     */
    def ajaxDenied = {
        render(status: 403, text: message(code: 'is.denied'))
    }
}
