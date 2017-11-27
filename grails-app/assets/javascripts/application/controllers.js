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

var controllers = angular.module('controllers', []);

var extensibleController = function(appControllerName, controllerArray) {
    isSettings.controllerHooks[appControllerName] = [];
    var functionIndex = controllerArray.length - 1;
    var oldFunction = controllerArray[functionIndex];
    var newControllerArray = _.dropRight(controllerArray);
    if (!_.includes(newControllerArray, '$scope')) {
        throw new Error('To be able to register the controller, inject $scope');
    }
    var indexOfScope = controllerArray.indexOf("$scope");
    var removeControllerProvider;
    if (!_.includes(newControllerArray, '$controller')) {
        newControllerArray.push('$controller');
        removeControllerProvider = true;
    }
    var indexOfControllerProvider = newControllerArray.indexOf('$controller');
    newControllerArray.push(function() {
        var $scope = arguments[indexOfScope];
        var $controller = arguments[indexOfControllerProvider];
        var newArguments = removeControllerProvider ? _.dropRight(arguments) : arguments;
        oldFunction.apply(null, newArguments); // Call the controller
        _.each(isSettings.controllerHooks[appControllerName], function(pluginControllerName) {
            $controller(pluginControllerName, {$scope: $scope});
        });
    });
    controllers.controller(appControllerName, newControllerArray);
};

extensibleController('applicationCtrl', ['$controller', '$scope', '$localStorage', '$state', '$uibModal', 'SERVER_ERRORS', 'Fullscreen', 'notifications', '$http', '$window', '$timeout', 'Session', 'UserService', 'postitSize', function($controller, $scope, $localStorage, $state, $uibModal, SERVER_ERRORS, Fullscreen, notifications, $http, $window, $timeout, Session, UserService, postitSize) {
    $controller('headerCtrl', {$scope: $scope});
    // Functions
    $scope.displayDetailsView = function() {
        var data = '';
        if ($state.current.views) {
            var isDetails = _.some(_.keys($state.current.views), function(viewName) {
                return _.startsWith(viewName, 'details');
            });
            if (isDetails) {
                data = 'with-details';
            }
        }
        return data;
    };
    $scope.showAutoPlanModal = function(options) {
        $uibModal.open({
            templateUrl: 'sprint.autoPlan.html',
            size: 'sm',
            controller: ["$scope", function($scope) {
                $scope.modelHolder = {};
                $scope.submit = function(capacity) {
                    options.args.push(capacity);
                    options.callback.apply(options.callback, options.args);
                    $scope.$close(true);
                };
            }]
        });
    };
    $scope.showWhatsNewModal = function() {
        if (Session.user.preferences) {
            Session.user.preferences.displayWhatsNew = false;
            UserService.update(Session.user);
        }
        $scope.showAbout(10);
    };
    $scope.openStorySelectorModal = function(options) {
        $uibModal.open({
            templateUrl: 'story.selector.html',
            size: 'md',
            controller: ["$scope", "$filter", "StoryService", function($scope, $filter, StoryService) {
                // Functions
                $scope.isSelected = function(story) {
                    return _.includes($scope.selectedIds, story.id);
                };
                $scope.submit = function(selectedIds) {
                    options.submit(selectedIds, $scope.backlog.stories).then(function() {
                        $scope.$close(true);
                    });
                };
                $scope.filterStories = function() {
                    $scope.selectedIds = [];
                    $scope.backlog.storiesLoaded = false;
                    StoryService.filter($scope.selectorOptions.filter).then(function(stories) {
                        $scope.backlog.stories = $scope.selectorOptions.order ? $filter('orderBy')(stories, $scope.selectorOptions.order) : stories;
                        $scope.backlog.storiesLoaded = true;
                        if ($scope.selectorOptions.initSelectedIds) {
                            $scope.selectedIds = $scope.selectorOptions.initSelectedIds($scope.backlog.stories);
                        }
                    });
                };
                // Init
                $scope.buttonColor = options.buttonColor ? options.buttonColor : 'primary';
                $scope.disabledGradient = true;
                $scope.selectedIds = [];
                $scope.backlog = {
                    stories: [],
                    code: options.code,
                    storiesLoaded: false
                };
                $scope.selectableOptions = {
                    notSelectableSelector: '.action, button, a',
                    allowMultiple: true,
                    forceMultiple: true,
                    selectionUpdated: function(selectedIds) {
                        $scope.selectedIds = selectedIds;
                    }
                };
                $scope.selectorOptions = options;
                $scope.filterStories();
            }]
        });
    };
    $scope.fullScreen = function() {
        $scope.application.isFullScreen = !$scope.application.isFullScreen;
    };
    // Postit size
    $scope.currentPostitSize = function(viewName, defaultSize) {
        return postitSize.currentPostitSize(viewName, defaultSize);
    };
    $scope.isAsListPostit = function(viewName) {
        return postitSize.currentPostitSize(viewName) == "list-group";
    };
    $scope.iconCurrentPostitSize = function(viewName) {
        return postitSize.iconCurrentPostitSize(viewName);
    };
    $scope.setPostitSize = function(viewName) {
        postitSize.setPostitSize(viewName);
    };
    $scope.goToHome = function() {
        window.location.href = $scope.serverUrl;
    };
    // Print
    $scope.print = function(data) {
        var url = data;
        if (angular.isObject(data)) {
            url = data.currentTarget.attributes['ng-href'] ? data.currentTarget.attributes['ng-href'].value : data.target.href;
            data.preventDefault();
        }
        var modal = $uibModal.open({
            keyboard: false,
            backdrop: 'static',
            templateUrl: "report.progress.html",
            size: 'sm',
            controller: ['$scope', function($scope) {
                $scope.downloadFile(url);
                $scope.progress = true;
            }]
        });
        modal.result.then(
            function() {
                $scope.downloadFile("");
            },
            function() {
                $scope.downloadFile("");
            }
        );
    };
    // Init loading
    $scope.$on('$viewContentLoading', function() {
        $scope.application.loading = true;
        if ($scope.application.loadingPercent < 90) {
            $scope.application.loadingPercent += 5;
        }
    });
    // Init loading
    var w = angular.element($window);
    var resizeTimeout = null;
    $scope.$on('$viewContentLoaded', function(event) {
        if (!event.defaultPrevented) {
            if ($scope.application.loadingPercent < 90) {
                $scope.application.loadingPercent += 5;
            } else {
                $scope.application.loading = false;
            }
            $timeout.cancel(resizeTimeout);
            resizeTimeout = $timeout(function() {
                w.triggerHandler('resize');
            }, 50);
        }
    });
    $scope.$on('$stateChangeStart', function(event) {
        if (!event.defaultPrevented) {
            $scope.application.loading = true;
            if ($scope.application.loadingPercent != 100) {
                $scope.application.loadingPercent += 10;
            }
        }
    });
    $scope.$on('$stateChangeSuccess', function(event) {
        if (!event.defaultPrevented) {
            $scope.application.loading = false;
            if ($scope.application.loadingPercent != 100) {
                $scope.application.loadingPercent = 100;
            }
        }
    });
    $scope.$watch(function() {
        return $http.pendingRequests.length;
    }, function(newVal) {
        $scope.application.loading = newVal > 0 || $scope.application.loadingPercent < 100;
        if ($scope.application.loadingPercent < 100) {
            if (newVal == 0) {
                $scope.application.loadingPercent = 100;
            } else {
                $scope.application.loadingPercent = 100 - ((100 - $scope.application.loadingPercent) / newVal);
            }
        }
    });
    // Init error managmeent
    $scope.$on(SERVER_ERRORS.notAuthenticated, function() {
        if (!$scope.application.visibleAuthModal) {
            $scope.showAuthModal();
        }
    });
    $scope.$on(SERVER_ERRORS.clientError, function(event, error) {
        var data = error.data;
        if (!data.silent) {
            if (angular.isArray(data)) {
                notifications.error("", data[0].text);
            } else if (angular.isObject(data)) {
                notifications.error("", data.text);
            } else {
                notifications.error("", $scope.message('todo.is.ui.error.unknown'));
            }
        }
    });
    $scope.$on(SERVER_ERRORS.serverError, function(event, error) {
        var data = error.data;
        if (angular.isArray(data)) {
            notifications.error($scope.message('todo.is.ui.error.server'), data[0].text);
        } else if (angular.isObject(data)) {
            notifications.error($scope.message('todo.is.ui.error.server'), data.text);
        } else {
            notifications.error($scope.message('todo.is.ui.error.server'), $scope.message('todo.is.ui.error.unknown'));
        }
    });
}]);

controllers.controller('mainMenuCtrl', ["$scope", 'ProjectService', 'FormService', 'PushService', 'UserService', 'Session', '$uibModal', '$state', function($scope, ProjectService, FormService, PushService, UserService, Session, $uibModal, $state) {
    $scope.authorizedProject = function(action, project) {
        return ProjectService.authorizedProject(action, project);
    };
    $scope.showProjectListModal = function(listType) {
        $uibModal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + "/project/listModal",
            size: 'lg',
            controller: ['$scope', '$controller', 'ProjectService', function($scope, $controller, ProjectService) {
                $controller('abstractProjectListCtrl', {$scope: $scope});
                // Functions
                $scope.searchProjects = function() {
                    var listFunction = {
                        public: ProjectService.listPublic,
                        user: ProjectService.listByUser,
                        all: ProjectService.list
                    }[listType];
                    var params = {term: $scope.projectSearch, paginate: true, page: $scope.currentPage, count: $scope.projectsPerPage};
                    listFunction(params).then(function(projectsAndCount) {
                        $scope.projectCount = projectsAndCount.count;
                        $scope.projects = projectsAndCount.projects;
                        if (!_.isEmpty($scope.projects) && _.isEmpty($scope.project)) {
                            $scope.selectProject(_.head($scope.projects));
                        }
                    });
                };
                // Init
                $scope.projectCount = 0;
                $scope.currentPage = 1;
                $scope.projectsPerPage = 9; // Constant
                $scope.projectSearch = '';
                $scope.projects = [];
                $scope.searchProjects();
            }]
        });
    };
    $scope['import'] = function(project) {
        var url = $scope.serverUrl + "/project/import";
        $uibModal.open({
            keyboard: false,
            backdrop: 'static',
            templateUrl: url + "Dialog",
            controller: ['$scope', '$http', '$rootScope', '$timeout', function($scope, $http, $rootScope, $timeout) {
                // Functions
                $scope.showProgress = function() {
                    $scope.progress = true;
                };
                $scope.handleImportError = function($file, $message) {
                    var data = JSON.parse($message);
                    $scope.notifyError(angular.isArray(data) ? data[0].text : data.text, {duration: 8000});
                    $scope.$close(true);
                };
                $scope.checkValidation = function($message) {
                    var data = !angular.isObject($message) ? JSON.parse($message) : $message;
                    if (data && data.class == 'Project') {
                        $scope.$close(true);
                        $rootScope.application.loading = true;
                        $rootScope.application.loadingText = " ";
                        $timeout(function() {
                            document.location = $scope.serverUrl + '/p/' + data.pkey + '/';
                        }, 2000);
                    } else {
                        $scope.progress = false;
                        $scope.changes = data;
                        $scope._changes = angular.copy($scope.changes);
                        $scope._changes = angular.extend($scope._changes, {
                            showTeam: $scope.changes.team ? true : false,
                            showUsernames: $scope.changes.usernames ? true : false,
                            showEmails: $scope.changes.emails ? true : false,
                            showProjectName: $scope.changes.project ? ($scope.changes.project.name ? true : false) : false,
                            showProjectPkey: $scope.changes.project ? ($scope.changes.project.pkey ? true : false) : false
                        });
                    }
                };
                $scope.applyChanges = function() {
                    if ($scope.changes.erase) { // Don't display delete message if erasing project
                        PushService.enabled = false;
                    }
                    $http({
                        url: url,
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                        transformRequest: function(data) {
                            return FormService.formObjectData(data, 'changes.');
                        },
                        data: $scope.changes
                    }).then(function(response) {
                            var data = response.data;
                            if (data && data.class == 'Project') {
                                $scope.$close(true);
                                $rootScope.application.loading = true;
                                $rootScope.application.loadingText = " ";
                                $timeout(function() {
                                    document.location = $scope.serverUrl + '/p/' + data.pkey + '/';
                                }, 2000);
                            } else {
                                $scope.checkValidation(data);
                            }
                        }, function() {
                            $scope.progress = false;
                        }
                    );
                    $scope.progress = true;
                };
                // Init
                $scope.flowConfig = {target: url, singleFile: true};
                $scope.changes = false;
                $scope._changes = {
                    showTeam: false,
                    showProject: false
                };
                $scope.progress = false
            }]
        }).result.then(function() {}, function() {
            PushService.enabled = true;
        });
    };
    $scope['export'] = function(project) {
        var modal = $uibModal.open({
            keyboard: false,
            backdrop: 'static',
            templateUrl: "project/exportDialog",
            controller: ['$scope', function($scope) {
                $scope.zip = true;
                $scope.progress = false;
                $scope.start = function() {
                    $scope.downloadFile("project/export/zip");
                    $scope.progress = true;
                };
                $scope.start();
            }]
        });
        modal.result.then(
            function() {
                $scope.downloadFile("");
            },
            function() {
                $scope.downloadFile("");
            }
        );
    };
    // Init
    $scope.project = Session.getProject();
    $scope.menuDragging = false;
    $scope.sortableId = 'menu';
    var menuSortableChange = function(event) {
        UserService.updateMenuPreferences({
            menuId: event.source.itemScope.modelValue.id,
            position: event.dest.index + 1,
            hidden: event.dest.sortableScope.modelValue === $scope.application.menus.hidden
        }).catch(function() {
            $scope.revertSortable(event);
        });
    };
    $scope.menuSortableOptions = {
        itemMoved: menuSortableChange,
        orderChanged: menuSortableChange,
        containment: 'header',
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        },
        dragStart: function() {
            $scope.menuDragging = true;
        },
        dragEnd: function() {
            $scope.menuDragging = false;
        }
    };
}]);

extensibleController('aboutCtrl', ['$scope', 'active', function($scope, active) {
    if (active) {
        $scope.active = active;
    }
}]); // Used to extend about in plugins

controllers.controller('headerCtrl', ['$scope', '$uibModal', 'Session', 'UserService', 'hotkeys', 'PushService', 'UserTokenService', function($scope, $uibModal, Session, UserService, hotkeys, PushService, UserTokenService) {
    // Functions
    $scope.notificationToggle = function(open) {
        if (open) {
            UserService.getActivities($scope.currentUser)
                .then(function(data) {
                    var groupedActivities = [];
                    angular.forEach(data, function(notif) {
                        var augmentedActivity = notif.activity;
                        augmentedActivity.story = notif.story;
                        augmentedActivity.notRead = notif.notRead;
                        if (_.isEmpty(groupedActivities) || _.last(groupedActivities).project.pkey != notif.project.pkey) {
                            groupedActivities.push({
                                project: notif.project,
                                activities: [augmentedActivity]
                            });
                        } else {
                            _.last(groupedActivities).activities.push(augmentedActivity);
                        }
                    });
                    $scope.groupedUserActivities = groupedActivities;
                    Session.unreadActivitiesCount = 0; // Cannot do that on open == false for the moment because it is called randomly
                }
            );
        }
    };
    $scope.getUnreadActivities = function() {
        return Session.unreadActivitiesCount;
    };
    $scope.showAbout = function(activeTabIndex) {
        $uibModal.open({
            controller: 'aboutCtrl',
            templateUrl: 'scrumOS/about',
            resolve: {
                active: function() {
                    return activeTabIndex; // Set active tab unsing index
                }
            }
        });
    };
    $scope.showProfile = function() {
        $uibModal.open({
            keyboard: false,
            backdrop: 'static',
            templateUrl: $scope.serverUrl + '/user/openProfile',
            controller: 'userCtrl',
            resolve: {
                // Only used to fetch tokens under user object
                _tokens: function() {
                    return UserTokenService.list($scope.currentUser);
                }
            }
        });
    };
    $scope.getPushState = function() {
        return PushService.push.connected ? 'connected' : 'disconnected';
    };
    // Init
    $scope.currentUser = Session.user;
    $scope.roles = Session.roles;
    hotkeys.bindTo($scope).add({
        combo: 'shift+l',
        description: $scope.message('is.button.connect'),
        callback: function() {
            if (!Session.authenticated()) {
                $scope.showAuthModal();
            }
        }
    });
}]);

controllers.controller('contextCtrl', ['$scope', '$location', '$state', '$timeout', 'Session', 'CacheService', 'ContextService', function($scope, $location, $state, $timeout, Session, CacheService, ContextService) {
    // Functions
    $scope.searchContext = function(term) {
        return !Session.authenticated() ? [] : ContextService.loadContexts().then(function(contexts) {
            var filteredContexts = _.filter(contexts, function(context) {
                return _.deburr(context.term.toLowerCase()).indexOf(_.deburr(term.toLowerCase())) != -1;
            });
            var context = $scope.application.context;
            if (context) {
                _.remove(filteredContexts, {type: context.type, id: context.id});
            }
            return filteredContexts;
        });
    };
    $scope.setContext = function(context) {
        $location.search('context', context ? context.type + ContextService.contextSeparator + context.id : null);
    };
    $scope.featureContextUrl = function(feature) {
        return $state.href($state.current.name, $state.params) + '?context=feature' + ContextService.contextSeparator + feature.id;
    };
    $scope.tagContextUrl = function(tag) {
        return $state.href($state.current.name, $state.params) + '?context=tag' + ContextService.contextSeparator + tag;
    };
    $scope.hasContextOrSearch = function() {
        return $scope.application.context || $scope.application.search;
    };
    $scope.clearContextAndSearch = function() {
        $scope.setContext(null);
    };
    $scope.setContextTermAndColorIfNeeded = function() {
        if ($scope.application.context) {
            var setContextTermAndColor = function(context) {
                $scope.application.context.term = context.term;
                $scope.application.context.color = context.color;
            };
            var cachedContext = _.find(ContextService.contexts, $scope.application.context);
            if (cachedContext) {
                setContextTermAndColor(cachedContext);
            } else {
                // Hack around the context loading if the context is a feature in the cache, othwervise setting feature context from feature backlog doesn't work properly
                var cachedFeature;
                if ($scope.application.context.type == 'feature') {
                    cachedFeature = CacheService.get('feature', $scope.application.context.id);
                    if (cachedFeature) {
                        setContextTermAndColor({id: cachedFeature.id.toString(), term: cachedFeature.name, color: cachedFeature.color});
                    }
                }
                if (!cachedFeature) {
                    ContextService.loadContexts().then(function(contexts) {
                        var fetchedContext = _.find(contexts, $scope.application.context);
                        if (fetchedContext) {
                            setContextTermAndColor(fetchedContext);
                        }
                    });
                }
            }
        }
    };
    // Init
    $scope.application.context = ContextService.getContextFromUrl();
    $scope.setContextTermAndColorIfNeeded();
    $scope.$on('$locationChangeSuccess', function() {
        if ($scope.application.ignoreUrlContextChange) {
            $scope.application.ignoreUrlContextChange = false;
        } else {
            var urlContext = ContextService.getContextFromUrl();
            if (!ContextService.equalContexts($scope.application.context, urlContext)) {
                $scope.application.context = urlContext;
                $scope.setContextTermAndColorIfNeeded();
                $scope.application.search = null;
                CacheService.emptyCaches();
                $state.reload();
            }
        }
    });
    $scope.$on('$stateChangeStart', function() {
        $scope.application.ignoreUrlContextChange = true;
    });
    $scope.$on('$stateChangeError', function() {
        $scope.application.ignoreUrlContextChange = false;
    });
    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState) {
        if (!event.defaultPrevented) {
            if (fromState.name && toState.name) {
                if (fromState.name.split('.')[0] !== toState.name.split('.')[0]) {
                    $scope.application.search = null;
                }
            }
            // Preserve context across state change, no other way for the moment, see https://github.com/angular-ui/ui-router/issues/202 https://github.com/angular-ui/ui-router/issues/539
            var appContext = $scope.application.context;
            var urlContext = ContextService.getContextFromUrl();
            if (appContext && !ContextService.equalContexts(appContext, urlContext)) {
                $timeout(function() {
                    $location.replace(); // Prevent the state without the ?context... part to be save in browser history, must be in timeout to avoid that all changes during the current digest are lost
                    $scope.setContext(appContext);
                });
            } else {
                $scope.application.ignoreUrlContextChange = false;
            }
        } else {
            $scope.application.ignoreUrlContextChange = false;
        }
    });
}]);

extensibleController('loginCtrl', ['$scope', '$state', '$rootScope', 'SERVER_ERRORS', 'AuthService', function($scope, $state, $rootScope, SERVER_ERRORS, AuthService) {
    $scope.credentials = {
        j_username: $scope.username ? $scope.username : '',
        j_password: ''
    };
    $rootScope.showRegisterModal = function() {
        if ($scope.$close) {
            $scope.$close(false); // Close auth modal if present
        }
        $state.go('userregister');
    };
    $rootScope.showRetrieveModal = function() {
        $state.go('userretrieve');
    };
    $scope.login = function(credentials) {
        AuthService.login(credentials).then(function(data) {
            if (!$scope.loginCallback) {
                $scope.application.submitting = true; // Avoid duplicated login, the page reloading will set that back to false
                var lastOpenedUrl = data.url;
                var currentLocation = window.location.href.replace($rootScope.serverUrl, "");
                if ($state.params.redirectTo) {
                    document.location = $state.params.redirectTo;
                } else if (['/', '/#', '/#/', '#/'].indexOf(currentLocation) && lastOpenedUrl) {
                    document.location = lastOpenedUrl;
                } else {
                    document.location.reload(true);
                }
            } else {
                $scope.$close(data);
            }
        }, function() {
            $rootScope.$broadcast(SERVER_ERRORS.loginFailed);
        });
    };
}]);

extensibleController('registerCtrl', ['$scope', '$state', '$filter', 'User', 'UserService', 'Session', function($scope, $state, $filter, User, UserService, Session) {
    // Functions
    $scope.register = function() {
        UserService.save($scope.user).then(function() {
            $scope.$close($scope.user.username);
        });
    };
    // Init
    $scope.user = new User();
    if ($state.params.token) {
        UserService.invitationEmail($state.params.token).then(function(invitation) {
            var namesFromEmail = $filter('userNamesFromEmail')(invitation.email);
            _.merge($scope.user, namesFromEmail);
            $scope.user.token = $state.params.token;
        });
    }
    $scope.languages = {};
    $scope.languageKeys = [];
    Session.getLanguages().then(function(languages) {
        $scope.languages = languages;
        $scope.languageKeys = _.keys(languages);
        if (!$scope.user.preferences) {
            $scope.user.preferences = {};
        }
        if (!$scope.user.preferences.language) {
            $scope.user.preferences.language = _.head($scope.languageKeys);
        }
    });
}]);

extensibleController('retrieveCtrl', ['$scope', '$timeout', 'User', 'UserService', function($scope, $timeout, User, UserService) {
    // Functions
    $scope.retrieve = function() {
        UserService.retrievePassword($scope.user).then(function(data) {
            $scope.$close();
            $timeout(function() {
                $scope.notifySuccess(data.text);
            });
        });
    };
    // Init
    $scope.user = new User();
}]);

controllers.controller('warningsCtrl', ['$scope', 'FormService', function($scope, FormService) {
    // Functions
    $scope.hideWarning = function(warning) {
        FormService.httpPost('scrumOS/hideWarning', {warningId: warning.id}, true).then(function(data) {
            warning.silent = data.silent;
        });
    };
    // Init
    FormService.httpGet('scrumOS/warnings').then(function(data) {
        $scope.warnings = data;
    });
}]);

controllers.controller('updateFormController', ['$scope', 'FormService', 'type', 'item', function($scope, FormService, type, item) {
    var upperType = _.upperFirst(type);
    var resetForm = 'reset' + upperType + 'Form';
    var authorized = 'authorized' + upperType;
    var form = type + 'Form';
    var editable = 'editable' + upperType;
    var editableReference = editable + 'Reference';
    // Functions
    $scope.isDirty = function() {
        return !_.isEqual($scope[editable], $scope[editableReference]);
    };
    $scope.isLatest = function() {
        return $scope[editable].lastUpdated == $scope[type].lastUpdated;
    };
    $scope.editForm = function(value) {
        if ($scope.formEditable() && value != $scope.formHolder.editing) {
            $scope.setInEditingMode(value); // global
            $scope[resetForm]();
        }
    };
    $scope.formEditable = function() {
        return $scope[authorized]('update', $scope[type]);
    };
    $scope[resetForm] = function() {
        $scope.formHolder.editing = $scope.formEditable() && $scope.isInEditingMode();
        if ($scope.formHolder.editing) {
            $scope[editable] = angular.copy($scope[type]);
            $scope[editableReference] = angular.copy($scope[type]);
        } else {
            $scope[editable] = $scope[type];
            $scope[editableReference] = $scope[type];
        }
        if ($scope.resetCallback) {
            $scope.resetCallback();
        }
        $scope.resetFormValidation($scope.formHolder[form]);
    };
    // Init
    $scope[type] = item;
    $scope[editable] = {};
    $scope[editableReference] = {};
    $scope.formHolder = {};
    $scope[resetForm]();
    FormService.addStateChangeDirtyFormListener($scope, function() { $scope.update($scope[editable]); }, type, true);
    $scope.$watch(type + '.lastUpdated', function() {
        if ($scope.isInEditingMode() && !$scope.isDirty()) {
            $scope[resetForm]();
        }
    });
}]);

controllers.controller('menuItemCtrl', ['$scope', function($scope) {
    $scope.getItem = function() {
        return $scope[$scope.itemType];
    };
}]);

controllers.controller("elementsListMenuCtrl", ['$scope', '$element', '$timeout', 'WindowService', '$state', function($scope, $element, $timeout, WindowService, $state) {
    var self = this;
    // Functions
    $scope.hideAndOrderElementsFromSettings = function(elementsList) {
        if ($scope.savedHiddenElementsOrder) {
            var partitionedElementsList = _.partition(elementsList, function(elem) {
                return _.includes($scope.savedHiddenElementsOrder, elem[self.propId])
            });
            $scope.hiddenElementsList = partitionedElementsList[0];
            $scope.visibleElementsList = partitionedElementsList[1];
        } else {
            $scope.visibleElementsList = elementsList.slice();
            $scope.hiddenElementsList = [];
        }
        if ($scope.savedHiddenElementsOrder) {
            $scope.hiddenElementsList = _.sortBy($scope.hiddenElementsList, function(elem) {
                return $scope.savedHiddenElementsOrder.indexOf(elem[self.propId]);
            });
        }
        if ($scope.savedVisibleElementsOrder) {
            // visibleElementsOrder is only used to order visible elements.
            // new elements (not in savedVisibleElementsOrder) should appear last in list.
            var partitionedVisibleElementsList = _.partition($scope.visibleElementsList, function(elem) {
                return _.includes($scope.savedVisibleElementsOrder, elem[self.propId])
            });
            $scope.visibleElementsList = _.sortBy(partitionedVisibleElementsList[0], function(elem) {
                return $scope.savedVisibleElementsOrder.indexOf(elem[self.propId]);
            }).concat(partitionedVisibleElementsList[1]);
        }
    };
    $scope.hideElementsToFitAvailableSpace = function() {
        var navTabsSize = $element.children('#elementslist-list').outerWidth();
        var btnToolbarSize = $element.children('#elementslist-toolbar').outerWidth();
        var totalSpace = $element.width();
        var leftSpace = totalSpace - navTabsSize - btnToolbarSize;
        if (leftSpace <= 5 && $scope.visibleElementsList.length > 0) {
            $scope.hiddenElementsList.unshift($scope.visibleElementsList.pop());
        }
        if ((leftSpace >= 210 && $scope.hiddenElementsList.length >= 2) || (leftSpace >= 160 && $scope.hiddenElementsList.length == 1)) {
            if (!_.includes($scope.savedHiddenElementsOrder, _.head($scope.hiddenElementsList).code)) {
                $scope.visibleElementsList.push($scope.hiddenElementsList.shift());
            }
        }
    };
    $scope.saveElementsListOrder = function(destScope) {
        var allElements = _.concat(
            _.map(destScope.visibleElementsList, self.propId),
            _.map(destScope.hiddenElementsList, self.propId)
        );
        $scope.savedVisibleElementsOrder = _.difference(allElements, $scope.savedHiddenElementsOrder);
        $scope.savedHiddenElementsOrder = _.intersection(allElements, $scope.savedHiddenElementsOrder);
        var newWindowSettings = {
            elementsListOrder: $scope.savedVisibleElementsOrder,
            hiddenElementsListOrder: $scope.savedHiddenElementsOrder
        };
        destScope.saveOrUpdateWindowSettings(newWindowSettings);
    };
    $scope.initialize = function(elementsList, parentView, propId) {
        self.type = parentView;
        self.parentView = parentView;
        self.propId = propId ? propId : 'id';
        $scope.elementsList = elementsList;
        $scope.visibleElementsList = [];
        $scope.hiddenElementsList = [];
        $scope.savedHiddenElementsOrder = $scope.getWindowSetting('hiddenElementsListOrder');
        $scope.savedVisibleElementsOrder = $scope.getWindowSetting('elementsListOrder');
        $scope.hideAndOrderElementsFromSettings(elementsList);
        $timeout($scope.hideElementsToFitAvailableSpace, 0, true);
    };
    $scope.isShown = function(element) {
        return _.includes([$state.params.pinnedElementId, $state.params.elementId], element[self.propId].toString());
    };
    $scope.isShownInMore = function() {
        return _.some($scope.hiddenElementsList, $scope.isShown);
    };
    $scope.isPinned = function(element) {
        return $state.params.pinnedElementId === element[self.propId];
    };
    $scope.toggleElementUrl = function(element) {
        if ($scope.isShown(element)) {
            if (!$state.params.pinnedElementId == !$state.params.elementId) { // Dirty hack to do a XOR
                return $scope.closeElementUrl(element);
            } else {
                return $state.href('.');
            }
        } else {
            var stateName = _.startsWith($state.current.name, self.parentView + '.' + self.type) || _.startsWith($state.current.name, self.parentView + '.multiple') ? '.' : self.parentView + '.' + self.type;
            return $state.href(stateName, {elementId: element[self.propId]});
        }
    };
    $scope.togglePinElementUrl = function(element) {
        var stateName;
        var stateParams;
        if ($scope.isPinned(element)) {
            stateName = '.' + self.parentView;
            stateParams = {elementId: element[self.propId]};
        } else {
            stateName = '.multiple';
            stateParams = {pinnedElementId: element[self.propId]};
            stateParams.elementId = $state.params.pinnedElementId ? $state.params.pinnedElementId : ($state.params.elementId !== element[self.propId] ? $state.params.elementId : null);
        }
        return $state.href(self.parentView + stateName, stateParams);
    };
    $scope.clickOnElementHref = function($event) {
        var href = angular.element($event.target).attr('href');
        if (href) {
            $event.preventDefault();
            $event.stopPropagation();
            document.location = href;
        }
    };
    $scope.sortableId = 'elements-list-menu';
    $scope.elementsListSortableOptions = {
        containment: '.elements-list',
        containerPositioning: 'relative',
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        },
        orderChanged: function(event) {
            $scope.saveElementsListOrder(event.dest.sortableScope);
        },
        itemMoved: function(event) {
            if (event.dest.sortableScope.modelValue === $scope.visibleElementsList) {
                _.pull($scope.savedHiddenElementsOrder, event.source.itemScope.modelValue[self.propId]);
            }
            if (event.dest.sortableScope.modelValue === $scope.hiddenElementsList) {
                // Save the elements below this element in hidden list as well,
                // so that elements order never changes even if this element was dragged
                // while other elements where hidden only because of the available space.
                var hiddenElemIndex = _.indexOf($scope.hiddenElementsList, event.source.itemScope.modelValue);
                if ($scope.hiddenElementsList.length > hiddenElemIndex) {
                    $scope.savedHiddenElementsOrder = _.concat($scope.savedHiddenElementsOrder,
                        _.filter(
                            _.map(
                                _.takeRight($scope.hiddenElementsList, $scope.hiddenElementsList.length - hiddenElemIndex)
                                , 'code')
                            , function(elemCode) {
                                return !_.includes($scope.savedHiddenElementsOrder, elemCode)

                            }
                        )
                    );
                }
            }
            $scope.saveElementsListOrder(event.dest.sortableScope);
        },
        dragStart: function() {
            $scope.menuDragging = true;
        },
        dragEnd: function() {
            $scope.menuDragging = false;
            $timeout($scope.hideElementsToFitAvailableSpace, 0, true);
        }
    };
    $scope.closeElementUrl = function(element) {
        var stateParams;
        if (element[self.propId] === $state.params.pinnedElementId) {
            stateParams = {pinnedElementId: $state.params.elementId, elementId: null};
        } else {
            stateParams = {elementId: null};
        }
        return $state.href('.', stateParams);
    };
    $scope.menuDragging = false;
    // Watchers
    $scope.$watchCollection('elementsList', function() {
        $scope.hideAndOrderElementsFromSettings($scope.elementsList);
        $timeout($scope.hideElementsToFitAvailableSpace, 0, true);
    });
    $scope.$watchCollection('hiddenElementsList', function() {
        $timeout($scope.hideElementsToFitAvailableSpace, 0, true);
    });
    $(window).on("resize.elementsList", _.throttle($scope.hideElementsToFitAvailableSpace, 200));
    $scope.$on("$destroy", function() {
        $(window).off("resize.elementsList");
    });
}]);