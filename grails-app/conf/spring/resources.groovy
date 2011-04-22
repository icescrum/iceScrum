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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */

import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils
import org.icescrum.core.security.MethodScrumExpressionHandler
import org.icescrum.core.security.ScrumDetailsService
import org.icescrum.core.security.WebScrumExpressionHandler
import org.icescrum.core.support.MenuBarSupport
import org.icescrum.web.security.ScrumAuthenticationProcessingFilter
import org.icescrum.web.upload.AjaxMultipartResolver

beans = {

  authenticationProcessingFilter(ScrumAuthenticationProcessingFilter) {
    def conf = SpringSecurityUtils.securityConfig
    authenticationManager = ref('authenticationManager')
    sessionAuthenticationStrategy = ref('sessionAuthenticationStrategy')
    authenticationSuccessHandler = ref('authenticationSuccessHandler')
    authenticationFailureHandler = ref('authenticationFailureHandler')
    rememberMeServices = ref('rememberMeServices')
    authenticationDetailsSource = ref('authenticationDetailsSource')
    filterProcessesUrl = conf.apf.filterProcessesUrl
    usernameParameter = conf.apf.usernameParameter
    passwordParameter = conf.apf.passwordParameter
    continueChainBeforeSuccessfulAuthentication = conf.apf.continueChainBeforeSuccessfulAuthentication
    allowSessionCreation = conf.apf.allowSessionCreation
    postOnly = conf.apf.postOnly
 }

  webExpressionHandler(WebScrumExpressionHandler) {
    roleHierarchy = ref('roleHierarchy')
  }

  expressionHandler(MethodScrumExpressionHandler) {
    parameterNameDiscoverer = ref('parameterNameDiscoverer')
    permissionEvaluator = ref('permissionEvaluator')
    roleHierarchy = ref('roleHierarchy')
    trustResolver = ref('authenticationTrustResolver')
  }

  menuBarSupport(MenuBarSupport){innerBean->
    innerBean.autowire = "byName"
  }

  userDetailsService(ScrumDetailsService){
    sessionFactory = ref('sessionFactory')
    transactionManager = ref('transactionManager')
  }

  multipartResolver(AjaxMultipartResolver){
    maxInMemorySize = 10240
    maxUploadSize = 1024000000
  }
}