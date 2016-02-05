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

controllers.controller('appCtrl', ['$scope', '$state', '$uibModal', 'Session', 'UserService', 'SERVER_ERRORS', 'Fullscreen', 'notifications', '$interval', '$timeout', 'hotkeys', 'PushService', '$http',
    function($scope, $state, $uibModal, Session, UserService, SERVER_ERRORS, Fullscreen, notifications, $interval, $timeout, hotkeys, PushService, $http) {
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
        $scope.getPushState = function() {
            return PushService.push.connected ? 'connected' : 'disconnected';
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

        //begin state loading app
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
        //end state loading app

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

        hotkeys.bindTo($scope).add({
            combo: 'shift+l',
            description: $scope.message('is.button.connect'),
            callback: function() {
                if (!Session.authenticated()) {
                    $scope.showAuthModal();
                }
            }
        });
    }]).controller('loginCtrl', ['$scope', '$state', '$rootScope', 'SERVER_ERRORS', 'AuthService', function($scope, $state, $rootScope, SERVER_ERRORS, AuthService) {
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
}]).controller('registerCtrl', ['$scope', '$state', 'User', 'UserService', 'Session', function($scope, $state, User, UserService, Session) {
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
}]).controller('retrieveCtrl', ['$scope', 'User', 'UserService', function($scope, User, UserService) {
    // Functions
    $scope.retrieve = function() {
        UserService.retrievePassword($scope.user).then(function() {
            $scope.$close();
        });
    };
    // Init
    $scope.user = new User();

}]);

controllers.controller('selectableCtrl', ['$scope', '$state', function($scope, $state) {
    // Functions
    $scope.isSelected = function(selectable) {
        if ($state.params.id) {
            return $state.params.id == selectable.id;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), selectable.id.toString());
        } else {
            return false;
        }
    };
    $scope.hasSelected = function() {
        return $state.params.id != undefined || $state.params.listId != undefined;
    };
    $scope.toggleSelectableMultiple = function() {
        $scope.app.selectableMultiple = !$scope.app.selectableMultiple;
        if ($state.params.listId != undefined) {
            $state.go($scope.viewName);
        }
    };
    // Init
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        multiple: true,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + '.details' + ($state.params.tabId ? '.tab' : ''), {id: selectedIds});
                    break;
                default:
                    $state.go($scope.viewName + '.multiple', {listId: selectedIds.join(",")});
                    break;
            }
        }
    };
}]);

controllers.controller('featuresCtrl', ['$scope', '$controller', 'FeatureService', 'features', function($scope, $controller, FeatureService, features) {
    $controller('selectableCtrl', {$scope: $scope});
    // Functions
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };
    $scope.orderByRank = function() {
        $scope.orderBy.reverse = false;
        $scope.orderBy.current = _.find($scope.orderBy.values, {id: 'rank'});
    };
    $scope.isSortableFeature = function() {
        return FeatureService.authorizedFeature('rank');
    };
    $scope.isSortingFeature = function() {
        return $scope.isSortableFeature() && $scope.orderBy.current.id == 'rank' && !$scope.orderBy.reverse;
    };
    // Init
    $scope.viewName = 'feature';
    $scope.features = features;
    var updateRank = function(event) {
        _.each(event.dest.sortableScope.modelValue, function(feature, index) {
            feature.rank = index + 1;
        });
        var feature = event.source.itemScope.modelValue;
        feature.rank = event.dest.index + 1;
        FeatureService.update(feature);
    };
    $scope.featureSortableOptions = {
        itemMoved: updateRank,
        orderChanged: updateRank,
        accept: function(sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.sortableId = 'feature';
    $scope.orderBy = {
        current: {id: 'dateCreated', name: $scope.message('todo.is.ui.sort.date')},
        values: _.sortBy([
            {id: 'rank', name: $scope.message('todo.is.ui.sort.rank')},
            {id: 'dateCreated', name: $scope.message('todo.is.ui.sort.date')},
            {id: 'name', name: $scope.message('todo.is.ui.sort.name')},
            {id: 'stories_ids.length', name: $scope.message('todo.is.ui.sort.stories')},
            {id: 'value', name: $scope.message('todo.is.ui.sort.value')},
            {id: 'state', name: $scope.message('todo.is.ui.sort.state')}
        ], 'name')
    };
    $scope.orderByRank();
}]);

controllers.controller('releasePlanCtrl', ['$scope', '$state', 'ReleaseService', 'SprintService', 'ProjectService', 'SprintStatesByName', 'ReleaseStatesByName', 'project', 'releases', function($scope, $state, ReleaseService, SprintService, ProjectService, SprintStatesByName, ReleaseStatesByName, project, releases) {
    // Functions
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    // Init
    $scope.viewName = 'releasePlan';
    $scope.project = project;

    //TODO bug fix: releases MAY BE empty on refresh
    project.releases = releases;

    $scope.releases = project.releases;
    $scope.sprints = [];

    $scope.timelineSelected = function(selectedItems) { // Timeline -> URL
        if (selectedItems.length == 0) {
            $state.go('releasePlan');
        } else if (selectedItems.length == 1 && selectedItems[0].class == 'Release') {
            var release = selectedItems[0];
            $state.go('releasePlan.release.details', {id: release.id});
        } else if (selectedItems.length == 1 && selectedItems[0].class == 'Sprint') {
            var sprint = selectedItems[0];
            var releaseId = sprint.parentRelease.id;
            $state.go('releasePlan.release.sprint.withId.details', {id: releaseId, sprintId: sprint.id});
        } else {
            var releaseId = selectedItems[0].parentRelease.id;
            $state.go('releasePlan.release.sprint.multiple.details', {id: releaseId, listId: _.map(selectedItems, 'id')});
        }
    };
    $scope.$watchGroup([function() { return $state.$current.self.name; }, function() { return $state.params.id; }, function() { return $state.params.sprintId; }, function() { return $state.params.listId; }], function(newValues) {
        var stateName = newValues[0];
        var releaseId = newValues[1];
        var sprintId = newValues[2];
        var sprintListId = newValues[3];
        var release = _.find($scope.releases, {id: releaseId});
        if (release && stateName.indexOf('.sprint') != -1 && stateName.indexOf('.new') == -1) {
            if (sprintId) {
                $scope.sprints = [_.find(release.sprints, {id: sprintId})];
            } else if (sprintListId) {
                var ids = _.map(sprintListId.split(','), function(id) {
                    return parseInt(id);
                });
                $scope.sprints = _.filter(release.sprints, function(sprint) {
                    return _.contains(ids, sprint.id);
                });
            } else {
                var sprint = _.find(release.sprints, function(sprint) {
                    return sprint.state == SprintStatesByName.WAIT || sprint.state == SprintStatesByName.IN_PROGRESS;
                });
                if (!sprint) {
                    sprint = _.last(release.sprints);
                }
                $scope.sprints = [sprint];
            }
            $scope.selectedItems = $scope.sprints; // URL -> Timeline
        } else {
            if (!release) {
                release = _.find($scope.releases, function(release) {
                    return release.state == ReleaseStatesByName.WAIT || release.state == ReleaseStatesByName.IN_PROGRESS;
                });
                if (!release) {
                    release = _.last($scope.releases);
                }
            }
            if (release) {
                $scope.sprints = release.sprints;
                $scope.selectedItems = [release]; // URL -> Timeline
            }
        }
        $scope.release = release;
    });
}]);

controllers.controller('sprintPlanCtrl', ['$scope', '$state', '$filter', 'UserService', 'StoryService', 'TaskService', 'Session', 'SprintStatesByName', 'StoryStatesByName', 'TaskStatesByName', 'sprint', function($scope, $state, $filter, UserService, StoryService, TaskService, Session, SprintStatesByName, StoryStatesByName, TaskStatesByName, sprint) {
    $scope.viewName = 'sprintPlan';
    // Functions
    $scope.isSelected = function(selectable) {
        return $state.params.taskId ? $state.params.taskId == selectable.id : false;
    };
    $scope.hasSelected = function() {
        return $state.params.taskId != undefined;
    };
    $scope.isSortableSprintPlan = function(sprint) {
        return Session.authenticated() && sprint.state < SprintStatesByName.DONE;
    };
    $scope.isSortingSprintPlan = function(sprint) {
        return $scope.isSortableSprintPlan(sprint) && $scope.currentSprintFilter.id == 'allTasks';
    };
    $scope.isSortingStory = function(story) {
        return story.state < StoryStatesByName.DONE;
    };
    $scope.openSprint = function(sprint) {
        $state.go('sprintPlan.details', {id: sprint.id});
    };
    $scope.openNewTaskByStory = function(story) {
        $state.go('sprintPlan.task.new', {taskTemplate: {parentStory: _.pick(story, ['id', 'name'])}});
    };
    $scope.openNewTaskByType = function(type) {
        $state.go('sprintPlan.task.new', {taskTemplate: {type: type}});
    };
    $scope.refreshTasks = function() {
        $scope.sprintTaskStates = $scope.sprint.state < SprintStatesByName.DONE ? $scope.taskStates : [TaskStatesByName.DONE];
        var partitionedTasks = _.partition($scope.sprint.tasks, function(task) {
            return _.isNull(task.parentStory);
        });
        var groupByStateAndSort = function(tasksDictionnary) {
            return _.mapValues(tasksDictionnary, function(tasks) {
                return _.mapValues(_.groupBy(tasks, 'state'), function(tasks) {
                    return _.sortBy($filter('filter')(tasks, $scope.currentSprintFilter.filter), 'rank');
                });
            });
        };
        $scope.tasksByTypeByState = groupByStateAndSort(_.groupBy(partitionedTasks[0], 'type'));
        $scope.tasksByStoryByState = groupByStateAndSort(_.groupBy(partitionedTasks[1], 'parentStory.id'));
        var fillGapsInDictionnary = function(dictionnary, firstLevelKeys, secondLevelKeys) {
            _.each(firstLevelKeys, function(firstLevelKey) {
                if (!dictionnary[firstLevelKey]) {
                    dictionnary[firstLevelKey] = {};
                }
                _.each(secondLevelKeys, function(secondLevelKey) {
                    if (!dictionnary[firstLevelKey][secondLevelKey]) {
                        dictionnary[firstLevelKey][secondLevelKey] = [];
                    }
                });
            });
        };
        fillGapsInDictionnary($scope.tasksByTypeByState, $scope.taskTypes, $scope.sprintTaskStates);
        fillGapsInDictionnary($scope.tasksByStoryByState, _.map($scope.backlog.stories, 'id'), $scope.sprintTaskStates);
    };
    $scope.changeSprintFilter = function(sprintFilter) {
        $scope.currentSprintFilter = sprintFilter;
        $scope.refreshTasks();
        var editableUser = angular.copy(Session.user);
        editableUser.preferences.filterTask = sprintFilter.id;
        UserService.update(editableUser);
    };
    $scope.setAllSprintFilter = function() {
        $scope.changeSprintFilter(_.find($scope.sprintFilters, {id: 'allTasks'}));
    };
    $scope.storyFilter = function(story) {
        return $scope.currentSprintFilter.id == 'allTasks' || _.any($scope.tasksByStoryByState[story.id], function(tasks) {
            return tasks.length > 0;
        });
    };
    // Init
    var fixTaskRank = function(tasks) {
       _.each(tasks, function(task, index) {
            task.rank = index + 1;
        });
    };
    $scope.taskSortableOptions = {
        itemMoved: function(event) {
            fixTaskRank(event.source.sortableScope.modelValue);
            fixTaskRank(event.dest.sortableScope.modelValue);
            var task = event.source.itemScope.modelValue;
            var newRank = event.dest.index + 1;
            var destScope = event.dest.sortableScope;
            var newState = destScope.taskState;
            var newType = destScope.taskType;
            var newStory = destScope.story;
            task.rank = newRank;
            task.type = newType;
            task.state = newState;
            task.parentStory = newStory ? {id: newStory.id} : null;
            TaskService.update(task, sprint);
        },
        orderChanged: function(event) {
            fixTaskRank(event.dest.sortableScope.modelValue);
            var task = event.source.itemScope.modelValue;
            task.rank = event.dest.index + 1;
            TaskService.update(task, sprint);
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            var isSortableDest = destSortableScope.story ? $scope.isSortingStory(destSortableScope.story) : true;
            return sameSortable && isSortableDest;
        }
    };
    $scope.selectableOptions = {
        notSelectableSelector: '.action, button, a',
        multiple: false,
        selectionUpdated: function(selectedIds) {
            switch (selectedIds.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + '.task.details' + ($state.params.tabId ? '.tab' : ''), {taskId: selectedIds});
                    break;
            }
        }
    };
    $scope.sprintFilters = [
        {id: 'allTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.allTasks'), filter: {}},
        {id: 'myTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.myTasks'), filter: {responsible: {id: Session.user.id}}},
        {id: 'freeTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.freeTasks'), filter: {responsible: null}},
        {id: 'blockedTasks', name: $scope.message('is.ui.sprintPlan.toolbar.filter.blockedTasks'), filter: {blocked: true}}
    ];
    var sprintFilter = Session.authenticated() ? Session.user.preferences.filterTask : 'allTasks';
    $scope.currentSprintFilter = _.find($scope.sprintFilters, {id: sprintFilter});
    $scope.sortableId = 'sprintPlan';
    $scope.sprint = sprint;
    $scope.backlog = sprint;
    $scope.tasksByTypeByState = {};
    $scope.tasksByStoryByState = {};
    $scope.allStories = StoryService.list;
    $scope.$watch('sprint.tasks', function(newValue, oldValue) {
        if (oldValue !== newValue) { // Prevent trigger watch on watch creation
            $scope.refreshTasks();
        }
    }, true);
    $scope.$watch('allStories', function(newValue, oldValue) {
        if (oldValue !== newValue) { // Prevent trigger watch on watch creation
            StoryService.listByType(sprint).then(function() {
                TaskService.list(sprint); // Reload tasks and cascade to sprint.tasks watch that will take care of refreshing
            });
        }
    }, true);
    $scope.refreshTasks(); // Init
}]);

controllers.controller('chartCtrl', ['$scope', '$element', '$filter', 'Session', 'ProjectService', 'SprintService', 'ReleaseService', 'MoodService', function($scope, $element, $filter, Session, ProjectService, SprintService, ReleaseService, MoodService) {
    var defaultOptions = {
        chart: {
            height: 350
        },
        title: {
            enable: true
        }
    };
    $scope.openProjectChart = function(chartName, project) {
        var options = {};
        if (chartName == 'flowCumulative') {
            options = {
                chart: {
                    type: 'stackedAreaChart'
                }
            }
        } else if (chartName == 'burndown' || chartName == 'velocity') {
            options = {
                chart: {
                    type: 'multiBarChart',
                    stacked: true
                }
            }
        } else if (chartName == 'parkingLot') {
            options = {
                chart: {
                    type: 'multiBarHorizontalChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showValues: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return entry;
                        }
                    }
                }
            }
        }
        var defaultProjectOptions = {
            chart: {
                type: 'lineChart',
                x: function(entry, index) { return index; },
                y: function(entry) { return entry[0]; },
                xAxis: {
                    tickFormat: function(entry) {
                        return $scope.labelsX[entry];
                    }
                }
            }
        };
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, defaultProjectOptions, options);
        ProjectService.openChart(project ? project : Session.getProject(), chartName).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX) {
                $scope.labelsX = chart.labelsX;
            }
        });
    };
    $scope.openReleaseChart = function(chartName, release) {
        var options = {};
        if (chartName == 'parkingLot') {
            options = {
                chart: {
                    type: 'multiBarHorizontalChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showValues: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return entry;
                        }
                    }
                }
            };
        } else if (chartName == 'burndown') {
            options = {
                chart: {
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    type: 'multiBarChart',
                    stacked: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsX[entry];
                        }
                    }
                }
            };
        }
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, options);
        ReleaseService.openChart(release, chartName).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX) {
                $scope.labelsX = chart.labelsX;
            }
        });
    };
    $scope.openSprintChart = function(chartName, sprint) {
        var defaultSprintOptions = {
            chart: {
                type: 'lineChart',
                x: function(entry) { return entry[0]; },
                y: function(entry) { return entry[1]; },
                xScale: d3.time.scale.utc(),
                xAxis: {
                    tickFormat: $filter('dateShorter')
                }
            }
        };
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, defaultSprintOptions);
        SprintService.openChart(sprint, $scope.currentProject ? $scope.currentProject : Session.getProject(), chartName).then(function(chart) {
            $scope.options = _.merge($scope.options, chart.options);
            $scope.data = chart.data;
        });
    };
    $scope.saveChart = function() {
        var title = $element.find('.title.h4');
        saveChartAsPng($element.find('svg')[0], {}, title[0], function(imageBase64) {
            // Server side "attachment" content type is needed because the a.download HTML5 feature is not supported in crappy browsers (safari & co).
            jQuery.download($scope.serverUrl + '/saveImage', {'image': imageBase64, 'title': title.text()});
        });
    };
    $scope.openMoodChart = function(chartName) {
        var options = {};
        if (chartName == 'sprintUserMood') {
            options = {
                chart: {
                    type: 'lineChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    xScale: d3.time.scale.utc(),
                    xAxis: {
                        tickFormat: $filter('dateShorter')
                    },
                    yAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsY[entry];
                        }
                    }
                }
            };
        } else if (chartName == 'releaseUserMood') {
            options = {
                chart: {
                    type: 'lineChart',
                    x: function(entry, index) {
                        return index;
                    },
                    y: function(entry) {
                        return entry[0];
                    },
                    xAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsX[entry];
                        }
                    },
                    yAxis: {
                        tickFormat: function(d) {
                            return $scope.labelsY[d];
                        }
                    }
                }
            };
        }
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, options);
        MoodService.openChart(chartName, $scope.currentProject ? $scope.currentProject : Session.getProject()).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX || chart.labelsY) {
                $scope.labelsX = chart.labelsX;
                $scope.labelsY = chart.labelsY;
            }
        });
    };
    $scope.cleanData = function() {
        $scope.data = [];
        $scope.labelsX = [];
        $scope.labelsY = [];
        $scope.options = {};
    };
    // Init
    $scope.cleanData();
}]);