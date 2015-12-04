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
controllers.controller('homeCtrl', ['$scope', 'HomeService', function($scope, HomeService) {
    // Init
    $scope.panelsLeft = [];
    $scope.panelsRight = [];
    var updatePosition = function(event) {
        HomeService.updatePositionPanel({
            id: event.source.itemScope.modelValue.id,
            position: event.dest.index,
            right: event.dest.sortableScope.modelValue === $scope.panelsRight
        });
    };
    $scope.panelSortableOptions = {
        itemMoved: updatePosition,
        orderChanged: updatePosition,
        accept: function (sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.sortableId = 'home';
    HomeService.getPanels().then(function(panels) {
        $scope.panelsLeft = panels.panelsLeft;
        $scope.panelsRight = panels.panelsRight;
    });
}]);