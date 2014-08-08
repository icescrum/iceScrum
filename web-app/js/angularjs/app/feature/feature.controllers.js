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
controllers.controller('featureCtrl', ['$scope', '$state', '$timeout', 'selected', 'FeatureService', 'StoryService', function($scope, $state, $timeout, selected, FeatureService, StoryService) {
    $scope.selected = selected;
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
    $scope.update = function(feature) {
        FeatureService.update(feature);
    };
    $scope['delete'] = function(feature) {
        FeatureService.delete(feature).then(function() {
            $state.go('^');
        });
    };
    $scope.stories = function(feature) {
        feature.stories = _.where(StoryService.list, { feature: { id: feature.id }});
    };
}]);

controllers.controller('featureHeaderCtrl', ['$scope', 'FeatureService', 'FormService', function($scope, FeatureService, FormService) {
    $scope.previous = FormService.previous(FeatureService.list, $scope.selected);
    $scope.next = FormService.next(FeatureService.list, $scope.selected);
}]);

controllers.controller('featureEditCtrl', ['$scope', 'Session', 'FormService', function($scope, Session, FormService) {
    $scope.feature = angular.copy($scope.selected);
    $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
    $scope.readOnly = function() {
        return !Session.po();
    };
}]);

controllers.controller('featureMultipleCtrl', ['$scope', '$state', 'listId', function($scope, $state, listId) {
    $scope.ids = listId;
}]);

