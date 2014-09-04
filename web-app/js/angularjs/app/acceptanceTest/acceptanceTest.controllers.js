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
controllers.controller('acceptanceTestCtrl', ['$scope', 'AcceptanceTestService', 'AcceptanceTestStatesByName', function($scope, AcceptanceTestService, AcceptanceTestStatesByName) {

    $scope.resetAcceptanceTestForm = function() {
        $scope.editableAcceptanceTest = $scope.acceptanceTest ? angular.copy($scope.acceptanceTest) : {
            parentStory: $scope.story,
            state: AcceptanceTestStatesByName.TOCHECK
        };
        if ($scope.formHolder.acceptanceTestForm) {
            $scope.formHolder.acceptanceTestForm.$setPristine();
        }
    };
    $scope.save = function(acceptanceTest, story) {
        AcceptanceTestService.save(acceptanceTest, story).then($scope.resetAcceptanceTestForm);
    };
    $scope['delete'] = function(acceptanceTest, story) {
        AcceptanceTestService.delete(acceptanceTest, story);
    };
    $scope.authorizedAcceptanceTest = function(action, acceptanceTest) {
        return AcceptanceTestService.authorizedAcceptanceTest(action, acceptanceTest);
    };
    function formatAcceptanceTestStateOption(state) {
        var colorClass;
        switch (parseInt(state.id)) {
            case AcceptanceTestStatesByName.TOCHECK:
                colorClass = 'text-default';
                break;
            case AcceptanceTestStatesByName.FAILED:
                colorClass = 'text-danger';
                break;
            case AcceptanceTestStatesByName.SUCCESS:
                colorClass = 'text-success';
                break;
        }
        return "<div class='" + colorClass + "'><i class='fa fa-check'></i> " + state.text + "</div>";
    }
    $scope.selectAcceptanceTestStateOptions = {
        formatResult: formatAcceptanceTestStateOption,
        formatSelection: formatAcceptanceTestStateOption
    };
    $scope.showForm = function(value) {
        $scope.formHolder.showForm = value;
    };
    $scope.editForm = function(value) {
        $scope.formHolder.editing = value;
    };
    $scope.blurAcceptanceTest = function(acceptanceTest, story, $event) {
        if ($($event.target).hasClass('ng-valid')) {
            $scope.showForm(false);
            $scope.editForm(false);
            if ($($event.target).hasClass('ng-dirty')) {
                AcceptanceTestService.update(acceptanceTest, story);
            }
        }
    };
    // Init
    $scope.formHolder = {};
    $scope.resetAcceptanceTestForm();
}]);