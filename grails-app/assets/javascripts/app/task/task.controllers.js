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
    // Functions
    $scope.save = function(task, obj) {
        TaskService.save(task, obj)
            .then(function() {
                $scope.resetTaskForm();
                $scope.notifySuccess('todo.is.ui.task.saved');
            });
    };
    // TODO cancellable delete
    $scope['delete'] = function(task, story) {
        TaskService.delete(task, story)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    $scope.authorizedTask = function(action, task) {
        return TaskService.authorizedTask(action, task);
    };
    $scope.resetTaskForm = function() {
        $scope.task = {};
        if ($scope.formHolder.taskForm) {
            $scope.formHolder.taskForm.$setPristine();
        }
    };
    $scope.disabledForm = function() {
        return $scope.formHolder.taskForm.$dirty && !$scope.formHolder.taskForm.$invalid;
    };
    // Init
    $scope.formHolder = {};
    if ($scope.task === undefined) {
        $scope.task = {};
    }
}]);


controllers.controller('usertaskCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
        $scope.task = [];
        TaskService.listByUser().then(function(task){
        $scope.task= task;

    });
}]);



