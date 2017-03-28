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
controllers.controller('appsCtrl', ['$scope', 'AppService', function($scope, AppService) {
    // Functions
    $scope.openAppDefinition = function(appDefinition) {
        $scope.appDefinition = appDefinition;
    };
    $scope.searchApp = function(appSearch) {
        $scope.holder.appSearch = appSearch;
    };
    $scope.updateEnabledForProject = function(appDefinition, enabledForProject) {
        AppService.updateEnabledForProject(appDefinition, enabledForProject).then(function() {
            appDefinition.enabledForProject = enabledForProject;
        });
    };
    $scope.appDefinitionFilter = function(appDefinition) {
        var search = $scope.holder.appSearch;
        if (search) {
            var containsText = function(text, subText) {
                return text.toLowerCase().indexOf(subText.toLowerCase()) != -1;
            };
            var textContainsSearch = _.some(['name', 'baseline'], function(attributeName) {
                return containsText(appDefinition[attributeName], search);
            });
            var tagContainsSearch = _.some(appDefinition.tags, function(tag) {
                return containsText(tag, search);
            });
            return textContainsSearch || tagContainsSearch;
        } else {
            return true;
        }
    };
    $scope.openAppProjectSettings = function(appDefinition) {
        $scope.$close();
        $scope.showProjectEditModal(appDefinition.id);
    };
    $scope.authorizedApp = AppService.authorizedApp;
    // Init
    $scope.holder = {};
    $scope.appDefinitions = [];
    AppService.getAppDefinitions().then(function(appDefinitions) {
        if (appDefinitions.length > 0) {
            $scope.appDefinitions = appDefinitions;
            if ($scope.defaultAppDefinitionId) {
                $scope.appDefinition = _.find($scope.appDefinitions, {id: $scope.defaultAppDefinitionId});
            }
        }
    });
}]);

