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
controllers.controller('actorCtrl', ['$scope', '$state', 'selected', 'ActorService', 'StoryService', function ($scope, $state, selected, ActorService, StoryService) {
    $scope.selected = selected;
    $scope.tabsType = 'tabs nav-tabs-google';
    $scope.tabSelected = {};
    $scope.$watch('$state.params', function() {
        if ($state.params.id == selected.id){
            $scope.tabSelected[$state.params.tabId] = true;
        }
    });
    $scope.setTabSelected = function(tab){
        if ($state.params.tabId) {
            $state.go('.', {tabId:tab});
        } else {
            $state.go('.tab', {tabId:tab});
        }
    };
    $scope.update = function (actor) {
        ActorService.update(actor, function () {
            $scope.$digest();
        });
    };
    $scope['delete'] = function (actor) {
        ActorService.delete(actor);
        $state.go('^');
    };
    $scope.stories = function(actor){
        actor.stories = _.where(StoryService.list, { actor: { id: actor.id }});
    };
}]);

controllers.controller('actorHeaderCtrl', ['$scope', 'ActorService', 'FormService', function ($scope, ActorService, FormService) {
    $scope.previous = FormService.previous(ActorService.list, $scope.selected);
    $scope.next = FormService.next(ActorService.list, $scope.selected);
}]);

controllers.controller('actorEditCtrl', ['$scope', 'Session', 'FormService', function ($scope, Session, FormService) {
    $scope.actor = angular.copy($scope.selected);
    $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
    $scope.readOnly = function() {
        return !Session.roles.productOwner;
    };
}]);

