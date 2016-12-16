/*
 * Copyright (c) 2016 Kagilum SAS.
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

controllers.controller('actorCtrl', ['$scope', '$state', 'ActorService', function($scope, $state, ActorService) {
    // Functions
    $scope.save = function(actor) {
        ActorService.save(actor).then(function(actor) {
            $scope.actors.push(actor);
            $scope.resetActorForm();
        });
    };
    $scope.update = function(actor) {
        ActorService.update(actor).then(function(actor) {
            _.merge(_.find($scope.actors, {id: actor.id}), actor);
            $scope.resetActorForm();
        });
    };
    $scope.delete = function(actor) {
        ActorService.delete(actor).then(function(   ) {
            _.remove($scope.actors, {id: actor.id});
        });
    };
    $scope.edit = function(actor) {
        $scope.actor = angular.copy(actor);
    };
    $scope.resetActorForm = function() {
        $scope.actor = {};
        $scope.resetFormValidation($scope.formHolder.actorForm);
    };
    $scope.authorizedActor = ActorService.authorizedActor;
    $scope.actorSearchUrl = function(actor) {
        return $state.href('backlog.backlog', {backlogCode: 'all'}) + '?context=actor_' + actor.id;
    };
    // Init
    $scope.actor = {};
    $scope.actors = [];
    ActorService.list().then(function(actors) {
        $scope.actors = actors;
    });
    $scope.formHolder = {};
    $scope.resetActorForm();
}]);
