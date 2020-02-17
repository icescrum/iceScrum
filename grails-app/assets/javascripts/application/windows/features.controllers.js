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

extensibleController('featuresCtrl', ['$scope', '$q', '$state', '$timeout', '$filter', '$controller', 'FeatureService', 'FeatureStatesByName', 'WorkspaceType', 'Feature', 'project', 'features', function($scope, $q, $state, $timeout, $filter, $controller, FeatureService, FeatureStatesByName, WorkspaceType, Feature, project, features) {
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
        return FeatureService.authorizedFeature('rank', null, $scope.project);
    };
    $scope.isSortingFeature = function() {
        return $scope.isSortableFeature() && $scope.orderBy.current.id == 'rank' && !$scope.orderBy.reverse && !$scope.hasContextOrSearch() && $scope.currentFeaturesFilter.id === 'all';
    };
    $scope.enableSortable = function() {
        $scope.clearContextAndSearch();
        $scope.orderByRank();
        $scope.currentFeaturesFilter = _.find($scope.featuresFilters, {id: 'all'});
    };
    $scope.openFeatureUrl = function(feature) {
        return '#/' + $scope.viewName + '/' + feature.id;
    };
    $scope.countByFilter = function(featuresFilter) {
        return _.filter(project.features, featuresFilter.filter).length;
    };
    $scope.changeFeaturesFilter = function(featuresFilter) {
        $scope.currentFeaturesFilter = featuresFilter;
    };
    // Init
    $scope.viewName = 'feature';
    $scope.project = project;
    $scope.features = features;
    var updateRank = function(event) {
        var feature = event.source.itemScope.modelValue;
        var newRank = event.dest.index + 1;
        if ($state.params.featureListId !== undefined) {
            var ids = $state.params.featureListId.split(',');
            FeatureService.rankMultiple(ids, newRank, project.id);
        } else {
            feature.rank = newRank;
            FeatureService.update(feature).catch(function() {
                $scope.revertSortable(event);
            });
        }
    };
    $scope.featureSortableOptions = {
        itemMoved: updateRank,
        orderChanged: updateRank,
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.newFromFiles = function($flow, project) {
        var createFeatureWithFile = function(files, project, selectOnComplet) {
            $flow.files = files;
            var feature = new Feature();
            $controller('attachmentCtrl', {$scope: $scope, attachmentable: feature, clazz: 'feature', workspace: project, workspaceType: WorkspaceType.PROJECT});
            feature.name = $flow.files[0].name.substr(0, $flow.files[0].name.length > 99 ? $flow.files[0].name.length : 99);
            return FeatureService.getAvailableColors(project.id).then(function(colors) {
                feature.color = colors && colors.length ? _.last(colors) : '#0067e8';
                return FeatureService.save(feature, project.id).then(function(savedObject) {
                    var onFileSuccess = function(flowFile) {
                        $flow.removeFile(flowFile);
                    };
                    var onFileError = function(flowFile, message) {
                        var data = JSON.parse(message);
                        $scope.notifyError(angular.isArray(data) ? data[0].text : data.text, {delay: 8000});
                        $flow.removeFile(flowFile);
                    };
                    var onComplete = function() {
                        if (selectOnComplet) {
                            $scope.selectableOptions.selectionUpdated([savedObject.id]);
                            $timeout(function() {
                                $("[ui-view='details'] input[name='name']").focus();
                            }, 25);
                        }
                        $flow.off('fileError', onFileError);
                        $flow.off('fileSuccess', onFileSuccess);
                        $flow.off('complete', onComplete);
                    };
                    $flow.on('fileError', onFileError);
                    $flow.on('fileSuccess', onFileSuccess);
                    $flow.on('complete', onComplete);
                    $scope.attachmentQuery($flow, savedObject);
                }, function() {
                    $flow.cancel();
                });
            });
        };
        var featurePerFile = $('.drop-split-zone-left').hasClass('draghover');
        var files = $flow.files;
        $flow.files = null;
        if (featurePerFile) {
            $q.serial(_.map(files, function(file) {
                return {
                    success: function() {
                        return createFeatureWithFile([file], project, false);
                    }
                };
            }));
        } else {
            createFeatureWithFile(files, project, true);
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
    $scope.featuresFilters = [
        {id: 'all', name: $scope.message('todo.is.ui.backlog.all'), filter: {}},
        {id: 'todo', name: $filter('i18n')(FeatureStatesByName.TODO, 'FeatureStates'), filter: {state: FeatureStatesByName.TODO}},
        {id: 'inProgress', name: $filter('i18n')(FeatureStatesByName.IN_PROGRESS, 'FeatureStates'), filter: {state: FeatureStatesByName.IN_PROGRESS}},
        {id: 'done', name: $filter('i18n')(FeatureStatesByName.DONE, 'FeatureStates'), filter: {state: FeatureStatesByName.DONE}}
    ];
    $scope.currentFeaturesFilter = _.find($scope.featuresFilters, {id: 'all'});
    $scope.orderByRank();
}]);
