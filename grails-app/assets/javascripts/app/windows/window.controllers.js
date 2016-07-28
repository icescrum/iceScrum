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

controllers.controller('featuresCtrl', ['$scope', '$state', '$controller', 'FeatureService', 'features', function($scope, $state, $controller, FeatureService, features) {
    // Functions
    $scope.isSelected = function(selectable) {
        if ($state.params.featureId) {
            return $state.params.featureId == selectable.id;
        } else if ($state.params.featureListId) {
            return _.includes($state.params.featureListId.split(','), selectable.id.toString());
        } else {
            return false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.featureId != undefined || $state.params.featureListId != undefined;
    };
    $scope.toggleSelectableMultiple = function() {
        $scope.app.selectableMultiple = !$scope.app.selectableMultiple;
        if ($state.params.featureListId != undefined) {
            $state.go($scope.viewName);
        }
    };
    $scope.authorizedFeature = FeatureService.authorizedFeature;
    $scope.orderByRank = function() {
        $scope.orderBy.reverse = false;
        $scope.orderBy.current = _.find($scope.orderBy.values, {id: 'rank'});
    };
    $scope.isSortableFeature = function() {
        return FeatureService.authorizedFeature('rank');
    };
    $scope.isSortingFeature = function() {
        return $scope.isSortableFeature() && $scope.orderBy.current.id == 'rank' && !$scope.orderBy.reverse && !$scope.hasContextOrSearch();
    };
    $scope.enableSortable = function() {
        $scope.clearContextAndSearch();
        $scope.orderByRank();
    };
    // Init
    $scope.viewName = 'feature';
    $scope.features = features;
    var fixFeatureRank = function(features) {
        _.each(features, function(feature, index) {
            feature.rank = index + 1;
        });
    };
    var updateRank = function(event) {
        fixFeatureRank(event.dest.sortableScope.modelValue);
        var feature = event.source.itemScope.modelValue;
        feature.rank = event.dest.index + 1;
        FeatureService.update(feature).catch(function() {
            $scope.revertSortable(event);
            fixFeatureRank(event.dest.sortableScope.modelValue);
            fixFeatureRank(event.source.itemScope.sortableScope);
        });
    };
    $scope.featureSortableOptions = {
        itemMoved: updateRank,
        orderChanged: updateRank,
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.sortableId = 'feature';
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        allowMultiple: true,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + '.details' + ($state.params.featureTabId ? '.tab' : ''), {featureId: selectedIds});
                    break;
                default:
                    $state.go($scope.viewName + '.multiple', {featureListId: selectedIds.join(",")});
                    break;
            }
        }
    };
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

controllers.controller('planningCtrl', ['$scope', '$state', 'ReleaseService', 'SprintService', 'ProjectService', 'SprintStatesByName', 'ReleaseStatesByName', 'project', 'releases', function($scope, $state, ReleaseService, SprintService, ProjectService, SprintStatesByName, ReleaseStatesByName, project, releases) {
    $scope.isSelected = function(selectable) {
        if ($state.params.storyId) {
            return $state.params.storyId == selectable.id;
        } else {
            return false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.storyId != undefined;
    };
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    $scope.hasPreviousVisibleSprints = function() {
        return $scope.visibleSprintOffset > 0;
    };
    $scope.hasNextVisibleSprints = function() {
        return $scope.visibleSprintMax + $scope.visibleSprintOffset + 1 <= $scope.sprints.length;
    };
    $scope.visibleSprintsPrevious = function() {
        $scope.visibleSprintOffset--;
        $scope.computeVisibleSprints();
    };
    $scope.visibleSprintsNext = function() {
        $scope.visibleSprintOffset++;
        $scope.computeVisibleSprints();
    };
    $scope.computeVisibleSprints = function() {
        $scope.visibleSprints = $scope.sprints.slice($scope.visibleSprintOffset, $scope.visibleSprintMax + $scope.visibleSprintOffset);
    };
    var getNewStoryState = function(storyId, currentStateName) {
        var newStateName;
        var newStateParams = {storyId: storyId};
        if (_.startsWith(currentStateName, 'planning.release.sprint.multiple')) {
            newStateName = 'planning.release.sprint.multiple.story.details';
        } else if (_.startsWith(currentStateName, 'planning.release.sprint.withId')) {
            newStateName = 'planning.release.sprint.withId.story.details';
        } else if (currentStateName === 'planning.release.sprint') {
            // Special case when there is no sprintId in the state params so we must retrieve it manually
            newStateName = 'planning.release.sprint.withId.story.details';
            newStateParams.sprintId = $scope.selectedItems[0].id;
        } else {
            newStateName = 'planning.release.story.details';
            if (currentStateName === 'planning' || currentStateName == 'planning.new') { // Special case when there is no releasedID in the state params so we must retrieve it manually
                newStateParams.releaseId = $scope.selectedItems[0].id;
            }
        }
        return {name: newStateName, params: newStateParams}
    };
    $scope.openStoryUrl = function(storyId) {
        var newStoryState = getNewStoryState(storyId, $state.current.name);
        return $state.href(newStoryState.name, newStoryState.params);
    };
    $scope.openSprintUrl = function(sprint) {
        var stateName = 'planning.release.sprint.withId';
        if ($state.current.name != 'planning.release.sprint.withId.details') {
            stateName += '.details';
        }
        return $state.href(stateName, {sprintId: sprint.id, releaseId: sprint.parentRelease.id});
    };
    $scope.openMultipleSprintDetailsUrl = function() {
        var stateName = 'planning.release.sprint.multiple';
        if ($state.current.name != 'planning.release.sprint.multiple.details') {
            stateName += '.details';
        }
        return $state.href(stateName);
    };
    $scope.isMultipleSprint = function() {
        return _.startsWith($state.current.name, 'planning.release.sprint.multiple');
    };
    // Init
    $scope.viewName = 'planning';
    $scope.visibleSprintMax = 3;
    $scope.visibleSprintOffset = 0;
    $scope.visibleSprints = [];
    $scope.project = project;
    $scope.releases = project.releases;
    $scope.sprints = [];
    $scope.timelineSelected = function(selectedItems) { // Timeline -> URL
        if (selectedItems.length == 0) {
            $state.go('planning');
        } else {
            var stateName, stateParams;
            if (selectedItems.length == 1 && selectedItems[0].class == 'Release') {
                stateName = 'planning.release';
                stateParams = {releaseId: selectedItems[0].id};
            } else if (selectedItems.length == 1 && selectedItems[0].class == 'Sprint') {
                var sprint = selectedItems[0];
                stateName = 'planning.release.sprint.withId';
                stateParams = {releaseId: sprint.parentRelease.id, sprintId: sprint.id};
            } else {
                stateName = 'planning.release.sprint.multiple';
                stateParams = {releaseId: selectedItems[0].parentRelease.id, sprintListId: _.map(selectedItems, 'id')};
            }
            var currentStateName = $state.current.name;
            var sameStateName = _.endsWith(currentStateName, '.details') && currentStateName == stateName + '.details' || currentStateName == stateName;
            var sameStateParams = $state.params.sprintId == stateParams.sprintId && $state.params.releaseId == stateParams.releaseId;
            var sameState = sameStateName && sameStateParams;
            if (_.endsWith(currentStateName, '.details') && !sameState || !_.endsWith(currentStateName, '.details') && sameState) {
                stateName += '.details';
            }
            $state.go(stateName, stateParams);
        }
    };
    $scope.$watchGroup([function() { return $state.$current.self.name; }, function() { return $state.params.releaseId; }, function() { return $state.params.sprintId; }, function() { return $state.params.sprintListId; }], function(newValues) {
        var stateName = newValues[0];
        var releaseId = newValues[1];
        var sprintId = newValues[2];
        var sprintListId = newValues[3];
        var release = _.find($scope.releases, {id: releaseId});
        $scope.visibleSprintOffset = 0;
        if (release && stateName.indexOf('.sprint') != -1 && stateName.indexOf('.new') == -1) {
            if (sprintId) {
                $scope.sprints = [_.find(release.sprints, {id: sprintId})];
            } else if (sprintListId) {
                var ids = _.map(sprintListId.split(','), function(id) {
                    return parseInt(id);
                });
                $scope.sprints = _.filter(release.sprints, function(sprint) {
                    return _.includes(ids, sprint.id);
                });
            } else {
                var sprint = _.find(release.sprints, function(sprint) {
                    return sprint.state == SprintStatesByName.TODO || sprint.state == SprintStatesByName.IN_PROGRESS;
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
                    return release.state == ReleaseStatesByName.TODO || release.state == ReleaseStatesByName.IN_PROGRESS;
                });
                if (!release) {
                    release = _.last($scope.releases);
                }
            }
            if (release) {
                if (release.sprints == null) {
                    release.sprints = [];
                }
                $scope.sprints = release.sprints;
                $scope.selectedItems = [release]; // URL -> Timeline
                var firstSprintToShowIndex = _.findIndex($scope.sprints, function(sprint) {
                    return sprint.state == SprintStatesByName.TODO || sprint.state == SprintStatesByName.IN_PROGRESS;
                });
                if (firstSprintToShowIndex == -1) {
                    firstSprintToShowIndex = $scope.sprints.length > $scope.visibleSprintMax ? $scope.sprints.length - $scope.visibleSprintMax - 1 : 0;
                }
                $scope.visibleSprintOffset = firstSprintToShowIndex;
            }
        }
        $scope.release = release;
        $scope.computeVisibleSprints();
    });
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        allowMultiple: false,
        selectionUpdated: function(selectedIds) {
            var currentStateName = $state.current.name;
            var storyIndexInStateName = currentStateName.indexOf('story');
            if (selectedIds.length == 0 && storyIndexInStateName != -1) {
                $state.go(currentStateName.slice(0, storyIndexInStateName - 1));
            } else {
                var newStoryState = getNewStoryState(selectedIds, currentStateName);
                $state.go(newStoryState.name, newStoryState.params);
            }
        }
    };
}]);

controllers.controller('taskBoardCtrl', ['$scope', '$state', '$filter', 'UserService', 'StoryService', 'TaskService', 'Session', 'SprintStatesByName', 'StoryStatesByName', 'TaskStatesByName', 'TaskTypesByName', 'sprint', 'releases', function($scope, $state, $filter, UserService, StoryService, TaskService, Session, SprintStatesByName, StoryStatesByName, TaskStatesByName, TaskTypesByName, sprint, releases) {
    $scope.viewName = 'taskBoard';
    // Functions
    $scope.isSelected = function(selectable) {
        return $state.params.taskId ? $state.params.taskId == selectable.id : false;
    };
    $scope.hasSelected = function() {
        return $state.params.taskId != undefined;
    };
    $scope.isSortableTaskBoard = function(sprint) {
        return Session.authenticated() && sprint.state < SprintStatesByName.DONE;
    };
    $scope.isSortingTaskBoard = function(sprint) {
        return $scope.isSortableTaskBoard(sprint) && $scope.currentSprintFilter.id == 'allTasks' && !$scope.hasContextOrSearch();
    };
    $scope.isSortingStory = function(story) {
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
        $state.go('taskBoard.task.new', {taskCategory: _.pick(story, ['id', 'name', 'class'])});
    };
    $scope.openNewTaskByType = function(type) {
        $state.go('taskBoard.task.new', {taskCategory: {id: type, name: $filter('i18n')(type, 'TaskTypes')}});
    };
    $scope.refreshTasks = function() {
        var tasks;
        tasks = $scope.sprint.tasks;
        $scope.taskCountByState = _.countBy(tasks, 'state');
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
        var sprintStoriesIds = _.map($scope.sprint.stories, 'id');
        var allStoriesIds = _.union(sprintStoriesIds, _.map(partitionedTasks[1], 'parentStory.id'));
        var ghostStoriesIds = _.difference(allStoriesIds, sprintStoriesIds);
        if (ghostStoriesIds) {
            StoryService.getMultiple(ghostStoriesIds).then(function(ghostStories) {
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
    };
    $scope.changeSprintFilter = function(sprintFilter) {
        $scope.currentSprintFilter = sprintFilter;
        $scope.refreshTasks();
        var editableUser = angular.copy(Session.user);
        editableUser.preferences.filterTask = sprintFilter.id;
        UserService.update(editableUser);
    };
    $scope.enableSortable = function() {
        $scope.clearContextAndSearch();
        $scope.changeSprintFilter(_.find($scope.sprintFilters, {id: 'allTasks'}));
    };
    $scope.storyFilter = function(story) {
        return $scope.currentSprintFilter.id == 'allTasks' || _.some($scope.tasksByStoryByState[story.id], function(tasks) {
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
    $scope.tasksShown = function(taskState, typeOrStory) {
        var taskLimit = 5;
        if (taskState == TaskStatesByName.DONE && $scope.sprint.state < SprintStatesByName.DONE) {
            if (_.isObject(typeOrStory)) {
                var story = typeOrStory;
                return $scope.tasksByStoryByState[story.id][taskState].length < taskLimit || $scope.tasksShownByTypeOrStory.stories[story.id];
            } else {
                var type = typeOrStory;
                return $scope.tasksByTypeByState[type][taskState].length < taskLimit || $scope.tasksShownByTypeOrStory[type];
            }
        } else {
            return true;
        }
    };
    $scope.tasksHidden = function(taskState, typeOrStory) {
        var taskLimit = 5;
        if (taskState == TaskStatesByName.DONE && $scope.sprint.state < SprintStatesByName.DONE) {
            if (_.isObject(typeOrStory)) {
                var story = typeOrStory;
                return $scope.tasksByStoryByState[story.id][taskState].length >= taskLimit && $scope.tasksShownByTypeOrStory.stories[story.id];
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
    $scope.sprintRemainingTime = function(sprint) {
        return _.sumBy(sprint.tasks, 'estimation');
    };
    // Init
    var fixTaskRank = function(tasks) {
        _.each(tasks, function(task, index) {
            task.rank = index + 1;
        });
    };
    $scope.taskSortableOptions = {
        itemMoved: function(event) {
            var destScope = event.dest.sortableScope;
            fixTaskRank(event.source.sortableScope.modelValue);
            fixTaskRank(destScope.modelValue);
            var task = event.source.itemScope.modelValue;
            task.rank = event.dest.index + 1;
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
                fixTaskRank(event.source.sortableScope.modelValue);
                fixTaskRank(destScope.modelValue);
            });
        },
        orderChanged: function(event) {
            fixTaskRank(event.dest.sortableScope.modelValue);
            var task = event.source.itemScope.modelValue;
            task.rank = event.dest.index + 1;
            TaskService.update(task).catch(function() {
                $scope.revertSortable(event);
                fixTaskRank(event.dest.sortableScope.modelValue);
            });
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            var isSortableDest = destSortableScope.story ? $scope.isSortingStory(destSortableScope.story) : true;
            return sameSortable && isSortableDest;
        }
    };
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a, .story-container',
        allowMultiple: false,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    $state.go($scope.viewName);
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
    var sprintFilter = Session.authenticated() ? Session.user.preferences.filterTask : 'allTasks';
    $scope.currentSprintFilter = _.find($scope.sprintFilters, {id: sprintFilter});
    $scope.sortableId = 'taskBoard';
    $scope.sprint = sprint;
    $scope.tasksByTypeByState = {};
    $scope.tasksByStoryByState = {};
    $scope.taskCountByState = {};
    $scope.taskStatesByName = TaskStatesByName;
    $scope.sprintStatesByName = SprintStatesByName;
    $scope.taskTypesByName = TaskTypesByName;
    $scope.ghostStories = [];
    $scope.$watch('sprint.tasks', function() {
        if ($scope.sprint) {
            $scope.refreshTasks();
        }
    }, true);  // Be careful of circular objects, it will blow up the stack when comparing equality by value
    $scope.$watch('sprint.state', function() { // To generate the proper $scope.sprintTaskStates when changing state
        if ($scope.sprint) {
            $scope.refreshTasks();
        }
    });
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
