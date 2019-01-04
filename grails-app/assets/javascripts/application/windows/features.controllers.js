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

extensibleController('featuresCtrl', ['$scope', '$state', '$controller', 'FeatureService', 'project', 'features', function($scope, $state, $controller, FeatureService, project, features) {
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
        $scope.selectableOptions.selectingMultiple = !$scope.selectableOptions.selectingMultiple;
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
        return FeatureService.authorizedFeature('rank', $scope.project);
    };
    $scope.isSortingFeature = function() {
        return $scope.isSortableFeature() && $scope.orderBy.current.id == 'rank' && !$scope.orderBy.reverse && !$scope.hasContextOrSearch();
    };
    $scope.enableSortable = function() {
        $scope.clearContextAndSearch();
        $scope.orderByRank();
    };
    $scope.openFeatureUrl = function(feature) {
        return '#/' + $scope.viewName + '/' + feature.id;
    };
    // Init
    $scope.viewName = 'feature';
    $scope.project = project;
    $scope.features = features;
    var updateRank = function(event) {
        var feature = event.source.itemScope.modelValue;
        feature.rank = event.dest.index + 1;
        FeatureService.update(feature).catch(function() {
            $scope.revertSortable(event);
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
                    if ($scope.selectableOptions.hasSelected()) {
                        $state.go($scope.viewName);
                    }
                    break;
                case 1:
                    $state.go($scope.viewName + '.details' + ($state.params.featureTabId ? '.tab' : ''), {featureId: selectedIds});
                    break;
                default:
                    $state.go($scope.viewName + '.multiple', {featureListId: selectedIds.join(",")});
                    break;
            }
        },
        hasSelected: function() { // Required to disable bulk select automatically when nothing is selected
            return !_.isUndefined($state.params.featureId) || !_.isUndefined($state.params.featureListId);
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
