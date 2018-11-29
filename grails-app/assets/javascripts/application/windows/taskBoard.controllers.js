/*
 * Copyright (c) 2016 Kagilum SAS.
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

extensibleController('taskBoardCtrl', ['$scope', '$state', '$filter', 'UserService', 'StoryService', 'TaskService', 'SprintService', 'Session', 'SprintStatesByName', 'StoryStatesByName', 'TaskStatesByName', 'TaskTypesByName', 'project', 'sprint', 'releases', function($scope, $state, $filter, UserService, StoryService, TaskService, SprintService, Session, SprintStatesByName, StoryStatesByName, TaskStatesByName, TaskTypesByName, project, sprint, releases) {
    $scope.viewName = 'taskBoard';
    // Functions
    $scope.isSelected = function(selectable) {
        if (selectable.class == "Story") {
            return $state.params.storyId ? $state.params.storyId == selectable.id : false;
        } else {
            return $state.params.taskId ? $state.params.taskId == selectable.id : false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.taskId != undefined;
    };
    $scope.isSortableTaskBoard = function(sprint) {
        return Session.authenticated() && sprint.state < SprintStatesByName.DONE;
    };
    $scope.isSortableStory = function(story) {
        return story.state < StoryStatesByName.DONE;
    };
    $scope.openSprintUrl = function(sprint, keepDetails) {
        var stateName = 'taskBoard';
        if (keepDetails && $state.current.name == 'taskBoard.details' || !keepDetails && $state.current.name != 'taskBoard.details') {
            stateName += '.details';
        }
        return $state.href(stateName, {sprintId: sprint.id});
    };
    $scope.openNewTaskByStory = function(story) {
        $state.go('taskBoard.task.new', {taskCategory: _.pick(story, ['id', 'name', 'class', 'feature'])});
    };
    $scope.openNewTaskByType = function(type) {
        $state.go('taskBoard.task.new', {taskCategory: {id: type, name: $filter('i18n')(type, 'TaskTypes')}});
    };
    $scope.copyRecurrentTasks = function(sprint) {
        SprintService.copyRecurrentTasks(sprint, project);
    };
    $scope.applySearchFilterToTasksByTypeByState = function() {
        // Search filter must be applied to model because of https://github.com/a5hik/ng-sortable/issues/184
        $scope.tasksByTypeByStateAndSearchFiltered = _.mapValues($scope.tasksByTypeByState, function(tasksByState) {
            return _.mapValues(tasksByState, function(tasks) {
                return $filter('search')(tasks);
            })
        });
    };
    $scope.refreshTasks = function() {
        if (!$scope.sprint) {
            return;
        }
        var tasks;
        tasks = $scope.sprint.tasks;
        $scope.taskCountByState = _.countBy(tasks, 'state');
        $scope.taskCountByType = _.countBy(tasks, 'type');
        $scope.countByFilter();
        switch ($scope.sprint.state) {
            case SprintStatesByName.TODO:
                $scope.sprintTaskStates = [TaskStatesByName.TODO];
                break;
            case SprintStatesByName.IN_PROGRESS:
                $scope.sprintTaskStates = $scope.taskStates;
                break;
            case SprintStatesByName.DONE:
                $scope.sprintTaskStates = [TaskStatesByName.DONE];
                break;
        }
        var partitionedTasks = _.partition(tasks, function(task) {
            return task.parentStory == null;
        });
        var groupByStateAndSort = function(tasksDictionnary) {
            return _.mapValues(tasksDictionnary, function(tasks) {
                return _.mapValues(_.groupBy(tasks, 'state'), function(tasks) {
                    return _.sortBy(_.filter(tasks, $scope.currentSprintFilter.filter), 'rank');
                });
            });
        };
        $scope.tasksByTypeByState = groupByStateAndSort(_.groupBy(partitionedTasks[0], 'type'));
        $scope.tasksByStoryByState = groupByStateAndSort(_.groupBy(partitionedTasks[1], 'parentStory.id'));
        var sprintStoriesIds = _.map($scope.sprint.stories, 'id');
        var allStoriesIds = _.union(sprintStoriesIds, _.map(partitionedTasks[1], 'parentStory.id'));
        var ghostStoriesIds = _.difference(allStoriesIds, sprintStoriesIds);
        if (ghostStoriesIds) {
            StoryService.getMultiple(ghostStoriesIds, project.id).then(function(ghostStories) {
                $scope.ghostStories = ghostStories;
            });
        }
        var fillGapsInDictionnary = function(dictionnary, firstLevelKeys, secondLevelKeys) {
            _.each(firstLevelKeys, function(firstLevelKey) {
                if (!dictionnary[firstLevelKey]) {
                    dictionnary[firstLevelKey] = {};
                }
                _.each(secondLevelKeys, function(secondLevelKey) {
                    if (!dictionnary[firstLevelKey][secondLevelKey]) {
                        dictionnary[firstLevelKey][secondLevelKey] = [];
                    }
                });
            });
        };
        fillGapsInDictionnary($scope.tasksByTypeByState, $scope.taskTypes, $scope.sprintTaskStates);
        fillGapsInDictionnary($scope.tasksByStoryByState, allStoriesIds, $scope.sprintTaskStates);
        $scope.applySearchFilterToTasksByTypeByState();
    };
    $scope.changeSprintFilter = function(sprintFilter) {
        $scope.currentSprintFilter = sprintFilter;
        $scope.refreshTasks();
        var editableUser = angular.copy(Session.user);
        editableUser.preferences.filterTask = sprintFilter.id;
        UserService.update(editableUser).then(function() {
            Session.user.preferences.filterTask = sprintFilter.id;
        });
    };
    $scope.storyFilter = function(story) {
        return $scope.currentSprintFilter.id == 'allTasks' ||
               _.some($scope.tasksByStoryByState[story.id], function(tasks) {
                   return tasks.length > 0;
               });
    };
    $scope.openStoryUrl = function(storyId) {
        return '#/' + $scope.viewName + ($state.params.sprintId ? '/' + $state.params.sprintId : '') + '/story/' + storyId;
    };
    $scope.selectStory = function(event, storyId) {
        if (angular.element(event.target).closest('.action, button, a').length == 0) {
            $state.go('taskBoard.story.details' + ($state.params.storyTabId ? '.tab' : ''), {storyId: storyId});
        }
    };
    $scope.tasksShown = function(taskState, typeOrStory, fromStoryGhost) {
        var taskLimit = 5;
        if (taskState == TaskStatesByName.DONE && $scope.sprint.state < SprintStatesByName.DONE) {
            if (_.isObject(typeOrStory)) {
                var story = typeOrStory;
                if (story.state === StoryStatesByName.DONE || fromStoryGhost) {
                    return $scope.tasksShownByTypeOrStory.stories[story.id];
                } else {
                    return $scope.tasksByStoryByState[story.id][taskState].length < taskLimit || $scope.tasksShownByTypeOrStory.stories[story.id];
                }
            } else {
                var type = typeOrStory;
                return $scope.tasksByTypeByState[type][taskState].length < taskLimit || $scope.tasksShownByTypeOrStory[type];
            }
        } else {
            return true;
        }
    };
    $scope.tasksHidden = function(taskState, typeOrStory, fromStoryGhost) {
        var taskLimit = 5;
        if (taskState == TaskStatesByName.DONE && $scope.sprint.state < SprintStatesByName.DONE) {
            if (_.isObject(typeOrStory)) {
                var story = typeOrStory;
                if (story.state === StoryStatesByName.DONE || fromStoryGhost) {
                    return $scope.tasksShownByTypeOrStory.stories[story.id];
                } else {
                    return $scope.tasksByStoryByState[story.id][taskState].length >= taskLimit && $scope.tasksShownByTypeOrStory.stories[story.id];
                }
            } else {
                var type = typeOrStory;
                return $scope.tasksByTypeByState[type][taskState].length >= taskLimit && $scope.tasksShownByTypeOrStory[type];
            }
        } else {
            return false;
        }
    };
    $scope.showTasks = function(typeOrStory, show) {
        if (_.isObject(typeOrStory)) {
            $scope.tasksShownByTypeOrStory.stories[typeOrStory.id] = show;
        } else {
            $scope.tasksShownByTypeOrStory[typeOrStory] = show;
        }
    };
    $scope.totalRemainingTime = function(tasks) {
        return _.sum(_.filter(_.map(tasks, 'estimation'), _.isNumber));
    };
    $scope.scrollToActiveSprint = function(open) {
        if (open) {
            var dropdown = angular.element('.planning-dropdown');
            var ele = dropdown.find("li>a.active");
            var list = dropdown.find('.planning-menu');
            var posi = list.scrollTop() + ele.offset().top - ele.innerHeight();
            list.animate({
                scrollTop: posi - 60
            }, 200);
        }
    };
    $scope.initSprintFilter = function() {
        var sprintFilter = Session.authenticated() ? Session.user.preferences.filterTask : 'allTasks';
        var filter = _.find($scope.sprintFilters, {id: sprintFilter});
        $scope.currentSprintFilter = filter ? filter : $scope.getDefaultFilter();
    };
    $scope.getDefaultFilter = function() {
        return _.find($scope.sprintFilters, {id: 'allTasks'});
    };
    $scope.countByFilter = function() {
        _.each($scope.sprintFilters, function(sprintFilter) {
            sprintFilter.count = _.filter($scope.sprint.tasks, sprintFilter.filter).length;
        });
    };
    $scope.findPreviousOrNextStory = StoryService.findPreviousOrNextStory([
        function() {
            return $filter('orderBy')($filter('taskBoardSearch')($filter('filter')($scope.sprint.stories, $scope.storyFilter), $scope.tasksByStoryByState), 'rank'); // Needs to be in a function because it can change
        }
    ]);
    // Init
    $scope.project = project;
    $scope.taskSortableOptions = {
        itemMoved: function(event) {
            var destScope = event.dest.sortableScope;
            var task = event.source.itemScope.modelValue;
            if (event.dest.index == 0) {
                task.rank = 1;
            } else {
                var previousTask = destScope.modelValue[event.dest.index - 1];
                task.rank = previousTask.rank + 1;
            }
            task.state = destScope.taskState;
            if (destScope.story) {
                task.parentStory = {id: destScope.story.id};
                task.type = null;
            } else {
                task.type = destScope.taskType;
                task.parentStory = null;
            }
            TaskService.update(task).catch(function() {
                $scope.revertSortable(event);
            });
        },
        orderChanged: function(event) {
            var task = event.source.itemScope.modelValue;
            var destScope = event.dest.sortableScope;
            if (event.dest.index == 0) {
                task.rank = 1;
            } else {
                var previousTask = destScope.modelValue[event.dest.index - 1];
                if (event.dest.index > event.source.index) {
                    task.rank = previousTask.rank;
                } else {
                    task.rank = previousTask.rank + 1;
                }
            }
            TaskService.update(task).catch(function() {
                $scope.revertSortable(event);
            });
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            var isSortableDest = destSortableScope.story ? $scope.isSortableStory(destSortableScope.story) : true;
            return sameSortable && isSortableDest;
        }
    };
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a, .story-container',
        allowMultiple: false,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    if (!_.isUndefined($state.params.taskId)) {
                        $state.go($scope.viewName);
                    }
                    break;
                case 1:
                    $state.go($scope.viewName + '.task.details' + ($state.params.taskTabId ? '.tab' : ''), {taskId: selectedIds});
                    break;
            }
        }
    };
    $scope.sprintFilters = [
        {id: 'allTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.allTasks'), filter: {}},
        {id: 'myTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.myTasks'), filter: {responsible: {id: Session.user.id}}},
        {id: 'freeTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.freeTasks'), filter: {responsible: null}},
        {id: 'blockedTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.blockedTasks'), filter: {blocked: true}}
    ];
    $scope.initSprintFilter();
    $scope.sortableId = 'taskBoard';
    $scope.sprint = sprint;
    $scope.tasksByTypeByState = {};
    $scope.tasksByTypeByStateAndSearchFiltered = {};
    $scope.tasksByStoryByState = {};
    $scope.taskCountByState = {};
    $scope.taskStatesByName = TaskStatesByName;
    $scope.sprintStatesByName = SprintStatesByName;
    $scope.taskTypesByName = TaskTypesByName;
    $scope.ghostStories = [];
    var refreshIfNotEqual = function(oldValue, newValue) {
        if (!_.isEqual(oldValue, newValue)) {
            $scope.refreshTasks();
        }
    };
    $scope.$watch('sprint.tasks', refreshIfNotEqual, true);
    $scope.$watchCollection('sprint.stories', refreshIfNotEqual);
    $scope.$watch('sprint.state', refreshIfNotEqual); // To generate the proper $scope.sprintTaskStates when changing state
    $scope.refreshTasks();
    $scope.$watch('application.search', $scope.applySearchFilterToTasksByTypeByState);
    $scope.sprintEntries = [];
    _.each(_.sortBy(releases, 'orderNumber'), function(release) {
        if (release.sprints && release.sprints.length > 0) {
            if ($scope.sprintEntries.length > 0) {
                $scope.sprintEntries.push({type: 'divider'});
            }
            $scope.sprintEntries.push({type: 'release', item: release});
            _.each(_.sortBy(release.sprints, 'orderNumber'), function(sprint) {
                $scope.sprintEntries.push({type: 'sprint', item: sprint})
            });
        }
    });
    $scope.tasksShownByTypeOrStory = {'stories': {}};
}]);
