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
                $scope.goToNewFeature();
                $scope.notifySuccess('todo.is.ui.feature.copied.to.backlog');
            });
    };
}]);

controllers.controller('featureDetailsCtrl', ['$scope', '$state', '$stateParams', '$timeout', '$controller', 'FeatureService', 'StoryService', 'FormService',
    function($scope, $state, $stateParams, $timeout, $controller, FeatureService, StoryService, FormService) {
        $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
        $scope.formHolder = {};
        $scope.feature = {};
        $scope.editableFeature = {};
        $scope.editableFeatureReference = {};
        $scope.stories = function(feature) {
            if (_.isEmpty(feature.stories)) {
                StoryService.listByType(feature);
            }
        };
        FeatureService.get($stateParams.id).then(function(feature) {
            $scope.feature = feature;
            // For edit
            $scope.resetFeatureForm();
            // For header
            $scope.previous = FormService.previous(FeatureService.list, $scope.feature);
            $scope.next = FormService.next(FeatureService.list, $scope.feature);
            $scope.stories(feature); // load the stories as soon as possible since we are sure that they are displayed
        });
        if ($state.params.tabId) {
            $scope.tabSelected = {};
            $scope.tabSelected[$state.params.tabId] = true;
        } else {
            $scope.tabSelected = {'stories': true};
        }
        $scope.$watch('$state.params', function() {
            if ($state.params.tabId) {
                if ($state.params.tabId != 'attachments') {
                    $scope.tabSelected[$state.params.tabId] = true;
                }
                $timeout((function() {
                    var container = angular.element('#right');
                    var pos = $state.params.tabId == 'attachments' ? angular.element('#right .table.attachments').offset().top - angular.element('#right .panel-body').offset().top - 9 : angular.element('#right .nav-tabs-google').offset().top - angular.element('#right .panel-body').offset().top - 9;
                    container.animate({ scrollTop: pos }, 1000);
                }));
            }
        });
        $scope.setTabSelected = function(tab) {
            if ($state.params.tabId) {
                $state.go('.', {tabId: tab});
            } else {
                if ($state.$current.toString().indexOf('details') > 0) {
                    $state.go('.tab', {tabId: tab});
                }
            }
        };
        // Edit
        $scope.isDirty = function() {
            return !_.isEqual($scope.editableFeature, $scope.editableFeatureReference);
        };
        $scope.update = function(feature) {
            FeatureService.update(feature).then(function(feature) {
                $scope.feature = feature;
                $scope.resetFeatureForm();
                $scope.notifySuccess('todo.is.ui.feature.updated');
            });
        };
        $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
        $scope.editForm = function(value) {
            $scope.setEditableMode(value); // global
            if (!value) {
                $scope.resetFeatureForm();
            }
        };
        $scope.getShowFeatureForm = function(feature) {
            return ($scope.getEditableMode() || $scope.formHolder.formHover) && $scope.authorizedFeature('update', feature);
        };
        $scope.resetFeatureForm = function() {
            $scope.editableFeature = angular.copy($scope.feature);
            $scope.editableFeatureReference = angular.copy($scope.feature);
            if ($scope.formHolder.featureForm) {
                $scope.formHolder.featureForm.$setPristine();
            }
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
        $scope.getSelected = function() {
            return $scope.feature;
        };
        $scope.clazz = 'feature';
        $scope.attachmentQuery = function($flow, feature) {
            $scope.flow = $flow;
            $flow.opts.target = 'attachment/feature/' + feature.id + '/flow';
            $flow.upload();
        };
        $scope.formHover = function(value) {
            $scope.formHolder.formHover = value;
        };
    }]);

controllers.controller('featureNewCtrl', ['$scope', '$state', '$controller', 'FeatureService', 'hotkeys', function($scope, $state, $controller, FeatureService, hotkeys) {
    $controller('featureCtrl', { $scope: $scope }); // inherit from featureCtrl
    // Functions
    $scope.resetFeatureForm = function() {
        $scope.feature = {};
        if ($scope.formHolder.featureForm) {
            $scope.formHolder.featureForm.$setPristine();
        }
    };
    $scope.save = function(feature, andContinue) {
        FeatureService.save(feature).then(function(feature) {
            if (andContinue) {
                $scope.resetFeatureForm();
            } else {
                $scope.setEditableMode(true);
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
    $scope.totalValue = function(features) {
        return _.reduce(features, function(sum, feature) {
            return sum + feature.value;
        }, 0);
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

