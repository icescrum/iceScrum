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
                function(result) {
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
            accept: function (sourceItemHandleScope, destSortableScope) {
                return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            },
            dragStart: function() { $scope.menuDragging = true; },
            dragEnd: function() { $scope.menuDragging = false; }
        };

        //begin state loading app
        $scope.$on('$viewContentLoading', function() {
            $scope.app.loading = true;
            if($scope.app.loadingPercent < 90) {
                $scope.app.loadingPercent += 10;
            }
        });

        $scope.$on('$stateChangeStart', function() {
            $scope.app.loading = true;
            if($scope.app.loadingPercent != 100) {
                $scope.app.loadingPercent += 10;
            }
        });

        $scope.$on('$stateChangeSuccess', function() {
            $scope.app.loading = false;
            if($scope.app.loadingPercent != 100) {
                $scope.app.loadingPercent = 100;
            }
        });

        $scope.$watch(function() {
            return $http.pendingRequests.length;
        }, function(newVal) {
            $scope.app.loading = newVal > 0;
            if($scope.app.loading && $scope.app.loadingPercent < 100){
                $scope.app.loadingPercent = 100 - ((100 - $scope.app.loadingPercent) / newVal);
            }
        });
        //end state loading app

        $scope.$on(SERVER_ERRORS.notAuthenticated, function(event, e) {
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

controllers.controller('featuresCtrl', ['$scope', '$state', 'FeatureService', 'features', function($scope, $state, FeatureService, features) {
    // Functions
    $scope.isSelected = function(feature) {
        if ($state.params.id) {
            return $state.params.id == feature.id;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), feature.id.toString());
        } else {
            return false;
        }
    };
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
        var feature = event.source.itemScope.modelValue;
        var newFeatures = event.dest.sortableScope.modelValue;
        var newRank = event.dest.index + 1;
        FeatureService.updateRank(feature, newRank, newFeatures);
    };
    $scope.featureSortableOptions = {
        itemMoved: updateRank,
        orderChanged: updateRank,
        accept: function (sourceItemHandleScope, destSortableScope) {
            return sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
        }
    };
    $scope.sortableId = 'feature';
    $scope.orderBy = {
        current: {id: 'dateCreated', name: $scope.message('todo.is.ui.sort.date')},
        values: [
            {id: 'rank', name: $scope.message('todo.is.ui.sort.rank')},
            {id: 'dateCreated', name: $scope.message('todo.is.ui.sort.date')},
            {id: 'name', name: $scope.message('todo.is.ui.sort.name')},
            {id: 'stories_ids.length', name: $scope.message('todo.is.ui.sort.stories')},
            {id: 'value', name: $scope.message('todo.is.ui.sort.value')}
        ]
    };
    $scope.orderByRank();
}]);

controllers.controller('releasePlanCtrl', ['$scope', '$state', 'ReleaseService', 'SprintService', 'ReleaseStatesByName', 'SprintStatesByName', 'releases', function($scope, $state, ReleaseService, SprintService, ReleaseStatesByName, SprintStatesByName, releases) {
    // Functions
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    $scope.goToRelease = function(release) {
        $state.go('releasePlan.details', {id: release.id});
    };
    $scope.goToSprint = function(sprint) {
        $state.go('releasePlan.sprint.details', {id: sprint.id});
    };
    $scope.isShownSprint = function(sprint) {
        return _.contains($scope.selectedSprintsIds, sprint.id);
    };
    $scope.manageShownSprint = function(sprint) {
        var allSprintsSorted = _.chain($scope.releases).sortBy('orderNumber').map(function(release) {
            return _.sortBy(release.sprints, 'orderNumber');
        }).flatten().value();
        if ($scope.isShownSprint(sprint)) {
            _.pull($scope.selectedSprintsIds, sprint.id);
        } else {
            $scope.selectedSprintsIds.push(sprint.id);
        }
        $scope.selectedSprints = _.filter(allSprintsSorted, function(sprint) {
            return _.contains($scope.selectedSprintsIds, sprint.id);
        });
    };
    // Init
    $scope.viewName = 'releasePlan';
    $scope.releases = releases;
    $scope.selectedSprintsIds = [];
    $scope.selectedSprints = [];
    var currentOrNextSprit = _.find(_.sortBy(_.find(releases, { state: ReleaseStatesByName.IN_PROGRESS }).sprints, 'orderNumber'), function(sprint) {
        return sprint.state < SprintStatesByName.DONE;
    });
    if (currentOrNextSprit) {
        $scope.manageShownSprint(currentOrNextSprit);
    }
}]);

controllers.controller('sprintPlanCtrl', ['$scope', '$state', 'StoryService', 'TaskService', 'Session', 'SprintStatesByName', 'StoryStatesByName', 'sprint', 'tasks', function($scope, $state, StoryService, TaskService, Session, SprintStatesByName, StoryStatesByName, sprint, tasks) {
    $scope.viewName = 'sprintPlan';
    // Functions
    $scope.isSortingSprintPlan = function(sprint) {
        return Session.authenticated() && sprint.state < SprintStatesByName.DONE;
    };
    $scope.isSortingStory = function(story) {
        return story.state < StoryStatesByName.DONE;
    };
    $scope.openSprint = function() {
        $state.go('sprintPlan.details');
    };
    $scope.openNewTaskByStory = function(story) {
        $state.go('sprintPlan.task.new', {taskTemplate: {parentStory: _.pick(story, ['id', 'name'])}});
    };
    $scope.openNewTaskByType = function(type) {
        $state.go('sprintPlan.task.new', {taskTemplate: {type: type}});
    };
    // Init
    $scope.taskSortableOptions = {
        itemMoved: function(event) {
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
            var task = event.source.itemScope.modelValue;
            task.rank = event.dest.index + 1;
            TaskService.update(task, sprint);
        },
        accept: function (sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            var isSortableDest = destSortableScope.story ? $scope.isSortingStory(destSortableScope.story) : true;
            return sameSortable && isSortableDest;
        }
    };
    $scope.sortableId = 'sprintPlan';
    $scope.sprint = sprint;
    $scope.backlog = {stories: _.sortBy(sprint.stories, 'rank')};
    $scope.tasksByTypeByState = {};
    $scope.tasksByStoryByState = {};
    $scope.taskStates = [0, 1, 2];
    $scope.taskTypes = [10, 11];
    var partitionedTasks = _.partition(tasks, function(task) {
        return _.isNull(task.parentStory);
    });
    var groupByStateAndSort = function(tasksDictionnary) {
        return _.mapValues(tasksDictionnary, function(tasks) {
            return _.mapValues(_.groupBy(tasks, 'state'), function(tasks) {
                return _.sortBy(tasks, 'rank');
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
    fillGapsInDictionnary($scope.tasksByTypeByState, $scope.taskTypes, $scope.taskStates);
    fillGapsInDictionnary($scope.tasksByStoryByState, _.map($scope.backlog.stories, 'id'), $scope.taskStates);
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
        $scope.options = _.merge({}, defaultOptions, defaultProjectOptions, $scope.initOptions, options);
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
                    tickFormat: function(d) {
                        // TODO USE date format from i18n
                        return $filter('date')(new Date(d), 'dd-MM-yyyy');
                    }
                }
            }
        };
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, defaultSprintOptions);
        SprintService.openChart(sprint, $scope.currentProject, chartName).then(function(chart) {
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
                    x: function (entry) { return entry[0]; },
                    y: function (entry) { return entry[1]; },
                    xScale: d3.time.scale.utc(),
                    xAxis: {
                        tickFormat: function(d) {
                            // TODO USE date format from i18n
                            return $filter('date')(new Date(d), 'dd-MM-yyyy');
                        }
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
        MoodService.openChart(chartName, $scope.currentProject).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX  ||  chart.labelsY) {
                $scope.labelsX = chart.labelsX;
                $scope.labelsY = chart.labelsY;
            }
        });
    };
    $scope.initProjectChart = function(chart, options, project) {
        $scope.initOptions = options ? options : {};
        $scope.openProjectChart(chart ? chart : 'burnup', project);
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