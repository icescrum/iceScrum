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
controllers.controller('featureCtrl', ['$scope', '$state', 'selected', 'FeatureService', 'StoryService', function ($scope, $state, selected, FeatureService, StoryService) {
    $scope.selected = selected;
    $scope.tabsType = 'tabs nav-tabs-google';
    $scope.tabSelected = {};
    $scope.$watch('$state.params', function() {
        if ($state.params.id == selected.id){
            $scope.tabSelected[$state.params.tabId] = true;
        }
    });
    $scope.setTabSelected = function(tab){
        $state.go('.', {tabId:tab});
    };
    $scope.update = function (feature) {
        FeatureService.update(feature, function () {
            $scope.$digest();
        });
    };
    $scope['delete'] = function (feature) {
        FeatureService.delete(feature);
        $state.go('^');
    };
    $scope.stories = function(feature){
        feature.stories = _.where(StoryService.list, { feature: { id: feature.id }});
    };
}]);

controllers.controller('featureHeaderCtrl', ['$scope', 'FeatureService', 'FormService', function ($scope, FeatureService, FormService) {
    $scope.previous = FormService.previous(FeatureService.list, $scope.selected);
    $scope.next = FormService.next(FeatureService.list, $scope.selected);
}]);

controllers.controller('featureEditCtrl', ['$scope', 'Session', 'FormService', function ($scope, Session, FormService) {
    $scope.feature = angular.copy($scope.selected);
    $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
    $scope.readOnly = function() {
        return !Session.roles.productOwner;
    };
}]);

