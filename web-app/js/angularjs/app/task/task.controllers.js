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
controllers.controller('taskCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
    $scope.showTaskForm = false;
    $scope.setShowTaskForm = function(show) {
        $scope.showTaskForm = show;
    };
    $scope.save = function(task, obj) {
        TaskService.save(task, obj).then($scope.resetTaskForm);
    };
    $scope['delete'] = function(task, story) {
        TaskService.delete(task, story);
    };
    $scope.authorizedTask = function(action, task) {
        return TaskService.authorizedTask(action, task);
    };
    $scope.resetTaskForm = function() {
        $scope.setShowTaskForm(false);
        $scope.task = {};
        if ($scope.formHolder.taskForm) {
            $scope.formHolder.taskForm.$setPristine();
        }
    };
    $scope.disabledForm = function() {
        console.log($scope.formHolder.taskForm.$dirty && !$scope.formHolder.taskForm.$invalid);
        return $scope.formHolder.taskForm.$dirty && !$scope.formHolder.taskForm.$invalid;
    };
    // Init
    $scope.formHolder = {};
}]);