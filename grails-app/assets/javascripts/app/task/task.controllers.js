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
        TaskService.save(task, story).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.saved');
        });
    };
    $scope['delete'] = function(task, story) {
        TaskService.delete(task, story).then(function() {
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

controllers.controller('taskSprintCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
    // Functions
    $scope.take = function(task) {
        TaskService.take(task, $scope.sprint);
    };
    $scope.release = function(task) {
        TaskService.release(task, $scope.sprint);
    };
    $scope.copy = function(task) {
        TaskService.copy(task, $scope.sprint);
    };
    $scope.block = function(task) {
        TaskService.block(task, $scope.sprint);
    };
    $scope.unBlock = function(task) {
        TaskService.unBlock(task, $scope.sprint);
    };
    $scope['delete'] = function(task) {
        TaskService.delete(task, $scope.sprint).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.authorizedTask = function(action, task) {
        return TaskService.authorizedTask(action, task);
    };
}]);

controllers.controller('taskNewCtrl', ['$scope', '$state', '$stateParams', '$controller', 'TaskService', 'hotkeys', 'sprint', function($scope, $state, $stateParams, $controller, TaskService, hotkeys, sprint) {
    $controller('taskSprintCtrl', {$scope: $scope});
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

controllers.controller('taskDetailsCtrl', ['$scope', '$state', '$filter', '$controller', 'TaskService', 'FormService', 'ProjectService', 'sprint', 'detailsTask', function($scope, $state, $filter, $controller, TaskService, FormService, ProjectService, sprint, detailsTask) {
    $controller('taskSprintCtrl', {$scope: $scope});
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsTask, clazz: 'task'});
    // Functions
    $scope.isDirty = function() {
        return !_.isEqual($scope.editableTask, $scope.editableTaskReference);
    };
    $scope.update = function(task) {
        TaskService.update(task, sprint).then(function() {
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
    // Init
    $scope.task = detailsTask;
    $scope.editableTask = {};
    $scope.editableTaskReference = {};
    $scope.formHolder = {};
    $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $stage.go
    $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
        if ($scope.mustConfirmStateChange && fromParams.id != toParams.id) {
            event.preventDefault(); // cancel the state change
            $scope.mustConfirmStateChange = false;
            $scope.confirm({
                message: $scope.message('todo.is.ui.dirty.confirm'),
                condition: $scope.isDirty() || ($scope.flow != undefined && $scope.flow.isUploading()),
                callback: function() {
                    if ($scope.flow != undefined && $scope.flow.isUploading()) {
                        $scope.flow.cancel();
                    }
                    $state.go(toState, toParams)
                },
                closeCallback: function() {
                    $scope.mustConfirmStateChange = true;
                }
            });
        }
    });
    $scope.tags = [];
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.resetTaskForm();
    var sortedTasks = $filter('orderBy')(sprint.tasks, [function(task) { return - task.type }, 'parentStory.rank', 'state', 'rank']);
    $scope.previousTask = FormService.previous(sortedTasks, $scope.task);
    $scope.nextTask = FormService.next(sortedTasks, $scope.task);
}]);

controllers.controller('userTaskCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
    $scope.tasksByProject = [];
    TaskService.listByUser().then(function(tasksByProject) {
        $scope.tasksByProject = tasksByProject;
    });
}]);
