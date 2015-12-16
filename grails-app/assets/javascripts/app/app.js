/*
 * Copyright (c) 2015 Kagilum SAS.
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

// Try to dectect as early as possible that the root misses as slash
// to trigger a redirect and lose as little time as possible
(function() {
    if (window.location.hash == '') {
        var fullPath = window.location.href;
        if (fullPath[fullPath.length - 1] != '/' && fullPath.indexOf('/?') == -1) {
            if (fullPath.indexOf('?') > -1) {
                fullPath = fullPath.replace('?', '/?');
            } else {
                fullPath = fullPath + '/'
            }
            window.location.replace(fullPath);
            throw new Error("Stopping page loading because a forward slash is missing, redirecting to the proper URL...");
        }
    }
})();

var isApp = angular.module('isApp', [
    'ngRoute',
    'ngAnimate',
    'ngSanitize',
    'controllers',
    'services',
    'filters',
    'directives',
    'ui.router',
    'ui.bootstrap',
    'ui.select',
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
    'as.sortable',
    'angular.atmosphere',
    'nvd3'
]);

isApp.config(['$stateProvider', '$httpProvider', '$urlRouterProvider',
        function ($stateProvider, $httpProvider, $urlRouterProvider) {
            $httpProvider.interceptors.push([
                '$injector',
                function ($injector) {
                    return $injector.get('AuthInterceptor');
                }
            ]);
            $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
            $urlRouterProvider.when('', '/');
            $stateProvider
                .state('root', {
                    url: '/',
                    controller: ['$state', function($state) {
                        var isInProject = window.location.pathname.indexOf('/p/') != -1;
                        $state.go(isInProject ? 'project' : 'home');
                    }]
                })
                .state('home', { // should not be acceded directly, called by 'root'
                    templateUrl: 'home.html',
                    controller: 'homeCtrl'
                })
                .state('userregister', {
                    url: "/user/register/:token",
                    params: { token: { value: null } }, // doesn't work currently but it should, see https://github.com/angular-ui/ui-router/pull/1032 & https://github.com/angular-ui/ui-router/issues/1652
                    onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                        var modal = $uibModal.open({
                            keyboard: false,
                            templateUrl: $rootScope.serverUrl + '/user/register',
                            controller: 'registerCtrl'
                        });
                        modal.result.then(
                            function(username) {
                                $state.transitionTo('root');
                                $rootScope.showAuthModal(username);
                            }, function() {
                                $state.transitionTo('root');
                            });
                    }]
                })
                .state('userretrieve', {
                    url: "/user/retrieve",
                    onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                        var modal = $uibModal.open({
                            templateUrl: $rootScope.serverUrl + '/user/retrieve',
                            size: 'sm',
                            controller: 'retrieveCtrl'
                        });
                        modal.result.then(
                            function(result) {
                                $state.transitionTo('root');
                            }, function() {
                                $state.transitionTo('root');
                            });
                    }]
                })
                .state('project', {  // should not be acceded directly, called by 'root'
                    templateUrl: 'openWindow/project',
                    controller: 'projectCtrl'
                })
                .state('newProject', {
                    url: "/project/new",
                    onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                        var modal = $uibModal.open({
                            keyboard: false,
                            templateUrl: $rootScope.serverUrl + "/project/add",
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
                .state('backlog', {
                    url: "/backlog",
                    templateUrl: 'openWindow/backlog',
                    controller: 'backlogCtrl',
                    resolve: {
                        backlogs: ['BacklogService', function(BacklogService) {
                            return BacklogService.list();
                        }],
                        stories: ['StoryService', 'backlogs', function(StoryService, backlogs) {
                            return StoryService.listByBacklog(backlogs[0]);
                        }]
                    }
                })
                    .state('backlog.new', {
                        url: "/new",
                        views: {
                            "details": {
                                templateUrl: 'story.new.html',
                                controller: 'storyNewCtrl'
                            }
                        }
                    })
                    .state('backlog.multiple', {
                        url: "/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        resolve: {
                            listId: ['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'story.multiple.html',
                                controller: 'storyMultipleCtrl'
                            }
                        }
                    })
                    .state('backlog.details', {
                        url: "/{id:int}",
                        resolve: {
                            //we add stories to wait for dynamic resolution from parent state
                            detailsStory: ['StoryService', '$stateParams', 'stories', function(StoryService, $stateParams, stories){
                                return StoryService.get($stateParams.id);
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'story.details.html',
                                controller: 'storyDetailsCtrl'
                            }
                        }
                    })
                        .state('backlog.details.tab', {
                            url: "/{tabId:.+}",
                            resolve: {
                                data: ['$stateParams', 'AcceptanceTestService', 'CommentService', 'TaskService', 'ActivityService', 'detailsStory', function($stateParams, AcceptanceTestService, CommentService, TaskService, ActivityService, detailsStory){
                                    if ($stateParams.tabId == 'tests') {
                                        return AcceptanceTestService.list(detailsStory);
                                    } else if($stateParams.tabId == 'tasks') {
                                        return TaskService.list(detailsStory);
                                    } else if($stateParams.tabId == 'comments') {
                                        return CommentService.list(detailsStory);
                                    } else if($stateParams.tabId == 'activities') {
                                        return ActivityService.activities(detailsStory, false);
                                    }
                                    return null;
                                }],
                                //we add data to wait for dynamic resolution - not used only for story.xxxx to be loaded
                                selected: ['data', 'detailsStory', function(data, detailsStory){
                                    return detailsStory;
                                }]
                            },
                            views: {
                                "details-tab": {
                                    templateUrl: function($stateParams) {
                                        var tpl;
                                        if ($stateParams.tabId == 'tests') {
                                            tpl = 'story.acceptanceTests.html';
                                        } else if($stateParams.tabId == 'tasks') {
                                            tpl = 'story.tasks.html';
                                        } else if($stateParams.tabId == 'comments') {
                                            tpl = 'comment.list.html';
                                        } else if($stateParams.tabId == 'activities') {
                                            tpl = 'activity.list.html';
                                        }
                                        return tpl;
                                    },
                                    controller: ['$scope', '$controller', '$stateParams', 'selected', function($scope, $controller, $stateParams, selected) {
                                        $scope.selected = selected;
                                        if($stateParams.tabId == 'activities') {
                                            $controller('activityCtrl', { $scope: $scope, selected: selected });
                                        }
                                    }]
                                }
                            }
                        })
                .state('feature', {
                    url: "/feature",
                    templateUrl: 'openWindow/feature',
                    controller: 'featuresCtrl',
                    resolve: {
                        features: ['FeatureService', function(FeatureService){
                            return FeatureService.list;
                        }]
                    }
                })
                    .state('feature.new', {
                        url: '/new',
                        views: {
                            "details": {
                                templateUrl: 'feature.new.html',
                                controller: 'featureNewCtrl'
                            }
                        }
                    })
                    .state('feature.multiple', {
                        url: "/{listId:[0-9]+(?:[\,][0-9]+)+}",
                        resolve: {
                            listId: ['$stateParams', function($stateParams){
                                return $stateParams.listId.split(',');
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'feature.multiple.html',
                                controller: 'featureMultipleCtrl'
                            }
                        }
                    })
                    .state('feature.details', {
                        url: "/{id:int}",
                        resolve: {
                            //we add features to wait for dynamic resolution from parent state
                            detailsFeature: ['FeatureService', '$stateParams', 'features', function(FeatureService, $stateParams, features){
                                return FeatureService.get($stateParams.id);
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'feature.details.html',
                                controller: 'featureDetailsCtrl'
                            }
                        }
                    })
                        .state('feature.details.tab', {
                            url: "/{tabId:.+}",
                            resolve: {
                                selected: ['StoryService', 'detailsFeature', function(StoryService, detailsFeature) {
                                    return StoryService.listByType(detailsFeature).then(function() {
                                        return detailsFeature;
                                    });
                                }]
                            },
                            views: {
                                "details-tab": {
                                    templateUrl: 'nested.stories.html',
                                    controller: ['$scope', 'selected', function($scope, selected) {
                                        $scope.selected = selected;
                                    }]
                                }
                            }
                        })
                .state('releasePlan', {
                    url: "/releasePlan",
                    templateUrl: 'openWindow/releasePlan',
                    controller: 'releasePlanCtrl',
                    resolve: {
                        project: ['Session', function(Session) {
                            return Session.getProjectPromise();
                        }],
                        releases: ['$q', 'ReleaseService', 'SprintService', 'project', function($q, ReleaseService, SprintService, project) {
                            return ReleaseService.list(project).then(function(releases) {            // Wait for releases
                                return $q.all(_.map(releases, SprintService.list)).then(function() { // Wait for sprints
                                    return releases;                                                 // Finally resolve the releases
                                });
                            });
                        }]
                    }
                })
                    .state('releasePlan.new', {
                        url: "/new",
                        views: {
                            "details": {
                                templateUrl: 'release.new.html',
                                controller: 'releaseNewCtrl'
                            }
                        }
                    })
                    .state('releasePlan.details', {
                        url: "/{id:int}",
                        resolve: {
                            detailsRelease: ['ReleaseService', '$stateParams', 'project', function(ReleaseService, $stateParams, project){
                                return ReleaseService.get($stateParams.id, project);
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'release.details.html',
                                controller: 'releaseDetailsCtrl'
                            }
                        }
                    })
                    .state('releasePlan.sprint', {
                        url: "/sprint"
                    })
                        .state('releasePlan.sprint.details', {
                            url: "/{id:int}",
                            resolve: {
                                detailsSprint: ['SprintService', '$stateParams', 'project', function(SprintService, $stateParams, project){
                                    return SprintService.get($stateParams.id, project);
                                }]
                            },
                            views: {
                                "details@releasePlan": {
                                    templateUrl: 'sprint.details.html',
                                    controller: 'sprintDetailsCtrl'
                                }
                            }
                        })
                        .state('releasePlan.sprint.new', {
                            url: "/new",
                            views: {
                                "details@releasePlan": {
                                    templateUrl: 'sprint.new.html',
                                    controller: 'sprintNewCtrl'
                                }
                            }
                        })
                .state('sprintPlan', {
                    url: "/sprintPlan/{id:int}",
                    params: {
                        id: {value: null, squash: true}
                    },
                    templateUrl: 'openWindow/sprintPlan',
                    controller: 'sprintPlanCtrl',
                    resolve: {
                        project: ['Session', function(Session) {
                            return Session.getProjectPromise();
                        }],
                        sprint: ['$stateParams', '$q', 'SprintService', 'StoryService', 'TaskService', 'project', function($stateParams, $q, SprintService, StoryService, TaskService, project) {
                            var promise = !$stateParams.id ? SprintService.getCurrentOrNextSprint(project) : SprintService.get($stateParams.id, project);
                            return promise.then(function(sprint) {
                                return StoryService.listByType(sprint).then(function(stories) {
                                    return sprint;
                                });
                            })
                        }],
                        tasks: ['TaskService', 'sprint', function(TaskService, sprint) {
                            return TaskService.list(sprint);
                        }]
                    }
                })
                    .state('sprintPlan.details', {
                        url: "/details",
                        resolve: {
                            detailsSprint: ['sprint', function(sprint) {
                                return sprint;
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'sprint.details.html',
                                controller: 'sprintDetailsCtrl'
                            }
                        }
                    })
                    .state('sprintPlan.task', {
                        url: "/task"
                    })
                        .state('sprintPlan.task.new', {
                            url: "/new",
                            params: {
                                taskTemplate: null
                            },
                            views: {
                                "details@sprintPlan": {
                                    templateUrl: 'task.new.html',
                                    controller: 'taskNewCtrl'
                                }
                            }
                        })
                        .state('sprintPlan.task.details', {
                            url: "/{taskId:int}",
                            resolve: {
                                detailsTask: ['$stateParams', 'tasks', function($stateParams, tasks) {
                                    return _.find(tasks, {id: $stateParams.taskId})
                                }]
                            },
                            views: {
                                "details@sprintPlan": {
                                    templateUrl: 'task.details.html',
                                    controller: 'taskDetailsCtrl'
                                }
                            }
                        })
                            .state('sprintPlan.task.details.tab', {
                                url: "/{tabId:.+}",
                                resolve: {
                                    data: ['$stateParams', 'ActivityService', 'CommentService', 'detailsTask', function($stateParams, ActivityService, CommentService, detailsTask) {
                                        if ($stateParams.tabId == 'comments') {
                                            return CommentService.list(detailsTask);
                                        } else if($stateParams.tabId == 'activities') {
                                            return ActivityService.activities(detailsTask, false);
                                        }
                                        return null;
                                    }],
                                    //we add data to wait for dynamic resolution - not used only for story.xxxx to be loaded
                                    selected: ['data', 'detailsTask', function(data, detailsTask) {
                                        return detailsTask;
                                    }]
                                },
                                views: {
                                    "details-tab": {
                                        templateUrl: function($stateParams) {
                                            var tpl;
                                            if ($stateParams.tabId == 'comments') {
                                                tpl = 'comment.list.html';
                                            } else if ($stateParams.tabId == 'activities') {
                                                tpl = 'activity.list.html';
                                            }
                                            return tpl;
                                        },
                                        controller: ['$scope', '$controller', '$stateParams', 'selected', function($scope, $controller, $stateParams, selected) {
                                            $scope.selected = selected;
                                            if($stateParams.tabId == 'activities') {
                                                $controller('activityCtrl', { $scope: $scope, selected: selected });
                                            }
                                        }]
                                    }
                                }
                            })
        }
    ])
    .config(['flowFactoryProvider', function (flowFactoryProvider) {
        flowFactoryProvider.defaults = {
            target: 'attachment/save',
            //only one at the time => prevent staleObjectException
            simultaneousUploads: 1
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
    .config(['$uibTooltipProvider', function ($uibTooltipProvider) {
        $uibTooltipProvider.options({appendToBody: true});
    }])
    .config(['uibDatepickerConfig', function (uibDatepickerConfig) {
        angular.extend(uibDatepickerConfig, {
            startingDay: 1 // TODO make it i18n
        });
    }])
    .config(['uibDatepickerPopupConfig', function (uibDatepickerPopupConfig) {
        angular.extend(uibDatepickerPopupConfig, {
            showButtonBar: false,
            datepickerPopup: 'dd/MM/yyyy' // TODO make it i18n
        });
    }])
    .config(['uiSelectConfig', function(uiSelectConfig) {
        uiSelectConfig.theme = 'select2';
        uiSelectConfig.appendToBody = true;
        uiSelectConfig.searchEnabled = false;
    }])
    .config(['$animateProvider', function($animateProvider) {
        $animateProvider.classNameFilter(/ng-animate-enabled/);
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
    run(['Session', '$rootScope', '$timeout', '$state', '$uibModal', '$filter', 'notifications', function(Session, $rootScope, $timeout, $state, $uibModal, $filter, notifications){

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
        $rootScope.notifyWarning = function(code, options) {
            return notifications.warning('', $rootScope.message(code), options);
        };

        $rootScope.inEditingMode = false;
        $rootScope.setInEditingMode = function(inEditingMode) {
            $rootScope.inEditingMode = inEditingMode;
        };
        $rootScope.isInEditingMode = function() {
            return $rootScope.inEditingMode;
        };

        $rootScope.resetFormValidation = function(form) {
            if (form) {
                form.$setPristine();
                form.$setUntouched();
            }
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
                var modal = $uibModal.open({
                    templateUrl: 'confirm.modal.html',
                    size: 'sm',
                    controller: ["$scope", "hotkeys", function($scope, hotkeys) {
                        $scope.message = options.message;
                        $scope.submit = function() {
                            callCallback();
                            $scope.$close(true);
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
            $uibModal.open({
                templateUrl: 'copy.html',
                size: 'sm',
                controller: ["$scope", 'hotkeys', function($scope, hotkeys) {
                    $scope.title = title;
                    $scope.value = $filter('permalink')(value); // change that if you want to use showCopyModal to copy other things than permalinks
                    hotkeys
                        .bindTo($scope)
                        .add({
                            combo: ['mod+c', 'mod+x'],
                            allowIn: ['INPUT'],
                            callback: $scope.$close
                        });
                }]
            });
        };

        $rootScope.immutableAddDaysToDate = function(date, days) {
            var newDate = new Date(date);
            newDate.setDate(date.getDate() + days);
            return newDate;
        };
        $rootScope.immutableAddMonthsToDate = function(date, months) {
            var newDate = new Date(date);
            newDate.setMonth(date.getMonth() + months);
            return newDate;
        };

        $rootScope.showAuthModal = function(username) {
            var childScope = $rootScope.$new();
            if (username) {
                childScope.username = username;
            }
            $uibModal.open({
                keyboard: false,
                templateUrl: $rootScope.serverUrl + '/login/auth',
                controller: 'loginCtrl',
                scope: childScope,
                size: 'sm'
            });
        };

        $rootScope.durationBetweenDates = function(startDateString, endDateString) {
            var duration = new Date(endDateString) - new Date(startDateString);
            return Math.floor(duration / (1000 * 3600 * 24)) + 1;
        };

        $rootScope.openProject = function (project) {
            document.location = $rootScope.serverUrl + '/p/' + project.pkey + '/';
        };

        $rootScope.openDatepicker = function($event, holder) {
            $event.preventDefault();
            $event.stopPropagation();
            if (holder) {
                holder.opened = true;
            }
        };

        // TODO Change ugly hack
        $rootScope.serverUrl = icescrum.grailsServer;

        $rootScope.integerSuite = [];
        for (var i = 0; i < 100; i++) {
            $rootScope.integerSuite.push(i);
        }
        $rootScope.integerSuiteNullable = ['?'].concat($rootScope.integerSuite);
        $rootScope.fibonacciSuite = [0, 1, 2, 3, 5, 8, 13, 21, 34];
        $rootScope.fibonacciSuiteNullable = ['?'].concat($rootScope.fibonacciSuite);

        $rootScope.app = {
            asList:false,
            loading: true,
            loadingPercent: 0,
            isFullScreen: false
        };

        // To be able to track state in views
        $rootScope.$state = $state;

        var messages = {};
        $rootScope.initMessages = function(initMessages) {
            messages = initMessages;
        };

        $rootScope.applicationMenus = [];
        $rootScope.initApplicationMenus = function(initMenus) {
            $rootScope.applicationMenus = initMenus;
            var menusByVisibility = _.groupBy(initMenus, 'visible');
            $rootScope.menus = {
                visible: _.sortBy(menusByVisibility[true], 'position'),
                hidden: _.sortBy(menusByVisibility[false], 'position')
            }
        };
    }])
    .constant('SERVER_ERRORS', {
        loginFailed: 'auth-login-failed',
        sessionTimeout: 'auth-session-timeout',
        notAuthenticated: 'auth-not-authenticated',
        notAuthorized: 'auth-not-authorized',
        clientError: 'client-error',
        serverError: 'server-error'
    })
    .constant('StoryCodesByState', {
        1: "suggested",
        2: "accepted",
        3: "estimated",
        4: "planned",
        5: "inprogress",
        7: "done",
        '-1': "icebox"
    })
    .constant('StoryStatesByName', {
        "SUGGESTED": 1,
        "ACCEPTED": 2,
        "ESTIMATED": 3,
        "PLANNED": 4,
        "IN_PROGRESS": 5,
        "DONE": 7,
        "ICEBOX": -1
    })
    .constant('TaskStatesByName', {
        "WAIT": 0,
        "IN_PROGRESS": 1,
        "DONE": 2
    })
    .constant('AcceptanceTestStatesByName', {
        "TOCHECK": 1,
        "FAILED": 5,
        "SUCCESS": 10
    })
    .constant('SprintStatesByName', {
        "WAIT": 1,
        "IN_PROGRESS": 2,
        "DONE": 3
    })
    .constant('ReleaseStatesByName', {
        "WAIT": 1,
        "IN_PROGRESS": 2,
        "DONE": 3
    })
    .constant('MoodFeelingsByName', {
        "GOOD": 1,
        "MEH": 2,
        "BAD": 3
    })
    .constant('USER_ROLES', { // TODO consider deleting (used only for dev user role switch)
        PO_SM: 'PO_SM',
        PO: 'PO',
        SM: 'SM',
        TM: 'TM',
        SH: 'SH'
    })
    .constant('IceScrumEventType', {
        CREATE: 'CREATE',
        UPDATE: 'UPDATE',
        DELETE: 'DELETE'
    });


//TODO should be move
String.prototype.formatLine = function(remove) {
    remove = remove ? "" : "<br/>";
    return this.replace(/\r\n/g, remove).replace(/\n/g, remove).replace(/"/g, '\\"');
};