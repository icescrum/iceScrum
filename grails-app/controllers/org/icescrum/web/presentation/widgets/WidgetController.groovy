package org.icescrum.web.presentation.widgets

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.User
import org.icescrum.core.domain.Widget
import org.icescrum.core.domain.preferences.UserPreferences
import org.icescrum.core.support.ApplicationSupport

class WidgetController {

    def widgetService
    def uiDefinitionService
    def springSecurityService

    @Secured(['permitAll()'])
    def index() {
        User user = springSecurityService.currentUser
        def widgets
        if (user) {
            widgets = Widget.createCriteria().list {
                eq('userPreferences', user.preferences)
                order('onRight', 'desc')
                order('position', 'asc')
            }
        } else {
            widgets = uiDefinitionService.widgetDefinitions.findResults{ ApplicationSupport.isAllowed(it.value, [], true) ? it : null }
                            .collect{ ['widgetDefinitionId':it.key] }
                                .eachWithIndex{ def entry, def i -> entry.onRight = i % 2 ? true : false }
        }
        render(status: 200, contentType: 'application/json', text: widgets as JSON)
    }

    @Secured(['permitAll()'])
    def show(String widgetDefinitionId, long id) {
        if (!widgetDefinitionId) {
            returnError(text: message(code: 'is.error.no.widget'))
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
    def update(long id) {
        User user = springSecurityService.currentUser
        if (!id || !params.widget) {
            returnError(text: message(code: 'is.user.preferences.error.widget'))
            return
        }
        Widget widget = Widget.findByIdAndUserPreferences(id, user.preferences)
        if(!widget){
            render(status: 403)
        } else {
            try {
                Map props = [:]
                if(params.widget.position){
                    props.position = params.widget.int('position')
                }
                if(params.widget.onRight){
                    props.onRight = params.widget.boolean('onRight')
                }
                if(params.widget.settings){
                    props.settings =  params.widget.settings
                }
                widgetService.update(widget, props)
                render(status: 200, text:widget as JSON)
            } catch (RuntimeException e) {
                returnError(text: message(code: 'is.user.preferences.error.widget'), exception: e)
            }
        }
    }

    @Secured('isAuthenticated()')
    def delete() {
        User user = springSecurityService.currentUser
        if (!params.id) {
            returnError(text: message(code: 'is.user.preferences.error.widget'))
            return
        }
        Widget widget = Widget.findByIdAndUserPreferences(params.long('id'), user.preferences)
        if(!widget){
            render(status: 403)
        } else {
            try {
                widgetService.delete(widget)
                render(status: 204)
            } catch (RuntimeException e) {
                returnError(text: message(code: 'is.user.preferences.error.widget'), exception: e)
            }
        }
    }
}
