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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */

extensibleController('taskStoryCtrl', ['$scope', '$controller', 'TaskService', function($scope, $controller, TaskService) {
    // Functions
    $scope.resetTaskForm = function() {
        $scope.task = {};
        $scope.resetFormValidation($scope.formHolder.taskForm);
    };
    $scope.save = function(task, story) {
        task.parentStory = {id: story.id};
        TaskService.save(task, $scope.project.id).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.saved');
        });
    };
    $scope['delete'] = function(task) {
        TaskService.delete(task).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.authorizedTask = TaskService.authorizedTask;
    // Init
    $scope.project = $scope.getProjectFromState();
    $scope.formHolder = {};
    $scope.resetTaskForm();
}]);

extensibleController('taskSortableStoryCtrl', ['$scope', 'TaskService', 'Session', 'TaskStatesByName', function($scope, TaskService, Session, TaskStatesByName) {
    // Functions
    $scope.taskSortableOptions = {
        orderChanged: function(event) {
            var task = event.source.itemScope.modelValue;
            task.rank = event.dest.index + 1;
            TaskService.update(task).catch(function() {
                $scope.revertSortable(event);
            });
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId &&
                   sourceItemHandleScope.itemScope.sortableScope.taskState === destSortableScope.taskState;
        }
    };
    $scope.isTaskSortableByState = function(state) {
        return state == TaskStatesByName.TODO && Session.sm();
    };
    // Init
    $scope.$watch('selected.tasks', function(tasks) {
        $scope.tasksByState = _.mapValues(_.groupBy(tasks, 'state'), function(tasksOfState) {
            return _.sortBy(tasksOfState, 'rank');
        });
    }, true);
    $scope.sortableId = 'story-tasks';
}]);

extensibleController('taskCtrl', ['$scope', '$timeout', '$uibModal', '$filter', '$state', 'TaskService', 'TaskStatesByName', 'StoryStatesByName', 'postitSize', 'screenSize', function($scope, $timeout, $uibModal, $filter, $state, TaskService, TaskStatesByName, StoryStatesByName, postitSize, screenSize) {
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
    $scope.authorizedTask = TaskService.authorizedTask;
    $scope.menus = [
        {
            name: 'todo.is.ui.details',
            priority: function(task, defaultPriority, viewType) {
                return viewType === 'list' ? 100 : defaultPriority;
            },
            visible: function(task, viewType) { return viewType !== 'details'; },
            action: function(task) { $state.go('.task.details', {taskId: task.id}); }
        },
        {
            name: 'is.ui.sprintPlan.menu.task.take',
            visible: function(task) { return $scope.authorizedTask('take', task); },
            action: function(task) { $scope.take(task); }
        },
        {
            name: 'is.ui.task.state.done',
            visible: function(task) { return task.state == TaskStatesByName.IN_PROGRESS && $scope.authorizedTask('updateState', task); },
            action: function(task) { TaskService.updateState(task, TaskStatesByName.DONE); }
        },
        {
            name: 'is.ui.task.state.inProgress',
            visible: function(task) { return _.includes([TaskStatesByName.TODO, TaskStatesByName.DONE], task.state) && $scope.authorizedTask('updateState', task); },
            action: function(task) { TaskService.updateState(task, TaskStatesByName.IN_PROGRESS); }
        },
        {
            name: 'is.ui.task.state.todo',
            visible: function(task) { return task.state == TaskStatesByName.IN_PROGRESS && $scope.authorizedTask('updateState', task); },
            action: function(task) { TaskService.updateState(task, TaskStatesByName.TODO); }
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
            action: function(task) { $scope.confirmDelete({callback: $scope.delete, args: [task]}); }
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
    $scope.showEditEstimationModal = function(task, $event) {
        if (TaskService.authorizedTask('update', task)) {
            $uibModal.open({
                size: 'sm',
                templateUrl: 'task.estimation.html',
                controller: ['$scope', function($scope) {
                    $scope.editableTask = angular.copy(task);
                    $scope.initialValue = $scope.editableTask.value;
                    $scope.submit = function(task) {
                        TaskService.update(task).then(function(taskUpdated) {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.task.updated');
                        });
                    };
                }]
            });
            if ($event) {
                $event.stopPropagation();
            }
        }
    };
    var getPostitClass = function() {
        $scope.postitClass = postitSize.postitClass($scope.viewName, 'grid-group size-sm');
    };
    getPostitClass();
    screenSize.on('xs, sm', getPostitClass, $scope);
    $scope.$watch(function() { return postitSize.currentPostitSize($scope.viewName); }, getPostitClass);
    $scope.storyStatesByName = StoryStatesByName;
}]);

extensibleController('taskNewCtrl', ['$scope', '$state', '$stateParams', '$controller', 'i18nFilter', 'TaskService', 'TaskTypesByName', 'hotkeys', 'sprint', 'project', function($scope, $state, $stateParams, $controller, i18nFilter, TaskService, TaskTypesByName, hotkeys, sprint, project) {
    $controller('taskCtrl', {$scope: $scope});
    // Functions
    $scope.resetTaskForm = function() {
        $scope.task = {backlog: {id: sprint.id}};
        $scope.selectCategory();
        $scope.resetFormValidation($scope.formHolder.taskForm);
    };
    $scope.save = function(task, andContinue) {
        TaskService.save(task, project.id).then(function(task) {
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

extensibleController('taskDetailsCtrl', ['$scope', '$state', '$filter', '$controller', 'Session', 'TaskStatesByName', 'TaskConstants', 'TaskService', 'FormService', 'TagService', 'taskContext', 'detailsTask', 'project', function($scope, $state, $filter, $controller, Session, TaskStatesByName, TaskConstants, TaskService, FormService, TagService, taskContext, detailsTask, project) {
    $controller('taskCtrl', {$scope: $scope});
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsTask, clazz: 'task', project: project});
    // Functions
    $scope.update = function(task) {
        TaskService.update(task, true).then(function() {
            $scope.resetTaskForm();
            $scope.notifySuccess('todo.is.ui.task.updated');
        });
    };
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            TagService.getTags().then(function(tags) {
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
    $scope.refreshMostUsedColors = function() {
        TaskService.getMostUsedColors().then(function(colors) {
            $scope.mostUsedColors = colors;
        });
    };
    // Init
    $controller('updateFormController', {$scope: $scope, item: detailsTask, type: 'task'});
    $scope.tags = [];
    $scope.project = project;
    var sortedTasks = $filter('orderBy')(taskContext.tasks, TaskConstants.ORDER_BY);
    $scope.previousTask = FormService.previous(sortedTasks, $scope.task);
    $scope.nextTask = FormService.next(sortedTasks, $scope.task);
    $scope.taskStatesByName = TaskStatesByName;
    $scope.mostUsedColors = [];
}]);