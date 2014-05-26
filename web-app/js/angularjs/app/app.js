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
    'ui.bootstrap',
    'ui.select2',
    'cfp.hotkeys'
]);

isApp
    .config(['$stateProvider', '$httpProvider',
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
                        filterList: { state:1 }
                    },
                    resolve:{
                        stories:function(StoryService){
                            return StoryService.list;
                        }
                    }
                })
                .state('sandbox.details', {
                    url: "/:id",
                    templateUrl: 'story.details.html',
                    controller: 'storyCtrl',
                    resolve:{
                        StoryService:'StoryService',
                        selected:function(StoryService, $stateParams){
                            return StoryService.get($stateParams.id);
                        }
                    }
                })
                .state('actor', {
                    url: '/actor',
                    templateUrl: 'openWindow/actor',
                    controller: 'actorsCtrl',
                    resolve:{
                        actors:function(ActorService){
                            return ActorService.list;
                        }
                    }
                })
                .state('actor.details', {
                    url: "/:id",
                    templateUrl: 'actor.details.html',
                    controller: 'actorCtrl',
                    resolve:{
                        ActorService:'ActorService',
                        selected:function(ActorService, $stateParams){
                            return ActorService.get($stateParams.id);
                        }
                    }
                })
                .state('feature', {
                    url: '/feature',
                    templateUrl: 'openWindow/feature',
                    controller: 'featuresCtrl',
                    resolve:{
                        features:function(FeatureService){
                            return FeatureService.list;
                        }
                    }
                })
                .state('feature.details', {
                    url: "/:id",
                    templateUrl: 'feature.details.html',
                    controller: 'featureCtrl',
                    resolve:{
                        FeatureService:'FeatureService',
                        selected:function(FeatureService, $stateParams){
                            return FeatureService.get($stateParams.id);
                        }
                    }
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
    run(['Session', function(Session){
        Session.create();
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
    .constant('USER_ROLES', { // TODO consider deleting (used only for dev user role switch)
        PO_SM: 'PO_SM',
        PO: 'PO',
        SM: 'SM',
        TM: 'TM',
        SH: 'SH'
    });