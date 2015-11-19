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
    // Functions
    $scope.sortablePanelUpdate = function(startModel, destModel, start, end) {
        var $panels = $('#view-home').find('>>');
        //HomeService.updatePositionPanel({id: destModel[end].id, position: pos});
    };
    // Init
    $scope.panels_l = [];
    $scope.panels_r = [];
    $scope.sortable_options = {
        handle: ".panel-heading",
        connectWith: 'panel',
        sortableClass: "sortable",
        forcePlaceholderSize: "> div",
        placeholder: '<div>&nbsp;</div>'
    };
    HomeService.getPanels().then(function(panels) {
        angular.forEach(panels, function(value, key) {
            if (key % 2 == 0) {
                $scope.panels_l.push(value);
            } else {
                $scope.panels_r.push(value);
            }
        });
    });
}]);