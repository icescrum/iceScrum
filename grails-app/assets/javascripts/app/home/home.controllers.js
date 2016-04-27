/*
 * Copyright (c) 2015 Kagilum SAS.
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
 *
 */
controllers.controller('homeCtrl', ['$scope', 'Session', 'UserService', function($scope, Session, UserService) {
    // Init
    $scope.widgetsLeft = [];
    $scope.widgetsRight = [];
    var updatePosition = function(event) {
        var widgetId = event.source.itemScope.modelValue.id.split('-');
        UserService.updateWidgetPosition({
            widgetId:widgetId[1],
            widgetDefinitionId:widgetId[0],
            position: event.dest.index,
            right: event.dest.sortableScope.modelValue === $scope.widgetsRight
        });
    };
    $scope.widgetSortableOptions = {
        itemMoved: updatePosition,
        orderChanged: updatePosition,
        accept: function (sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.sortableId = 'home';
    UserService.getWidgets(Session.user).then(function(widgets) {
        $scope.widgetsLeft = widgets.widgetsLeft;
        $scope.widgetsRight = widgets.widgetsRight;
    });
    $scope.authenticated = Session.authenticated; // This is a function which return value will change when user will be set
}]);