/*
 * Copyright (c) 2017 Kagilum SAS
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */
package org.icescrum.web.presentation.windows

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport

class WindowController implements ControllerErrorHandler {

    def windowService
    def uiDefinitionService
    def springSecurityService

    @Secured(['permitAll()'])
    def show(String windowDefinitionId) {
        if (!windowDefinitionId) {
            returnError(code: 'is.error.no.window')
            return
        }
        def windowDefinition = uiDefinitionService.getWindowDefinitionById(windowDefinitionId)
        if (windowDefinition) {
            if (!ApplicationSupport.isAllowed(windowDefinition, params)) {
                if (springSecurityService.isLoggedIn()) {
                    render(status: 403)
                } else {
                    render(status: 401, contentType: 'application/json', text: [] as JSON)
                }
                return
            }

            def context = windowDefinition.context ? ApplicationSupport.getCurrentContext(params, windowDefinition.context) : null
            def _continue = true
            if (windowDefinition.before) {
                windowDefinition.before.delegate = delegate
                windowDefinition.before.resolveStrategy = Closure.DELEGATE_FIRST
                _continue = windowDefinition.before(context?.object)
            }

            if (!_continue) {
                render(status: 404)
            } else {
                def model = [windowDefinition: windowDefinition]
                if (context) {
                    model[context.name] = context.object
                    model['contextScope'] = context.contextScope
                }
                if (ApplicationSupport.controllerExist(windowDefinition.id, "window")) {
                    forward(action: 'window', controller: windowDefinition.id, model: model)
                } else {
                    render(plugin: windowDefinition.pluginName, template: "/${windowDefinition.id}/window", model: model)
                }
            }
        } else {
            render(status: 404)
        }
    }

    @Secured(['permitAll()'])
    def settings(String windowDefinitionId) {
        User user = springSecurityService.currentUser
        def context = ApplicationSupport.getCurrentContext(params)
        //defaultValues
        def defaultWindow = context ? [windowDefinitionId: windowDefinitionId, context: context.name, contextId: context.object.id] : [windowDefinitionId: windowDefinitionId]
        def windowDefinition = uiDefinitionService.getWindowDefinitionById(windowDefinitionId)
        if (!user) {
            render(status: 200, contentType: 'application/json', text: defaultWindow as JSON)
            return
        }
        def window = windowService.retrieve(windowDefinition, user, context)
        render(status: 200, contentType: 'application/json', text: (window ?: defaultWindow) as JSON)
    }

    @Secured(['isAuthenticated()'])
    def updateSettings(String windowDefinitionId) {
        def windowParams = params.window
        User user = springSecurityService.currentUser
        def context = ApplicationSupport.getCurrentContext(params)
        def windowDefinition = uiDefinitionService.getWindowDefinitionById(windowDefinitionId)
        if (!user) {
            render(status: 200, contentType: 'text/javascript', text: [windowDefinitionId: windowDefinitionId, context: context.name, contextId: context.object.id] as JSON)
            return
        }
        Map props = [:]
        if (windowParams.settingsData) {
            props.settings = JSON.parse(windowParams.settingsData)
        }
        def window = windowService.retrieve(windowDefinition, user, context)
        if (!window) {
            window = windowService.save(windowDefinition, user, context)
        }
        windowService.update(window, props)
        render(status: 200, contentType: 'application/json', text: window as JSON)
    }
}
