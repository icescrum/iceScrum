/*
 * Copyright (c) 2014 Kagilum SAS.
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

package org.icescrum.presentation.taglib

import grails.plugin.springsecurity.SpringSecurityUtils
import org.icescrum.core.domain.security.Authority
import org.icescrum.core.support.ApplicationSupport
import org.icescrum.core.ui.UiDefinition
import org.icescrum.core.utils.BundleUtils
import org.springframework.web.servlet.support.RequestContextUtils as RCU

class UtilsTagLib {

    static returnObjectForTags = ['i18nBundle', 'exportFormats', 'getMenuBarFromUiDefinitions']

    static namespace = 'is'

    def grailsApplication
    def uiDefinitionService
    def menuBarSupport

    def loadJsVar = { attrs, body ->

        def current = pageScope.variables?.space ? pageScope.space.object : null
        def p = current ? pageScope.space.params : [:]
        def locale = attrs.locale ? attrs.locale : RCU.getLocale(request).toString()
        def jsCode = """var icescrum = {
                          grailsServer:"${grailsApplication.config.grails.serverURL}",
                          baseUrl: "${createLink(controller: 'scrumOS')}",
                          versionUrl: "${createLink(controller: 'scrumOS', action:'version')}",
                          baseUrlSpace: ${p ? '\'' + createLink(controller: 'scrumOS', params: p, mapping:'baseUrl'+pageScope.variables.space.name.capitalize()) + '/\'' : null},
                          urlOpenWindow:"${createLink(controller: 'scrumOS', action: 'openWindow', params: p)}",
                          deleteConfirmMessage:"${message(code: 'is.confirm.delete').encodeAsJavaScript()}",
                          cancelFormConfirmMessage:"${message(code: 'is.confirm.cancel.form').encodeAsJavaScript()}",
                          more:"${message(code: 'is.menu.more').encodeAsJavaScript()}",
                          uploading:"${message(code:'is.upload.inprogress.wait').encodeAsJavaScript()}",
                          locale:'${locale}'
                };"""
        out << g.javascript(null, jsCode)
    }

    def header = { attrs, body ->
        out << g.render(template: '/scrumOS/header',
                model: [
                        importEnable: (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.import.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)),
                        exportEnable: (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.export.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)),
                        creationProjectEnable: (ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.creation.enable) || SpringSecurityUtils.ifAnyGranted(Authority.ROLE_ADMIN)),
                ]
        )
    }

    def exportFormats = { attrs, body ->
        def exportFormats = uiDefinitionService.getDefinitionById(controllerName).exportFormats
        if (exportFormats instanceof Closure){
            exportFormats.delegate = delegate
            exportFormats.resolveStrategy = Closure.DELEGATE_FIRST
            exportFormats = exportFormats()
        }
        entry.hook(id:"${controllerName}-getExportFormats", model:[exportFormats:exportFormats])
        return exportFormats
    }

    def i18nBundle = {
        def bundles = ['storyStates', 'storyTypes', 'taskStates', 'taskTypes', 'featureTypes', 'featureStates', 'sprintStates',
                       'releaseStates', 'planningPokerGameSuites', 'acceptanceTestStates', 'moodFeelings']
        return bundles.collectEntries { bundleName -> [
            (bundleName.capitalize()): BundleUtils."$bundleName".collectEntries { k, v -> [(k): message(code: v)]}
        ]}
    }

    def errors = {
        def trueError = grailsApplication.config.icescrum.errors?.find{ it.error }
        if (grailsApplication.config.icescrum.errors){
            out << """<a class="show-warning" ng-click="showAbout()" href tooltip-placement="right" uib-tooltip="${g.message(code:'is.warning')}"><i class="text-danger fa ${trueError ? 'fa-warning' : 'fa-cloud-download'}"></i></a>"""
        }
    }

    def appId = {
        out << grailsApplication.config.icescrum.appID
    }

    def getMenuBarFromUiDefinitions = { attrs ->
        def menus = []
        uiDefinitionService.getDefinitions().each { String uiDefinitionId, UiDefinition uiDefinition ->
            def menuBar = uiDefinition.menuBar
            if (menuBar?.spaceDynamicBar) {
                menuBar.show = menuBarSupport.spaceDynamicBar(uiDefinitionId, menuBar.defaultVisibility, menuBar.defaultPosition, uiDefinition.space, uiDefinition.window.init)
            }
            def show = menuBar?.show
            if (show in Closure) {
                show.delegate = delegate
                show = show()
            }
            if (show) {
                menus << [title: message(code: menuBar?.title),
                          id: uiDefinitionId,
                          shortcut: "ctrl+" + (menus.size() + 1),
                          icon: uiDefinition.icon,
                          position: show instanceof Map ? show.pos.toInteger() ?: 1 : 1,
                          visible: show.visible]
            }
        }
        return menus
    }
}