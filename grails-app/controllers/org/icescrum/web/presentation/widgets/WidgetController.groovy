/*
 * Copyright (c) 2016 Kagilum SAS
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

package org.icescrum.web.presentation.widgets

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Widget
import org.icescrum.core.domain.preferences.UserPreferences
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.ui.WidgetDefinition

class WidgetController implements ControllerErrorHandler {

    def widgetService
    def uiDefinitionService
    def springSecurityService

    @Secured(['permitAll()'])
    def index() {
        User user = springSecurityService.currentUser
        def widgets
        if (user) {
            widgets = user.preferences.widgets
        } else {
            widgets = uiDefinitionService.widgetDefinitions.findResults {
                ApplicationSupport.isAllowed(it.value, [], true) ? it : null
            }.collect {
                ['widgetDefinitionId': it.key, 'height': it.value.height, 'width': it.value.width]
            }
        }
        render(status: 200, contentType: 'application/json', text: widgets as JSON)
    }

    @Secured(['permitAll()'])
    def show(String widgetDefinitionId, long id) {
        if (!widgetDefinitionId) {
            returnError(code: 'is.error.no.widget')
            return
        }
        def widgetDefinition = uiDefinitionService.getWidgetDefinitionById(widgetDefinitionId)
        if (widgetDefinition && ApplicationSupport.isAllowed(widgetDefinition, params, true)) {
            UserPreferences userPreferences = springSecurityService.currentUser?.preferences
            if (id && !userPreferences) {
                render(status: 200, text: "")
            } else {
                def model = [widgetDefinition: widgetDefinition, widget: id ? Widget.findByIdAndUserPreferences(id, userPreferences) : null]
                if (ApplicationSupport.controllerExist(widgetDefinition.id, "widget")) {
                    forward(action: 'widget', controller: widgetDefinition.id, model: model)
                } else if (widgetDefinition.templatePath) {
                    render(plugin: widgetDefinition.pluginName, template: widgetDefinition.templatePath, model: model)
                }
            }
        } else {
            render(status: 200, text: "")
        }
    }

    @Secured('isAuthenticated()')
    def save(String widgetDefinitionId) {
        User user = springSecurityService.currentUser
        WidgetDefinition widgetDefinition = uiDefinitionService.getWidgetDefinitionById(widgetDefinitionId)
        if (!widgetDefinition || !user || !ApplicationSupport.isAllowed(widgetDefinition, [], true)) {
            returnError(code: 'is.user.preferences.error.widget')
            return
        }
        Widget widget = widgetService.save(user, widgetDefinition)
        render(status: 201, contentType: 'application/json', text: widget as JSON)
    }

    @Secured('isAuthenticated()')
    def update(long id) {
        User user = springSecurityService.currentUser
        def widgetParams = params.widget
        if (!id || !widgetParams) {
            returnError(code: 'is.user.preferences.error.widget')
            return
        }
        Widget widget = Widget.findByIdAndUserPreferences(id, user.preferences)
        if (!widget) {
            render(status: 403)
        } else {
            Map props = [:]
            if (widgetParams.position) {
                props.position = widgetParams.int('position')
            }
            if (widgetParams.settingsData) {
                props.settings = JSON.parse(widgetParams.settingsData)
            }
            if (widgetParams.type && widgetParams.typeId) {
                widget.typeId = widgetParams.long('typeId')
                widget.type = widgetParams.type
            }
            widgetService.update(widget, props)
            render(status: 200, contentType: 'application/json', text: widget as JSON)
        }
    }

    @Secured('isAuthenticated()')
    def delete() {
        User user = springSecurityService.currentUser
        if (!params.id) {
            returnError(code: 'is.user.preferences.error.widget')
            return
        }
        Widget widget = Widget.findByIdAndUserPreferences(params.long('id'), user.preferences)
        if (!widget) {
            render(status: 403)
        } else {
            widgetService.delete(widget)
            render(status: 204)
        }
    }

    @Secured('isAuthenticated()')
    def definitions() {
        User user = springSecurityService.currentUser
        def userWidgets = user.preferences.widgets.collect { it.widgetDefinitionId }
        def widgetDefinitions = uiDefinitionService.widgetDefinitions
                .findResults { ApplicationSupport.isAllowed(it.value, [], true) ? it : null }
                .collect {
                    [id         : it.value.id,
                     icon       : it.value.icon,
                     name       : message(code: it.value.name),
                     description: message(code: it.value.description),
                     available  : !(!it.value.allowDuplicate && userWidgets.contains(it.value.id))]
                }
        render(status: 200, contentType: 'application/json', text: widgetDefinitions as JSON)
    }
}
