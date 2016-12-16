/*
 * Copyright (c) 2013/2014 Kagilum SAS.
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
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */


import grails.plugin.springsecurity.SpringSecurityUtils
import groovy.util.slurpersupport.GPathResult
import org.geeks.browserdetection.ComparisonType
import org.grails.databinding.xml.GPathResultMap
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.support.ApplicationSupport
import org.springframework.web.servlet.support.RequestContextUtils

class IceScrumFilters {

    def securityService
    def springSecurityService
    def userAgentIdentService

    private static final String HEADER_CACHE_CONTROL = "Cache-Control";

    def filters = {

        all(controller: '*', action: '*') {
            before = {
                response.addHeader(HEADER_CACHE_CONTROL, "no-store, no-cache, no-transform, must-revalidate")
            }
        }

        permissions(controller: '*', action: '*') {
            before = {
                if (!request.getRequestURI().contains('/ws/') && controllerName != "errors" && actionName != "browserNotSupported"){
                    if(userAgentIdentService.isMsie(ComparisonType.LOWER, "9")){
                        if (!request.getHeader('user-agent').contains('chromeframe')){
                            redirect(controller:'errors',action:'browserNotSupported')
                            return false
                        }
                    }
                }
                if (params.product && !(actionName == 'save' && controllerName == 'project')) {
                    params.product = params.product.decodeProductKey()
                    if (!params.product) {
                        forward(controller:"errors", action:"error404")
                        return false
                    }
                }
                securityService.filterRequest()
                return
            }
        }

        projectCreationEnableSave(controller:'project', action:'save') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable)) {
                    if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                        forward(controller:"errors", action:"error403")
                        return false
                    }
                }
            }
        }

        projectCreationEnableAdd(controller:'project', action:'add'){
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable)) {
                    if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                        forward(controller:"errors", action:"error403")
                        return false
                    }
                }
            }
        }

        projectImportEnable(controller:'project', action:'import'){
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable)) {
                    if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                        render(status: 403)
                        return false
                    }
                }
            }
        }

        projectExportEnable(controller:'project', action:'export'){
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.export.enable)) {
                    if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                        forward(controller:"errors", action:"error403")
                        return false
                    }
                }
            }
        }

        userRegistrationEnable(controller:'user', action:'register'){
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
                    forward(controller:"errors", action:"error403")
                    return false
                }
            }
        }

        userRegistrationEnable2(controller:'user', action:'save'){
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
                    if (!SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                        forward(controller:"errors", action:"error403")
                        return false
                    }
                }
            }
        }

        userRetrieveEnable(controller:'user', action:'retrieve'){
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.login.retrieve.enable)) {
                    forward(controller:"errors", action:"error403")
                    return false
                }
            }
        }

        webservices(uri: '/ws/**') {
            before = {
                def webservices
                if (params.product) {
                    webservices = Product.createCriteria().get {
                        //TODO test if product is really a long
                        eq 'id', params.product.toLong()
                        preferences {
                            projections {
                                property 'webservices'
                            }
                        }
                        cache true
                    }
                    if (!webservices) {
                        render(status: 503)
                    }
                } else {
                    webservices = true
                }
                if (webservices) {
                    // Replace old parseRequest, warning: the request body (InputStream) cannot be read after that, that a one shot
                    request.withFormat {
                        json {
                            params << request.JSON
                        }
                    }
                }
                return webservices
            }
        }

        locale(uri: '/ws/**', invert:true) {
            before = {

                //manually set
                def locale = params.lang ?: null
                if(locale){
                    RequestContextUtils.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
                    return
                }

                //determine from browser to user set...
                try {
                    def localeAccept = request.getHeader("accept-language")?.split(",")
                    if (localeAccept)
                        localeAccept = localeAccept[0]?.split("-")

                    if (localeAccept?.size() > 0) {
                        locale = params.lang ?: localeAccept[0].toString()
                    }
                } catch (Exception e) {}

                if (springSecurityService.isLoggedIn()) {
                    def currentUserInstance = User.get(springSecurityService.principal.id)
                    if (locale != currentUserInstance.preferences?.language || RequestContextUtils.getLocale(request).toString() != currentUserInstance.preferences?.language) {
                        RequestContextUtils.getLocaleResolver(request).setLocale(request, response, currentUserInstance.locale)
                    }
                } else {
                    if (locale) {
                        RequestContextUtils.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
                    }
                }
            }
        }

        attachmentable(controller:'attachmentable', action:'download'){
            before = {
                redirect(controller: "errors", action: "error403")
            }
        }
    }

}