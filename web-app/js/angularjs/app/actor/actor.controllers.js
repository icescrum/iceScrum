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

controllers.controller('actorCtrl', ['$scope', '$state', 'ActorService', function($scope, $state, ActorService) {
    $scope.authorizedActor = function(action) {
        return ActorService.authorizedActor(action);
    };
    $scope['delete'] = function(actor) {
        ActorService.delete(actor).then($scope.goToNewActor);
    };
}]);

controllers.controller('actorDetailsCtrl', ['$scope', '$state', '$timeout', '$controller', 'selected', 'ActorService', 'StoryService', 'FormService',
    function($scope, $state, $timeout, $controller, selected, ActorService, StoryService, FormService) {
        $controller('actorCtrl', { $scope: $scope }); // inherit from actorCtrl
        $scope.actor = selected;
        $scope.initEditableActor = function() {
            $scope.editableActor = angular.copy(selected);
            $scope.editableActorReference = angular.copy(selected);
        };
        $scope.initEditableActor();
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
        $scope.stories = function(actor) {
            actor.stories = _.where(StoryService.list, { actor: { id: actor.id }});
        };
        // header
        $scope.previous = FormService.previous(ActorService.list, $scope.actor);
        $scope.next = FormService.next(ActorService.list, $scope.actor);
        // edit
        $scope.isDirty = function() {
            return !_.isEqual($scope.editableActor, $scope.editableActorReference);
        };
        $scope.update = function(actor) {
            ActorService.update(actor).then(function(actor) {
                $scope.actor = actor;
            });
        };
        $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
        $scope.enableEditableActorMode = function() {
            $scope.setEditableMode(true);
        };
        $scope.disableEditableActorMode = function() {
            $scope.setEditableMode(false);
            $scope.initEditableActor();
        };
        $scope.getEditableActorMode = function(actor) {
            return $scope.getEditableMode() && $scope.authorizedActor('update', actor);
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


controllers.controller('actorNewCtrl', ['$scope', '$state', '$controller', 'ActorService', function($scope, $state, $controller, ActorService) {
    $controller('actorCtrl', { $scope: $scope }); // inherit from actorCtrl
    $scope.save = function(actor, andContinue) {
        ActorService.save(actor).then(function(actor) {
            if (andContinue) {
                $scope.actor = {};
            } else {
                $scope.setEditableMode(true);
                $state.go('^.details', { id: actor.id });
            }
        });
    };
}]);

controllers.controller('actorMultipleCtrl', ['$scope', '$controller', 'listId', 'ActorService', function($scope, $controller, listId, ActorService) {
    $controller('actorCtrl', { $scope: $scope }); // inherit from actorCtrl
    $scope.ids = listId;
    $scope.topActor = {};
    ActorService.getMultiple(listId).then(function(actors) {
        $scope.topActor = _.first(actors);
    });
    $scope.deleteMultiple = function() {
        ActorService.deleteMultiple(listId).then($scope.goToNewActor);
    };
    $scope.updateMultiple = function(updatedFields) {
        ActorService.updateMultiple(listId, updatedFields);
    };
}]);

