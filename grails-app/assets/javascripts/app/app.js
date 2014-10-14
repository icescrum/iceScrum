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

var isApp = angular.module('isApp', [
    'ngRoute',
    'controllers',
    'services',
    'filters',
    'directives',
    'ui.router',
    'ui.selectable',
    'ui.sortable',
    'ui.bootstrap',
    'ui.select2',
    'monospaced.elastic',
    'cfp.hotkeys',
    'colorpicker.module',
    'mgo-angular-wizard',
    'ngPasswordStrength',
    'flow',
    'ngPDFViewer',
    'remoteValidation'
]);

isApp.config(['$stateProvider', '$httpProvider',
        function ($stateProvider, $httpProvider) {
            $httpProvider.interceptors.push([
                '$injector',
                function ($injector) {
                    return $injector.get('AuthInterceptor');
                }
            ]);
            $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
            $stateProvider
                .state('root', {
                    url:'/'
                })
                .state('project', {
                    url: '/project',
                    controller: 'projectCtrl'
                })
                .state('project.new', {
                    url: "/new",
                    onEnter: ["$state", "$modal", 'WizardHandler', function($state, $modal, WizardHandler) {
                        var modal = $modal.open({
                            templateUrl: icescrum.grailsServer + '/' + "project/add",
                            size: 'lg',
                            controller: 'newProjectCtrl'
                            });
                        modal.result.then(
                            function(result) {
                                $state.transitionTo('root');
                            }, function(){
                                $state.transitionTo('root');
                            });
                    }]
                })

                .state('sandbox', {
                    templateUrl: 'openWindow/sandbox',
                    controller: 'sandboxCtrl',
                    data: {
                        filterListParams: {
                            state:1
                        }
                    },
                    resolve:{
                        stories:['StoryService', function(StoryService){
                            return StoryService.list;
                        }]
                    }
                })
                    .state('sandbox.new', {
                        url: "/sandbox",
                        templateUrl: 'story.new.html',
                        controller: 'storyNewCtrl'
                    })
                    .state('sandbox.multiple', {
                        url: "/sandbox/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        templateUrl: 'story.multiple.html',
                        controller: 'storyMultipleCtrl',
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        }
                    })
                    .state('sandbox.details', {
                        url: "/sandbox/{id:[0-9]+}",
                        templateUrl: 'story.details.html',
                        controller: 'storyDetailsCtrl'
                    })
                        .state('sandbox.details.tab', {
                            url: "/{tabId:.+}"
                        })

                .state('actor', {
                    templateUrl: 'openWindow/actor',
                    controller: 'actorsCtrl',
                    resolve:{
                        actors:['ActorService', function(ActorService){
                            return ActorService.list;
                        }]
                    }
                })
                    .state('actor.new', {
                        url: '/actor',
                        templateUrl: 'actor.new.html',
                        controller: 'actorNewCtrl'
                    })
                    .state('actor.multiple', {
                        url: "/actor/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        templateUrl: 'actor.multiple.html',
                        controller: 'actorMultipleCtrl',
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        }
                    })
                    .state('actor.details', {
                        url: "/actor/{id:[0-9]+}",
                        templateUrl: 'actor.details.html',
                        controller: 'actorDetailsCtrl'
                    })
                        .state('actor.details.tab', {
                            url: "/{tabId:.+}"
                        })

                .state('feature', {
                    templateUrl: 'openWindow/feature',
                    controller: 'featuresCtrl',
                    resolve:{
                        features:['FeatureService', function(FeatureService){
                            return FeatureService.list;
                        }]
                    }
                })
                    .state('feature.new', {
                        url: '/feature',
                        templateUrl: 'feature.new.html',
                        controller: 'featureNewCtrl'
                    })
                    .state('feature.multiple', {
                        url: "/feature/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        templateUrl: 'feature.multiple.html',
                        controller: 'featureMultipleCtrl',
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        }
                    })
                    .state('feature.details', {
                        url: "/feature/{id:[0-9]+}",
                        templateUrl: 'feature.details.html',
                        controller: 'featureDetailsCtrl'
                    })
                        .state('feature.details.tab', {
                            url: "/{tabId:.+}"
                        });
        }
    ])
    .config(['flowFactoryProvider', function (flowFactoryProvider) {
        flowFactoryProvider.defaults = {
            target: 'attachment/save',
            simultaneousUploads: 4
        };
        flowFactoryProvider.on('catchAll', function (event) {
            console.log('catchAll', arguments);
        });
    }])
    .factory('AuthInterceptor', ['$rootScope', '$q', 'AUTH_EVENTS', function ($rootScope, $q, AUTH_EVENTS) {
        return {
            responseError: function (response) {
                if (response.status === 401) {
                    $rootScope.$broadcast(AUTH_EVENTS.notAuthenticated,response);
                }
                if (response.status === 403) {
                    $rootScope.$broadcast(AUTH_EVENTS.notAuthorized,response);
                }
                if (response.status === 419 || response.status === 440) {
                    $rootScope.$broadcast(AUTH_EVENTS.sessionTimeout,response);
                }
                return $q.reject(response);
            }
        };
    }]).
    run(['Session', '$rootScope', '$timeout', '$state', '$modal', 'uiSelect2Config', function(Session, $rootScope, $timeout, $state, $modal, uiSelect2Config){
        Session.create();

        uiSelect2Config.minimumResultsForSearch = 6;

        //used to handle click with shortcut hotkeys
        $rootScope.hotkeyClick = function(event, hotkey) {
            if (hotkey.el && (hotkey.el.is( "a" ) || hotkey.el.is( "button" ))){
                event.preventDefault();
                $timeout(function(){
                    hotkey.el.click();
                });
            }
        };
        //To be able to track state in app
        $rootScope.$state = $state;

        var messages = {};
        $rootScope.initMessages = function(initMessages) {
            messages = initMessages;
        };
        $rootScope.message = function(code, args) {
            var text = messages[code] ? messages[code] : code;
            angular.forEach(args, function(arg, index) {
                var placeholderMatcher = new RegExp('\\{' + index + '\\}', 'g');
                text = text.replace(placeholderMatcher, arg);
            });
            return text;
        };

        $rootScope.editableMode = false;
        $rootScope.setEditableMode = function(editableMode) {
            $rootScope.editableMode = editableMode;
        };
        $rootScope.getEditableMode = function() {
            return $rootScope.editableMode;
        };

        $rootScope.confirm = function(options) {
            var callCallback = function() {
                if (options.args) {
                    options.callback.apply(options.callback, options.args);
                } else {
                    options.callback();
                }
            };
            if (options.condition !== false) {
                var modal = $modal.open({
                    templateUrl: 'confirm.modal.html',
                    size: 'sm',
                    controller: ["$scope", "$modalInstance", "hotkeys", function($scope, $modalInstance, hotkeys) {
                        $scope.message = options.message;
                        $scope.submit = function() {
                            callCallback();
                            $modalInstance.close(true);
                        };
                        // Required because there is not input so the form cannot be submitted by "return"
                        hotkeys.bindTo($scope) // to remove the hotkey when the scope is destroyed
                            .add({
                                combo: 'return',
                                callback: $scope.submit
                            });
                    }]
                });
                var callCloseCallback = function(confirmed) {
                    if (!confirmed && options.closeCallback) {
                        options.closeCallback();
                    }
                };
                modal.result.then(callCloseCallback, callCloseCallback);
            } else {
                callCallback();
            }
        };

        // TODO Change ugly hack
        $rootScope.serverUrl = icescrum.grailsServer;

        //to switch between grid / list view
        $rootScope.view = {
            asList:false
        };

        //store previous state
        $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState){
            $rootScope.previousState = fromState;
        });

    }])
    .constant('AUTH_EVENTS', {
        loginFailed: 'auth-login-failed',
        sessionTimeout: 'auth-session-timeout',
        notAuthenticated: 'auth-not-authenticated',
        notAuthorized: 'auth-not-authorized'
    })
    .constant('StoryStates', {
        1: {"value": "Suggested", "code": "suggested"},
        2: {"value": "Accepted", "code": "accepted"},
        3: {"value": "Estimated", "code": "estimated"},
        4: {"value": "Planned", "code": "planned"},
        5: {"value": "In progress", "code": "inprogress"},
        7: {"value": "Done", "code": "done"},
        '-1': {"value": "In the Icebox", "code": "icebox"}
    })
    .constant('StoryStatesByName', {
        "SUGGESTED": 1,
        "ACCEPTED": 2,
        "ESTIMATED": 3,
        "PLANNED": 4,
        "IN_PROGRESS": 5,
        "DONE": 6,
        "ICEBOX": -1
    })
    .constant('AcceptanceTestStatesByName', {
        "TOCHECK": 1,
        "FAILED": 5,
        "SUCCESS": 10
    })
    .constant('FeatureStates', {
        0: {"value": "todo.To do", "code": "wait"},
        1: {"value": "todo.In progress", "code": "inprogress"},
        2: {"value": "todo.Done", "code": "done"}
    })
    .constant('USER_ROLES', { // TODO consider deleting (used only for dev user role switch)
        PO_SM: 'PO_SM',
        PO: 'PO',
        SM: 'SM',
        TM: 'TM',
        SH: 'SH'
    });