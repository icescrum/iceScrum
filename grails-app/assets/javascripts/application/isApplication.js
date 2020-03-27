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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */
var isApplication = angular.module('isApplication', [
        'isCore',
        'ngRoute',
        'ngAnimate',
        'ngSanitize',
        'controllers',
        'services',
        'filters',
        'directives',
        'ui.router.stateHelper',
        'ui.bootstrap',
        'ui.select',
        'cfp.hotkeys',
        'colorpicker.module',
        'mgo-angular-wizard',
        'ngPasswordStrength',
        'flow',
        'ngPDFViewer',
        'remoteValidation',
        'FBAngular',
        'angular-notifications',
        'as.sortable',
        'angular.atmosphere',
        'nvd3',
        'ngStorage',
        'ui.bootstrap-slider',
        'matchMedia',
        'satellizer',
        'angular.qserial'
    ].concat(isSettings.plugins)
)
    .config(['$httpProvider', function($httpProvider) {
        $httpProvider.interceptors.push('ErrorInterceptor');
        $httpProvider.interceptors.push('SubmittingInterceptor');
        $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    }])
    .config(['$compileProvider', function($compileProvider) {
        $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|tel|file|blob|smb|skype):/)
    }])
    .config(['stateHelperProvider', '$urlRouterProvider', '$stateProvider', 'isStateProvider', function(stateHelperProvider, $urlRouterProvider, $stateProvider, isStateProvider) {
        $urlRouterProvider.when('', '/');
        stateHelperProvider
            .state({
                name: 'root',
                url: '/?redirectTo',
                controller: ['$state', 'Session', function($state, Session) {
                    // Restore _HASH_ => #
                    if ($state.params.redirectTo) {
                        $state.params.redirectTo = $state.params.redirectTo.replace('_HASH_', '#');
                    }
                    $state.go(Session.defaultView, $state.params, {location: 'replace'});
                }]
            })
            // No workspace
            .state({
                name: 'home', // Should not be acceded directly, called by 'root'
                controller: 'homeCtrl',
                params: {redirectTo: null},
                templateUrl: 'ui/window/home'
            })
            .state({
                name: 'userregister',
                url: "/user/register/:token",
                params: {token: {value: null}}, // Doesn't work currently but it should, see https://github.com/angular-ui/ui-router/pull/1032 & https://github.com/angular-ui/ui-router/issues/1652
                onEnter: ['$rootScope', '$state', '$stateParams', '$uibModal', function($rootScope, $state, $stateParams, $uibModal) {
                    if ($stateParams.token) {
                        $uibModal.open({
                            keyboard: false,
                            backdrop: 'static',
                            templateUrl: 'user.invitation.html',
                            controller: 'userInvitationCtrl'
                        }).result.then(function(continuing) {
                            if (!continuing) {
                                $state.transitionTo('root');
                            }
                        }, function() {
                            $state.transitionTo('root');
                        });
                    } else {
                        $state.transitionTo('root');
                    }
                }]
            })
            .state({
                name: 'userretrieve',
                url: "/user/retrieve",
                onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                    $uibModal.open({
                        templateUrl: $rootScope.serverUrl + '/user/retrieve',
                        size: 'sm',
                        controller: 'retrieveCtrl'
                    }).result.then(function() {
                        $state.transitionTo('root');
                    }, function() {
                        $state.transitionTo('root');
                    });
                }]
            })
            .state({
                name: 'new',
                url: "/new",
                onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                    var callback = function(type) {
                        if (type === undefined || type === false) {
                            $state.transitionTo('root');
                        }
                    };
                    $uibModal.open({
                        keyboard: false,
                        backdrop: 'static',
                        templateUrl: $rootScope.serverUrl + "/add",
                        size: 'md2',
                        controller: 'newCtrl'
                    }).result.then(callback, callback);
                }]
            })
            // Project workspace
            .state({
                name: 'project',
                url: '/project',
                templateUrl: 'ui/window/project',
                resolve: {
                    project: ['Session', function(Session) {
                        return Session.getWorkspace();
                    }],
                    window: ['WindowService', 'project', function(WindowService, project) {
                        return WindowService.get('project', project);
                    }]
                },
                controller: 'dashboardCtrl'
            })
            .state({
                name: 'newProject',
                url: "/project/new",
                onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                    $uibModal.open({
                        keyboard: false,
                        backdrop: 'static',
                        templateUrl: $rootScope.serverUrl + "/project/add",
                        size: 'lg',
                        resolve: {
                            manualSave: false,
                            projectTemplate: null,
                            lastStepButtonLabel: false
                        },
                        controller: 'newProjectCtrl'
                    }).result.then(function() {
                        $state.transitionTo('root');
                    }, function() {
                        $state.transitionTo('root');
                    });
                }]
            })
            .state({
                name: 'backlog',
                url: "/backlog",
                templateUrl: 'ui/window/backlog',
                controller: 'backlogCtrl',
                resolve: {
                    project: ['Session', function(Session) {
                        return Session.getWorkspace();
                    }],
                    backlogs: ['BacklogService', 'project', function(BacklogService, project) {
                        return BacklogService.list(project);
                    }],
                    window: ['WindowService', 'project', function(WindowService, project) {
                        return WindowService.get('backlog', project);
                    }]
                },
                children: [
                    {
                        name: 'multiple',
                        url: "/:pinnedElementId,:elementId",
                        children: [isStateProvider.getBacklogStoryState()]
                    },
                    {
                        name: 'backlog',
                        url: "/:elementId",
                        resolve: {
                            backlog: ['$stateParams', 'backlogs', function($stateParams, backlogs) {
                                return _.find(backlogs, {code: $stateParams.elementId});
                            }]
                        },
                        children: [
                            isStateProvider.getBacklogDetailsState("@backlog"),
                            isStateProvider.getBacklogStoryState()
                        ]
                    }
                ]
            })
            .state({
                name: 'feature',
                url: "/feature",
                templateUrl: 'ui/window/feature',
                controller: 'featuresCtrl',
                resolve: {
                    project: ['Session', function(Session) {
                        return Session.getWorkspace();
                    }],
                    features: ['FeatureService', 'project', function(FeatureService, project) {
                        return FeatureService.list(project);
                    }]
                },
                children: [
                    isStateProvider.getFeatureNewState(),
                    {
                        name: 'multiple',
                        url: "/{featureListId:[0-9]+(?:[\,][0-9]+)+}",
                        resolve: {
                            featureListId: ['$stateParams', function($stateParams) {
                                return $stateParams.featureListId.split(',');
                            }]
                        },
                        views: {
                            "details": {
                                templateUrl: 'feature.multiple.html',
                                controller: 'featureMultipleCtrl'
                            }
                        }
                    },
                    isStateProvider.getFeatureDetailsState('@feature')
                ]
            })
            .state({
                name: 'planning',
                url: "/planning",
                templateUrl: 'ui/window/planning',
                controller: 'planningCtrl',
                resolve: {
                    project: ['Session', function(Session) {
                        return Session.getWorkspace();
                    }],
                    releases: ['$q', 'ReleaseService', 'SprintService', 'project', function($q, ReleaseService, SprintService, project) {
                        return ReleaseService.list(project).then(function() {                            // Wait for releases
                            return $q.all(_.map(project.releases, SprintService.list)).then(function() { // Wait for sprints
                                return project.releases;                                                 // Finally resolve the releases
                            });
                        });
                    }]
                },
                children: [
                    {
                        name: 'new',
                        url: "/new",
                        data: {
                            authorizedState: function(Session) {
                                return Session.poOrSm();
                            }
                        },
                        views: {
                            "details": {
                                templateUrl: 'release.new.html',
                                controller: 'releaseNewCtrl'
                            }
                        }
                    },
                    {
                        name: 'release',
                        url: "/{releaseId:int}",
                        resolve: {
                            detailsRelease: ['$stateParams', 'releases', function($stateParams, releases) {
                                return _.find(releases, {id: $stateParams.releaseId})
                            }],
                            sprints: ['detailsRelease', function(detailsRelease) {
                                return detailsRelease.sprints;
                            }]
                        },
                        children: [
                            isStateProvider.getReleaseDetailsState('@planning'),
                            {
                                name: 'story',
                                url: "/story",
                                children: [isStateProvider.getStoryDetailsState('@planning.release')]
                            },
                            {
                                name: 'sprint',
                                url: "/sprint",
                                children: [
                                    {
                                        name: 'new',
                                        url: "/new",
                                        data: {
                                            authorizedState: function(Session) {
                                                return Session.poOrSm();
                                            }
                                        },
                                        views: {
                                            "details@planning": {
                                                templateUrl: 'sprint.new.html',
                                                controller: 'sprintNewCtrl'
                                            }
                                        }
                                    },
                                    {
                                        name: 'withId',
                                        url: "/{sprintId:int}",
                                        resolve: {
                                            detailsSprint: ['$stateParams', 'detailsRelease', function($stateParams, detailsRelease) {
                                                return _.find(detailsRelease.sprints, {id: $stateParams.sprintId});
                                            }],
                                            sprint: ['detailsSprint', function(detailsSprint) {
                                                return detailsSprint;
                                            }]
                                        },
                                        children: [
                                            isStateProvider.getSprintDetailsState('@planning'),
                                            {
                                                name: 'story',
                                                url: "/story",
                                                children: [isStateProvider.getStoryDetailsState('@planning.release.sprint.withId')]
                                            }
                                        ]
                                    },
                                    {
                                        name: 'multiple',
                                        url: "/{sprintListId:[0-9]+(?:[\,][0-9]+)+}",
                                        children: [
                                            {
                                                name: 'details',
                                                url: "/details",
                                                views: {
                                                    "details@planning": {
                                                        templateUrl: 'sprint.multiple.html',
                                                        controller: 'sprintMultipleCtrl'
                                                    }
                                                }
                                            },
                                            {
                                                name: 'story',
                                                url: "/story",
                                                children: [isStateProvider.getStoryDetailsState('@planning.release.sprint.multiple')]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    }
                ]
            })
            .state({
                name: 'taskBoard',
                url: "/taskBoard/{sprintId:int}",
                params: {
                    sprintId: {value: null, squash: true}
                },
                templateUrl: 'ui/window/taskBoard',
                controller: 'taskBoardCtrl',
                resolve: {
                    project: ['Session', function(Session) {
                        return Session.getWorkspace();
                    }],
                    releases: ['$q', 'ReleaseService', 'SprintService', 'project', function($q, ReleaseService, SprintService, project) {
                        return ReleaseService.list(project).then(function() {                            // Wait for releases
                            return $q.all(_.map(project.releases, SprintService.list)).then(function() { // Wait for sprints
                                return project.releases;                                                 // Finally resolve the releases
                            });
                        });
                    }],
                    sprint: ['$stateParams', '$state', '$q', 'ReleaseService', 'SprintService', 'StoryService', 'TaskService', 'project', 'releases', function($stateParams, $state, $q, ReleaseService, SprintService, StoryService, TaskService, project, releases) {
                        var promise;
                        if ($stateParams.sprintId) {
                            var sprint = _.find(ReleaseService.findAllSprints(releases), {id: $stateParams.sprintId});
                            if (sprint) {
                                promise = StoryService.listByType(sprint, project.id).then(function() {
                                    return TaskService.list(sprint, project.id).then(function() {
                                        return sprint;
                                    });
                                });
                            } else {
                                promise = $q.when(null);
                            }
                        } else {
                            var openSprintTaskBoard = function(sprint) {
                                $state.go('taskBoard', {sprintId: sprint.id}, {location: 'replace'});
                            };
                            promise = SprintService.getCurrentOrNextSprint(project).then(function(currentOrNextSprint) {
                                if (currentOrNextSprint && currentOrNextSprint.id) {
                                    openSprintTaskBoard(currentOrNextSprint);
                                } else {
                                    SprintService.getCurrentOrLastSprint(project).then(function(currentOrLastSprint) {
                                        if (currentOrLastSprint && currentOrLastSprint.id) {
                                            openSprintTaskBoard(currentOrLastSprint);
                                        }
                                    });
                                }
                            });
                        }
                        return promise;
                    }]
                },
                children: [
                    isStateProvider.getSprintDetailsState('@taskBoard'),
                    {
                        name: 'task',
                        url: "/task",
                        resolve: {
                            taskContext: ['sprint', function(sprint) {
                                return sprint;
                            }]
                        },
                        children: [
                            {
                                name: 'new',
                                url: "/new",
                                data: {
                                    authorizedState: function(Session) {
                                        return Session.inProject();
                                    }
                                },
                                params: {
                                    taskCategory: null
                                },
                                views: {
                                    "details@taskBoard": {
                                        templateUrl: 'task.new.html',
                                        controller: 'taskNewCtrl'
                                    }
                                }
                            },
                            isStateProvider.getTaskDetailsState('@taskBoard')
                        ]
                    },
                    {
                        name: 'story',
                        url: "/story",
                        children: [isStateProvider.getStoryDetailsState('@taskBoard')]
                    }
                ]
            })
            // Portfolio workspace
            .state({
                name: 'newPortfolio',
                url: "/portfolio/new",
                onEnter: ['$state', '$uibModal', '$rootScope', function($state, $uibModal, $rootScope) {
                    $uibModal.open({
                        keyboard: false,
                        backdrop: 'static',
                        templateUrl: $rootScope.serverUrl + "/portfolio/add",
                        size: 'lg',
                        controller: 'newPortfolioCtrl'
                    }).result.then(function() {
                        $state.transitionTo('root');
                    }, function() {
                        $state.transitionTo('root');
                    });
                }]
            });
        $stateProvider.state('404', {
            url: '*path',
            template: ''
        });
    }])
    .config(['flowFactoryProvider', function(flowFactoryProvider) {
        flowFactoryProvider.defaults = {
            target: 'attachment/save',
            simultaneousUploads: 1 // Only one at the time => prevent staleObjectException
        };
    }])
    .config(['$uibTooltipProvider', function($uibTooltipProvider) {
        $uibTooltipProvider.options({appendToBody: true});
    }])
    .config(['uibDatepickerConfig', function(uibDatepickerConfig) {
        angular.extend(uibDatepickerConfig, {
            startingDay: 1 // TODO make it i18n
        });
    }])
    .config(['uibDatepickerPopupConfig', function(uibDatepickerPopupConfig) {
        angular.extend(uibDatepickerPopupConfig, {
            showButtonBar: false,
            appendToBody: true,
            datepickerPopup: 'dd/MM/yyyy' // TODO make it i18n
        });
    }])
    .config(['uiSelectConfig', function(uiSelectConfig) {
        uiSelectConfig.theme = 'select2';
        uiSelectConfig.appendToBody = false;
        uiSelectConfig.searchEnabled = false;
    }])
    .config(['$animateProvider', function($animateProvider) {
        $animateProvider.classNameFilter(/ng-animate-enabled/);
    }])
    .config(['$authProvider', function($authProvider) {
        var providers = isSettings.clientsOauth;
        _.each(providers, function(opts, key) {
            var options = {
                name: key,
                url: isSettings.serverUrl + "/clientOauth/token/" + key,
                redirectUri: isSettings.serverUrl + "/clientOauth/redirectUri",
            }
            _.each(opts, function(value, key) {
                options[key] = value;
            });
            $authProvider.oauth2(options);
        });
    }])
    .factory('ErrorInterceptor', ['$rootScope', '$q', 'SERVER_ERRORS', function($rootScope, $q, SERVER_ERRORS) {
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
                return $q.reject(response); // Required to mimic default interceptor
            }
        };
    }])
    .factory('SubmittingInterceptor', ['$rootScope', '$q', function($rootScope, $q) {
        var isSubmitting = function(config) {
            return _.includes(['POST', 'DELETE'], config.method) && !config.isBackground;
        };
        return {
            request: function(config) {
                if (isSubmitting(config)) {
                    $rootScope.application.submitting = true;
                }
                return config; // Required to mimic default interceptor
            },
            response: function(response) {
                if (isSubmitting(response.config)) {
                    $rootScope.application.submitting = false;
                }
                return response; // Required to mimic default interceptor
            },
            responseError: function(response) {
                $rootScope.application.submitting = false; // In case of any error, always give back the control to the user
                return $q.reject(response); // Required to mimic default interceptor
            }
        };
    }])
    .factory('UserTimeZone', function() {
        return jstz.determine();
    })
    .run(['Session', 'I18nService', 'PushService', 'UserService', 'WidgetService', 'AppService', 'FormService', 'WorkspaceType', '$controller', '$rootScope', '$timeout', '$state', '$uibModal', '$filter', '$document', '$window', '$localStorage', '$interval', 'notifications', 'screenSize', 'hotkeys', function(Session, I18nService, PushService, UserService, WidgetService, AppService, FormService, WorkspaceType, $controller, $rootScope, $timeout, $state, $uibModal, $filter, $document, $window, $localStorage, $interval, notifications, screenSize, hotkeys) {
        $rootScope.uiWorking = function(message) {
            $rootScope.loaders.menu.play();
            $rootScope.loaders.menu.loop = true;
            $rootScope.application.loading = true;
            $rootScope.application.loadingText = $rootScope.message((message === true || message === undefined) ? 'todo.is.ui.loading.working' : message);
            if ($rootScope.application.loadingText) {
                $rootScope.loaders.main.play();
                $rootScope.loaders.main.loop = true;
            }
        };
        $rootScope.uiReadyTimeout = null;
        $rootScope.uiReady = function() {
            $rootScope.loaders.menu.loop = false;
            $rootScope.loaders.main.loop = false;
            $rootScope.application.loading = false;
            $rootScope.application.loadingText = null;
        };
        $rootScope.hotkeyClick = function(event, hotkey) {
            if (hotkey.el && (hotkey.el.is("a") || hotkey.el.is("button"))) {
                event.preventDefault();
                $timeout(function() {
                    hotkey.el.click();
                });
            }
        };
        var $download;
        $rootScope.downloadFile = function(url, params) {
            var updateQueryStringParameter = function(uri, key, value) {
                var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
                var separator = uri.indexOf('?') !== -1 ? "&" : "?";
                if (uri.match(re)) {
                    return uri.replace(re, '$1' + key + "=" + value + '$2');
                } else {
                    return uri + separator + key + "=" + value;
                }
            };
            if (params) {
                _.each(params, function(val, key) {
                    url = updateQueryStringParameter(url, key, val);
                });
            }
            if ($download) {
                $download.attr('src', url);
            } else {
                $download = $('<iframe>', {id: 'idown', src: encodeURI(url)}).hide().appendTo('body');
            }
        };
        $rootScope.message = I18nService.message;
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
                var el = angular.element('[name="' + form.$name + '"] input[autofocus]');
                if (el.size() > 0) {
                    el[0].focus();
                }
            }
        };
        $rootScope.confirm = function(options) {
            var modal = $uibModal.open({
                templateUrl: 'confirm.modal.html',
                size: 'sm',
                controller: ["$scope", "hotkeys", function($scope, hotkeys) {
                    $scope.confirmTitle = $scope.message(options.confirmTitle ? options.confirmTitle : 'todo.is.ui.confirm.title');
                    $scope.buttonColor = options.buttonColor ? options.buttonColor : 'primary';
                    $scope.buttonTitle = $scope.message(options.buttonTitle ? options.buttonTitle : 'todo.is.ui.confirm');
                    $scope.message = options.message;
                    $scope.submit = function() {
                        if (options.args) {
                            options.callback.apply(options.callback, options.args);
                        } else {
                            options.callback();
                        }
                        $scope.$close(true);
                    };
                    // Required because there is not input so the form cannot be submitted by "return"
                    hotkeys.bindTo($scope).add({
                        combo: 'return',
                        callback: function(event) {
                            event.preventDefault(); // Prevents propagation of click to unwanted places
                            $scope.submit();
                        }
                    });
                }]
            });
            var callCloseCallback = function(confirmed) {
                if (!confirmed && options.closeCallback) {
                    options.closeCallback();
                }
            };
            modal.result.then(callCloseCallback, callCloseCallback);
        };
        $rootScope.delayCall = function(callback, args) {
            // BIG HACK when a DOM change in a blur event will move a button and it will not be there anymore to receive the click, so we delay the blur enough so the button is clicked first
            $timeout(function() {
                if (args) {
                    callback.apply(callback, args);
                } else {
                    callback();
                }
            }, 200); // Less than that often does not work
        };
        $rootScope.plus = function(value) {
            return _.isNumber(value) ? $filter('preciseFloatSum')([value, 1]) : 1;
        };
        $rootScope.minus = function(value) {
            return _.isNumber(value) && value >= 1 ? $filter('preciseFloatSum')([value, -1]) : 0;
        };
        $rootScope.alert = function(options) {
            $uibModal.open({
                templateUrl: 'message.modal.html',
                size: options.size ? options.size : 'sm',
                controller: ['$scope', function($scope) {
                    $scope.title = options.title ? options.title : $scope.message('todo.is.ui.message.title');
                    $scope.message = options.message;
                }]
            });
        };
        $rootScope.confirmDelete = function(options) {
            $rootScope.confirm(_.assign({ // Don't use merge, we want to keep the original references and avoid object copy
                buttonColor: 'danger',
                buttonTitle: 'default.button.delete.label',
                message: $rootScope.message('is.confirm.delete')
            }, options));
        };
        $rootScope.dirtyChangesConfirm = function(options) {
            var modal = $uibModal.open({
                templateUrl: 'confirm.dirty.modal.html',
                size: 'sm',
                keyboard: false,
                backdrop: 'static',
                controller: ["$scope", "hotkeys", function($scope, hotkeys) {
                    $scope.confirmTitle = $scope.message(options.confirmTitle ? options.confirmTitle : 'todo.is.ui.dirty.confirm.title');
                    $scope.confirmSaveButton = $scope.message(options.confirmSaveButton ? options.confirmSaveButton : 'todo.is.ui.dirty.confirm.save');
                    $scope.confirmDontSaveButton = $scope.message(options.confirmDontSaveButton ? options.confirmDontSaveButton : 'todo.is.ui.dirty.confirm.dontsave');
                    $scope.message = options.message;
                    $scope.saveChanges = function() {
                        if (options.args) {
                            options.saveChangesCallback.apply(options.saveChangesCallback, options.args);
                        } else {
                            options.saveChangesCallback();
                        }
                        $scope.$close(true);
                    };
                    $scope.dontSave = function() {
                        if (options.args) {
                            options.dontSaveChangesCallback.apply(options.dontSaveChangesCallback, options.args);
                        } else {
                            options.dontSaveChangesCallback();
                        }
                        $scope.$close(true);
                    };
                    // Required because there is not input so the form cannot be submitted by "return"
                    hotkeys.bindTo($scope).add({
                        combo: 'return',
                        callback: function(event) {
                            event.preventDefault(); // Prevents propagation of click to unwanted places
                            $scope.saveChanges();
                        }
                    });
                }]
            });
            var callCloseCallback = function(confirmed) {
                debugger;
                if (!confirmed && options.cancelChangesCallback) {
                    options.cancelChangesCallback();
                }
            };
            modal.result.then(callCloseCallback, callCloseCallback);
        };
        $rootScope.revertSortable = function(event) {
            event.dest.sortableScope.removeItem(event.dest.index);
            event.source.itemScope.sortableScope.insertItem(event.source.index, event.source.itemScope.modelValue);
        };
        $rootScope.showProjectEditModal = function(panelName) {
            var scope = $rootScope.$new();
            if (panelName) {
                scope.panel = {current: panelName};
            }
            $uibModal.open({
                keyboard: false,
                backdrop: 'static',
                templateUrl: $rootScope.serverUrl + "/project/edit",
                size: 'lg',
                scope: scope,
                controller: 'editProjectModalCtrl'
            });
        };
        $rootScope.showPortfolioEditModal = function(panelName) {
            var scope = $rootScope.$new();
            if (panelName) {
                scope.panel = {current: panelName};
            }
            $uibModal.open({
                keyboard: false,
                backdrop: 'static',
                templateUrl: $rootScope.serverUrl + "/portfolio/edit",
                size: 'lg',
                scope: scope,
                controller: 'editPortfolioModalCtrl',
                resolve: {
                    projects: ['PortfolioService', function(PortfolioService) {
                        return PortfolioService.listProjects(scope.getPortfolioFromState());
                    }]
                }
            });
        };
        $rootScope.showManageTeamsModal = function(team) { // Needs to be next to showProjectEditModal
            $uibModal.open({
                keyboard: false,
                backdrop: 'static',
                templateUrl: $rootScope.serverUrl + "/team/manage",
                size: 'lg',
                controller: ['$scope', '$controller', function($scope, $controller) {
                    if (team) {
                        $scope.selectedTeam = team;
                    }
                    $controller('manageTeamsModalCtrl', {$scope: $scope});
                }]
            });
        };
        $rootScope.logIn = function() {
            document.location = $rootScope.serverUrl + '/login/auth?redirectTo=' + encodeURI(document.location.href.replace('#', '_HASH_'));
        };
        $rootScope.showNotEnabledFeature = function() {
            $rootScope.alert({
                message: $rootScope.message('is.ui.admin.contact.enable')
            });
        };
        $rootScope.showAppsModal = function(appDefinitionId, isTerm) {
            var scope = $rootScope.$new();
            if (appDefinitionId) {
                if (isTerm) {
                    scope.defaultSearchTerm = appDefinitionId;
                } else {
                    scope.defaultAppDefinitionId = appDefinitionId;
                }
            }
            $uibModal.open({
                keyboard: false,
                templateUrl: 'apps.modal.html',
                controller: 'appsCtrl',
                size: 'lg',
                scope: scope
            });
        };
        $rootScope.copyToClipboard = function(text) {
            FormService.copyToClipboard(text).then(function() {
                $rootScope.notifySuccess('is.ui.copy.to.clipboard.success');
            }, function() {
                $rootScope.notifySuccess('is.ui.copy.to.clipboard.error');
            });
        };
        $rootScope.openWorkspace = function(object) {
            document.location = object.pkey ? $filter('projectUrl')(object.pkey) : $filter('portfolioUrl')(object.fkey);
        };
        $rootScope.openDatepicker = function($event, holder) {
            $event.preventDefault();
            $event.stopPropagation();
            if (holder) {
                holder.opened = true;
            }
        };
        $rootScope.menuClick = function(menuElement, item, $event) {
            var actionConfirmed = true;
            if (menuElement.deleteMenu) {
                actionConfirmed = false;
                $event.preventDefault();
                $event.stopPropagation();
                var el = angular.element($event.target);
                el = el.hasClass("name") ? el : el.find('.name');
                if (!el.hasClass("confirm-delete-action")) {
                    el.addClass("confirm-delete-action");
                    el.html($rootScope.message('is.ui.delete.confirm'));
                } else {
                    actionConfirmed = true;
                }
            }
            if (menuElement.action && actionConfirmed) {
                $event.preventDefault();
                menuElement.action(item);
            }
        };
        $rootScope.workspaceTypes = WorkspaceType;
        $rootScope.integerSuite = _.range(100);
        $rootScope.integerSuiteNullable = ['?'].concat($rootScope.integerSuite);
        $rootScope.fibonacciSuite = [0, 1, 2, 3, 5, 8, 13, 21, 34];
        $rootScope.fibonacciSuiteNullable = ['?'].concat($rootScope.fibonacciSuite);
        $rootScope.application = {
            loading: true,
            loadingText: '',
            loadingPercent: 0,
            submitting: false,
            isFullScreen: false,
            mediaBreakpoint: screenSize.get()
        };
        $rootScope.$state = $state; // To be able to track state in views
        $rootScope.sortableScrollOptions = function(scrollableContainerSelector) {
            return {
                scrollableContainerSelector: scrollableContainerSelector ? scrollableContainerSelector : '.card-body',
                dragStart: function() {
                    $rootScope.application.sortableMoving = true;
                    if ($state.params.storyListId || $state.params.featureListId) {
                        $rootScope.application.sortableMultiple = true;
                        angular.element('.as-sortable-dragging-item').addClass('stack twisted');
                    }
                },
                dragEnd: function() {
                    $rootScope.application.sortableMoving = false;
                    $rootScope.application.sortableMultiple = false;
                }
            }
        };
        if (isSettings) {
            $rootScope.serverUrl = isSettings.serverUrl;
            $rootScope.taskTypes = isSettings.types.task;
            $rootScope.storyTypes = isSettings.types.story;
            $rootScope.featureTypes = isSettings.types.feature;
            $rootScope.backlogChartTypes = isSettings.backlogChartTypes;
            $rootScope.backlogChartUnits = isSettings.backlogChartUnits;
            $rootScope.planningPokerTypes = isSettings.types.planningPoker;
            $rootScope.taskStates = isSettings.states.task;
            $rootScope.storyStates = isSettings.states.story;
            $rootScope.acceptanceTestStates = isSettings.states.acceptanceTest;
            $rootScope.warning = isSettings.warning;
            $rootScope.displayWhatsNew = isSettings.displayWhatsNew;
            $rootScope.workspaceType = Session.workspaceType;
            $rootScope.logoutLink = isSettings.logoutLink;
            if (isSettings.announcement && isSettings.announcement.code && !$localStorage['hideAnnouncement-' + isSettings.announcement.code]) {
                $rootScope.application.announcement = isSettings.announcement;
            }
            if ($rootScope.workspaceType === WorkspaceType.PROJECT) {
                $controller('contextCtrl', {$scope: $rootScope});
            }
            PushService.initPush(isSettings.workspace ? isSettings.workspace.id : null, $rootScope.workspaceType);
            I18nService.initMessages(isSettings.messages);
            I18nService.initBundles(isSettings.bundles);
            if (isSettings.userPreferences) {
                isSettings.user.preferences = isSettings.userPreferences;
            }
            PDFJS.workerSrc = isSettings.workerSrc;
            $rootScope.application.menus = {
                visible: isSettings.menus,
                hidden: []
            };
            Session.create(isSettings.user, isSettings.roles, isSettings.defaultView);
            $rootScope.loaders = {
                menu: menuLoaderAnimation,
                main: mainLoaderAnimation
            };
            moment.locale(isSettings.lang);
        }
        $rootScope.authenticated = Session.authenticated;
        $rootScope.authorizedApp = AppService.authorizedApp;
        $rootScope.hideAnnouncement = function() {
            $localStorage['hideAnnouncement-' + $rootScope.application.announcement.code] = true;
            $rootScope.application.announcement = null;
        };
        $rootScope.getProjectFromState = function() {
            return $state.$current.locals.globals.project;
        };
        $rootScope.getPortfolioFromState = function() {
            return $state.$current.locals.globals.portfolio;
        };
        $rootScope.showWorkspaceListModal = function(listType, workspaceType) {
            workspaceType = workspaceType ? workspaceType : 'all';
            $uibModal.open({
                keyboard: false,
                templateUrl: $rootScope.serverUrl + "/scrumOS/listModal",
                size: 'lg',
                controller: ['$scope', '$controller', 'ProjectService', 'PortfolioService', 'Session', function($scope, $controller, ProjectService, PortfolioService, Session) {
                    $controller('abstractProjectListCtrl', {$scope: $scope});
                    // Functions
                    $scope.searchWorkspaces = function() {
                        var listFunction = {
                            portfolio: {
                                all: PortfolioService.list
                            },
                            project: {
                                public: ProjectService.listPublic,
                                all: ProjectService.list
                            },
                            all: {
                                user: Session.workspacesListByUser
                            }
                        }[workspaceType][listType];
                        listFunction({term: $scope.workspaceSearch, page: $scope.currentPage, count: $scope.workspacesPerPage}).then(function(workspacesAndCount) {
                            $scope.workspaceCount = workspacesAndCount.count;
                            $scope.workspaces = [];
                            if (workspacesAndCount.portfolios) {
                                $scope.workspaces = _.concat($scope.workspaces, workspacesAndCount.portfolios);
                            }
                            if (workspacesAndCount.projects) {
                                $scope.workspaces = _.concat($scope.workspaces, workspacesAndCount.projects);
                            }
                            if (!_.isEmpty($scope.workspaces) && _.isEmpty($scope.workspace)) {
                                $scope.selectWorkspace(_.head($scope.workspaces));
                            }
                        });
                    };
                    $scope.selectWorkspace = function(workspace) {
                        var setSummary = function() {
                            $scope.summary = workspace.class.toLowerCase() + '.summary.html';
                        };
                        if ($scope.summary != null) {
                            // Force deletion / re-creation of template to start over with fresh data
                            $scope.summary = null;
                            $timeout(setSummary);
                        } else {
                            setSummary();
                        }
                        if ($scope['select' + workspace.class]) {
                            $scope['select' + workspace.class](workspace);
                        } else {
                            $scope[workspace.class.toLowerCase()] = workspace;
                        }
                        $scope.workspace = workspace;
                    };
                    // Init
                    $scope.workspaceCount = 0;
                    $scope.currentPage = 1;
                    $scope.workspacesPerPage = 9; // Constant
                    $scope.workspaceSearch = '';
                    $scope.workspaces = [];
                    $scope.summary = null;
                    $scope.searchWorkspaces();
                }]
            });
        };
        $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams, options) {
            if (toState.name == "404") {
                event.preventDefault();
                $state.go('root');
            } else if (!event.defaultPrevented) {
                var state = toState.$$state();
                if (state.data && state.data.authorizedState) {
                    var authorized = state.data.authorizedState(Session);
                    if (!authorized) {
                        event.preventDefault();
                        if (!Session.authenticated()) {
                            $rootScope.logIn();
                        } else {
                            $state.go(angular.isDefined(fromState) && fromState.name ? fromState.name : "404");
                        }
                    }
                }
            }
            $rootScope.application.focusedDetailsView = toState.name.indexOf('.focus') > 0;
        });
        $rootScope.getColorScheme = getColorScheme;
        $rootScope.setColorScheme = setColorScheme;
        $rootScope.toggleColorScheme = function() {
            var newColorScheme = $rootScope.getColorScheme() === 'dark' ? 'light' : 'dark';
            $rootScope.setColorScheme(newColorScheme);
            if (Session.authenticated()) {
                UserService.updateColorScheme(newColorScheme);
            }
        };
        screenSize.onRuleChange($rootScope, function(breakPoint) {
            $rootScope.application.mediaBreakpoint = breakPoint;
        });
        hotkeys.add({
            combo: 'shift+d',
            callback: $rootScope.toggleColorScheme,
            description: $rootScope.message('is.ui.colorScheme.toggle')
        });
        $rootScope.getMeetingProviders = function() {
            return isSettings.meeting.providers;
        }
    }]);