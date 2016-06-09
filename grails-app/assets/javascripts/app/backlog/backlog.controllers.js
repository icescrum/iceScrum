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
registerAppController('backlogCtrl', ['$scope', '$filter', '$timeout', '$state', 'Session', 'StoryService', 'BacklogService', 'BacklogCodes', 'StoryStatesByName', 'backlogs', function($scope, $filter, $timeout, $state, Session, StoryService, BacklogService, BacklogCodes, StoryStatesByName, backlogs) {
    // Functions
    $scope.authorizedStory = StoryService.authorizedStory;
    $scope.isSelected = function(selectable) {
        if ($state.params.storyId) {
            return $state.params.storyId == selectable.id;
        } else if ($state.params.storyListId) {
            return _.includes($state.params.storyListId.split(','), selectable.id.toString());
        } else {
            return false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.storyId != undefined || $state.params.storyListId != undefined;
    };
    $scope.toggleSelectableMultiple = function() {
        $scope.app.selectableMultiple = !$scope.app.selectableMultiple;
        if ($state.params.storyListId != undefined) {
            var currentStateName = $state.current.name;
            var storyIndexInStateName = currentStateName.indexOf('story');
            $state.go(currentStateName.slice(0, storyIndexInStateName - 1));
        }
    };
    $scope.refreshSingleBacklog = function(backlogContainer) {
        var backlog = backlogContainer.backlog;
        var filteredStories = BacklogService.filterStories(backlog, Session.getProject().stories);
        var sortOrder = [backlogContainer.orderBy.current.value, 'id']; // Order by id is crucial to ensure stable order regardless of storyService.list order which itself depends on navigation order
        if (BacklogService.isAll(backlog) && backlogContainer.orderBy.current.id == 'rank') { // Hack to ensure that rank sort in "All" backlog is consistent with individual backlog ranking
            var sortByStateGroupingByBacklogState = function(story) {
                var orderCriteria = story.state == StoryStatesByName.ESTIMATED ? StoryStatesByName.ACCEPTED : story.state; // Ignore the differences betweed accepted and estimated
                return -orderCriteria; // "minus" the state to make done stories more prioritary
            };
            sortOrder.unshift(sortByStateGroupingByBacklogState);
        }
        backlog.stories = $filter('orderBy')(filteredStories, sortOrder, backlogContainer.orderBy.reverse);
        if (backlog.stories && backlog.stories.length > 0) {
            backlogContainer.storiesLoaded = true; // To render stories already there in the client
        }
        backlogContainer.sortable = StoryService.authorizedStory('rank') && (BacklogService.isBacklog(backlog) || BacklogService.isSandbox(backlog));
        backlogContainer.sorting = backlogContainer.sortable && backlogContainer.orderBy.current.id == 'rank' && !backlogContainer.orderBy.reverse && !$scope.hasContextOrSearch();
        $timeout(function() { // Timeout to wait for story rendering
            $scope.$emit('selectable-refresh');
        }, 0);
    };
    var getValueEffortRateForSorting = function(story) {
        var rate = -3; // Rate = -3 when no effort (null) & no value (0)
        if (story.value == 0) {
            if (story.effort != null) {
                rate = -story.effort / 10000; // Rate spans from 0 to -1 (unless effort is > 1000, very unlikely), higher effort => lower rate
            }
        } else {
            if (story.effort == null) {
                rate = -1 / story.value - 1; // Rate spans from -2 to -1, higher value => higher rate
            } else {
                rate = story.value / story.effort; // Rate spans from 0 to Infinity, higher value compared to effort => higher rate
            }
        }
        return rate;
    };
    $scope.orderBacklogByRank = function(backlogContainer) {
        backlogContainer.orderBy.reverse = false;
        $scope.changeBacklogOrder(backlogContainer, _.find(backlogContainer.orderBy.values, {id: 'rank'}));
    };
    $scope.changeBacklogOrder = function(backlogContainer, order) {
        backlogContainer.orderBy.current = order;
        $scope.refreshSingleBacklog(backlogContainer);
    };
    $scope.reverseBacklogOrder = function(backlogContainer) {
        backlogContainer.orderBy.reverse = !backlogContainer.orderBy.reverse;
        $scope.refreshSingleBacklog(backlogContainer);
    };
    $scope.enableSortable = function(backlogContainer) {
        $scope.clearContextAndSearch();
        $scope.orderBacklogByRank(backlogContainer)
    };
    $scope.openStoryUrl = function(storyId) {
        return '#/' + $scope.viewName + '/' + $state.params.backlogCode + '/story/' + storyId;
    };
    $scope.toggleBacklogUrl = function(backlog) {
        if ($scope.isShown(backlog)) {
            if ($scope.backlogContainers.length > 1) {
                return $scope.closeBacklogUrl(backlog);
            } else {
                return $state.href('.');
            }
        } else {
            var stateName = _.startsWith($state.current.name, 'backlog.backlog') || _.startsWith($state.current.name, 'backlog.multiple') ? '.' : 'backlog.backlog';
            return $state.href(stateName, {backlogCode: backlog.code});
        }
    };
    $scope.togglePinBacklogUrl = function(backlog) {
        var stateName;
        var stateParams;
        if ($scope.isPinned(backlog)) {
            stateName = 'backlog.backlog';
            stateParams = {backlogCode: backlog.code};
        } else {
            stateName = 'backlog.multiple';
            stateParams = {pinnedBacklogCode: backlog.code};
            stateParams.backlogCode = $state.params.pinnedBacklogCode ? $state.params.pinnedBacklogCode : ($state.params.backlogCode != backlog.code ? $state.params.backlogCode : null);
        }
        return $state.href(stateName, stateParams);
    };
    $scope.closeBacklogUrl = function(backlog) {
        var stateParams;
        if (backlog.code == $state.params.pinnedBacklogCode) {
            stateParams = {pinnedBacklogCode: $state.params.backlogCode, backlogCode: null};
        } else {
            stateParams = {backlogCode: null};
        }
        return $state.href('.', stateParams);
    };
    $scope.isShown = function(backlog) {
        return _.includes([$state.params.pinnedBacklogCode, $state.params.backlogCode], backlog.code);
    };
    $scope.isPinned = function(backlog) {
        return $state.params.pinnedBacklogCode == backlog.code;
    };
    $scope.getBacklogContainer = function(backlogCode) {
        return _.find($scope.backlogContainers, function(backlogContainer) {
            return backlogContainer.backlog.code == backlogCode;
        });
    };
    $scope.showBacklog = function(backlogCode) {
        var backlogContainer = $scope.getBacklogContainer(backlogCode);
        if (!backlogContainer) {
            backlogContainer = {
                backlog: _.find($scope.availableBacklogs, {code: backlogCode}),
                storiesLoaded: false,
                orderBy: {
                    values: _.sortBy([
                        {id: 'effort', value: 'effort', name: $scope.message('todo.is.ui.sort.effort')},
                        {id: 'rank', value: 'rank', name: $scope.message('todo.is.ui.sort.rank')},
                        {id: 'name', value: 'name', name: $scope.message('todo.is.ui.sort.name')},
                        {id: 'tasks_count', value: 'tasks_count', name: $scope.message('todo.is.ui.sort.tasks')},
                        {id: 'suggestedDate', value: 'suggestedDate', name: $scope.message('todo.is.ui.sort.date')},
                        {id: 'feature.id', value: 'feature.id', name: $scope.message('todo.is.ui.sort.feature')},
                        {id: 'value', value: 'value', name: $scope.message('todo.is.ui.sort.value')},
                        {id: 'type', value: 'type', name: $scope.message('todo.is.ui.sort.type')},
                        {id: 'state', value: 'state', name: $scope.message('todo.is.ui.sort.state')},
                        {id: 'value/effort', value: getValueEffortRateForSorting, name: $scope.message('todo.is.ui.sort.value.effort.rate')}
                    ], 'name')
                }
            };
            $scope.orderBacklogByRank(backlogContainer); // Initialize order {current, reverse}, sortable, sorting and init the backlog from client data (storyService.list)
            StoryService.listByBacklog(backlogContainer.backlog).then(function() { // Retrieve server data, stories that were missing will be automatically added through the watch on storyService.list
                backlogContainer.storiesLoaded = true;
            });
            $scope.backlogContainers.push(backlogContainer);
            $scope.backlogContainers = _.sortBy($scope.backlogContainers, function(backlogContainer) {
                return backlogContainer.backlog.id;
            });
        }
    };
    $scope.$watchGroup([function() { return $state.$current.self.name; }, function() { return $state.params.pinnedBacklogCode; }, function() { return $state.params.backlogCode; }], function(newValues) {
        var stateName = newValues[0];
        var pinnedBacklogCode = newValues[1];
        var backlogCode = newValues[2];
        if (stateName == 'backlog') {
            $state.go('backlog.backlog', {backlogCode: _.head($scope.availableBacklogs).code}, {location: 'replace'});
        } else if (_.startsWith(stateName, 'backlog')) {
            if (pinnedBacklogCode) {
                $scope.showBacklog(pinnedBacklogCode);
            }
            if (backlogCode) {
                $scope.showBacklog(backlogCode);
            }
            _.remove($scope.backlogContainers, function(backlogContainer) {
                return !_.includes([pinnedBacklogCode, backlogCode], backlogContainer.backlog.code);
            });
        }
    });
    // Init
    $scope.viewName = 'backlog';
    var fixStoryRank = function(stories) {
        _.each(stories, function(story, index) {
            story.rank = index + 1;
        });
    };
    $scope.backlogSortableOptions = {
        itemMoved: function(event) {
            var story = event.source.itemScope.modelValue;
            var newRank = event.dest.index + 1;
            var sourceScope = event.source.sortableScope;
            var destScope = event.dest.sortableScope;
            fixStoryRank(sourceScope.modelValue);
            fixStoryRank(destScope.modelValue);
            if (BacklogService.isBacklog(sourceScope.backlogContainer.backlog) && BacklogService.isSandbox(destScope.backlogContainer.backlog)) {
                StoryService.returnToSandbox(story, newRank);
            } else if (BacklogService.isSandbox(sourceScope.backlogContainer.backlog) && BacklogService.isBacklog(destScope.backlogContainer.backlog)) {
                StoryService.acceptToBacklog(story, newRank);
            }
        },
        orderChanged: function(event) {
            fixStoryRank(event.dest.sortableScope.modelValue);
            var story = event.source.itemScope.modelValue;
            story.rank = event.dest.index + 1;
            StoryService.update(story);
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            // We don't check more that the fact that the dest backlog is also sorting
            // because we know that the only backlogs that can be sorted (Sandbox & Backlog) can always be inter-sorted (accept <-> return to backlog)
            return sameSortable && destSortableScope.backlogContainer.sorting;
        }
    };
    $scope.sortableId = 'backlog';
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        allowMultiple: true,
        selectionUpdated: function(selectedIds) {
            var currentStateName = $state.current.name;
            var storyIndexInStateName = currentStateName.indexOf('story');
            if (selectedIds.length == 0) {
                if (storyIndexInStateName != -1) {
                    $state.go(currentStateName.slice(0, storyIndexInStateName - 1));
                }
            } else {
                var stateName;
                var stateParams;
                if (_.startsWith(currentStateName, 'backlog.backlog')) {
                    stateName = 'backlog.backlog.story'
                } else if (_.startsWith(currentStateName, 'backlog.multiple')) {
                    stateName = 'backlog.multiple.story'
                }
                if (selectedIds.length == 1) {
                    stateName += '.details' + ($state.params.storyTabId ? '.tab' : '');
                    stateParams = {storyId: selectedIds};
                } else {
                    stateName += '.multiple';
                    stateParams = {storyListId: selectedIds.join(",")};
                }
                $state.go(stateName, stateParams);
            }
        }
    };
    $scope.backlogContainers = [];
    $scope.availableBacklogs = backlogs;
    $scope.backlogCodes = BacklogCodes;
    // Ensures that the stories of displayed backlogs are up to date
    $scope.$on('is:backlogsUpdated', function(event, backlogCodes) {
        _.each(backlogCodes, function(backlogCode) {
            var backlogContainer = $scope.getBacklogContainer(backlogCode);
            if (backlogContainer) {
                $timeout(function() {
                    $scope.refreshSingleBacklog(backlogContainer);
                })
            }
        });
    });
}]);