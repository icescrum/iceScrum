/*
 * Copyright (c) 2015 Kagilum SAS.
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

extensibleController('featureCtrl', ['$scope', '$controller', '$filter', '$window', 'FormService', 'FeatureService', 'FeatureStatesByName', 'WorkspaceType', function($scope, $controller, $filter, $window, FormService, FeatureService, FeatureStatesByName, WorkspaceType) {
    $controller('tagCtrl', {$scope: $scope, type: 'feature'});
    // Functions
    $scope.authorizedFeature = FeatureService.authorizedFeature;
    $scope['delete'] = function(feature) {
        FeatureService.delete(feature).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.menus = [
        {
            name: 'todo.is.ui.details',
            visible: function(feature, viewType) { return viewType !== 'details'; },
            action: function(feature) { $window.location.hash = $scope.openFeatureUrl(feature); }
        },
        {
            name: 'todo.is.ui.context.set',
            visible: function(feature) { return $scope.workspaceType === WorkspaceType.PROJECT },
            url: $scope.featureContextUrl
        },
        {
            name: 'is.ui.feature.state.done',
            visible: function(feature) { return $scope.authorizedFeature('markDone', feature); },
            action: function(feature) {
                FeatureService.updateState(feature, FeatureStatesByName.DONE).then(function() {
                    $scope.notifySuccess('todo.is.ui.feature.updated');
                });
            }
        },
        {
            name: 'is.ui.feature.state.inProgress',
            visible: function(feature) { return $scope.authorizedFeature('markInProgress', feature); },
            action: function(feature) {
                FeatureService.updateState(feature, FeatureStatesByName.IN_PROGRESS).then(function() {
                    $scope.notifySuccess('todo.is.ui.feature.updated');
                });
            }
        },
        {
            name: 'todo.is.ui.permalink.copy',
            visible: function(feature) { return true; },
            action: function(feature) {
                FormService.copyToClipboard(feature.permalink).then(function() {
                    $scope.notifySuccess('is.ui.permalink.copy.success');
                }, function(text) {
                    $scope.notifyError($scope.message('is.ui.permalink.copy.error') + ' ' + text);
                });
            }
        },
        {
            name: 'default.button.delete.label',
            deleteMenu: true,
            visible: function(feature) { return $scope.authorizedFeature('delete'); },
            action: function(feature) { $scope.delete(feature); }
        }
    ];
    $scope.showFeatureProgress = function(feature) {
        return feature.state === FeatureStatesByName.IN_PROGRESS;
    };
    $scope.stateHoverProgress = function(feature) {
        var progress = $filter('percentProgress')(feature.countDoneStories, feature.stories_ids.length);
        return $scope.showFeatureProgress(feature) && progress > 50;
    }
}]);

controllers.controller('featureDetailsCtrl', ['$scope', '$state', '$controller', 'FeatureStatesByName', 'ReleaseStatesByName', 'WorkspaceType', 'FeatureService', 'StoryService', 'FormService', 'detailsFeature', 'StoryStatesByName', 'features', 'project', function($scope, $state, $controller, FeatureStatesByName, ReleaseStatesByName, WorkspaceType, FeatureService, StoryService, FormService, detailsFeature, StoryStatesByName, features, project) {
    $controller('featureCtrl', {$scope: $scope}); // inherit from featureCtrl
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsFeature, clazz: 'feature', workspace: project, workspaceType: WorkspaceType.PROJECT});
    // Functions
    $scope.update = function(feature) {
        FeatureService.update(feature).then(function() {
            $scope.resetFeatureForm();
            $scope.notifySuccess('todo.is.ui.feature.updated');
        });
    };
    $scope.tabUrl = function(featureTabId) {
        var stateName = $state.params.featureTabId ? (featureTabId ? '.' : '^') : (featureTabId ? '.tab' : '.');
        return $state.href(stateName, {featureTabId: featureTabId});
    };
    $scope.refreshAvailableColors = function() {
        FeatureService.getAvailableColors(project.id).then(function(colors) {
            $scope.availableColors = colors;
        });
    };
    $scope.openStoryUrl = function(storyId) {
        return $state.href('.story.details', {storyId: storyId});
    };
    $scope.toggleFocusUrl = function() {
        var stateName = $scope.application.focusedDetailsView ? ($state.params.featureTabId ? '^.^.tab' : '^') : $state.params.featureTabId ? '^.focus.tab' : '.focus';
        return $state.href(stateName, {featureTabId: $state.params.featureTabId});
    };
    $scope.currentStateUrl = function(id) {
        return $state.href($state.current.name, {featureId: id});
    };
    $scope.getCurrentRelease = function(feature) {
        var release = _.find(feature.actualReleases, function(release) {
            return release.state < ReleaseStatesByName.DONE;
        });
        if (!release) {
            release = _.findLast(feature.actualReleases, function(release) {
                return release.state === ReleaseStatesByName.DONE;
            });
        }
        return release;
    };
    $scope.showAllReleases = function() {
        $scope.isAllReleases = true;
    };
    $scope.authorizedStory = StoryService.authorizedStory;
    // Init
    $scope.isAllReleases = false;
    $controller('updateFormController', {$scope: $scope, item: detailsFeature, type: 'feature'});
    $scope.previousFeature = FormService.previous(features, $scope.feature);
    $scope.nextFeature = FormService.next(features, $scope.feature);
    $scope.featureStatesByName = FeatureStatesByName;
    $scope.releaseStatesByName = ReleaseStatesByName;
    $scope.storyStatesByName = StoryStatesByName;
    $scope.availableColors = [];
}]);

controllers.controller('featureNewCtrl', ['$scope', '$state', '$controller', 'FeatureService', 'hotkeys', 'project', 'availableColors', function($scope, $state, $controller, FeatureService, hotkeys, project, availableColors) {
    $controller('featureCtrl', {$scope: $scope}); // inherit from featureCtrl
    // Functions
    $scope.resetFeatureForm = function() {
        $scope.feature = {color: $scope.availableColors && $scope.availableColors.length ? _.last($scope.availableColors) : '#0067e8'};
        $scope.resetFormValidation($scope.formHolder.featureForm);
        $scope.refreshAvailableColors(); // To get a new list the next time
    };
    $scope.save = function(feature, andContinue) {
        FeatureService.save(feature, project.id).then(function(feature) {
            if (andContinue) {
                $scope.resetFeatureForm();
            } else {
                $scope.setInEditingMode(true);
                $scope.openFeatureDetails(feature);
            }
            $scope.notifySuccess('todo.is.ui.feature.saved');
        });
    };
    $scope.refreshAvailableColors = function() {
        return FeatureService.getAvailableColors(project.id).then(function(colors) {
            $scope.availableColors = colors;
        });
    };
    $scope.openFeatureDetails = function(feature) { // Here to be overriden
        $state.go('^.details', {featureId: feature.id});
    };
    // Init
    $scope.formHolder = {};
    $scope.availableColors = availableColors;
    $scope.resetFeatureForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetFeatureForm
    });
}]);

extensibleController('featureMultipleCtrl', ['$scope', '$controller', 'featureListId', 'FeatureService', 'FeatureStatesByName', 'project', function($scope, $controller, featureListId, FeatureService, FeatureStatesByName, project) {
    $controller('featureCtrl', {$scope: $scope}); // inherit from featureCtrl
    // Functions
    $scope.sumValues = function(features) {
        return _.sumBy(features, 'value');
    };
    $scope.sumStories = function(features) {
        return _.sumBy(features, function(feature) {
            return feature.stories_ids.length;
        });
    };
    $scope.deleteMultiple = function() {
        FeatureService.deleteMultiple(featureListId, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.multiple.deleted');
        });
    };
    $scope.updateMultiple = function(updatedFields) {
        FeatureService.updateMultiple(featureListId, updatedFields, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.feature.multiple.updated');
        });
    };
    $scope.inProgressMultiple = function() {
        FeatureService.updateStateMultiple(featureListId, FeatureStatesByName.IN_PROGRESS, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.feature.multiple.updated');
        });
    };
    $scope.doneMultiple = function() {
        FeatureService.updateStateMultiple(featureListId, FeatureStatesByName.DONE, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.feature.multiple.updated');
        });
    };
    $scope.authorizedFeatures = FeatureService.authorizedFeatures;
    // Init
    $scope.selectableOptions.selectingMultiple = true;
    $scope.featureListId = featureListId;
    $scope.topFeature = {};
    $scope.featurePreview = {};
    $scope.features = [];
    FeatureService.getMultiple(featureListId, project.id).then(function(features) {
        $scope.features = features;
        $scope.topFeature = _.head(features);
        $scope.featurePreview = {
            type: _.every(features, {type: $scope.topFeature.type}) ? $scope.topFeature.type : null,
            tags: _.intersection.apply(null, _.map(features, 'tags'))
        };
    });
}]);

