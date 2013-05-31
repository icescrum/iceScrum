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
 * Stephane Maldini (stephane.maldini@icescrum.com)
 */


import org.geeks.browserdetection.BrowserTagLib
import org.geeks.browserdetection.ComparisonType
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User
import org.springframework.web.servlet.support.RequestContextUtils

class IceScrumFilters {

    def securityService
    def springSecurityService
    def userAgentIdentService

    def filters = {
        pkey(controller: 'scrumOS', action: 'index') {
            before = {
                if (params.product) {
                    params.product = params.product.decodeProductKey()
                    if (!params.product) {
                        redirect(controller: 'scrumOS', action: 'index')
                        return
                    }

                }
            }
        }

        webservices(uri: '/ws/**') {
            before = {
                def webservices = false
                if (params.product) {
                    params.product = params.product.decodeProductKey()
                    webservices = Product.createCriteria().get {
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
                    } else {
                        if (request.format == 'xml' && params.values) {
                            params.remove('values')?.each { k, v ->
                                params."${k}" = v
                            }
                        }
                    }
                }
                return webservices
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
                securityService.filterRequest()
                return
            }
        }

        pkeyFeed(controller: 'project', action: 'feed') {
            before = {
                if (params.product) {
                    params.product = params.product.decodeProductKey()
                    if (!params.product) {
                        render(status: 404)
                        return
                    }

                }
            }

        }

        releaseId(controller: 'releasePlan', action: '*') {
            before = {
                if (!params.id) {
                    params.id = !actionName.contains('Chart') ? Release.findCurrentOrNextRelease(Product.load(params.product).id).list()[0]?.id : Release.findCurrentOrLastRelease(Product.load(params.product).id).list()[0]?.id
                }
            }
        }

        sprintId(controller: 'sprintPlan', action: '*') {
            before = {
                if (!params.id) {
                    params.id = !actionName.contains('Chart') ? Sprint.findCurrentOrNextSprint(Product.load(params.product).id).list()[0]?.id : Sprint.findCurrentOrLastSprint(Product.load(params.product).id).list()[0]?.id
                }
            }
        }

        locale(uri: '/ws/**', invert:true) {
            before = {
                def locale = params.lang ?: null
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
                    if (locale != currentUserInstance.preferences.language || RequestContextUtils.getLocale(request).toString() != currentUserInstance.preferences.language) {
                        RequestContextUtils.getLocaleResolver(request).setLocale(request, response, currentUserInstance.locale)
                    }
                } else {
                    if (locale) {
                        RequestContextUtils.getLocaleResolver(request).setLocale(request, response, new Locale(locale))
                    }
                }
            }
        }
    }

}
