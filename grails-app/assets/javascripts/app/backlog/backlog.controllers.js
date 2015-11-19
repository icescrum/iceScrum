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
controllers.controller('backlogCtrl', ['$scope', '$state', 'backlogs', 'stories', 'StoryService', '$filter', function($scope, $state, backlogs, stories, StoryService, $filter) {
    // Functions
    $scope.goToNewStory = function() {
        $state.go('backlog.new');
    };
    $scope.goToStory = function(story, tabId) {
        var params = {id: story.id};
        var state = $scope.viewName + '.details';
        if (tabId) {
            params.tabId = tabId;
            state += '.tab';
        }
        $state.go(state, params);
    };
    $scope.isSelected = function(story) {
        if ($state.params.id) {
            return $state.params.id == story.id;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), story.id.toString());
        } else {
            return false;
        }
    };
    $scope.authorizedStory = function(action, story) {
        return StoryService.authorizedStory(action, story);
    };

    $scope.refreshBacklogs = function(stories) {
        _.each($scope.backlogs, function(backlog){
            $scope.refreshSingleBacklog(backlog, stories);
        });
    };

    $scope.refreshSingleBacklog = function(backlog, stories){
        var filter = JSON.parse(backlog.filter);
        var filteredStories = $filter('filter')(stories, filter.story, function(expected, actual) {
            return angular.isArray(actual) && actual.indexOf(expected) > -1 || angular.equals(actual, expected);
        });
        backlog.stories = $filter('orderBy')(filteredStories, backlog.orderBy.current.id, backlog.orderBy.reverse);
    };

    $scope.manageActiveBacklog = function(backlog){
        if(backlog.active){
            backlog.active = false;
            _.remove($scope.backlogs, {id: backlog.id});
        } else {
            //max 2 backlogs so remove the first added
            if($scope.backlogs.length >= $scope.maxParallelsBacklogs) {
                $scope.backlogs[0].active = false;
                $scope.backlogs = $scope.backlogs.slice(1);
            }
            $scope.backlogs.push(backlog);
            backlog.active = true;
            backlog.storiesRendered = false;
            backlog.orderBy = {
                status: false,
                reverse: false,
                current: {id: 'rank', name: $scope.message('todo.is.ui.sort.rank')},
                values: [
                    {id: 'effort', name: $scope.message('todo.is.ui.sort.effort')},
                    {id: 'rank', name: $scope.message('todo.is.ui.sort.rank')},
                    {id: 'name', name: $scope.message('todo.is.ui.sort.name')},
                    {id: 'tasks_count', name: $scope.message('todo.is.ui.sort.tasks')},
                    {id: 'suggestedDate', name: $scope.message('todo.is.ui.sort.date')},
                    {id: 'feature.id', name: $scope.message('todo.is.ui.sort.feature')},
                    {id: 'value', name: $scope.message('todo.is.ui.sort.value')},
                    {id: 'type', name: $scope.message('todo.is.ui.sort.type')}
                ]
            };
            StoryService.listByBacklog(backlog).then(function(stories){
                $scope.refreshSingleBacklog(backlog, stories);
            });
        }
    };

    $scope.changeBacklogOrder = function(backlog, order){
        backlog.orderBy.current = order;
        backlog.orderBy.status = false;
        $scope.refreshSingleBacklog(backlog, backlog.stories);
    };

    $scope.reverseBacklogOrder = function(backlog){
        backlog.orderBy.reverse = !backlog.orderBy.reverse;
        $scope.refreshSingleBacklog(backlog, backlog.stories);
    };

    // Init
    $scope.viewName = 'backlog';
    $scope.selectableOptions = {
        filter: ">.postit-container",
        cancel: "a,.ui-selectable-cancel",
        stop: function(e, ui, selectedItems) {
            switch (selectedItems.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + ($state.params.tabId ? '.details.tab' : '.details'), {id: selectedItems[0].id});
                    break;
                default:
                    $state.go($scope.viewName + '.multiple', {listId: _.pluck(selectedItems, 'id').join(",")});
                    break;
            }
        }
    };

    $scope.backlogSortable = {
        accept: function (sourceItemHandleScope, destSortableScope) { return true; },
        itemMoved: function (event) { },
        orderChanged: function(event) { }
    };

    $scope.backlogs = [];
    $scope.maxParallelsBacklogs = 2;
    $scope.availableBacklogs = backlogs;
    $scope.manageActiveBacklog(backlogs[0]);
    //Useful to keep stories from update
    $scope.stories = StoryService.list;
    $scope.$watch('stories', $scope.refreshBacklogs, true);
}]);