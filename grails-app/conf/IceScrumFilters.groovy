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
import org.geeks.browserdetection.ComparisonType
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
                if (!request.getRequestURI().contains('/ws/')
                        && controllerName != "errors"
                        && actionName != "browserNotSupported"
                        && userAgentIdentService.isMsie(ComparisonType.LOWER, "9")
                        && !request.getHeader('user-agent').contains('chromeframe')) {
                    redirect(controller: 'errors', action: 'browserNotSupported')
                    return false
                }
                if (params.project) {
                    params.project = params.project.decodeProjectKey()
                    if (!params.project) {
                        forward(controller: "errors", action: "error404")
                        return false
                    }
                }
                securityService.filterRequest()
                return
            }
        }

        projectCreationEnableSave(controller: 'project', action: 'save') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                    forward(controller: "errors", action: "error403")
                    return false
                }
            }
        }

        projectCreationEnableAdd(controller: 'project', action: 'add') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                    forward(controller: "errors", action: "error403")
                    return false
                }
            }
        }

        projectImportEnable(controller: 'project', action: 'import') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                    render(status: 403)
                    return false
                }
            }
        }

        projectExportEnable(controller: 'project', action: 'export') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.export.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                    forward(controller: "errors", action: "error403")
                    return false
                }
            }
        }

        userRegistrationEnable(controller: 'user', action: 'register') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable)) {
                    forward(controller: "errors", action: "error403")
                    return false
                }
            }
        }

        userRegistrationEnable2(controller: 'user', action: 'save') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.registration.enable) && !SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)) {
                    forward(controller: "errors", action: "error403")
                    return false
                }
            }
        }

        userRetrieveEnable(controller: 'user', action: 'retrieve') {
            before = {
                if (!ApplicationSupport.booleanValue(grailsApplication.config.icescrum.login.retrieve.enable)) {
                    forward(controller: "errors", action: "error403")
                    return false
                }
            }
        }

        webservices(uri: '/ws/**') {
            before = {
                request.withFormat {
                    json {
                        // Project cannot be provided in body, it must be provided in URL
                        def data = request.JSON
                        data.remove("project")
                        params << request.JSON
                    }
                }
            }
        }


        locale(uri: '/ws/**', invert: true) {
            before = {
                try {
                    Locale locale
                    if (params.lang) {
                        locale = new Locale(params.lang)
                    } else if (springSecurityService.isLoggedIn()) {
                        locale = User.getLocale(springSecurityService.principal.id) // May be executed for every incoming request, so it is optimized and cached
                    } else {
                        def acceptLanguage = request.getHeader("accept-language")?.split(",")
                        if (acceptLanguage) {
                            locale = new Locale(*acceptLanguage[0].split('-', 3))
                        }
                    }
                    if (locale) {
                        RequestContextUtils.getLocaleResolver(request).setLocale(request, response, locale) // Stored in Session because LocaleResolver is a SessionLocaleResolver
                    }
                } catch (Exception e) {
                    e.printStackTrace()
                }
            }
        }

        attachmentable(controller: 'attachmentable', action: 'download') {
            before = {
                redirect(controller: "errors", action: "error403")
            }
        }
    }

}
