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
    'ui.bootstrap',
    'ui.select2',
    'monospaced.elastic',
    'cfp.hotkeys',
    'colorpicker.module',
    'mgo-angular-wizard',
    'ngPasswordStrength',
    'flow',
    'ngPDFViewer',
    'remoteValidation',
    'FBAngular',
    'angular-extended-notifications',
    'htmlSortable'
]);

isApp.config(['$stateProvider', '$httpProvider',
        function ($stateProvider, $httpProvider, $animateProvider) {
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
                .state('userregister', {
                    url: "/user/register",
                    onEnter: ["$state", "$modal", function($state, $modal) {
                        var modal = $modal.open({
                            //todo move to angular 1.3 to inject $scope and use $scope.serverUrl
                            templateUrl: icescrum.grailsServer + '/'+ 'user/register',
                            size: 'md',
                            controller: 'registerCtrl'
                        });
                        modal.result.then(
                            function(result) {
                                $state.transitionTo('root');
                            }, function(){
                                $state.transitionTo('root');
                            });
                    }]
                })
                .state('userretrieve', {
                    url: "/user/retrieve",
                    onEnter: ["$state", "$modal", function($state, $modal) {
                        var modal = $modal.open({
                            //todo move to angular 1.3 to inject $scope and use $scope.serverUrl
                            templateUrl: icescrum.grailsServer + '/'+ 'user/retrieve',
                            size: 'sm',
                            controller: 'retrieveCtrl'
                        });
                        modal.result.then(
                            function(result) {
                                $state.transitionTo('root');
                            }, function(){
                                $state.transitionTo('root');
                            });
                    }]
                })
                .state('project', {
                    url: '/project',
                    controller: 'projectCtrl'
                })
                .state('project.new', {
                    url: "/new",
                    onEnter: ["$state", "$modal", function($state, $modal) {
                        var modal = $modal.open({
                            //todo move to angular 1.3 to inject $scope and use $scope.serverUrl
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
                    url: "/sandbox",
                    templateUrl: 'openWindow/sandbox',
                    controller: 'sandboxCtrl',
                    data: {
                        filterListParams: {
                            state: 1
                        }
                    },
                    resolve:{
                        stories:['StoryService', function(StoryService){
                            return StoryService.list;
                        }]
                    }
                })
                    .state('sandbox.new', {
                        url: "/new",
                        data:{
                            stack: 2
                        },
                        views:{
                            "details@sandbox": {
                                templateUrl: 'story.new.html',
                                controller: 'storyNewCtrl'
                            }
                        }
                    })
                    .state('sandbox.multiple', {
                        url: "/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        data:{
                            stack: 2
                        },
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        },
                        views:{
                            "details@sandbox": {
                                templateUrl: 'story.multiple.html',
                                controller: 'storyMultipleCtrl'
                            }
                        }
                    })
                    .state('sandbox.details', {
                        url: "/{id:[0-9]+}",
                        data:{
                            stack: 2
                        },
                        views:{
                            "details@sandbox": {
                                templateUrl: 'story.details.html',
                                controller: 'storyDetailsCtrl'
                            }
                        }
                    })
                        .state('sandbox.details.tab', {
                            url: "/{tabId:.+}",
                            data:{
                                stack: 3
                            },
                            views:{
                                "details-list@sandbox": {
                                    templateUrl: function($stateParams){
                                        var tpl;
                                        if ($stateParams.tabId == 'tests')
                                            tpl = 'story.acceptanceTests.html';
                                        else if($stateParams.tabId == 'tasks')
                                            tpl = 'story.tasks.html';
                                        else if($stateParams.tabId == 'comments')
                                            tpl = 'comment.list.html';
                                        return tpl;
                                    },
                                    controllerProvider: function($stateParams){
                                        var tpl;
                                        if ($stateParams.tabId == 'tests')
                                            tpl = 'Tests';
                                        else if($stateParams.tabId == 'tasks')
                                            tpl = 'Tasks';
                                        else if($stateParams.tabId == 'comments')
                                            tpl = 'Comments';
                                        return 'storyDetails'+tpl+'Ctrl';
                                    }
                                }
                            }
                        })

                .state('actor', {
                    url: "/actor",
                    templateUrl: 'openWindow/actor',
                    controller: 'actorsCtrl',
                    resolve:{
                        actors:['ActorService', function(ActorService){
                            return ActorService.list;
                        }]
                    }
                })
                    .state('actor.new', {
                        url: '/new',
                        data:{
                            stack: 2
                        },
                        views:{
                            "details@actor": {
                                templateUrl: 'actor.new.html',
                                controller: 'actorNewCtrl'
                            }
                        }

                    })
                    .state('actor.multiple', {
                        url: "/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        data:{
                            stack: 2
                        },
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        },
                        views:{
                            "details@actor": {
                                templateUrl: 'actor.multiple.html',
                                controller: 'actorMultipleCtrl'
                            }
                        }
                    })
                    .state('actor.details', {
                        url: "/{id:[0-9]+}",
                        data:{
                            stack: 2
                        },
                        views:{
                            "details@actor": {
                                templateUrl: 'actor.details.html',
                                controller: 'actorDetailsCtrl'
                            }
                        }

                    })
                        .state('actor.details.tab', {
                            url: "/{tabId:.+}",
                            data:{
                                stack: 3
                            },
                            views:{
                                "details-list@actor": {
                                    templateUrl: 'nested.stories.html',
                                    controller:'actorDetailsStoryCtrl'
                                }
                            }
                        })

                .state('feature', {
                    url: "/feature",
                    templateUrl: 'openWindow/feature',
                    controller: 'featuresCtrl',
                    resolve:{
                        features:['FeatureService', function(FeatureService){
                            return FeatureService.list;
                        }]
                    }
                })
                    .state('feature.new', {
                        url: '/new',
                        data:{
                            stack: 2
                        },
                        views: {
                            "details@feature": {
                                templateUrl: 'feature.new.html',
                                controller: 'featureNewCtrl'
                            }
                        }
                    })
                    .state('feature.multiple', {
                        url: "/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        data:{
                            stack: 2
                        },
                        resolve:{
                            listId:['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        },
                        views: {
                            "details@feature": {
                                templateUrl: 'feature.multiple.html',
                                controller: 'featureMultipleCtrl'
                            }
                        }
                    })
                    .state('feature.details', {
                        url: "/{id:[0-9]+}",
                        data:{
                            stack: 2
                        },
                        views:{
                            "details@feature": {
                                templateUrl: 'feature.details.html',
                                controller: 'featureDetailsCtrl'
                            }
                        }
                    })
                        .state('feature.details.tab', {
                            url: "/{tabId:.+}",
                            data:{
                                stack: 3
                            },
                            views:{
                                "details-list@feature": {
                                    templateUrl: 'nested.stories.html',
                                    controller:'featureDetailsStoryCtrl'
                                }
                            }
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
    .config(['notificationsProvider', function (notificationsProvider) {
        notificationsProvider.setDefaults({
            faIcons: true,
            closeOnRouteChange: 'state',
            duration: 4500
        });
    }])
    .factory('AuthInterceptor', ['$rootScope', '$q', 'SERVER_ERRORS', function ($rootScope, $q, SERVER_ERRORS) {
        return {
            responseError: function(response) {
                if (response.status === 401) {
                    $rootScope.$broadcast(SERVER_ERRORS.notAuthenticated, response);
                } else if (response.status === 403) {
                    $rootScope.$broadcast(SERVER_ERRORS.notAuthorized, response);
                } else if (response.status === 419 || response.status === 440) {
                    $rootScope.$broadcast(SERVER_ERRORS.sessionTimeout, response);
                } else if (response.status > 399 && response.status <= 499) {
                    $rootScope.$broadcast(SERVER_ERRORS.clientError, response);
                } else if (response.status > 499) {
                    $rootScope.$broadcast(SERVER_ERRORS.serverError, response);
                }
                return $q.reject(response);
            }
        };
    }]).
    run(['Session', '$rootScope', '$timeout', '$state', '$modal', 'uiSelect2Config', 'notifications', 'CONTENT_LOADED', function(Session, $rootScope, $timeout, $state, $modal, uiSelect2Config, notifications, CONTENT_LOADED){

        $rootScope.$watch('$viewContentLoaded', function() {
            $timeout(function() {
                $rootScope.$broadcast(CONTENT_LOADED);
            }, 500)
        });

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

        var $download;
        $rootScope.downloadFile = function (url) {
            if ($download) {
                $download.attr('src', url);
            } else {
                $download = $('<iframe>', { id: 'idown', src: url }).hide().appendTo('body');
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
        $rootScope.notifySuccess = function(code, options) {
            return notifications.success('', $rootScope.message(code), options);
        };

        $rootScope.notifyError = function(code, options) {
            return notifications.error('', $rootScope.message(code), options);
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
                        hotkeys.bindTo($scope).add({
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

        $rootScope.showCopyModal = function(title, value) {
            $modal.open({
                templateUrl: 'copy.html',
                size: 'sm',
                controller: ["$scope", "$modalInstance", 'hotkeys', function($scope, $modalInstance, hotkeys) {
                    $scope.title = title;
                    $scope.value = value;
                    hotkeys
                        .bindTo($scope)
                        .add({
                            combo: 'mod+c',
                            allowIn: ['INPUT'],
                            callback: $modalInstance.close
                        });
                }]
            });
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

        $(document).on('click', '.stacks.three-stacks > div, .stacks.four-stacks > div', function(event){
            if(angular.element(event.target).parent('a').length > 0){
                return false;
            }
            var $this = $(this);
            if($this.parent().hasClass('three-stacks')){
                if($this.index() == 0){
                    $state.go('^.');
                }
            } else {
                //TODO need to be changed when we will have new subview
                if($this.index() == 0){
                    $state.go('^');
                }
                if($this.index() == 1){
                    $state.go('^');
                }
            }
        });

    }])
    .constant('SERVER_ERRORS', {
        loginFailed: 'auth-login-failed',
        sessionTimeout: 'auth-session-timeout',
        notAuthenticated: 'auth-not-authenticated',
        notAuthorized: 'auth-not-authorized',
        clientError: 'client-error',
        serverError: 'server-error'
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
    })
    .constant('CONTENT_LOADED', 'loadingFinished');