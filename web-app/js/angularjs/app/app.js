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
    'cfp.hotkeys',
    'colorpicker.module'
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
                .state('sandbox', {
                    url: '/sandbox',
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
                    .state('sandbox.multiple', {
                        url: "/{listId:[0-9]+[\,][0-9]+}",
                        templateUrl: 'story.multiple.html',
                        controller: 'storyMultipleCtrl',
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        }
                    })
                    .state('sandbox.details', {
                        url: "/{id:[0-9]+}",
                        templateUrl: 'story.details.html',
                        controller: 'storyCtrl',
                        resolve:{
                            selected:['StoryService', '$stateParams', function(StoryService, $stateParams){
                                return StoryService.get($stateParams.id);
                            }]
                        }
                    })
                        .state('sandbox.details.tab', {
                            url: "/{tabId:.+}"
                        })
                .state('actor', {
                    url: '/actor',
                    templateUrl: 'openWindow/actor',
                    controller: 'actorsCtrl',
                    resolve:{
                        actors:['ActorService', function(ActorService){
                            return ActorService.list;
                        }]
                    }
                })
                    .state('actor.multiple', {
                        url: "/{listId:[0-9]+[\,][0-9]+}",
                        templateUrl: 'actor.multiple.html',
                        controller: 'actorMultipleCtrl',
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        }
                    })
                    .state('actor.details', {
                        url: "/{id:[0-9]+}",
                        templateUrl: 'actor.details.html',
                        controller: 'actorCtrl',
                        resolve:{
                            selected:['ActorService', '$stateParams', function(ActorService, $stateParams){
                                return ActorService.get($stateParams.id);
                            }]
                        }
                    })
                        .state('actor.details.tab', {
                            url: "/{tabId:.+}"
                        })
                .state('feature', {
                    url: '/feature',
                    templateUrl: 'openWindow/feature',
                    controller: 'featuresCtrl',
                    resolve:{
                        features:['FeatureService', function(FeatureService){
                            return FeatureService.list;
                        }]
                    }
                })
                    .state('feature.multiple', {
                        url: "/{listId:[0-9]+[\,][0-9]+}",
                        templateUrl: 'feature.multiple.html',
                        controller: 'featureMultipleCtrl',
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        }
                    })
                    .state('feature.details', {
                        url: "/{id:[0-9]+}",
                        templateUrl: 'feature.details.html',
                        controller: 'featureCtrl',
                        resolve:{
                            selected:['FeatureService', '$stateParams', function(FeatureService, $stateParams){
                                return FeatureService.get($stateParams.id);
                            }]
                        }
                    })
                        .state('feature.details.tab', {
                            url: "/{tabId:.+}"
                        });
        }
    ])
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
    run(['Session', '$rootScope', '$timeout', '$state', function(Session, $rootScope, $timeout, $state){
        Session.create();
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

        //to switch between grid / list view
        $rootScope.view = {
            asList:true
        };
    }])
    .constant('AUTH_EVENTS', {
        loginSuccess: 'auth-login-success',
        loginFailed: 'auth-login-failed',
        logoutSuccess: 'auth-logout-success',
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