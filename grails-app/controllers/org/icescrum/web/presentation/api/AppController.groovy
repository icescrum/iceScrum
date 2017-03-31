/*
 * Copyright (c) 2017 Kagilum SAS
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

package org.icescrum.web.presentation.api

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.app.AppDefinition
import org.icescrum.core.domain.Project
import org.icescrum.core.domain.SimpleProjectApp
import org.icescrum.core.error.ControllerErrorHandler

class AppController implements ControllerErrorHandler {

    def appService
    def appDefinitionService
    def grailsApplication

    @Secured('stakeHolder() or inProject()')
    def definitions(long project) {
        Project _project = Project.withProject(project)
        List<String> enabledAppIds = SimpleProjectApp.getEnabledAppIdsForProject(_project)
        def marshalledDefinitions = appDefinitionService.getAppDefinitions().collect { AppDefinition appDefinition ->
            Map marshalledAppDefinition = appDefinition.properties.clone()
            ['class', 'onDisableForProject', 'onEnableForProject', 'isEnabledForServer', 'isAvailableForServer'].each { k ->
                marshalledAppDefinition.remove(k)
            }
            ['name', 'baseline', 'description'].each { k ->
                marshalledAppDefinition[k] = message(code: 'is.ui.apps.' + appDefinition.id + '.'+ k)
            }
            marshalledAppDefinition.tags = marshalledAppDefinition.tags?.collect {
                message(code: it)
            }
            marshalledAppDefinition.availableForServer = appDefinition.isAvailableForServer ? appDefinition.isAvailableForServer() : true
            marshalledAppDefinition.enabledForServer = appDefinition.isEnabledForServer ? appDefinition.isEnabledForServer(grailsApplication) : true
            if (appDefinition.isProject) {
                marshalledAppDefinition.enabledForProject = enabledAppIds.contains(appDefinition.id)
            }
            return marshalledAppDefinition
        }
        render(status: 200, contentType: 'application/json', text: marshalledDefinitions as JSON)
    }

    @Secured('scrumMaster()')
    def updateEnabledForProject(long project, String appDefinitionId, boolean enabledForProject) {
        Project _project = Project.withProject(project)
        appService.updateEnabledForProject(_project, appDefinitionId, enabledForProject)
        render(status: 200)
    }
}
