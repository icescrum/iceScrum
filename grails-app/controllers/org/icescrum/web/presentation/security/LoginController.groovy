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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */
package org.icescrum.web.presentation.security

import grails.converters.JSON
import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.springframework.security.authentication.AccountExpiredException
import org.springframework.security.authentication.CredentialsExpiredException
import org.springframework.security.authentication.DisabledException
import org.springframework.security.authentication.LockedException
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.servlet.support.RequestContextUtils as RCU
import org.icescrum.core.domain.User
import org.icescrum.core.support.ApplicationSupport

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
			redirect uri: config.successHandler.defaultTargetUrl
			return
		}
        session.invalidate()
        def userAgent = request.getHeader("user-agent")
        def headers = userAgent.substring(userAgent.indexOf("(") + 1).split("; ")
        def locale = params.lang?:null
        if (headers.size() >= 4){
          locale = params.lang?:headers[3]?.substring(0,2)
        }
        if (locale){
          RCU.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
        }
		String view = 'auth'
		String postUrl = "${config.apf.filterProcessesUrl}"
		render view: view, model: [postUrl: postUrl, rememberMeParameter: config.rememberMe.parameter, activeLostPassword:ApplicationSupport.booleanValue(grailsApplication.config.icescrum.enable.login.retrieve), enableRegistration:ApplicationSupport.booleanValue(grailsApplication.config.icescrum.enable.registration)]
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
      render(status:401, text:[error: message(code:'is.denied')] as JSON)
    }

	/**
	 * Callback after a failed username. Redirects to the auth page with a warning message.
	 */
	def authfail = {

        //IF the password is encode in MD5 (like an user imported
        // from IS2, on first connect it changes is password to SHA)
		def username = session[UsernamePasswordAuthenticationFilter.SPRING_SECURITY_LAST_USERNAME_KEY]
        def password = session[UsernamePasswordAuthenticationFilter.SPRING_SECURITY_FORM_PASSWORD_KEY]
        def u = User.findByUsernameAndPasswordExpired(username.toString(),true)
        if (u && u.password == password.toString().encodeAsMD5()){
          u.passwordExpired = false
          u.password = springSecurityService.encodePassword(password.toString())
          u.save()
          springSecurityService.reauthenticate(username.toString(),password.toString())
          if (springSecurityService.isLoggedIn()){
            redirect(action:'ajaxSuccess')
          }
        }

		String msg = ''
		def exception = session[AbstractAuthenticationProcessingFilter.SPRING_SECURITY_LAST_EXCEPTION_KEY]
		if (exception) {
			if (exception instanceof AccountExpiredException) {
				msg = SpringSecurityUtils.securityConfig.errors.login.expired
			}
			else if (exception instanceof CredentialsExpiredException) {
				msg = SpringSecurityUtils.securityConfig.errors.login.passwordExpired
			}
			else if (exception instanceof DisabledException) {
				msg = SpringSecurityUtils.securityConfig.errors.login.disabled
			}
			else if (exception instanceof LockedException) {
				msg = SpringSecurityUtils.securityConfig.errors.login.locked
			}
			else {
				msg = SpringSecurityUtils.securityConfig.errors.login.fail
			}
		}

		if (springSecurityService.isAjax(request)) {
			render(status: 400, contentType:'application/json', text: [notice: [text: message(code:'is.dialog.login.error')]] as JSON)
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
      render('')
	}

	/**
	 * The Ajax denied redirect url.
	 */
	def ajaxDenied = {
      render(status:403, text:message(code:'is.denied'))
    }
}
