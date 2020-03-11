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
extensibleController('meetingCtrl', ['$scope', '$injector', 'AppService', function($scope, $injector, AppService) {
    // Init
    $scope.injector = $injector;
    $scope.selectedProvider = function(object, provider) {
        if (provider.enabled) {
            provider.start(object, $scope);
        } else {
            $scope.showAppsModal($scope.message('is.ui.apps.tag.collaboration'), true)
        }
    };

    $scope.$watch('project.simpleProjectApps', function() {
        $scope.providers = _.each(isSettings.meeting.providers, function(provider) {
            provider.enabled = AppService.authorizedApp('use', provider.id, $scope.project);
        });
    }, true);
}]);