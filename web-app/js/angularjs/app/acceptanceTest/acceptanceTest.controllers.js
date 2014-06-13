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
controllers.controller('acceptanceTestCtrl', ['$scope', 'AcceptanceTestService', 'hotkeys', function ($scope, AcceptanceTestService, hotkeys) {

    $scope.setShowForm = function(show) { $scope.editAcceptanceTest($scope.acceptanceTest ? $scope.acceptanceTest.id : -1, show) };
    $scope.getShowForm = function() { return ($scope.acceptanceTestEdit[$scope.acceptanceTest ? $scope.acceptanceTest.id : -1] == true) };

    $scope.acceptanceTest = angular.copy($scope.readOnlyAcceptanceTest);

    $scope.setShortCut = function() {
        var cancelKey = 'esc';
        hotkeys.del(cancelKey);
        hotkeys.add({
            combo: cancelKey,
            allowIn: ['INPUT', 'TEXTAREA'],
            callback: function(event, hotkey) {
                $scope.cancel();
            }
        });
    };

    $scope.toggleShowForm = function() {
        $scope.setShowForm(!$scope.getShowForm());
    };

    $scope.submitForm = function(type, acceptanceTest, story){
        if (type == 'save') {
            AcceptanceTestService.save(acceptanceTest, story);
            // TODO remove the existing data from the form after saving new story
        } else if (type == 'update') {
            AcceptanceTestService.update(acceptanceTest, story);
        }
        $scope.setShowForm(false);
    };

    $scope.switchState = function(acceptanceTest, story) {
        if (!$scope.stateReadOnly()) {
            // TODO use constants, not hardcoded values
            var newState = {
                1: 5,
                5: 10,
                10: 1
            };
            acceptanceTest.state = newState[acceptanceTest.state];
            AcceptanceTestService.update(acceptanceTest, story);
        }
    };

    $scope['delete'] = function(acceptanceTest, story){
        AcceptanceTestService.delete(acceptanceTest, story);
    };

    $scope.readOnly = function() {
        return this.selected.state == 7; // TODO use constants, not hardcoded values
    };

    $scope.stateReadOnly = function() {
        return $scope.readOnly() || (this.selected.state < 4); // TODO use constants, not hardcoded values
    };

    $scope.cancel = function() {
        $scope.setShowForm(false);
        if ($scope.readOnlyAcceptanceTest) {
            $scope.acceptanceTest = angular.copy($scope.readOnlyAcceptanceTest);
        }
        // TODO remove the existing data from the form after cancelling new story
    };
}]);