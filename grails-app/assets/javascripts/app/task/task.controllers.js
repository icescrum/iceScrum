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

controllers.controller('taskCtrl', ['$scope', '$timeout', '$uibModal', '$filter', '$state', 'TaskService', function($scope, $timeout, $uibModal, $filter, $state, TaskService) {
    // Functions
    $scope.take = function(task) {
        TaskService.take(task);
    };
    $scope.release = function(task) {
        TaskService.release(task);
    };
    $scope.makeStory = function(task) {
        TaskService.makeStory(task).then(function() {
            $scope.notifySuccess('todo.is.ui.task.makeStory.success');
        });
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
    $scope.menus = [
        {
            name: 'todo.is.ui.details',
            visible: function(task) { return $state.current.name.indexOf('task.details') == -1; },
            action: function(task) { $state.go('.task.details', {taskId: task.id}); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.take',
            visible: function(task) { return $scope.authorizedTask('take', task); },
            action: function(task) { $scope.take(task); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.unassign',
            visible: function(task) { return $scope.authorizedTask('release', task); },
            action: function(task) { $scope.release(task); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.copy',
            visible: function(task) { return $scope.authorizedTask('copy', task); },
            action: function(task) { $scope.copy(task); }
        },
        {
            name: 'todo.is.ui.task.makeStory',
            visible: function(task) { return $scope.authorizedTask('makeStory', task); },
            action: function(task) { return $scope.confirm({message: $scope.message('todo.is.ui.task.makeStory.confirm'), callback: $scope.makeStory, args: [task]}); }
        },
        {
            name: 'todo.is.ui.permalink.copy',
            visible: function(task) { return true; },
            action: function(task) { $scope.showCopyModal($scope.message('is.permalink'), $filter('permalink')(task.uid, 'task')); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.delete',
            visible: function(task) { return $scope.authorizedTask('delete', task); },
            action: function(task) { $scope.confirm({message: $scope.message('is.confirm.delete'), callback: $scope.delete, args: [task]}); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.block',
            visible: function(task) { return $scope.authorizedTask('block', task); },
            action: function(task) { $scope.block(task); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.unblock',
            visible: function(task) { return $scope.authorizedTask('unBlock', task); },
            action: function(task) { $scope.unBlock(task); }
        }
    ];
    $scope.showEditEstimationModal = function(task) {
        if (TaskService.authorizedTask('update', task)) {
            $uibModal.open({
                size: 'sm',
                templateUrl: 'task.estimation.html',
                controller: ["$scope", '$timeout', function($scope) {
                    $scope.editableTask = angular.copy(task);
                    $scope.initialValue = $scope.editableTask.value;
                    $scope.submit = function(task) {
                        TaskService.update(task).then(function() {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.task.remainingTime.updated');
                        });
                    };
                    $timeout(function() {
                        angular.element('.modal-dialog .modal-body input:visible:first[autofocus]').focus(); // Hack because UibModal loses focus
                    }, 500);
                }]
            });
        }
    };
}]);

controllers.controller('taskNewCtrl', ['$scope', '$state', '$stateParams', '$controller', 'i18nFilter', 'TaskService', 'TaskTypesByName', 'hotkeys', 'sprint', function($scope, $state, $stateParams, $controller, i18nFilter, TaskService, TaskTypesByName, hotkeys, sprint) {
    $controller('taskCtrl', {$scope: $scope});
    // Functions
    $scope.resetTaskForm = function() {
        $scope.task = {backlog: {id: sprint.id}};
        $scope.selectCategory();
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
    $scope.groupCategory = function(category) {
        return category.class == 'Story' ? $scope.message('is.story') : $scope.message('is.task.type');
    };
    $scope.selectCategory = function() {
        var category = $scope.formHolder.category;
        if (category) {
            var newType = null;
            var newParentStory = null;
            if (category.class == 'Story') {
                newParentStory = _.pick(category, 'id');
            } else {
                newType = category.id;
            }
            $scope.task.type = newType;
            $scope.task.parentStory = newParentStory;
        }
    };
    // Init
    $scope.formHolder = {};
    $scope.formHolder.category = $stateParams.taskCategory;
    $scope.resetTaskForm();
    var taskTypesCategories = _.map(_.filter($scope.taskTypes, function(taskType) {
        if (taskType == TaskTypesByName.URGENT) {
            return TaskService.authorizedTask('showUrgent');
        } else if (taskType == TaskTypesByName.RECURRENT) {
            return TaskService.authorizedTask('showRecurrent');
        }
    }), function(taskType) {
        return {id: taskType, name: i18nFilter(taskType, 'TaskTypes')};
    });
    $scope.categories = _.concat(_.reverse(taskTypesCategories), sprint.stories);
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetTaskForm
    });
}]);

registerAppController('taskDetailsCtrl', ['$scope', '$state', '$filter', '$controller', 'Session', 'TaskStatesByName', 'TaskConstants', 'TaskService', 'FormService', 'ProjectService', 'taskContext', 'detailsTask', function($scope, $state, $filter, $controller, Session, TaskStatesByName, TaskConstants, TaskService, FormService, ProjectService, taskContext, detailsTask) {
    $controller('taskCtrl', {$scope: $scope});
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsTask, clazz: 'task'});
    // Functions
    $scope.update = function(task) {
        $scope.formHolder.submitting = true;
        TaskService.update(task, true).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.updated');
        });
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
    $controller('updateFormController', {$scope: $scope, item: detailsTask, type: 'task'});
    $scope.tags = [];
    $scope.project = Session.getProject();
    var sortedTasks = $filter('orderBy')(taskContext.tasks, TaskConstants.ORDER_BY);
    $scope.previousTask = FormService.previous(sortedTasks, $scope.task);
    $scope.nextTask = FormService.next(sortedTasks, $scope.task);
    $scope.taskStatesByName = TaskStatesByName;

    $scope.mostUsedColors = [];
    TaskService.getMostUsedColors().then(function(colors) {
        $scope.mostUsedColors = colors;
    });
}]);

controllers.controller('userTaskCtrl', ['$scope', 'TaskService', function($scope, TaskService) {
    $scope.tasksByProject = [];
    TaskService.listByUser().then(function(tasksByProject) {
        $scope.tasksByProject = tasksByProject;
    });
}]);
