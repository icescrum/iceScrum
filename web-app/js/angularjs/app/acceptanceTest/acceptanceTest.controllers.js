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
controllers.controller('acceptanceTestCtrl', ['$scope', 'AcceptanceTestService', function($scope, AcceptanceTestService) {

    $scope.setShowForm = function(show) {
        $scope.editAcceptanceTest($scope.acceptanceTest.id, show)
    };
    $scope.getShowForm = function() {
        return ($scope.acceptanceTestEdit[$scope.acceptanceTest.id] == true)
    };
    $scope.acceptanceTest = AcceptanceTestService.initAcceptanceTest($scope.readOnlyAcceptanceTest);
    $scope.submitForm = function(type, acceptanceTest, story) {
        var promise;
        if (type == 'save') {
            promise = AcceptanceTestService.save(acceptanceTest, story).then(function() {
                $scope.acceptanceTest = AcceptanceTestService.initAcceptanceTest($scope.readOnlyAcceptanceTest);
            });
        } else if (type == 'update') {
            promise = AcceptanceTestService.update(acceptanceTest, story);
        }
        promise.then(function() {
            $scope.setShowForm(false);
        });
    };
    $scope.cancel = function() {
        $scope.setShowForm(false);
        $scope.acceptanceTest = AcceptanceTestService.initAcceptanceTest($scope.readOnlyAcceptanceTest);
    };
    $scope.switchState = function(acceptanceTest, story) {
        AcceptanceTestService.update(acceptanceTest, story);
    };
    $scope['delete'] = function(acceptanceTest, story) {
        AcceptanceTestService.delete(acceptanceTest, story);
    };
    $scope.readOnly = function() {
        return AcceptanceTestService.readOnly(this.story);
    };
    $scope.stateReadOnly = function() {
        return AcceptanceTestService.stateReadOnly(this.story);
    };
    function formatAcceptanceTestStateOption(state) {
        var colorClass;
        // TODO use constants, not hardcoded values
        switch (state.id) {
            case "1":
                colorClass = 'text-default';
                break;
            case "5":
                colorClass = 'text-danger';
                break;
            case "10":
                colorClass = 'text-success';
                break;
        }
        return "<div class='" + colorClass + "'><i class='fa fa-check'></i>" + state.text + "</div>";
    }

    $scope.selectAcceptanceTestStateOptions = {
        formatResult: formatAcceptanceTestStateOption,
        formatSelection: formatAcceptanceTestStateOption
    };
}]);