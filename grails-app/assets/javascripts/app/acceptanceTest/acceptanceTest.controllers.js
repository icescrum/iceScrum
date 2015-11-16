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
controllers.controller('acceptanceTestCtrl', ['$scope', 'AcceptanceTestService', 'AcceptanceTestStatesByName', 'hotkeys', function($scope, AcceptanceTestService, AcceptanceTestStatesByName, hotkeys) {
    // Functions
    $scope.resetAcceptanceTestForm = function() {
        $scope.editableAcceptanceTest = $scope.acceptanceTest ? $scope.acceptanceTest : {
            parentStory: $scope.story,
            state: AcceptanceTestStatesByName.TOCHECK
        };
        $scope.formHolder.editing = false;
        $scope.formHolder.editable = $scope.acceptanceTest ? $scope.authorizedAcceptanceTest('update', $scope.editableAcceptanceTest) : false;
        $scope.formHolder.deletable = $scope.acceptanceTest ? $scope.authorizedAcceptanceTest('delete', $scope.editableAcceptanceTest) : false;
        $scope.resetFormValidation($scope.formHolder.acceptanceTestForm);
    };
    $scope.save = function(acceptanceTest, story) {
        AcceptanceTestService.save(acceptanceTest, story)
            .then(function() {
                $scope.resetAcceptanceTestForm();
                $scope.notifySuccess('todo.is.ui.acceptanceTest.saved');
            });
    };
    // TODO cancellable delete
    $scope['delete'] = function(acceptanceTest, story) {
        AcceptanceTestService.delete(acceptanceTest, story)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    $scope.authorizedAcceptanceTest = function(action, acceptanceTest) {
        return AcceptanceTestService.authorizedAcceptanceTest(action, acceptanceTest);
    };
    $scope.editForm = function(value) {
        $scope.formHolder.editing = value;
        if (value) {
            $scope.editableAcceptanceTest = angular.copy($scope.editableAcceptanceTest);
            hotkeys.bindTo($scope).add({
                combo: 'esc',
                allowIn: ['INPUT', 'TEXTAREA', 'SELECT'],
                callback: $scope.resetAcceptanceTestForm
            });
        } else {
            hotkeys.del('esc');
        }
    };
    $scope.update = function(acceptanceTest, story) {
        if (!$scope.formHolder.acceptanceTestForm.$invalid) {
            $scope.editForm(false);
            if ($scope.formHolder.acceptanceTestForm.$dirty) {
                AcceptanceTestService.update(acceptanceTest, story)
                    .then(function() {
                        $scope.resetAcceptanceTestForm();
                        $scope.notifySuccess('todo.is.ui.acceptanceTest.updated');
                    });
            } else {
                $scope.resetAcceptanceTestForm();
            }
        }
    };
    // Settings
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
    // Init
    $scope.formHolder = {};
    $scope.resetAcceptanceTestForm();
}]);