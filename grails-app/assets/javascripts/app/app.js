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

angular.module('isPlugins', []).provider('controllerHooks', function() {
    this.$get = angular.noop;
    this.register = function(entryPoints) {
        _.each(entryPoints, function(appControllerName, pluginControllerName) {
            if (_.has(isSettings.controllerHooks, appControllerName)) {
                isSettings.controllerHooks[appControllerName].push(pluginControllerName);
            } else {
                console.error("App controller " + appControllerName + " is not registered so plugin controller " + pluginControllerName + " cannot be hooked");
            }
        });
    }
});

angular.module('isApp', [
        'ngRoute',
        'ngAnimate',
        'ngSanitize',
        'controllers',
        'services',
        'filters',
        'directives',
        'ui.router',
        'ui.router.stateHelper',
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
    ].concat(isSettings.plugins)
).config(['stateHelperProvider', '$httpProvider', '$urlRouterProvider', '$stateProvider', function(stateHelperProvider, $httpProvider, $urlRouterProvider, $stateProvider) {
    $httpProvider.interceptors.push([
        '$injector',
        function($injector) {
            return $injector.get('AuthInterceptor');
        }
    ]);

    $stateProvider.decorator('parent', function(state, parentFn) {
        state.self.$$state = function() {
            return state;
        };
        state.self.isSetAuthorize = function() {
            return angular.isDefined(state.data) && angular.isDefined(state.data.authorize);
        };
        return parentFn(state);
    });

    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    $urlRouterProvider.when('', '/');
    var getDetailsModalState = function(detailsType, options) {
        return _.merge({
            name: detailsType,
            url: '/' + detailsType,
            abstract: true,
            resolve: {
                modalHolder: [function() { return {}; }]
            },
            onEnter: ['$state', '$uibModal', 'modalHolder', function($state, $uibModal, modalHolder) {
                var goToCaller = function(reason) {
                    if (reason !== true) {
                        $state.go(($state.params[detailsType + 'TabId'] ? '^.' : '') + '^.^');
                    }
                };
                modalHolder.modal = $uibModal.open({
                    templateUrl: 'details.modal.html',
                    controller: ['$scope', function($scope) {
                        $scope.detailsType = detailsType;
                        $scope.isModal = true;
                    }]
                });
                modalHolder.modal.result.then(goToCaller, goToCaller);
            }],
            onExit: ['modalHolder', function(modalHolder) {
                modalHolder.modal.dismiss(true)
            }]
        }, options);
    };
    var getTaskDetailsState = function(viewContext) {
        var options = {
            name: 'details',
            url: "/{taskId:int}",
            resolve: {
                detailsTask: ['$stateParams', 'taskContext', function($stateParams, taskContext) {
                    return _.find(taskContext.tasks, {id: $stateParams.taskId})
                }]
            },
            views: {},
            children: [
                {
                    name: 'tab',
                    url: "/{taskTabId:(?:comments|activities)}",
                    resolve: {
                        data: ['$stateParams', 'ActivityService', 'CommentService', 'detailsTask', function($stateParams, ActivityService, CommentService, detailsTask) {
                            if ($stateParams.taskTabId == 'comments') {
                                return CommentService.list(detailsTask);
                            } else if ($stateParams.taskTabId == 'activities') {
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
                                if ($stateParams.taskTabId == 'comments') {
                                    tpl = 'comment.list.html';
                                } else if ($stateParams.taskTabId == 'activities') {
                                    tpl = 'activity.list.html';
                                }
                                return tpl;
                            },
                            controller: ['$scope', '$controller', '$stateParams', 'selected', function($scope, $controller, $stateParams, selected) {
                                $scope.selected = selected;
                                if ($stateParams.taskTabId == 'activities') {
                                    $controller('activityCtrl', {$scope: $scope, selected: selected});
                                }
                            }]
                        }
                    }
                }
            ]
        };
        options.views['details' + (viewContext ? viewContext : '')] = {
            templateUrl: 'task.details.html',
            controller: 'taskDetailsCtrl'
        };
        return options;
    };
    var getFeatureDetailsState = function(viewContext, isModal) {
        var options = {
            name: 'details',
            url: "/{featureId:int}",
            resolve: {
                //we add features to wait for dynamic resolution from parent state
                detailsFeature: ['FeatureService', '$stateParams', 'features', function(FeatureService, $stateParams, features) {
                    return FeatureService.get($stateParams.featureId);
                }]
            },
            views: {},
            children: [
                {
                    name: 'tab',
                    url: "/{featureTabId:stories}",
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
                }
            ]
        };
        options.views['details' + (viewContext ? viewContext : '')] = {
            templateUrl: 'feature.details.html',
            controller: 'featureDetailsCtrl'
        };
        if (!isModal) {
            options.children[0].children = [
                getDetailsModalState('story', {
                    children: [getStoryDetailsState('@', true)]
                })
            ];
        }
        return options;
    };
    var getStoryDetailsState = function(viewContext, isModal) {
        var options = {
            name: 'details',
            url: "/{storyId:int}",
            resolve: {
                detailsStory: ['StoryService', '$stateParams', function(StoryService, $stateParams) {
                    return StoryService.get($stateParams.storyId);
                }]
            },
            views: {},
            children: [
                {
                    name: 'tab',
                    url: "/{storyTabId:(?:tests|tasks|comments|activities)}",
                    resolve: {
                        data: ['$stateParams', 'AcceptanceTestService', 'CommentService', 'TaskService', 'ActivityService', 'detailsStory', function($stateParams, AcceptanceTestService, CommentService, TaskService, ActivityService, detailsStory) {
                            if ($stateParams.storyTabId == 'tests') {
                                return AcceptanceTestService.list(detailsStory);
                            } else if ($stateParams.storyTabId == 'tasks') {
                                return TaskService.list(detailsStory);
                            } else if ($stateParams.storyTabId == 'comments') {
                                return CommentService.list(detailsStory);
                            } else if ($stateParams.storyTabId == 'activities') {
                                return ActivityService.activities(detailsStory, false);
                            }
                            return null;
                        }],
                        //we add data to wait for dynamic resolution - not used only for story.xxxx to be loaded
                        selected: ['data', 'detailsStory', function(data, detailsStory) {
                            return detailsStory;
                        }]
                    },
                    views: {
                        "details-tab": {
                            templateUrl: function($stateParams) {
                                var tpl;
                                if ($stateParams.storyTabId == 'tests') {
                                    tpl = 'story.acceptanceTests.html';
                                } else if ($stateParams.storyTabId == 'tasks') {
                                    tpl = 'story.tasks.html';
                                } else if ($stateParams.storyTabId == 'comments') {
                                    tpl = 'comment.list.html';
                                } else if ($stateParams.storyTabId == 'activities') {
                                    tpl = 'activity.list.html';
                                }
                                return tpl;
                            },
                            controller: ['$scope', '$controller', '$stateParams', 'selected', function($scope, $controller, $stateParams, selected) {
                                $scope.selected = selected;
                                if ($stateParams.storyTabId == 'activities') {
                                    $controller('activityCtrl', {$scope: $scope, selected: selected});
                                } else if ($stateParams.storyTabId == 'tasks') {
                                    $controller('taskStoryCtrl', {$scope: $scope});
                                }
                            }]
                        }
                    }
                }
            ]
        };
        options.views['details' + (viewContext ? viewContext : '')] = {
            templateUrl: 'story.details.html',
            controller: 'storyDetailsCtrl'
        };
        if (!isModal) {
            options.children[0].children = [
                getDetailsModalState('task', {
                    resolve: {
                        taskContext: ['selected', function(selected) {
                            return selected;
                        }]
                    },
                    children: [getTaskDetailsState('@')]
                })
            ];
            options.children.push(getDetailsModalState('feature', {
                resolve: {
                    features: ['FeatureService', function(FeatureService) {
                        return FeatureService.list();
                    }]
                },
                children: [getFeatureDetailsState('@', true)]
            }));
        }
        return options;
    };
    var getBacklogStoryState = function() {
        return {
            name: 'story',
            url: "/story",
            children: [
                {
                    name: 'new',
                    url: "/new",
                    data: {
                        authorize: {
                            roles: ['inProduct']
                        }
                    },
                    views: {
                        "details@backlog": {
                            templateUrl: 'story.new.html',
                            controller: 'storyNewCtrl'
                        }
                    }
                },
                {
                    name: 'multiple',
                    url: "/{storyListId:[0-9]+(?:[\,][0-9]+)+}",
                    resolve: {
                        storyListId: ['$stateParams', function($stateParams) {
                            return $stateParams.storyListId.split(',');
                        }]
                    },
                    views: {
                        "details@backlog": {
                            templateUrl: 'story.multiple.html',
                            controller: 'storyMultipleCtrl'
                        }
                    },
                    children: [
                        getDetailsModalState('feature', {
                            resolve: {
                                features: ['FeatureService', function(FeatureService) {
                                    return FeatureService.list();
                                }]
                            },
                            children: [getFeatureDetailsState('@backlog', true)]
                        })
                    ]
                },
                getStoryDetailsState('@backlog')
            ]
        }
    };
    stateHelperProvider
        .state({
            name: 'root',
            url: '/',
            controller: ['$state', function($state) {
                var isInProject = window.location.pathname.indexOf('/p/') != -1;
                $state.go(isInProject ? 'project' : 'home', $state.params);
            }]
        })
        .state({
            name: 'home', // should not be acceded directly, called by 'root'
            templateUrl: 'ui/window/home',
            controller: 'homeCtrl'
        })
        .state({
            name: 'userregister',
            url: "/user/register/:token",
            params: {token: {value: null}}, // doesn't work currently but it should, see https://github.com/angular-ui/ui-router/pull/1032 & https://github.com/angular-ui/ui-router/issues/1652
            onEnter: ["$state", "$uibModal", "$rootScope", function($state, $uibModal, $rootScope) {
                $uibModal.open({
                    keyboard: false,
                    templateUrl: $rootScope.serverUrl + '/user/register',
                    controller: 'registerCtrl'
                }).result.then(function(username) {
                        $state.transitionTo('root');
                        $rootScope.showAuthModal(username);
                    }, function() {
                        $state.transitionTo('root');
                    });
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
            name: 'project',  // should not be acceded directly, called by 'root'
            templateUrl: 'ui/window/project',
            controller: 'projectCtrl'
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
                backlogs: ['BacklogService', function(BacklogService) {
                    return BacklogService.list();
                }]
            },
            children: [
                {
                    name: 'multiple',
                    url: "/:pinnedBacklogCode,:backlogCode",
                    children: [getBacklogStoryState()]
                },
                {
                    name: 'backlog',
                    url: "/:backlogCode",
                    resolve: {
                        backlog: ['$stateParams', 'backlogs', function($stateParams, backlogs) {
                            return _.find(backlogs, {code: $stateParams.backlogCode});
                        }]
                    },
                    children: [
                        {
                            name: 'details',
                            url: "/details",
                            views: {
                                "details@backlog": {
                                    templateUrl: 'backlog.details.html',
                                    controller: 'backlogDetailsCtrl'
                                }
                            }
                        },
                        getBacklogStoryState()
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
                features: ['FeatureService', function(FeatureService) {
                    return FeatureService.list();
                }]
            },
            children: [
                {
                    name: 'new',
                    url: '/new',
                    data: {
                        authorize: {
                            roles: ['po']
                        }
                    },
                    views: {
                        "details": {
                            templateUrl: 'feature.new.html',
                            controller: 'featureNewCtrl'
                        }
                    }
                },
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
                getFeatureDetailsState()
            ]
        })
        .state({
            name: 'planning',
            url: "/planning",
            templateUrl: 'ui/window/planning',
            controller: 'planningCtrl',
            resolve: {
                project: ['Session', function(Session) {
                    return Session.getProjectPromise();
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
                        authorize: {
                            roles: ['poOrSm']
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
                        {
                            name: 'details',
                            url: "/details",
                            views: {
                                "details@planning": {
                                    templateUrl: 'release.details.html',
                                    controller: 'releaseDetailsCtrl'
                                }
                            }
                        },
                        {
                            name: 'story',
                            url: "/story",
                            children: [getStoryDetailsState('@planning')]
                        },
                        {
                            name: 'sprint',
                            url: "/sprint",
                            children: [
                                {
                                    name: 'new',
                                    url: "/new",
                                    data: {
                                        authorize: {
                                            roles: ['poOrSm']
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
                                        }]
                                    },
                                    children: [
                                        {
                                            name: 'details',
                                            url: "/details",
                                            views: {
                                                "details@planning": {
                                                    templateUrl: 'sprint.details.html',
                                                    controller: 'sprintDetailsCtrl'
                                                }
                                            }
                                        },
                                        {
                                            name: 'story',
                                            url: "/story",
                                            children: [getStoryDetailsState('@planning')]
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
                                            children: [getStoryDetailsState('@planning')]
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
                    return Session.getProjectPromise();
                }],
                releases: ['$q', 'ReleaseService', 'SprintService', 'project', function($q, ReleaseService, SprintService, project) {
                    return ReleaseService.list(project).then(function() {                            // Wait for releases
                        return $q.all(_.map(project.releases, SprintService.list)).then(function() { // Wait for sprints
                            return project.releases;                                                 // Finally resolve the releases
                        });
                    });
                }],
                sprint: ['$stateParams', '$q', 'ReleaseService', 'SprintService', 'StoryService', 'TaskService', 'project', 'releases', function($stateParams, $q, ReleaseService, SprintService, StoryService, TaskService, project, releases) {
                    var promise;
                    if ($stateParams.sprintId) {
                        promise = $q.when(_.find(ReleaseService.findAllSprints(releases), {id: $stateParams.sprintId}));
                    } else {
                        promise = SprintService.getCurrentOrNextSprint(project);
                    }
                    return promise.then(function(sprint) {
                        return sprint == undefined || sprint.id == undefined ? undefined : StoryService.listByType(sprint).then(function() {
                            return TaskService.list(sprint).then(function() {
                                return sprint;
                            });
                        });
                    })
                }]
            },
            children: [
                {
                    name: 'details',
                    url: "/details",
                    resolve: {
                        detailsSprint: ['sprint', function(sprint) {
                            return sprint;
                        }],
                        detailsRelease: ['releases', 'sprint', function(releases, sprint) {
                            return _.find(releases, {id: sprint.parentRelease.id});
                        }]
                    },
                    views: {
                        "details": {
                            templateUrl: 'sprint.details.html',
                            controller: 'sprintDetailsCtrl'
                        }
                    }
                },
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
                                authorize: {
                                    roles: ['inProduct']
                                }
                            },
                            params: {
                                taskTemplate: null
                            },
                            views: {
                                "details@taskBoard": {
                                    templateUrl: 'task.new.html',
                                    controller: 'taskNewCtrl'
                                }
                            }
                        },
                        getTaskDetailsState('@taskBoard')
                    ]
                },
                {
                    name: 'story',
                    url: "/story",
                    children: [getStoryDetailsState('@taskBoard')]
                }
            ]
        });

    $stateProvider.state('404', {
        url: '*path',
        template: ''
    });
}])
.config(['flowFactoryProvider', function(flowFactoryProvider) {
    flowFactoryProvider.defaults = {
        target: 'attachment/save',
        //only one at the time => prevent staleObjectException
        simultaneousUploads: 1
    };
    flowFactoryProvider.on('catchAll', function(event) {
        console.log('catchAll', arguments);
    });
}])
.config(['notificationsProvider', function(notificationsProvider) {
    notificationsProvider.setDefaults({
        faIcons: true,
        closeOnRouteChange: 'state',
        duration: 4500
    });
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
.factory('AuthInterceptor', ['$rootScope', '$q', 'SERVER_ERRORS', function($rootScope, $q, SERVER_ERRORS) {
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
}])
.factory('UserTimeZone', function() {
    return jstz.determine();
})
.run(['Session', 'BundleService', 'PushService', 'UserService', 'WidgetService', '$rootScope', '$timeout', '$state', '$uibModal', '$filter', '$document', '$window', '$interval', 'notifications', function(Session, BundleService, PushService, UserService, WidgetService, $rootScope, $timeout, $state, $uibModal, $filter, $document, $window, $interval, notifications) {

    //used to handle click with shortcut hotkeys
    $rootScope.hotkeyClick = function(event, hotkey) {
        if (hotkey.el && (hotkey.el.is("a") || hotkey.el.is("button"))) {
            event.preventDefault();
            $timeout(function() {
                hotkey.el.click();
            });
        }
    };

    var $download;
    $rootScope.downloadFile = function(url) {
        if ($download) {
            $download.attr('src', url);
        } else {
            $download = $('<iframe>', {id: 'idown', src: url}).hide().appendTo('body');
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
            controller: ["$scope", function($scope) {
                $scope.title = title;
                $scope.value = value;
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

    $rootScope.showAuthModal = function(username, loginSuccess, loginFailure) {
        var childScope = $rootScope.$new();
        if (username) {
            childScope.username = username;
        }
        var loginCallback = null;
        if (loginSuccess) {
            childScope.loginCallback = true;
            loginCallback = function(loggedIn) {
                if (loggedIn) {
                    loginSuccess();
                } else {
                    loginFailure();
                }
            };
        }
        $uibModal.open({
            keyboard: false,
            templateUrl: $rootScope.serverUrl + '/login/auth',
            controller: 'loginCtrl',
            scope: childScope,
            size: 'sm'
        }).result.then(loginCallback);
    };

    $rootScope.showAddWidgetModal = function(onRight) {
        $uibModal.open({
            keyboard: false,
            templateUrl: 'addWidget.modal.html',
            controller: ['$scope', function($scope) {
                $scope.detailsWidgetDefinition = function(widgetDefinition) {
                    $scope.widgetDefinition = widgetDefinition;
                };
                $scope.addWidget = function(widgetDefinition) {
                    WidgetService.save(widgetDefinition.id, onRight).then(function() {
                        $scope.$close();
                    });
                };
                // Init
                $scope.widgetDefinition = {};
                $scope.widgetDefinitions = [];
                WidgetService.getWidgetDefinitions().then(function(widgetDefinitions) {
                    if (widgetDefinitions.length > 0) {
                        $scope.widgetDefinitions = widgetDefinitions;
                        $scope.widgetDefinition = widgetDefinitions[0];
                    }
                });
            }],
            size: 'lg'
        });
    };

    $rootScope.durationBetweenDates = function(startDateString, endDateString) {
        var duration = new Date(endDateString) - new Date(startDateString);
        return Math.floor(duration / (1000 * 3600 * 24)) + 1;
    };

    $rootScope.openProject = function(project) {
        document.location = $rootScope.serverUrl + '/p/' + project.pkey + '/';
    };

    $rootScope.openDatepicker = function($event, holder) {
        $event.preventDefault();
        $event.stopPropagation();
        if (holder) {
            holder.opened = true;
        }
    };

    $rootScope.integerSuite = [];
    for (var i = 0; i < 100; i++) {
        $rootScope.integerSuite.push(i);
    }
    $rootScope.integerSuiteNullable = ['?'].concat($rootScope.integerSuite);
    $rootScope.fibonacciSuite = [0, 1, 2, 3, 5, 8, 13, 21, 34];
    $rootScope.fibonacciSuiteNullable = ['?'].concat($rootScope.fibonacciSuite);

    $rootScope.app = {
        asList: false,
        loading: true,
        loadingPercent: 0,
        isFullScreen: false,
        menus: Session.menus,
        selectableMultiple: false
    };

    // To be able to track state in views
    $rootScope.$state = $state;

    var messages = {};
    $rootScope.initMessages = function(initMessages) {
        messages = initMessages;
    };

    $rootScope.sortableScrollOptions = function(scrollableContainerSelector) {
        if (!scrollableContainerSelector) {
            scrollableContainerSelector = '.panel-body';
        }
        var scrollSpeed = 0;
        var destScrollableContainer; // Store the dest container because it cannot be retrieved (mouse must be on panel to get the element) and used (mouse is out of panel when we must scroll) in the same move
        var scheduledScroll = null;
        var cancelScheduledScroll = function() {
            scrollSpeed = 0;
            if (scheduledScroll) {
                $interval.cancel(scheduledScroll);
                scheduledScroll = null;
            }
        };
        return {
            dragMove: function(itemPosition, containment, eventObj) {
                $rootScope.app.sortableMoving = true;
                if (eventObj) {
                    // This HORRIBLE SOUP isolated in a private function gets the dest panel body and stores it in a captured variable.
                    // There may be a better way but it is the way ng-sortable does it
                    (function(eventObj) {
                        var destX = eventObj.pageX - $document[0].documentElement.scrollLeft;
                        var destY = eventObj.pageY - ($window.pageYOffset || $document[0].documentElement.scrollTop);
                        $document[0].elementFromPoint(destX, destY); // This is done twice on purpose, ng-sortable does it like that (don't know why though...)
                        var destElement = angular.element($document[0].elementFromPoint(destX, destY)); // Gets the DOM element under the cursor
                        function fetchScope(element) {
                            var scope;
                            while (!scope && element.length) {
                                scope = element.data('_scope');
                                if (!scope) {
                                    element = element.parent();
                                }
                            }
                            return scope;
                        }
                        var destScope = fetchScope(destElement); // Retrieve the closest scope from the DOM element
                        if (destScope) {
                            destScrollableContainer = angular.element(destScope.element).closest(scrollableContainerSelector)[0]; // Store the dest scrollable container for later use
                        }
                    })(eventObj);
                    // Retrieve scrollable container, very likely stored during a previous move, and scroll if needed (for the moment scroll occurs only when moving)
                    if (destScrollableContainer) {
                        var marginAroundCursor = 30;
                        var targetY = eventObj.pageY - ($window.pageYOffset || $document[0].documentElement.scrollTop);
                        var containerRect = destScrollableContainer.getBoundingClientRect();
                        var topDifference = containerRect.top - targetY + marginAroundCursor;
                        var bottomDifference = containerRect.bottom - targetY - marginAroundCursor;
                        var cursorUpperThanPanel = topDifference > 0;
                        var cursorLowerThanPanel = bottomDifference < 0;
                        if (cursorUpperThanPanel || cursorLowerThanPanel) {
                            var computeSpeed = function(difference) {
                                return Math.floor(difference / 4); // Magic formula
                            };
                            scrollSpeed = cursorUpperThanPanel ? computeSpeed(topDifference) : computeSpeed(bottomDifference);
                            var moveScroll = function() {
                                destScrollableContainer.scrollTop = destScrollableContainer.scrollTop - scrollSpeed;
                            };
                            moveScroll();
                            // With the solution above, scroll occurs only when moving the cursor so we define a recurring callback to sustain the scroll when not moving
                            if (!scheduledScroll) {
                                var timeInterval = 4; // 4 ms scheduledScroll between each automatic scroll
                                scheduledScroll = $interval(moveScroll, timeInterval);
                            }
                        } else if (scheduledScroll != null) {
                            cancelScheduledScroll();
                        }
                    }
                }
            },
            dragEnd: function() {
                $rootScope.app.sortableMoving = false;
                cancelScheduledScroll(); // Prevent persistent scroll in case of release out of sortable container
            }
        }
    };             

    if (isSettings) {
        $rootScope.serverUrl = isSettings.serverUrl;
        $rootScope.taskTypes = isSettings.types.task;
        $rootScope.storyTypes = isSettings.types.story;
        $rootScope.featureTypes = isSettings.types.feature;
        $rootScope.planningPokerTypes = isSettings.types.planningPoker;
        $rootScope.taskStates = isSettings.states.task;
        $rootScope.acceptanceTestStates = isSettings.states.acceptanceTest;

        if (isSettings.project) {
            isSettings.project.startDate = new Date(isSettings.project.startDate);
            isSettings.project.endDate = new Date(isSettings.project.endDate);
            Session.initProject(isSettings.project);
        }

        PushService.initPush(isSettings.pushContext);
        $rootScope.initMessages(isSettings.messages);
        BundleService.initBundles(isSettings.bundles);

        Session.create(isSettings.user, isSettings.roles);
    }

    $rootScope.authenticated = Session.authenticated;

    $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams, options) {
        if (toState.name == "404") {
            event.preventDefault();
            $state.go('root');
        } else if (!event.defaultPrevented) {
            var state = toState.$$state();
            authorized = true;
            if (state.isSetAuthorize()) {
                var authorized = false;
                _.every(state.data.authorize.roles, function(role) {
                    authorized = role.indexOf('!') > -1 ? !Session[role.substring(role.indexOf('!') + 1)]() : (Session[role]() === true);
                    return authorized;
                });
            }
            if (!authorized) {
                event.preventDefault();
                if (!Session.authenticated()) {
                    $rootScope.showAuthModal('', function() {
                        UserService.getCurrent().then(function(data) {
                            Session.create(data.user, data.roles);
                            $state.go(toState.name, toParams);
                        });
                    });
                } else {
                    $state.go(angular.isDefined(fromState) && fromState.name ? fromState.name : "404");
                }
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
.constant('BacklogCodes', {
    SANDBOX: 'sandbox',
    BACKLOG: 'backlog',
    DONE: 'done',
    ALL: 'all',
    SPRINT: 'sprint'
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
    "TODO": 0,
    "IN_PROGRESS": 1,
    "DONE": 2
})
.constant('TaskTypesByName', {
    "RECURRENT": 10,
    "URGENT": 11
})
.constant('AcceptanceTestStatesByName', {
    "TOCHECK": 1,
    "FAILED": 5,
    "SUCCESS": 10
})
.constant('SprintStatesByName', {
    "TODO": 1,
    "IN_PROGRESS": 2,
    "DONE": 3
})
.constant('FeatureStatesByName', {
    "TODO": 0,
    "IN_PROGRESS": 1,
    "DONE": 2
})
.constant('ReleaseStatesByName', {
    "TODO": 1,
    "IN_PROGRESS": 2,
    "DONE": 3
})
.constant('MoodFeelingsByName', {
    "GOOD": 2,
    "MEH": 1,
    "BAD": 0
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
})
.constant('TaskConstants', {
    ORDER_BY: [function(task) { return -task.type }, 'parentStory.rank', 'state', 'rank']
});