/*
 * Copyright (c) 2017 Kagilum SAS.
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

services.service("AppService", ['Session', 'FormService', function(Session, FormService) {
    var self = this;
    this.updateEnabledForProject = function(appDefinition, project, enabledForProject) {
        return FormService.httpPost('app/updateEnabledForProject', {appDefinitionId: appDefinition.id, enabledForProject: enabledForProject}).then(function() {
            var updatedAppDefinition = _.find(project.simpleProjectApps, {appDefinitionId: appDefinition.id});
            if (!updatedAppDefinition) {
                updatedAppDefinition = {appDefinitionId: appDefinition.id};
                project.simpleProjectApps.push(updatedAppDefinition);
            }
            updatedAppDefinition.enabled = enabledForProject;
        });
    };
    this.getAppDefinitions = function() {
        return FormService.httpGet('app/definitions', null, true);
    };
    this.getAppDefinitionsWithProjectSettings = function(project) {
        return self.getAppDefinitions().then(function(appDefinitions) {
            return _.filter(appDefinitions, function(appDefinition) {
                return self.authorizedApp('updateProjectSettings', appDefinition, project)
            });
        });
    };
    this.authorizedApp = function(action, appDefinitionOrId, project) {
        switch (action) {
            case 'show':
                return Session.authenticated() && Session.workspaceType == 'project';
            case 'enableForProject':
                var appDefinition = appDefinitionOrId;
                return Session.poOrSm() && appDefinition && appDefinition.availableForServer && appDefinition.enabledForServer && appDefinition.isProject;
            case 'askToEnableForProject':
                var appDefinition = appDefinitionOrId;
                return Session.tm() && appDefinition && appDefinition.availableForServer && appDefinition.enabledForServer && appDefinition.isProject;
            case 'updateProjectSettings':
                var appDefinition = appDefinitionOrId;
                return self.authorizedApp('enableForProject', appDefinition) && self.authorizedApp('use', appDefinition.id, project) && appDefinition.projectSettings;
            case 'use':
                var appDefinitionId = appDefinitionOrId;
                return !!(project && _.find(project.simpleProjectApps, {appDefinitionId: appDefinitionId, enabled: true}));
            default:
                return false;
        }
    };
}]);