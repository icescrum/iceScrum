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
        $scope.showAcceptanceTestDescriptionTextarea = false;
        $scope.resetFormValidation($scope.formHolder.acceptanceTestForm);
    };
    $scope.formEditable = function() {
        return $scope.acceptanceTest ? $scope.authorizedAcceptanceTest('update', $scope.story) : false;
    };
    $scope.formDeletable = function() {
        return $scope.acceptanceTest ? $scope.authorizedAcceptanceTest('delete', $scope.story) : false;
    };
    $scope.save = function(acceptanceTest, story) {
        AcceptanceTestService.save(acceptanceTest, story)
            .then(function() {
                $scope.resetAcceptanceTestForm();
                $scope.notifySuccess('todo.is.ui.acceptanceTest.saved');
            });
    };
    $scope['delete'] = function(acceptanceTest, story) {
        AcceptanceTestService.delete(acceptanceTest, story)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    $scope.authorizedAcceptanceTest = AcceptanceTestService.authorizedAcceptanceTest;
    $scope.editForm = function(value) {
        $scope.formHolder.editing = $scope.formEditable() && value;
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
            }
        }
    };
    $scope.blurAcceptanceTestDescription = function() {
        $scope.showAcceptanceTestDescriptionTextarea = false;
        if ($scope.editableAcceptanceTest.description.trim() == $scope.acceptanceTestTemplate.trim()) {
            $scope.editableAcceptanceTest.description = '';
        }
    };
    $scope.focusAcceptanceTestDescription = function() {
        $scope.showAcceptanceTestDescriptionTextarea = true;
        if (!$scope.editableAcceptanceTest.description) {
            $scope.editableAcceptanceTest.description = $scope.acceptanceTestTemplate;
        }
    };
    $scope.selectAcceptanceTestState = function(editableAcceptanceTest, selected) {
        if (!$scope.formHolder.acceptanceTestForm.name.$dirty && !$scope.formHolder.acceptanceTestForm.description.$dirty) {
            $scope.update(editableAcceptanceTest, selected);
        }
    };
    // Init
    $scope.acceptanceTestTemplate = _.map(['given', 'when', 'then'], function(step) {
        return '_*' + $scope.message('is.acceptanceTest.template.' + step) + '*_ ';
    }).join('\n');
    $scope.formHolder = {};
    $scope.resetAcceptanceTestForm();
}]);
