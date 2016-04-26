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

controllers.controller('taskStoryCtrl', ['$scope', '$controller', 'TaskService', function($scope, $controller, TaskService) {
    // Functions
    $scope.resetTaskForm = function() {
        $scope.task = {};
        $scope.resetFormValidation($scope.formHolder.taskForm);
    };
    $scope.save = function(task, story) {
        task.parentStory = {id: story.id};
        TaskService.save(task).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.saved');
        });
    };
    $scope['delete'] = function(task) {
        TaskService.delete(task).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.authorizedTask = function(action, task) {
        return TaskService.authorizedTask(action, task);
    };
    // Init
    $scope.formHolder = {};
    $scope.resetTaskForm();
}]);

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
    $scope['delete'] = function(task) {
        TaskService.delete(task).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.authorizedTask = function(action, task) {
        return TaskService.authorizedTask(action, task);
    };
}]);

controllers.controller('taskNewCtrl', ['$scope', '$state', '$stateParams', '$controller', 'TaskService', 'hotkeys', 'sprint', function($scope, $state, $stateParams, $controller, TaskService, hotkeys, sprint) {
    $controller('taskCtrl', {$scope: $scope});
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
        TaskService.save(task).then(function(task) {
            if (andContinue) {
                $scope.resetTaskForm();
            } else {
                $scope.setInEditingMode(true);
                $state.go('^.details', {taskId: task.id});
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

controllers.controller('taskDetailsCtrl', ['$scope', '$state', '$filter', '$controller', 'TaskStatesByName', 'TaskConstants', 'TaskService', 'FormService', 'ProjectService', 'taskContext', 'detailsTask', function($scope, $state, $filter, $controller, TaskStatesByName, TaskConstants, TaskService, FormService, ProjectService, taskContext, detailsTask) {
    $controller('taskCtrl', {$scope: $scope});
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsTask, clazz: 'task'});
    // Functions
    $scope.isDirty = function() {
        return !_.isEqual($scope.editableTask, $scope.editableTaskReference);
    };
    $scope.update = function(task) {
        TaskService.update(task, true).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.updated');
        });
    };
    $scope.editForm = function(value) {
        if (value != $scope.formHolder.editing) {
            $scope.setInEditingMode(value); // global
            $scope.resetTaskForm();
        }
    };
    $scope.resetTaskForm = function() {
        $scope.formHolder.editing = $scope.isInEditingMode();
        $scope.formHolder.editable = $scope.authorizedTask('update', $scope.task);
        if ($scope.formHolder.editable) {
            $scope.editableTask = angular.copy($scope.task);
            $scope.editableTaskReference = angular.copy($scope.task);
        } else {
            $scope.editableTask = $scope.task;
            $scope.editableTaskReference = $scope.task;
        }
        $scope.resetFormValidation($scope.formHolder.taskForm);
    };
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.tabUrl = function(taskTabId) {
        var stateName = $state.params.taskTabId ? (taskTabId ? '.' : '^') : (taskTabId ? '.tab' : '.');
        return $state.href(stateName, {taskTabId: taskTabId});
    };
    $scope.currentStateUrl = function(id) {
        return $state.href($state.current.name, {taskId: id});
    };
    // Init
    $scope.task = detailsTask;
    $scope.editableTask = {};
    $scope.editableTaskReference = {};
    $scope.formHolder = {};
    FormService.addStateChangeDirtyFormListener($scope, 'task', true);
    $scope.tags = [];
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.resetTaskForm();
    var sortedTasks = $filter('orderBy')(taskContext.tasks, TaskConstants.ORDER_BY);
    $scope.previousTask = FormService.previous(sortedTasks, $scope.task);
    $scope.nextTask = FormService.next(sortedTasks, $scope.task);
    $scope.taskStatesByName = TaskStatesByName;
}]);

controllers.controller('userTaskCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
    $scope.tasksByProject = [];
    TaskService.listByUser().then(function(tasksByProject) {
        $scope.tasksByProject = tasksByProject;
    });
}]);
