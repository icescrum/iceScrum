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

controllers.controller('featureCtrl', ['$scope', '$filter', 'FeatureService', function($scope, $filter, FeatureService) {
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };
    $scope['delete'] = function(feature) {
        FeatureService.delete(feature).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.copyToBacklog = function(feature) {
        FeatureService.copyToBacklog(feature).then(function() {
            $scope.notifySuccess('todo.is.ui.feature.copied.to.backlog');
        });
    };
    $scope.menus = [{
        name:$scope.message('todo.is.ui.context.set'),
        visible:function(feature, viewName){ return true; },
        action:function(feature, viewName) {
            $scope.setFeatureContext(feature)
        }
    },{
        name:$scope.message('is.ui.feature.menu.copy'),
        visible:function(feature, viewName){ return $scope.authorizedFeature('copyToBacklog'); },
        action:function(feature, viewName) {
            $scope.copyToBacklog(feature)
        }
    },{
        name:$scope.message('todo.is.ui.permalink.copy'),
        visible:function(feature, viewName){ return $scope.authorizedFeature('copyToBacklog'); },
        action:function(feature, viewName) {
            $scope.showCopyModal($scope.message('is.permalink'), ($filter('permalink')(feature.uid,'feature')));
        }
    },{
        name:$scope.message('is.ui.feature.menu.delete'),
        visible:function(feature, viewName){ return $scope.authorizedFeature('delete'); },
        action:function(feature, viewName) {
            $scope.confirm({ message: $scope.message('is.confirm.delete'), callback: $scope.delete, args: [feature] })
        }
    }];
}]);

controllers.controller('featureDetailsCtrl', ['$scope', '$state', '$controller', 'Session', 'FeatureStatesByName', 'FeatureService', 'FormService', 'ProjectService', 'detailsFeature', function($scope, $state, $controller, Session, FeatureStatesByName, FeatureService, FormService, ProjectService, detailsFeature) {
    $controller('featureCtrl', {$scope: $scope}); // inherit from featureCtrl
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsFeature, clazz: 'feature'});
    // Functions
    $scope.update = function(feature) {
        FeatureService.update(feature).then(function() {
            $scope.resetFeatureForm();
            $scope.notifySuccess('todo.is.ui.feature.updated');
        });
    };
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.tabUrl = function(featureTabId) {
        var stateName = $state.params.featureTabId ? (featureTabId ? '.' : '^') : (featureTabId ? '.tab' : '.');
        return $state.href(stateName, {featureTabId: featureTabId});
    };
    // Init
    $controller('updateFormController', {$scope: $scope, item: detailsFeature, type: 'feature', resetOnProperties: []});
    $scope.tags = [];
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.previousFeature = FormService.previous(Session.getProject().features, $scope.feature);
    $scope.nextFeature = FormService.next(Session.getProject().features, $scope.feature);
    $scope.featureStatesByName = FeatureStatesByName;
}]);

controllers.controller('featureNewCtrl', ['$scope', '$state', '$controller', 'FeatureService', 'hotkeys', function($scope, $state, $controller, FeatureService, hotkeys) {
    $controller('featureCtrl', {$scope: $scope}); // inherit from featureCtrl
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
                $state.go('^.details', {featureId: feature.id});
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

controllers.controller('featureMultipleCtrl', ['$scope', '$controller', 'featureListId', 'FeatureService', function($scope, $controller, featureListId, FeatureService) {
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
        FeatureService.deleteMultiple(featureListId).then(function() {
            $scope.notifySuccess('todo.is.ui.multiple.deleted');
        });
    };
    $scope.updateMultiple = function(updatedFields) {
        FeatureService.updateMultiple(featureListId, updatedFields).then(function() {
            $scope.notifySuccess('todo.is.ui.feature.multiple.updated');
        });
    };
    $scope.copyToBacklogMultiple = function() {
        FeatureService.copyToBacklogMultiple(featureListId).then(function() {
            $scope.notifySuccess('todo.is.ui.feature.multiple.copied.to.backlog');
        });
    };
    // Init
    $scope.app.selectableMultiple = true;
    $scope.ids = featureListId;
    $scope.topFeature = {};
    $scope.featurePreview = {};
    $scope.features = [];
    FeatureService.getMultiple(featureListId).then(function(features) {
        $scope.features = features;
        $scope.topFeature = _.head(features);
        $scope.featurePreview = {
            type: _.every(features, {type: $scope.topFeature.type}) ? $scope.topFeature.type : null
        };
    });
}]);

