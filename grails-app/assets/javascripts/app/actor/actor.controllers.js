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
    // TODO cancellable delete
    $scope['delete'] = function(actor) {
        ActorService.delete(actor)
            .then(function() {
                $scope.goToNewActor();
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
}]);

controllers.controller('actorDetailsCtrl', ['$scope', '$state', '$stateParams', '$timeout', '$controller', 'ActorService', 'StoryService', 'FormService',
    function($scope, $state, $stateParams, $timeout, $controller, ActorService, StoryService, FormService) {
        $controller('actorCtrl', { $scope: $scope }); // inherit from actorCtrl
        $scope.formHolder = {};
        $scope.actor = {};
        $scope.editableActor = {};
        $scope.editableActorReference = {};
        $scope.stories = function(actor) {
            if (_.isEmpty(actor.stories)) {
                StoryService.listByType(actor);
            }
        };
        ActorService.get($stateParams.id).then(function(actor) {
            $scope.actor = actor;
            // For edit
            $scope.resetActorForm();
            // For header
            $scope.previous = FormService.previous(ActorService.list, $scope.actor);
            $scope.next = FormService.next(ActorService.list, $scope.actor);
            $scope.stories(actor); // load the stories as soon as possible since we are sure that they are displayed
        }).catch(function(e){
            $state.go('^.new');
            $scope.notifyError(e.message)
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
        // edit
        $scope.isDirty = function() {
            return !_.isEqual($scope.editableActor, $scope.editableActorReference);
        };
        $scope.update = function(actor) {
            ActorService.update(actor).then(function(actor) {
                $scope.actor = actor;
                $scope.resetActorForm();
                $scope.notifySuccess('todo.is.ui.actor.updated');
            });
        };
        $scope.selectTagsOptions = angular.copy(FormService.selectTagsOptions);
        $scope.editForm = function(value) {
            $scope.setEditableMode(value); // global
            if (!value) {
                $scope.resetActorForm();
            }
        };
        $scope.getShowActorForm = function(actor) {
            return ($scope.getEditableMode() || $scope.formHolder.formHover) && $scope.authorizedActor('update', actor);
        };
        $scope.resetActorForm = function() {
            $scope.editableActor = angular.copy($scope.actor);
            $scope.editableActorReference = angular.copy($scope.actor);
            if ($scope.formHolder.actorForm) {
                $scope.formHolder.actorForm.$setPristine();
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
            return $scope.actor;
        };
        $scope.clazz = 'actor';
        $scope.attachmentQuery = function($flow, actor) {
            $scope.flow = $flow;
            $flow.opts.target = 'attachment/actor/' + actor.id + '/flow';
            $flow.upload();
        };
        $scope.formHover = function(value) {
            $scope.formHolder.formHover = value;
        };
    }]);


controllers.controller('actorNewCtrl', ['$scope', '$state', '$controller', 'ActorService', 'hotkeys', function($scope, $state, $controller, ActorService, hotkeys) {
    $controller('actorCtrl', { $scope: $scope }); // inherit from actorCtrl
    // Functions
    $scope.resetActorForm = function() {
        $scope.actor = {};
        if ($scope.formHolder.actorForm) {
            $scope.formHolder.actorForm.$setPristine();
        }
    };
    $scope.save = function(actor, andContinue) {
        ActorService.save(actor).then(function(actor) {
            if (andContinue) {
                $scope.resetActorForm();
            } else {
                $scope.setEditableMode(true);
                $state.go('^.details', { id: actor.id });
            }
            $scope.notifySuccess('todo.is.ui.actor.saved');
        });
    };
    // Init
    $scope.formHolder = {};
    $scope.resetActorForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetActorForm
    });
}]);

controllers.controller('actorMultipleCtrl', ['$scope', '$controller', 'listId', 'ActorService', function($scope, $controller, listId, ActorService) {
    $controller('actorCtrl', { $scope: $scope }); // inherit from actorCtrl
    // Functions
    $scope.deleteMultiple = function() {
        // TODO cancellable delete ?
        ActorService.deleteMultiple(listId)
            .then(function() {
                $scope.goToNewActor();
                $scope.notifySuccess('todo.is.ui.multiple.deleted');
            });
    };
    // Init
    $scope.ids = listId;
    $scope.topActor = {};
    ActorService.getMultiple(listId).then(function(actors) {
        $scope.topActor = _.first(actors);
    });
}]);

