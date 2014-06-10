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
controllers.controller('actorCtrl', ['$scope', '$state', '$timeout', 'selected', 'ActorService', 'StoryService', function ($scope, $state, $timeout, selected, ActorService, StoryService) {
    $scope.selected = selected;
    $scope.tabsType = 'tabs nav-tabs-google';
    if ($state.params.tabId){
        $scope.tabSelected = {};
        $scope.tabSelected[$state.params.tabId] = true;
    } else {
        $scope.tabSelected = {'attachments':true};
    }
    $scope.$watch('$state.params', function() {
        if ($state.params.tabId){
            $scope.tabSelected[$state.params.tabId] = true;
            $timeout((function(){
                var container = angular.element('#right');
                var pos = angular.element('#right .nav-tabs-google [active="tabSelected.'+$state.params.tabId+'"]').position().top + container.scrollTop();
                container.animate({ scrollTop : pos }, 1000);
            }));
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

controllers.controller('actorMultipleCtrl', ['$scope', '$state', 'listId', function ($scope, $state, listId) {
    $scope.ids = listId;
}]);

