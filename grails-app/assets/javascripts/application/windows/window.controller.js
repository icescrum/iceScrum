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
 *
 */
controllers.controller("windowCtrl", ['$scope', 'WindowService', 'window', '$q', function($scope, WindowService, window, $q) {
    $scope.getWindowSetting = function(name, defaultValue) {
        var value = window.settings[name];
        return angular.isUndefined(value) ? defaultValue : value
    };
    $scope.saveOrUpdateWindowSetting = function(name, value) {
        window.settings[name] = value;
        return WindowService.update(window).$promise;
    };
    $scope.deleteWindowSetting = function(name) {
        delete window.settings[name];
        return WindowService.update(window).$promise;
    };
}]);