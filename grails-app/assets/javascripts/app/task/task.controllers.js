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
    $scope.take = function(task) {
        TaskService.take(task);
    };
    $scope.release = function(task) {
        TaskService.release(task);
    };
    $scope.copy = function(task) {
        TaskService.copy(task);
    };
    $scope.block = function(task) {
        TaskService.block(task);
    };
    $scope.unBlock = function(task) {
        TaskService.unBlock(task);
    };
    // TODO cancellable delete
    $scope['delete'] = function(task, story) {
        TaskService.delete(task, story).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.authorizedTask = function(action, task) {
        return TaskService.authorizedTask(action, task);
    };
}]);

controllers.controller('taskStoryNewCtrl', ['$scope', '$state', '$controller', 'TaskService', 'hotkeys', function($scope, $state, $controller, TaskService, hotkeys) {
    $controller('taskCtrl', { $scope: $scope }); // inherit from taskCtrl
    // Functions
    $scope.resetTaskForm = function() {
        $scope.task = {};
        $scope.resetFormValidation($scope.formHolder.taskForm);
    };
    $scope.save = function(task, obj) {
        task.parentStory = {id: obj.id};
        TaskService.save(task, obj).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.saved');
        });
    };
    // Init
    $scope.formHolder = {};
    $scope.resetTaskForm();
}]);

controllers.controller('taskNewCtrl', ['$scope', '$state', '$stateParams', '$controller', 'TaskService', 'hotkeys', 'sprint', function($scope, $state, $stateParams, $controller, TaskService, hotkeys, sprint) {
    $controller('taskCtrl', { $scope: $scope }); // inherit from taskCtrl
    // Functions
    $scope.resetTaskForm = function() {
        $scope.task = {backlog: {id: sprint.id}};
        if ($stateParams.taskTemplate) {
            angular.extend($scope.task, $stateParams.taskTemplate);
        } else {
            $scope.task.type = 11;
        }
        $scope.resetFormValidation($scope.formHolder.taskForm);
    };
    $scope.save = function(task, andContinue) {
        TaskService.save(task, sprint).then(function(task) {
            if (andContinue) {
                $scope.resetTaskForm();
            } else {
                $scope.setInEditingMode(true);
                $state.go('^.details', { id: task.id });
            }
            $scope.notifySuccess('todo.is.ui.task.saved');
        });
    };
    // Init
    $scope.formHolder = {};
    $scope.resetTaskForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetTaskForm
    });
}]);

controllers.controller('userTaskCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
    $scope.tasksByProject = [];
    TaskService.listByUser().then(function(tasksByProject) {
        $scope.tasksByProject = tasksByProject;
    });
}]);
