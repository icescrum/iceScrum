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
import org.icescrum.core.domain.Portfolio
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Widget
import org.icescrum.core.domain.Widget.WidgetParentType
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.ui.WidgetDefinition

class WidgetController implements ControllerErrorHandler {

    def widgetService
    def uiDefinitionService
    def springSecurityService
    def securityService

    @Secured(['permitAll()'])
    def index(Long portfolio) {
        def widgets
        if (portfolio) {
            def auth = springSecurityService.authentication
            if (!securityService.businessOwner(portfolio, auth) && !securityService.portfolioStakeHolder(portfolio, auth)) {
                render(status: 403)
                return
            }
            widgets = Portfolio.withPortfolio(portfolio).widgets
        } else {
            User user = springSecurityService.currentUser
            if (user) {
                widgets = user.preferences.widgets
            } else {
                widgets = uiDefinitionService.widgetDefinitions.findResults { id, WidgetDefinition widgetDefinition ->
                    ApplicationSupport.isAllowed(widgetDefinition, params) ? ['widgetDefinitionId': id, 'height': widgetDefinition.height, 'width': widgetDefinition.width] : null
                }
            }
        }
        render(status: 200, contentType: 'application/json', text: widgets as JSON)
    }

    @Secured(['permitAll()'])
    def show(String widgetDefinitionId, long id, Long portfolio) {
        def widgetDefinition = uiDefinitionService.getWidgetDefinitionById(widgetDefinitionId)
        if (!widgetDefinition || !ApplicationSupport.isAllowed(widgetDefinition, params)) {
            render(status: 403)
            return
        }
        Widget widget = Widget.get(id)
        if (widget) {
            if (widget.parentType == WidgetParentType.PORTFOLIO && (
                    widget.portfolio.id != portfolio ||
                    (!securityService.businessOwner(portfolio, springSecurityService.authentication) && !securityService.portfolioStakeHolder(portfolio, springSecurityService.authentication)))) {
                render(status: 403)
                return
            }
            if (widget.parentType == WidgetParentType.USER && widget.userPreferences.id != springSecurityService.currentUser.preferences.id) {
                render(status: 403)
                return
            }
        }
        def model = [widgetDefinition: widgetDefinition, widget: widget]
        if (ApplicationSupport.controllerExist(widgetDefinition.id, "widget")) {
            forward(action: 'widget', controller: widgetDefinition.id, model: model)
        } else if (widgetDefinition.templatePath) {
            render(plugin: widgetDefinition.pluginName, template: widgetDefinition.templatePath, model: model)
        }
    }

    @Secured('isAuthenticated()')
    def save(String widgetDefinitionId, Long portfolio) {
        WidgetDefinition widgetDefinition = uiDefinitionService.getWidgetDefinitionById(widgetDefinitionId)
        if (!widgetDefinition || !ApplicationSupport.isAllowed(widgetDefinition, params)) {
            returnError(code: 'is.widget.error.save')
            return
        }
        def parentType
        def parent
        if (portfolio) {
            parentType = WidgetParentType.PORTFOLIO
            parent = Portfolio.withPortfolio(portfolio)
        } else {
            parentType = WidgetParentType.USER
            parent = springSecurityService.currentUser.preferences
        }
        Widget widget = widgetService.save(widgetDefinition, parentType, parent)
        render(status: 201, contentType: 'application/json', text: widget as JSON)
    }

    @Secured('isAuthenticated()')
    def update(long id, Long portfolio) {
        def widgetParams = params.widget
        if (!widgetParams) {
            returnError(code: 'is.widget.error.update')
            return
        }
        Widget widget = Widget.withWidget(id)
        if (widget.parentType == WidgetParentType.PORTFOLIO && (widget.portfolio.id != portfolio || !securityService.businessOwner(portfolio, springSecurityService.authentication))) {
            render(status: 403)
            return
        }
        if (widget.parentType == WidgetParentType.USER && widget.userPreferences.id != springSecurityService.currentUser.preferences.id) {
            render(status: 403)
            return
        }
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

    @Secured('isAuthenticated()')
    def delete(long id, Long portfolio) {
        Widget widget = Widget.withWidget(id)
        if (widget.parentType == WidgetParentType.PORTFOLIO && (widget.portfolio.id != portfolio || !securityService.businessOwner(portfolio, springSecurityService.authentication))) {
            render(status: 403)
            return
        }
        if (widget.parentType == WidgetParentType.USER && widget.userPreferences.id != springSecurityService.currentUser.preferences.id) {
            render(status: 403)
            return
        }
        widgetService.delete(widget)
        render(status: 204)
    }

    @Secured('isAuthenticated()')
    def definitions(Long portfolio) {
        def existingWidgets = portfolio ? Portfolio.withPortfolio(portfolio).widgets : springSecurityService.currentUser.preferences.widgets
        def widgetDefinitions = uiDefinitionService.widgetDefinitions.findResults { id, WidgetDefinition widgetDefinition ->
            ApplicationSupport.isAllowed(widgetDefinition, params) ? [
                    id         : id,
                    icon       : widgetDefinition.icon,
                    name       : message(code: widgetDefinition.name),
                    description: message(code: widgetDefinition.description),
                    available  : widgetDefinition.allowDuplicate || !existingWidgets*.widgetDefinitionId.contains(id)
            ] : null
        }
        render(status: 200, contentType: 'application/json', text: widgetDefinitions as JSON)
    }
}
