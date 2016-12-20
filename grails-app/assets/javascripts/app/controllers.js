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

var registerAppController = function(appControllerName, controllerArray) {
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

controllers.controller('appCtrl', ['$controller', '$scope', '$localStorage', '$state', '$uibModal', 'SERVER_ERRORS', 'Fullscreen', 'notifications', '$http', '$window', '$timeout', function($controller, $scope, $localStorage, $state, $uibModal, SERVER_ERRORS, Fullscreen, notifications, $http, $window, $timeout) {
    $controller('headerCtrl', {$scope: $scope});
    $controller('searchCtrl', {$scope: $scope});
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
    $scope.openStorySelectorModal = function(options) {
        $uibModal.open({
            templateUrl: 'story.selector.html',
            size: 'md',
            controller: ["$scope", "$filter", "StoryService", function($scope, $filter, StoryService) {
                var liveFilter;
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
        $scope.app.isFullScreen = !$scope.app.isFullScreen;
    };
    // Postit size
    $scope.currentPostitSize = function(viewName, defaultSize) {
        var contextSizeName = viewName + 'PostitSize';
        if (!$localStorage[contextSizeName]) {
            $localStorage[contextSizeName] = defaultSize;
        }
        return $localStorage[contextSizeName];
    };
    $scope.isAsListPostit = function(viewName) {
        return $scope.currentPostitSize(viewName) == "list-group"
    };
    $scope.iconCurrentPostitSize = function(viewName) {
        var icon;
        switch ($scope.currentPostitSize(viewName)) {
            case 'grid-group':
                icon = 'fa-sticky-note fa-xl';
                break;
            case 'grid-group size-sm':
                icon = 'fa-sticky-note fa-lg';
                break;
            case 'grid-group size-xs':
                icon = 'fa-sticky-note';
                break;
            case 'list-group':
                icon = 'fa-list';
                break;
            default:
                icon = 'fa-sticky-note';
                break;
        }
        return icon;
    };
    $scope.setPostitSize = function(viewName) {
        var next;
        switch ($scope.currentPostitSize(viewName)) {
            case 'grid-group':
                next = 'grid-group size-sm';
                break;
            case 'grid-group size-sm':
                next = 'grid-group size-xs';
                break;
            case 'grid-group size-xs':
                next = 'list-group';
                break;
            default:
            case 'list-group':
                next = 'grid-group';
                break;
        }
        var contextSizeName = viewName + 'PostitSize';
        $localStorage[contextSizeName] = next;
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
        $scope.app.loading = true;
        if ($scope.app.loadingPercent < 90) {
            $scope.app.loadingPercent += 5;
        }
    });
    // Init loading
    var w = angular.element($window);
    var resizeTimeout = null;
    $scope.$on('$viewContentLoaded', function(event) {
        if (!event.defaultPrevented) {
            if ($scope.app.loadingPercent < 90) {
                $scope.app.loadingPercent += 5;
            } else {
                $scope.app.loading = false;
            }
            $timeout.cancel(resizeTimeout);
            resizeTimeout = $timeout(function() {
                w.triggerHandler('resize');
            }, 50);
        }
    });
    $scope.$on('$stateChangeStart', function(event) {
        if (!event.defaultPrevented) {
            $scope.app.loading = true;
            if ($scope.app.loadingPercent != 100) {
                $scope.app.loadingPercent += 10;
            }
        }
    });
    $scope.$on('$stateChangeSuccess', function(event) {
        if (!event.defaultPrevented) {
            $scope.app.loading = false;
            if ($scope.app.loadingPercent != 100) {
                $scope.app.loadingPercent = 100;
            }
        }
    });
    $scope.$watch(function() {
        return $http.pendingRequests.length;
    }, function(newVal) {
        $scope.app.loading = newVal > 0 || $scope.app.loadingPercent < 100;
        if ($scope.app.loadingPercent < 100) {
            if (newVal == 0) {
                $scope.app.loadingPercent = 100;
            } else {
                $scope.app.loadingPercent = 100 - ((100 - $scope.app.loadingPercent) / newVal);
            }
        }
    });
    // Init error managmeent
    $scope.$on(SERVER_ERRORS.notAuthenticated, function() {
        $scope.showAuthModal();
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

controllers.controller('headerCtrl', ['$scope', '$uibModal', 'Session', 'UserService', 'hotkeys', 'PushService', function($scope, $uibModal, Session, UserService, hotkeys, PushService) {
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
    $scope.showAbout = function() {
        $uibModal.open({
            templateUrl: 'scrumOS/about'
        });
    };
    $scope.showProfile = function() {
        $uibModal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + '/user/openProfile',
            controller: 'userCtrl'
        });
    };
    $scope.showManageTeamsModal = function() {
        $uibModal.open({
            keyboard: false,
            templateUrl: $scope.serverUrl + "/team/manage",
            size: 'lg',
            controller: 'manageTeamsModalCtrl'
        });
    };
    $scope.getPushState = function() {
        return PushService.push.connected ? 'connected' : 'disconnected';
    };
    // Init
    $scope.currentUser = Session.user;
    $scope.roles = Session.roles;
    $scope.menuDragging = false;
    var menuSortableChange = function(event) {
        UserService.updateMenuPreferences({
            menuId: event.source.itemScope.modelValue.id,
            position: event.dest.index + 1,
            hidden: event.dest.sortableScope.modelValue === $scope.app.menus.hidden
        }).catch(function() {
            $scope.revertSortable(event);
        });
    };
    $scope.menuSortableOptions = {
        itemMoved: menuSortableChange,
        orderChanged: menuSortableChange,
        containment: '#header',
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

controllers.controller('searchCtrl', ['$scope', '$location', '$state', '$timeout', 'Session', 'CacheService', 'ContextService', function($scope, $location, $state, $timeout, Session, CacheService, ContextService) {
    // Functions
    $scope.searchContext = function(term) {
        return !Session.authenticated() ? [] : ContextService.loadContexts().then(function(contexts) {
            var filteredResult = _.filter(contexts, function(context) {
                return _.deburr(context.term.toLowerCase()).indexOf(_.deburr(term.toLowerCase())) != -1;
            });
            var context = $scope.app.context;
            if (context) {
                _.remove(filteredResult, {type: context.type, id: context.id});
            }
            return filteredResult;
        });
    };
    $scope.setContext = function(context) {
        $location.search('context', context ? context.type + ContextService.contextSeparator + context.id : null);
    };
    $scope.setFeatureContext = function(feature) {
        $scope.setContext({type: 'feature', id: feature.id, term: feature.name});
    };
    $scope.setTagContext = function(tag) {
        $scope.setContext({type: 'tag', id: tag, term: tag});
    };
    $scope.hasContextOrSearch = function() {
        return $scope.app.context || $scope.app.search;
    };
    $scope.clearContextAndSearch = function() {
        $scope.setContext(null);
    };
    $scope.setContextTermAndColorIfNeeded = function() {
        if ($scope.app.context) {
            var cachedContext = _.find(ContextService.contexts, $scope.app.context);
            if (cachedContext) {
                $scope.app.context.term = cachedContext.term;
                $scope.app.context.color = cachedContext.color;
            } else {
                ContextService.loadContexts().then(function(contexts) {
                    var fetchedContext = _.find(contexts, $scope.app.context);
                    if (fetchedContext) {
                        $scope.app.context.term = fetchedContext.term;
                        $scope.app.context.color = fetchedContext.color;
                    }
                })
            }
        }
    };
    // Init
    $scope.app.context = ContextService.getContextFromUrl();
    $scope.setContextTermAndColorIfNeeded();
    $scope.$on('$locationChangeSuccess', function() {
        if ($scope.app.ignoreUrlContextChange) {
            $scope.app.ignoreUrlContextChange = false;
        } else {
            var urlContext = ContextService.getContextFromUrl();
            if (!ContextService.equalContexts($scope.app.context, urlContext)) {
                $scope.app.context = urlContext;
                $scope.setContextTermAndColorIfNeeded();
                $scope.app.search = null;
                CacheService.emptyCaches();
                $state.reload();
            }
        }
    });
    $scope.$on('$stateChangeStart', function() {
        $scope.app.ignoreUrlContextChange = true;
    });
    $scope.$on('$stateChangeError', function() {
        $scope.app.ignoreUrlContextChange = false;
    });
    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState) {
        if (!event.defaultPrevented) {
            if (fromState.name && toState.name) {
                if (fromState.name.split('.')[0] !== toState.name.split('.')[0]) {
                    $scope.app.search = null;
                }
            }
            // Preserve context across state change, no other way for the moment, see https://github.com/angular-ui/ui-router/issues/202 https://github.com/angular-ui/ui-router/issues/539
            var appContext = $scope.app.context;
            var urlContext = ContextService.getContextFromUrl();
            if (appContext && !ContextService.equalContexts(appContext, urlContext)) {
                $timeout(function() {
                    $location.replace(); // Prevent the state without the ?context... part to be save in browser history, must be in timeout to avoid that all changes during the current digest are lost
                    $scope.setContext(appContext);
                });
            } else {
                $scope.app.ignoreUrlContextChange = false;
            }
        } else {
            $scope.app.ignoreUrlContextChange = false;
        }
    });
}]);

controllers.controller('loginCtrl', ['$scope', '$state', '$rootScope', 'SERVER_ERRORS', 'AuthService', function($scope, $state, $rootScope, SERVER_ERRORS, AuthService) {
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
                var lastOpenedUrl = data.url;
                var normalizedCurrentLocation = window.location.href.charAt(window.location.href.length - 1) == '/' ? window.location.href.substring(0, window.location.href.length - 1) : window.location.href;
                if (normalizedCurrentLocation == $rootScope.serverUrl && lastOpenedUrl) {
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

controllers.controller('registerCtrl', ['$scope', '$state', 'User', 'UserService', 'Session', function($scope, $state, User, UserService, Session) {
    // Functions
    $scope.register = function() {
        UserService.save($scope.user).then(function() {
            $scope.$close($scope.user.email);
        });
    };
    // Init
    $scope.user = new User();
    if ($state.params.token) {
        UserService.getInvitationUserMock($state.params.token).then(function(mockUser) {
            _.merge($scope.user, mockUser);
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

controllers.controller('retrieveCtrl', ['$scope', '$timeout', 'User', 'UserService', function($scope, $timeout, User, UserService) {
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

controllers.controller('updateFormController', ['$scope', 'FormService', 'type', 'item', 'resetOnProperties', function($scope, FormService, type, item, resetOnProperties) {
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
        if ($scope.formHolder.editable() && value != $scope.formHolder.editing) {
            $scope.setInEditingMode(value); // global
            $scope[resetForm]();
        }
    };
    $scope[resetForm] = function() {
        $scope.formHolder.editable = function() {
            return $scope[authorized]('update', $scope[type]);
        };
        $scope.formHolder.editing = $scope.formHolder.editable() && $scope.isInEditingMode();
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
    if (resetOnProperties.length > 0) {
        var resetOnPropertiesW = '';
        var length = resetOnProperties.length - 1;
        _.each(resetOnProperties, function(resetOnProperty, index) {
            resetOnPropertiesW += type + '.' + resetOnProperty;
            if (index != length) {
                resetOnPropertiesW += ';';
            }
        });
        $scope.$watch(resetOnPropertiesW, function() {
            if ($scope.isInEditingMode() && !$scope.isDirty()) {
                $scope[resetForm]();
                $scope.editForm(true);
            }
        });
    }
}]);