/*
 * Copyright (c) 2019 Kagilum.
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
 */
controllers.controller("notesWidgetCtrl", ['$scope', '$filter', 'FormService', 'WidgetService', '$controller', function($scope, $filter, FormService, WidgetService, $controller) {
    $controller('widgetCtrl', {$scope: $scope});
    //$scope.widget inherited
    var widget = $scope.widget;
    $scope.markitupCheckboxOptions = function() {
        return {
            options: {
                object: function() { return widget.settings; },
                property: 'text',
                action: function() { $scope.update(widget); },
                autoSubmit: function() { return true; },
                isEnabled: function() { return true; }
            }
        }
    };
}]);
