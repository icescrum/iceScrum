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
    $scope.authorized = function(action) {
        return FeatureService.authorized(action);
    };
    $scope['delete'] = function(feature) {
        FeatureService.delete(feature).then($scope.goToNewFeature);
    };
}]);

controllers.controller('featureDetailsCtrl', ['$scope', '$state', '$timeout', '$controller', 'selected', 'FeatureService', 'StoryService', 'FormService',
    function($scope, $state, $timeout, $controller, selected, FeatureService, StoryService, FormService) {
        $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
        $scope.feature = selected;
        $scope.editableFeature = angular.copy(selected);
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
                    var pos = angular.element('#right .nav-tabs-google [active="tabSelected.' + $state.params.tabId + '"]').position().top + container.scrollTop();
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
            feature.stories = _.where(StoryService.list, { feature: { id: feature.id }});
        };
        // Header
        $scope.previous = FormService.previous(FeatureService.list, $scope.feature);
        $scope.next = FormService.next(FeatureService.list, $scope.feature);
        // Edit
        $scope.update = function(feature) {
            FeatureService.update(feature).then(function(feature) {
                $scope.feature = feature;
            });
        };
        $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
        $scope.setEditableFeatureMode = function(editableMode) {
            $scope.setEditableMode(editableMode);
            if (!editableMode) {
                $scope.editableFeature = angular.copy($scope.feature);
            }
        };
        $scope.getEditableFeatureMode = function(feature) {
            return $scope.getEditableMode() && $scope.authorized('update', feature);
        };
        $scope.cancel = function() {
            $scope.editableFeature = angular.copy($scope.feature);
        };
    }]);

controllers.controller('featureNewCtrl', ['$scope', '$state', '$controller', 'FeatureService', function($scope, $state, $controller, FeatureService) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
    $scope.save = function(feature, andContinue) {
        FeatureService.save(feature).then(function(feature) {
            if (andContinue) {
                $scope.feature = {};
            } else {
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
            type: $scope.topFeature.type
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
}]);

