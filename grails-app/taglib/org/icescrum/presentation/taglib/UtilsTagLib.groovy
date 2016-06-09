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

class UtilsTagLib {

    static returnObjectForTags = ['i18nBundle', 'exportFormats']

    static namespace = 'is'

    def grailsApplication
    def uiDefinitionService

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
        assert attrs.windowDefinition
        def exportFormats = uiDefinitionService.getWindowDefinitionById(attrs.windowDefinition.id).exportFormats
        if (exportFormats instanceof Closure){
            exportFormats.delegate = delegate
            exportFormats.resolveStrategy = Closure.DELEGATE_FIRST
            exportFormats = exportFormats()
        }
        entry.hook(id:"${controllerName}-getExportFormats", model:[exportFormats:exportFormats])
        return exportFormats
    }

    def i18nBundle = {
        return grailsApplication.config.icescrum.resourceBundles.collectEntries { bundleName, values -> [
            (bundleName.capitalize()): values.collectEntries { k, v -> [(k): message(code: v)]}
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
}