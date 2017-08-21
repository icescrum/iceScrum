/*
 * Copyright (c) 2016 Kagilum SAS.
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

controllers.controller("widgetCtrl", ['$scope', 'WidgetService', '$q', function($scope, WidgetService, $q) {
    //used to be overrided by plugin if necessary
    $scope.display = function(widget){};

    $scope.toggleSettings = function(widget) {
        if ($scope.showSettings) {
            return $scope.update(widget).then(function(widget){
                $scope.showSettings = !$scope.showSettings;
                $scope.display(widget);
            });
        }
        $scope.showSettings = !$scope.showSettings;
        return $q.when(widget);
    };
    $scope.update = function(widget) {
        return WidgetService.update(widget);
    };
    $scope.delete = function(widget) {
        return WidgetService.delete(widget);
    };
}]);