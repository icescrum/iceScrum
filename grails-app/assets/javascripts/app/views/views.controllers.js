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
 *
 */

// Abstract Ctrl for view with selectable items
controllers.controller('selectableCtrl', ['$scope', '$state', function($scope, $state) {
    // Functions
    $scope.isSelected = function(selectable) {
        if ($state.params.id) {
            return $state.params.id == selectable.id;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), selectable.id.toString());
        } else {
            return false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.id != undefined || $state.params.listId != undefined;
    };
    $scope.toggleSelectableMultiple = function() {
        $scope.app.selectableMultiple = !$scope.app.selectableMultiple;
        if ($state.params.listId != undefined) {
            $state.go($scope.viewName);
        }
    };
    // Init
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        multiple: true,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + '.details' + ($state.params.tabId ? '.tab' : ''), {id: selectedIds});
                    break;
                default:
                    $state.go($scope.viewName + '.multiple', {listId: selectedIds.join(",")});
                    break;
            }
        }
    };
}]);

controllers.controller('featuresCtrl', ['$scope', '$controller', 'FeatureService', 'features', function($scope, $controller, FeatureService, features) {
    $controller('selectableCtrl', {$scope: $scope});
    // Functions
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };
    $scope.orderByRank = function() {
        $scope.orderBy.reverse = false;
        $scope.orderBy.current = _.find($scope.orderBy.values, {id: 'rank'});
    };
    $scope.isSortableFeature = function() {
        return FeatureService.authorizedFeature('rank');
    };
    $scope.isSortingFeature = function() {
        return $scope.isSortableFeature() && $scope.orderBy.current.id == 'rank' && !$scope.orderBy.reverse;
    };
    // Init
    $scope.viewName = 'feature';
    $scope.features = features;
    var updateRank = function(event) {
        _.each(event.dest.sortableScope.modelValue, function(feature, index) {
            feature.rank = index + 1;
        });
        var feature = event.source.itemScope.modelValue;
        feature.rank = event.dest.index + 1;
        FeatureService.update(feature);
    };
    $scope.featureSortableOptions = {
        itemMoved: updateRank,
        orderChanged: updateRank,
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.sortableId = 'feature';
    $scope.orderBy = {
        current: {id: 'dateCreated', name: $scope.message('todo.is.ui.sort.date')},
        values: _.sortBy([
            {id: 'rank', name: $scope.message('todo.is.ui.sort.rank')},
            {id: 'dateCreated', name: $scope.message('todo.is.ui.sort.date')},
            {id: 'name', name: $scope.message('todo.is.ui.sort.name')},
            {id: 'stories_ids.length', name: $scope.message('todo.is.ui.sort.stories')},
            {id: 'value', name: $scope.message('todo.is.ui.sort.value')},
            {id: 'state', name: $scope.message('todo.is.ui.sort.state')}
        ], 'name')
    };
    $scope.orderByRank();
}]);

controllers.controller('releasePlanCtrl', ['$scope', '$state', 'ReleaseService', 'SprintService', 'ProjectService', 'SprintStatesByName', 'ReleaseStatesByName', 'project', 'releases', function($scope, $state, ReleaseService, SprintService, ProjectService, SprintStatesByName, ReleaseStatesByName, project, releases) {
    // Functions
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    // Init
    $scope.viewName = 'releasePlan';
    $scope.project = project;

    // TODO bug fix: project.releases MAY BE empty on refresh that's why we assign it manually
    project.releases = releases;

    $scope.releases = project.releases;
    $scope.sprints = [];

    $scope.timelineSelected = function(selectedItems) { // Timeline -> URL
        if (selectedItems.length == 0) {
            $state.go('releasePlan');
        } else if (selectedItems.length == 1 && selectedItems[0].class == 'Release') {
            var release = selectedItems[0];
            $state.go('releasePlan.release.details', {id: release.id});
        } else if (selectedItems.length == 1 && selectedItems[0].class == 'Sprint') {
            var sprint = selectedItems[0];
            var releaseId = sprint.parentRelease.id;
            $state.go('releasePlan.release.sprint.withId.details', {id: releaseId, sprintId: sprint.id});
        } else {
            var releaseId = selectedItems[0].parentRelease.id;
            $state.go('releasePlan.release.sprint.multiple.details', {id: releaseId, listId: _.map(selectedItems, 'id')});
        }
    };
    $scope.$watchGroup([function() { return $state.$current.self.name; }, function() { return $state.params.id; }, function() { return $state.params.sprintId; }, function() { return $state.params.listId; }], function(newValues) {
        var stateName = newValues[0];
        var releaseId = newValues[1];
        var sprintId = newValues[2];
        var sprintListId = newValues[3];
        var release = _.find($scope.releases, {id: releaseId});
        if (release && stateName.indexOf('.sprint') != -1 && stateName.indexOf('.new') == -1) {
            if (sprintId) {
                $scope.sprints = [_.find(release.sprints, {id: sprintId})];
            } else if (sprintListId) {
                var ids = _.map(sprintListId.split(','), function(id) {
                    return parseInt(id);
                });
                $scope.sprints = _.filter(release.sprints, function(sprint) {
                    return _.contains(ids, sprint.id);
                });
            } else {
                var sprint = _.find(release.sprints, function(sprint) {
                    return sprint.state == SprintStatesByName.WAIT || sprint.state == SprintStatesByName.IN_PROGRESS;
                });
                if (!sprint) {
                    sprint = _.last(release.sprints);
                }
                $scope.sprints = [sprint];
            }
            $scope.selectedItems = $scope.sprints; // URL -> Timeline
        } else {
            if (!release) {
                release = _.find($scope.releases, function(release) {
                    return release.state == ReleaseStatesByName.WAIT || release.state == ReleaseStatesByName.IN_PROGRESS;
                });
                if (!release) {
                    release = _.last($scope.releases);
                }
            }
            if (release) {
                $scope.sprints = release.sprints;
                $scope.selectedItems = [release]; // URL -> Timeline
            }
        }
        $scope.release = release;
    });
}]);

controllers.controller('sprintPlanCtrl', ['$scope', '$state', '$filter', 'UserService', 'StoryService', 'TaskService', 'Session', 'SprintStatesByName', 'StoryStatesByName', 'TaskStatesByName', 'sprint', function($scope, $state, $filter, UserService, StoryService, TaskService, Session, SprintStatesByName, StoryStatesByName, TaskStatesByName, sprint) {
    $scope.viewName = 'sprintPlan';
    // Functions
    $scope.isSelected = function(selectable) {
        return $state.params.taskId ? $state.params.taskId == selectable.id : false;
    };
    $scope.hasSelected = function() {
        return $state.params.taskId != undefined;
    };
    $scope.isSortableSprintPlan = function(sprint) {
        return Session.authenticated() && sprint.state < SprintStatesByName.DONE;
    };
    $scope.isSortingSprintPlan = function(sprint) {
        return $scope.isSortableSprintPlan(sprint) && $scope.currentSprintFilter.id == 'allTasks';
    };
    $scope.isSortingStory = function(story) {
        return story.state < StoryStatesByName.DONE;
    };
    $scope.openSprint = function(sprint) {
        $state.go('sprintPlan.details', {id: sprint.id});
    };
    $scope.openNewTaskByStory = function(story) {
        $state.go('sprintPlan.task.new', {taskTemplate: {parentStory: _.pick(story, ['id', 'name'])}});
    };
    $scope.openNewTaskByType = function(type) {
        $state.go('sprintPlan.task.new', {taskTemplate: {type: type}});
    };
    $scope.refreshTasks = function() {
        $scope.sprintTaskStates = $scope.sprint.state < SprintStatesByName.DONE ? $scope.taskStates : [TaskStatesByName.DONE];
        var partitionedTasks = _.partition($scope.sprint.tasks, function(task) {
            return _.isNull(task.parentStory);
        });
        var groupByStateAndSort = function(tasksDictionnary) {
            return _.mapValues(tasksDictionnary, function(tasks) {
                return _.mapValues(_.groupBy(tasks, 'state'), function(tasks) {
                    return _.sortBy($filter('filter')(tasks, $scope.currentSprintFilter.filter), 'rank');
                });
            });
        };
        $scope.tasksByTypeByState = groupByStateAndSort(_.groupBy(partitionedTasks[0], 'type'));
        $scope.tasksByStoryByState = groupByStateAndSort(_.groupBy(partitionedTasks[1], 'parentStory.id'));
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
        fillGapsInDictionnary($scope.tasksByStoryByState, _.map($scope.backlog.stories, 'id'), $scope.sprintTaskStates);
    };
    $scope.changeSprintFilter = function(sprintFilter) {
        $scope.currentSprintFilter = sprintFilter;
        $scope.refreshTasks();
        var editableUser = angular.copy(Session.user);
        editableUser.preferences.filterTask = sprintFilter.id;
        UserService.update(editableUser);
    };
    $scope.setAllSprintFilter = function() {
        $scope.changeSprintFilter(_.find($scope.sprintFilters, {id: 'allTasks'}));
    };
    $scope.storyFilter = function(story) {
        return $scope.currentSprintFilter.id == 'allTasks' || _.any($scope.tasksByStoryByState[story.id], function(tasks) {
                return tasks.length > 0;
            });
    };
    // Init
    var fixTaskRank = function(tasks) {
        _.each(tasks, function(task, index) {
            task.rank = index + 1;
        });
    };
    $scope.taskSortableOptions = {
        itemMoved: function(event) {
            fixTaskRank(event.source.sortableScope.modelValue);
            fixTaskRank(event.dest.sortableScope.modelValue);
            var task = event.source.itemScope.modelValue;
            var newRank = event.dest.index + 1;
            var destScope = event.dest.sortableScope;
            var newState = destScope.taskState;
            var newType = destScope.taskType;
            var newStory = destScope.story;
            task.rank = newRank;
            task.type = newType;
            task.state = newState;
            task.parentStory = newStory ? {id: newStory.id} : null;
            TaskService.update(task, sprint);
        },
        orderChanged: function(event) {
            fixTaskRank(event.dest.sortableScope.modelValue);
            var task = event.source.itemScope.modelValue;
            task.rank = event.dest.index + 1;
            TaskService.update(task, sprint);
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            var isSortableDest = destSortableScope.story ? $scope.isSortingStory(destSortableScope.story) : true;
            return sameSortable && isSortableDest;
        }
    };
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        multiple: false,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + '.task.details' + ($state.params.tabId ? '.tab' : ''), {taskId: selectedIds});
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
    var sprintFilter = Session.authenticated() ? Session.user.preferences.filterTask : 'allTasks';
    $scope.currentSprintFilter = _.find($scope.sprintFilters, {id: sprintFilter});
    $scope.sortableId = 'sprintPlan';
    $scope.sprint = sprint;
    $scope.backlog = sprint;
    $scope.tasksByTypeByState = {};
    $scope.tasksByStoryByState = {};
    $scope.allStories = StoryService.list;
    $scope.$watch('sprint.tasks', function(newValue, oldValue) {
        if (oldValue !== newValue) { // Prevent trigger watch on watch creation
            $scope.refreshTasks();
        }
    }, true);
    $scope.$watch('allStories', function(newValue, oldValue) {
        if (oldValue !== newValue) { // Prevent trigger watch on watch creation
            StoryService.listByType(sprint).then(function() {
                TaskService.list(sprint); // Reload tasks and cascade to sprint.tasks watch that will take care of refreshing
            });
        }
    }, true);
    $scope.refreshTasks(); // Init
}]);