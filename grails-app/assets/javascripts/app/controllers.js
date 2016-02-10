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

controllers.controller('appCtrl', ['$controller', '$scope', '$state', '$uibModal', 'SERVER_ERRORS', 'Fullscreen', 'notifications', '$http', function($controller, $scope, $state, $uibModal, SERVER_ERRORS, Fullscreen, notifications, $http) {
    $controller('headerCtrl', {$scope: $scope});
    $controller('searchCtrl', {$scope: $scope});
    // Functions
    $scope.displayDetailsView = function() {
        var data = '';
        if ($state.current.views) {
            var isDetails = _.any(_.keys($state.current.views), function(viewName) {
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
    $scope.fullScreen = function() {
        if (Fullscreen.isEnabled()) {
            Fullscreen.cancel();
            $scope.app.isFullScreen = false;
        }
        else {
            var el = angular.element('.main > div:first-of-type');
            if (el.length > 0) {
                Fullscreen.enable(el[0]);
                $scope.app.isFullScreen = !$scope.app.isFullScreen;
            }
        }
    };
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
            $scope.app.loadingPercent += 10;
        }
    });
    $scope.$on('$stateChangeStart', function() {
        $scope.app.loading = true;
        if ($scope.app.loadingPercent != 100) {
            $scope.app.loadingPercent += 10;
        }
    });
    $scope.$on('$stateChangeSuccess', function() {
        $scope.app.loading = false;
        if ($scope.app.loadingPercent != 100) {
            $scope.app.loadingPercent = 100;
        }
    });
    $scope.$watch(function() {
        return $http.pendingRequests.length;
    }, function(newVal) {
        $scope.app.loading = newVal > 0;
        if ($scope.app.loading && $scope.app.loadingPercent < 100) {
            $scope.app.loadingPercent = 100 - ((100 - $scope.app.loadingPercent) / newVal);
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
    // TODO remove, user role change for dev only
    $scope.changeRole = function(newRole) {
        Session.changeRole(newRole);
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
            id: event.source.itemScope.modelValue.id,
            position: event.dest.index + 1,
            hidden: event.dest.sortableScope.modelValue === $scope.menus.hidden
        });
    };
    $scope.menuSortableOptions = {
        itemMoved: menuSortableChange,
        orderChanged: menuSortableChange,
        containment: '#header',
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        },
        dragStart: function() { $scope.menuDragging = true; },
        dragEnd: function() { $scope.menuDragging = false; }
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

controllers.controller('searchCtrl', ['$scope', '$filter', '$q', '$location', '$window', '$injector', 'Session', 'ProjectService', function($scope, $filter, $q, $location, $window, $injector, Session, ProjectService) {
    // Functions
    $scope.searchContext = function(term) {
        return !Session.authenticated() ? [] : $scope.loadContexts().then(function() {
            var filteredResult = _.filter($scope.contexts, function(context) {
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
        $location.search('context', context ? context.type + ':' + context.id : null);
        $window.location.reload();
    };
    $scope.setFeatureContext = function(feature) {
        $scope.setContext({type: 'feature', id: feature.id});
    };
    $scope.setTagContext = function(tag) {
        $scope.setContext({type: 'tag', id: tag});
    };
    $scope.loadContexts = function() {
        var FeatureService = $injector.get('FeatureService'); // Warning: cannot be injected in the controller because it will init the service systematically and call Feature.query which require authentication
        return $q.all([ProjectService.getTags(), FeatureService.list.$promise]).then(function(data) {
            var tags = data[0];
            var features = data[1];
            var contexts = _.map(tags, function(tag) {
                return {type: 'tag', id: tag, term: tag};
            });
            contexts = contexts.concat(_.map(features, function(feature) {
                return {type: 'feature', id: feature.uid.toString(), term: feature.name};
            }));
            $scope.contexts = contexts;
        });
    };
    // Init
    var context = $location.search().context;
    if (context === true || !context || context.indexOf(':') == -1) { // ?context with no value returns true, we don't want that
        $location.search('context', null);
        $scope.app.context = null;
    } else {
        var contextFields = context.split(':');
        var type = contextFields[0];
        var id = contextFields[1];
        $scope.app.context = {type: type, id: id}; // Partial context as soon as possible
        $scope.loadContexts().then(function() {
            $scope.app.context = _.find($scope.contexts, $scope.app.context); // Load the full context to get the name in case of feature
        });
    }
    // Preserve context across state change, no other way for the moment, see https://github.com/angular-ui/ui-router/issues/202 https://github.com/angular-ui/ui-router/issues/539
    $scope.$on('$stateChangeSuccess', function() {
        var context = $scope.app.context;
        if (context) {
            $location.search('context', context.type + ':' + context.id);
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
            $scope.$close(); // Close auth modal if present
        }
        $state.go('userregister');
    };
    $rootScope.showRetrieveModal = function() {
        $state.go('userretrieve');
    };
    $scope.login = function(credentials) {
        AuthService.login(credentials).then(function(data) {
            var lastOpenedUrl = data.url;
            var normalizedCurrentLocation = window.location.href.charAt(window.location.href.length - 1) == '/' ? window.location.href.substring(0, window.location.href.length - 1) : window.location.href;
            if (normalizedCurrentLocation == $rootScope.serverUrl && lastOpenedUrl) {
                document.location = lastOpenedUrl;
            } else {
                document.location.reload(true);
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
            $scope.$close($scope.user.username);
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
            $scope.user.preferences.language = _.first($scope.languageKeys);
        }
    });
}]);

controllers.controller('retrieveCtrl', ['$scope', 'User', 'UserService', function($scope, User, UserService) {
    // Functions
    $scope.retrieve = function() {
        UserService.retrievePassword($scope.user).then(function() {
            $scope.$close();
        });
    };
    // Init
    $scope.user = new User();
}]);