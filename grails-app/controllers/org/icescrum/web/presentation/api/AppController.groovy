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

    @Secured('stakeHolder() or inProject()')
    def definitions(long project) {
        Project _project = Project.withProject(project)
        def appDefinitions = appDefinitionService.getAppDefinitions().sort { it.name }.collect { AppDefinition appDefinition ->
            def properties = appDefinition.properties
            ['class', 'onDisableForProject', 'onEnableForProject', 'isEnabledForProject'].each { k ->
                properties.remove(k)
            }
            if (appDefinition.isProject) {
                if (appDefinition.isSimple) {
                    properties.enabledForProject = SimpleProjectApp.findByParentProjectAndAppDefinitionId(_project, appDefinition.id)?.enabled ?: false
                } else {
                    properties.enabledForProject = appDefinition.isEnabledForProject ? appDefinition.isEnabledForProject() : false
                }
            }
            return properties
        }
        render(status: 200, contentType: 'application/json', text: appDefinitions as JSON)
    }

    @Secured('scrumMaster()')
    def updateEnabledForProject(long project, String appDefinitionId, boolean enabledForProject) {
        Project _project = Project.withProject(project)
        appService.updateEnabledForProject(_project, appDefinitionId, enabledForProject)
        render(status: 200)
    }
}
