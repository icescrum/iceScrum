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

controllers.controller('featureCtrl', ['$scope', '$state', 'FeatureService', function($scope, $state, FeatureService) {
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };
    $scope['delete'] = function(feature) {
        FeatureService.delete(feature).then($scope.goToNewFeature);
    };
    $scope.copyToBacklog = function(feature) {
        FeatureService.copyToBacklog(feature);
    };
}]);

controllers.controller('featureDetailsCtrl', ['$scope', '$state', '$timeout', '$controller', 'selected', 'FeatureService', 'StoryService', 'FormService',
    function($scope, $state, $timeout, $controller, selected, FeatureService, StoryService, FormService) {
        $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
        $scope.feature = selected;
        $scope.initEditableFeature = function() {
            $scope.editableFeature = angular.copy(selected);
            $scope.editableFeatureReference = angular.copy(selected);
        };
        $scope.initEditableFeature();
        $scope.tabsType = 'tabs nav-tabs-google';
        if ($state.params.tabId) {
            $scope.tabSelected = {};
            $scope.tabSelected[$state.params.tabId] = true;
        } else {
            $scope.tabSelected = {'attachments': true};
        }
        $scope.$watch('$state.params', function() {
            if ($state.params.tabId) {
                $scope.tabSelected[$state.params.tabId] = true;
                $timeout((function() {
                    var container = angular.element('#right');
                    var pos = angular.element('#right .nav-tabs-google').offset().top - angular.element('#right .panel-body').offset().top - 9;
                    container.animate({ scrollTop: pos }, 1000);
                }));
            }
        });
        $scope.setTabSelected = function(tab) {
            if ($state.params.tabId) {
                $state.go('.', {tabId: tab});
            } else {
                $state.go('.tab', {tabId: tab});
            }
        };
        $scope.stories = function(feature) {
            StoryService.listByType(feature);
        };
        // Header
        $scope.previous = FormService.previous(FeatureService.list, $scope.feature);
        $scope.next = FormService.next(FeatureService.list, $scope.feature);
        // Edit
        $scope.isDirty = function() {
            return !_.isEqual($scope.editableFeature, $scope.editableFeatureReference);
        };
        $scope.update = function(feature) {
            FeatureService.update(feature).then(function(feature) {
                $scope.feature = feature;
            });
        };
        $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
        $scope.enableEditableFeatureMode = function() {
            $scope.setEditableMode(true);
        };
        $scope.disableEditableStoryMode = function() {
            $scope.setEditableMode(false);
            $scope.initEditableFeature();
        };
        $scope.getEditableFeatureMode = function(feature) {
            return $scope.getEditableMode() && $scope.authorizedFeature('update', feature);
        };
        $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $stage.go
        $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams){
            if ($scope.mustConfirmStateChange && fromParams.id != toParams.id) {
                event.preventDefault(); // cancel the state change
                $scope.mustConfirmStateChange = false;
                $scope.confirm({
                    message: 'todo.is.ui.dirty.confirm',
                    condition: $scope.isDirty(),
                    callback: function () {
                        $state.go(toState, toParams)
                    },
                    closeCallback: function() {
                        $scope.mustConfirmStateChange = true;
                    }
                });
            }
        });
    }]);

controllers.controller('featureNewCtrl', ['$scope', '$state', '$controller', 'FeatureService', function($scope, $state, $controller, FeatureService) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
    $scope.save = function(feature, andContinue) {
        FeatureService.save(feature).then(function(feature) {
            if (andContinue) {
                $scope.feature = {};
            } else {
                $scope.setEditableMode(true);
                $state.go('^.details', { id: feature.id });
            }
        });
    };
}]);

controllers.controller('featureMultipleCtrl', ['$scope', '$controller', 'listId', 'FeatureService', function($scope, $controller, listId, FeatureService) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
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
    $scope.totalValue = function(features) {
        return _.reduce(features, function(sum, feature) {
            return sum + feature.value;
        }, 0);
    };
    $scope.deleteMultiple = function() {
        FeatureService.deleteMultiple(listId).then($scope.goToNewFeature);
    };
    $scope.updateMultiple = function(updatedFields) {
        FeatureService.updateMultiple(listId, updatedFields);
    };
    $scope.copyToBacklogMultiple = function() {
        FeatureService.copyToBacklogMultiple(listId);
    };
}]);

