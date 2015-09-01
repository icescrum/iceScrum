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

var controllers = angular.module('controllers', []);

controllers.controller('appCtrl', ['$scope', '$state', '$modal', 'Session', 'UserService', 'SERVER_ERRORS', 'CONTENT_LOADED' , 'Fullscreen', 'notifications', '$interval', '$timeout', '$http', 'hotkeys',
    function ($scope, $state, $modal, Session, UserService, SERVER_ERRORS, CONTENT_LOADED, Fullscreen, notifications, $interval, $timeout, $http, hotkeys) {
        $scope.app = {
            isFullScreen:false,
            loading:10
        };
        $scope.currentUser = Session.user;
        $scope.roles = Session.roles;

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
                    }
                );
            } else {
                Session.unreadActivitiesCount = 0;
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
            $modal.open({
                templateUrl: 'scrumOS/about'
            });
        };
        $scope.showProfile = function() {
            $modal.open({
                keyboard: false,
                templateUrl: $scope.serverUrl + '/user/openProfile',
                controller: 'userCtrl'
            });
        };
        $scope.showManageTeamsModal = function() {
            $modal.open({
                keyboard: false,
                templateUrl: $scope.serverUrl + "/team/manage",
                size: 'lg',
                controller: 'manageTeamsModalCtrl'
            });
        };
        $scope.menus = {
            visible:[],
            hidden:[]
        };
        $scope.menuSortableOptions = {
            items:'li.menuitem',
            connectWith:'.menubar',
            handle:'.handle'
        };
        var updateMenu = function(info){
            $http({ url: $scope.serverUrl + '/user/menu',
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: function (data) { return formObjectData(data, ''); },
                data:info});
        };
        $scope.menuSortableUpdate = function (startModel, destModel, start, end) {
            updateMenu({id:destModel[end].id, position:end + 1, hidden:false});
        };

        $scope.menuHiddenSortableUpdate = function (startModel, destModel, start, end) {
            updateMenu({id:destModel[end].id, position:end + 1, hidden:true});
        };
        //fake loading
        var loadingAppProgress = $interval(function() {
            if ($scope.app.loading <= 80){
                $scope.app.loading += 10;
            }
        }, 100);
        //real ready app
        $scope.$on(CONTENT_LOADED, function() {
            $scope.app.loading = 90;
            $timeout(function() {
                $scope.app.loading = 100;
                $interval.cancel(loadingAppProgress);
                angular.element('#app-progress').remove();
            }, 500);
        });
        $scope.$on(SERVER_ERRORS.notAuthenticated, function(event, e) {
            $scope.showAuthModal();
        });
        $scope.$on(SERVER_ERRORS.clientError, function(event, error) {
            if (angular.isArray(error.data)) {
                notifications.error("", error.data[0].text);
            } else if (angular.isObject(error.data)) {
                notifications.error("", error.data.text);
            } else {
                notifications.error("", $scope.message('todo.is.ui.error.unknown'));
            }
        });
        $scope.$on(SERVER_ERRORS.serverError, function(event, error) {
            if (angular.isArray(error.data)) {
                notifications.error($scope.message('todo.is.ui.error.server'), error.data[0].text);
            } else if (angular.isObject(error.data)) {
                notifications.error($scope.message('todo.is.ui.error.server'), error.data.text);
            } else {
                notifications.error($scope.message('todo.is.ui.error.server'), $scope.message('todo.is.ui.error.unknown'));
            }
        });
        $scope.fullScreen = function(){
            if (Fullscreen.isEnabled()){
                Fullscreen.cancel();
                $scope.app.isFullScreen = false;
            }
            else {
                var el = angular.element('#main-content > div:first-of-type');
                if (el.length > 0){
                    Fullscreen.enable(el[0]);
                    $scope.app.isFullScreen = !$scope.app.isFullScreen;
                }
            }
        };
        $scope.print = function(data){
            var url = data;
            if (angular.isObject(data)){
                url = data.currentTarget.attributes['ng-href'] ? data.currentTarget.attributes['ng-href'].value : data.target.href;
                data.preventDefault();
            }
            var modal = $modal.open({
                keyboard: false,
                templateUrl: "report.progress.html",
                size: 'sm',
                controller: ['$scope', function($scope){
                    $scope.downloadFile(url);
                    $scope.progress = true;
                }]
            });
            modal.result.then(
                function(result) {
                    $scope.downloadFile("");
                },
                function(){
                    $scope.downloadFile("");
                }
            );
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
    }]).controller('loginCtrl',['$scope', '$state', '$rootScope', 'SERVER_ERRORS', 'AuthService', function ($scope, $state, $rootScope, SERVER_ERRORS, AuthService) {
    $scope.credentials = {
        j_username: $scope.username ? $scope.username : '',
        j_password: ''
    };
    $rootScope.showRegisterModal = function() {
        if($scope.$close) {
            $scope.$close(); // Close auth modal if present
        }
        $state.go('userregister');
    };
    $rootScope.showRetrieveModal = function() {
        $state.go('userretrieve');
    };
    $scope.login = function (credentials) {
        AuthService.login(credentials).then(function (stuff) {
            var lastOpenedUrl = stuff.data.url;
            var normalizedCurrentLocation = window.location.href.charAt(window.location.href.length - 1) == '/' ? window.location.href.substring(0, window.location.href.length - 1) : window.location.href;
            if (normalizedCurrentLocation == $rootScope.serverUrl && lastOpenedUrl) {
                document.location = lastOpenedUrl;
            } else {
                document.location.reload(true);
            }
        }, function () {
            $rootScope.$broadcast(SERVER_ERRORS.loginFailed);
        });
    };
}]).controller('registerCtrl',['$scope', 'User', 'UserService', '$state', function ($scope, User, UserService, $state) {
    $scope.user = new User();
    if ($state.params.token) {
        UserService.getInvitationUserMock($state.params.token).then(function(mockUser) {
            _.merge($scope.user, mockUser);
            $scope.user.token = $state.params.token;
        });
    }
    $scope.register = function(){
        UserService.save($scope.user).then(function() {
            $scope.$close($scope.user.username);
        });
    }
}]).controller('retrieveCtrl',['$scope', 'User', 'UserService', function ($scope, User, UserService) {
    $scope.user = new User();
    $scope.retrieve = function(){
        UserService.retrievePassword($scope.user).then(function(){
            $scope.$close();
        });
    }

}]).controller('storyViewCtrl', ['$scope', '$state', '$filter', 'StoryService', 'StoryStatesByName', function ($scope, $state, $filter, StoryService, StoryStatesByName) {
    $scope.goToNewStory = function() {
        $state.go('backlog.new');
    };
    $scope.goToTab = function(story, tabId) {
        $state.go($scope.viewName + '.details.tab',  { id: story.id, tabId: tabId });
    };
    $scope.defaultStoryState = StoryStatesByName.SUGGESTED;
    $scope.selectableOptions = {
        filter:">.postit-container",
        cancel: "a,.ui-selectable-cancel",
        stop: function(e, ui, selectedItems) {
            switch (selectedItems.length) {
                case 0:
                    $state.go($scope.viewName);
                    break;
                case 1:
                    $state.go($scope.viewName + ($state.params.tabId ? '.details.tab' : '.details'), { id: selectedItems[0].id });
                    break;
                default:
                    $state.go($scope.viewName + '.multiple',{listId:_.pluck(selectedItems, 'id').join(",")});
                    break;
            }
        }
    };
    $scope.isSelected = function(story) {
        if ($state.params.id) {
            return $state.params.id == story.id ;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), story.id.toString());
        } else {
            return false;
        }
    };
    $scope.authorizedStory = function(action, story) {
        return StoryService.authorizedStory(action, story);
    };
    // Required instead of ng-repeat stories | filters
    // because for sortable we need to have the stories in a ng-model, so the expression must be assignable
    $scope.refreshStories = function() {
        $scope.filteredAndSortedStories = $filter('orderBy')($scope.stories, $scope.orderBy.current.id, $scope.orderBy.reverse);
    };
    $scope.filteredAndSortedStories = [];
    $scope.$watchGroup(['orderBy.current.id', 'orderBy.reverse'], $scope.refreshStories);
    $scope.$watch('stories', $scope.refreshStories, true);
}]).controller('backlogCtrl', ['$scope', '$controller', '$state', 'stories', 'StoryService', function ($scope, $controller, $state, stories, StoryService) {
    $controller('storyViewCtrl', { $scope: $scope }); // inherit from storyViewCtrl
    $scope.viewName = 'backlog';
    $scope.stories = stories;
    $scope.orderBy = {
        reverse: false,
        status: false,
        current: {id:'rank', name:'todo.is.ui.sort.rank'},
        values:[
            {id:'effort', name:'todo.is.ui.sort.effort'},
            {id:'rank', name:'todo.is.ui.sort.rank'},
            {id:'name', name:'todo.is.ui.sort.name'},
            {id:'tasks_count', name:'todo.is.ui.sort.tasks'},
            {id:'suggestedDate', name:'todo.is.ui.sort.date'},
            {id:'feature.id', name:'todo.is.ui.sort.feature'},
            {id:'value', name:'todo.is.ui.sort.value'},
            {id:'type', name:'todo.is.ui.sort.type'}
        ]
    };
    $scope.storySortableOptions = {
        items:'.postit-container'
    };
    $scope.storySortableUpdate = function (startModel, destModel, start, end) {
        var story = destModel[end];
        var newRank = end + 1;
        if (story.rank != newRank) {
            story.rank = newRank;
            StoryService.update(story).then(function() {
                angular.forEach(destModel, function(s, index) {
                    var currentRank = index + 1;
                    if (s.rank != currentRank) {
                        s.rank = currentRank;
                    }
                });
            });
        }
    };
}]);

controllers.controller('featuresCtrl', ['$scope', '$state', 'FeatureService', 'features', function ($scope, $state, FeatureService, features) {
    $scope.orderBy = {
        reverse: false,
        status: false,
        current: {id:'dateCreated', name:'todo.Date'},
        values:[
            {id:'dateCreated', name:'todo.Date'},
            {id:'name', name:'todo.Name'},
            {id:'stories_ids.length', name:'todo.Stories'},
            {id:'value', name:'todo.Value'}
        ]
    };
    $scope.goToNewFeature = function() {
        $state.go('feature.new');
    };
    $scope.selectableOptions = {
        filter:"> .postit-container",
        cancel: "a",
        stop:function(e, ui, selectedItems) {
            switch (selectedItems.length){
                case 0:
                    $state.go('feature');
                    break;
                case 1:
                    $state.go($state.params.tabId ? 'feature.details.tab' : 'feature.details', { id: selectedItems[0].id });
                    break;
                default:
                    $state.go('feature.multiple',{listId:_.pluck(selectedItems, 'id').join(",")});
                    break;
            }
        }
    };
    $scope.features = features;
    $scope.isSelected = function(feature) {
        if ($state.params.id) {
            return $state.params.id == feature.id ;
        } else if ($state.params.listId) {
            return _.contains($state.params.listId.split(','), feature.id.toString());
        } else {
            return false;
        }
    };
    $scope.authorizedFeature = function(action) {
        return FeatureService.authorizedFeature(action);
    };


}]);

controllers.controller('chartCtrl', ['$scope', 'Session', 'ProjectService', 'SprintService', function($scope, Session, ProjectService, SprintService) {
    $scope.charts = {
        sprintBurnupStoriesChart: {
            options: {
                chart: {
                    yAxis: {
                        axisLabel: 'Stories'
                    }
                },
                title: {
                    text: 'sprintBurnupStoriesChart'
                }
            }
        },
        sprintBurnupPointsChart: {
            options: {
                chart: {
                    yAxis: {
                        axisLabel: 'Points'
                    }
                },
                title: {
                    text: 'sprintBurnupPointsChart'
                }
            }
        },
        sprintBurnupTasksChart: {
            options: {
                chart: {
                    yAxis: {
                        axisLabel: 'Tasks'
                    }
                },
                title: {
                    text: 'sprintBurnupTasksChart'
                }
            }
        },
        sprintBurndownRemainingChart: {
            options: {
                chart: {
                    yAxis: {
                        axisLabel: 'Remaining time'
                    }
                },
                title: {
                    text: 'sprintBurndownRemainingChart'
                }
            }
        },
        productBurnupChart: {
            options: {
                chart: {
                    showValues: true,
                    height: 350,
                    type: 'lineChart',
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    xAxis: {
                        axisLabel: 'Sprints',
                        tickFormat: function(entry) {
                            return $scope.charts.productBurnupChart.labels[entry];
                        }
                    },
                    yAxis: {
                        axisLabel: 'Points'
                    }
                },
                title: {
                    enable: true,
                    text: 'Product burnup chart'
                }
            },
            labels: [],
            load: function() {
                $scope.data = [];
                $scope.options = $scope.charts.productBurnupChart.options;
                ProjectService.openChart(Session.getProject(), 'productBurnupChart').then(function(chart) {
                    $scope.data = chart.data;
                    $scope.charts.productBurnupChart.labels = chart.labels;
                });
            }
        },
        productCumulativeFlowChart: {
            options: {
                chart: {
                    showValues: true,
                    height: 350,
                    type: 'stackedAreaChart',
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    xAxis: {
                        axisLabel: 'Sprints',
                        tickFormat: function(entry) {
                            return $scope.charts.productCumulativeFlowChart.labels[entry];
                        }
                    },
                    yAxis: {
                        axisLabel: 'Nb stories'
                    }
                },
                title: {
                    enable: true,
                    text: 'Product cumulative flow chart'
                }
            },
            labels: [],
            load: function() {
                $scope.data = [];
                $scope.options = $scope.charts.productCumulativeFlowChart.options;
                ProjectService.openChart(Session.getProject(), 'productCumulativeFlowChart').then(function(chart) {
                    $scope.data = chart.data;
                    $scope.charts.productCumulativeFlowChart.labels = chart.labels;
                });
            }
        },
        productBurndownChart: {
            options: {
                chart: {
                    showValues: true,
                    height: 350,
                    type: 'multiBarChart',
                    stacked: true,
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    xAxis: {
                        axisLabel: 'Sprints',
                        tickFormat: function(entry) {
                            return $scope.charts.productBurndownChart.labels[entry];
                        }
                    },
                    yAxis: {
                        axisLabel: 'Points'
                    }
                },
                title: {
                    enable: true,
                    text: 'Product cumulative flow chart'
                }
            },
            labels: [],
            load: function() {
                $scope.data = [];
                $scope.options = $scope.charts.productBurndownChart.options;
                ProjectService.openChart(Session.getProject(), 'productBurndownChart').then(function(chart) {
                    $scope.data = chart.data;
                    $scope.charts.productBurndownChart.labels = chart.labels;
                });
            }
        },
        productVelocityChart: {
            options: {
                chart: {
                    showValues: true,
                    height: 350,
                    type: 'multiBarChart',
                    stacked: true,
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    xAxis: {
                        axisLabel: 'Sprints',
                        tickFormat: function(entry) {
                            return $scope.charts.productVelocityChart.labels[entry];
                        }
                    },
                    yAxis: {
                        axisLabel: 'Points'
                    }
                },
                title: {
                    enable: true,
                    text: 'Product velocity chart'
                }
            },
            labels: [],
            load: function() {
                $scope.data = [];
                $scope.options = $scope.charts.productVelocityChart.options;
                ProjectService.openChart(Session.getProject(), 'productVelocityChart').then(function(chart) {
                    $scope.data = chart.data;
                    $scope.charts.productVelocityChart.labels = chart.labels;
                });
            }
        },
        productParkingLotChart: {
            options: {
                chart: {
                    showValues: true,
                    height: 350,
                    type: 'multiBarHorizontalChart',
                    stacked: true,
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    yAxis: {
                        axisLabel: '% achievement'
                    }
                },
                title: {
                    enable: true,
                    text: 'Product parking lot chart'
                }
            },
            load: function() {
                $scope.data = [];
                $scope.options = $scope.charts.productParkingLotChart.options;
                ProjectService.openChart(Session.getProject(), 'productParkingLotChart').then(function(chart) {
                    $scope.data = chart.data;
                });
            }
        },
        productVelocityCapacityChart: {
            options: {
                chart: {
                    showValues: true,
                    height: 350,
                    type: 'lineChart',
                    stacked: true,
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    xAxis: {
                        axisLabel: 'Sprints',
                        tickFormat: function(entry) {
                            return $scope.charts.productVelocityCapacityChart.labels[entry];
                        }
                    },
                    yAxis: {
                        axisLabel: 'Points'
                    }
                },
                title: {
                    enable: true,
                    text: 'Product velocity chart'
                }
            },
            labels: [],
            load: function() {
                $scope.data = [];
                $scope.options = $scope.charts.productVelocityCapacityChart.options;
                ProjectService.openChart(Session.getProject(), 'productVelocityCapacityChart').then(function(chart) {
                    $scope.data = chart.data;
                    $scope.charts.productVelocityCapacityChart.labels = chart.labels;
                });
            }
        },
    };
    $scope.openChart = function(chart) {
        $scope.charts[chart].load ? $scope.charts[chart].load() : $scope.defaultLoad(chart);
    };
    $scope.defaultLoad = function(chart) {
        var defaultLineOptions = {
            chart: {
                showValues: true,
                height: 350,
                type: 'lineChart',
                x: function(entry) { return entry[0]; },
                y: function(entry) { return entry[1]; },
                xAxis: {
                    axisLabel: 'Days',
                    tickFormat: function(d) {
                        return d3.time.format('%x')(new Date(d));
                    }
                }
            },
            title: {
                enable: true
            }
        };
        $scope.data = [];
        $scope.options = _.merge({}, defaultLineOptions, $scope.charts[chart].options);
        SprintService.openChart($scope.sprint, $scope.currentProject, chart).then(function(data) {
            $scope.data = data;
        });
    };
    // Init
    $scope.options = {};
    $scope.data = [];
    $scope.openChart('productBurnupChart');
}]);