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
 *
 */

controllers.controller('featureCtrl', ['$scope', '$state', 'FeatureService', function($scope, $state, FeatureService) {
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };
    // TODO cancellable delete
    $scope['delete'] = function(feature) {
        FeatureService.delete(feature)
            .then(function() {
                $scope.goToNewFeature();
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    $scope.copyToBacklog = function(feature) {
        FeatureService.copyToBacklog(feature)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.feature.copied.to.backlog');
            });
    };
}]);

controllers.controller('featureDetailsCtrl', ['$scope', '$state', '$stateParams', '$controller', 'FeatureService', 'FormService', 'ProjectService', function($scope, $state, $stateParams, $controller, FeatureService, FormService, ProjectService) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
    $scope.formHolder = {};
    $scope.feature = {};
    $scope.editableFeature = {};
    $scope.editableFeatureReference = {};
    FeatureService.get($stateParams.id).then(function(feature) {
        $scope.feature = feature;
        $scope.selected = feature;
        // For edit
        $scope.resetFeatureForm();
        // For header
        $scope.previous = FormService.previous(FeatureService.list, $scope.feature);
        $scope.next = FormService.next(FeatureService.list, $scope.feature);
    }).catch(function(e){
        $state.go('^');
        $scope.notifyError(e.message)
    });
    // Edit
    $scope.isDirty = function() {
        return !_.isEqual($scope.editableFeature, $scope.editableFeatureReference);
    };
    $scope.update = function(feature) {
        FeatureService.update(feature).then(function(feature) {
            $scope.resetFeatureForm();
            $scope.notifySuccess('todo.is.ui.feature.updated');
        });
    };
    $scope.editForm = function(value) {
        if (value != $scope.isInEditingMode()) {
            $scope.setInEditingMode(value); // global
            $scope.resetFeatureForm();
        }
    };
    $scope.getShowFeatureForm = function(feature) {
        return ($scope.isInEditingMode() || $scope.formHolder.formHover) && $scope.authorizedFeature('update', feature);
    };
    $scope.resetFeatureForm = function() {
        if ($scope.isInEditingMode()) {
            $scope.editableFeature = angular.copy($scope.feature);
            $scope.editableFeatureReference = angular.copy($scope.feature);
        } else {
            $scope.editableFeature = $scope.feature;
            $scope.editableFeatureReference = $scope.feature;
        }
        $scope.resetFormValidation($scope.formHolder.featureForm);
    };
    $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $stage.go
    $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
        if ($scope.mustConfirmStateChange && fromParams.id != toParams.id) {
            event.preventDefault(); // cancel the state change
            $scope.mustConfirmStateChange = false;
            $scope.confirm({
                message: 'todo.is.ui.dirty.confirm',
                condition: $scope.isDirty() || ($scope.flow != undefined && $scope.flow.isUploading()),
                callback: function() {
                    if ($scope.flow != undefined && $scope.flow.isUploading()) {
                        $scope.flow.cancel();
                    }
                    $state.go(toState, toParams)
                },
                closeCallback: function() {
                    $scope.mustConfirmStateChange = true;
                }
            });
        }
    });
    $scope.clazz = 'feature';
    $scope.attachmentQuery = function($flow, feature) {
        $scope.flow = $flow;
        $flow.opts.target = 'attachment/feature/' + feature.id + '/flow';
        $flow.upload();
    };
    $scope.formHover = function(value) {
        $scope.formHolder.formHover = value;
    };
    $scope.tags = [];
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function (tags) {
                $scope.tags = tags;
            });
        }
    };
}]);

controllers.controller('featureDetailsStoryCtrl', ['$scope', '$controller', 'StoryService', function($scope, $controller, StoryService) {
    $controller('featureDetailsCtrl', { $scope: $scope }); // inherit from featureDetailsCtrl
    $scope.$watch('feature', function(){
        $scope.selected = $scope.feature;
        if (_.isEmpty($scope.selected.stories)) {
            StoryService.listByType($scope.selected);
        }
    });
}]);

controllers.controller('featureNewCtrl', ['$scope', '$state', '$controller', 'FeatureService', 'hotkeys', function($scope, $state, $controller, FeatureService, hotkeys) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
    // Functions
    $scope.resetFeatureForm = function() {
        $scope.feature = {};
        $scope.resetFormValidation($scope.formHolder.featureForm);
    };
    $scope.save = function(feature, andContinue) {
        FeatureService.save(feature).then(function(feature) {
            if (andContinue) {
                $scope.resetFeatureForm();
            } else {
                $scope.setInEditingMode(true);
                $state.go('^.details', { id: feature.id });
            }
            $scope.notifySuccess('todo.is.ui.feature.saved');
        });
    };
    // Init
    $scope.formHolder = {};
    $scope.resetFeatureForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetFeatureForm
    });
}]);

controllers.controller('featureMultipleCtrl', ['$scope', '$controller', 'listId', 'FeatureService', function($scope, $controller, listId, FeatureService) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
    // Functions
    $scope.sumValues = function(features) {
        return _.sum(features, 'value');
    };
    $scope.sumStories = function(features) {
        return _.sum(features, function(feature) { return feature.stories_ids.length; });
    };
    // TODO cancellable delete ?
    $scope.deleteMultiple = function() {
        FeatureService.deleteMultiple(listId)
            .then(function() {
                $scope.goToNewFeature();
                $scope.notifySuccess('todo.is.ui.multiple.deleted');
            });
    };
    $scope.updateMultiple = function(updatedFields) {
        FeatureService.updateMultiple(listId, updatedFields)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.feature.multiple.updated');
            });
    };
    $scope.copyToBacklogMultiple = function() {
        FeatureService.copyToBacklogMultiple(listId)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.feature.multiple.copied.to.backlog');
            });
    };
    // Init
    $scope.ids = listId;
    $scope.topFeature = {};
    $scope.featurePreview = {};
    $scope.features = [];
    FeatureService.getMultiple(listId).then(function(features) {
        $scope.features = features;
        $scope.topFeature = _.first(features);
        $scope.featurePreview = {
            type: _.every(features, { type: $scope.topFeature.type }) ? $scope.topFeature.type : null
        };
    });
}]);

