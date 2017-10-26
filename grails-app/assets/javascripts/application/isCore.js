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

// Try to detect as early as possible that the root misses as slash
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

angular.module('isCore', ['ui.router'])
    .provider('controllerHooks', function() {
        this.$get = angular.noop;
        this.register = function(entryPoints) {
            _.each(entryPoints, function(appControllerName, pluginControllerName) {
                if (_.has(isSettings.controllerHooks, appControllerName)) {
                    isSettings.controllerHooks[appControllerName].push(pluginControllerName);
                } else {
                    console.error("Application controller " + appControllerName + " is not registered so plugin controller " + pluginControllerName + " cannot be hooked");
                }
            });
        }
    })
    .provider('charts', function() {
        this.$get = function() {
            return this.charts;
        };
        this.charts = {
            project: {
                project: [
                    {id: 'burnup', name: 'is.ui.project.charts.projectBurnup', 'view': 'project'},
                    {id: 'burndown', name: 'is.ui.project.charts.projectBurndown', 'view': 'project'},
                    {id: 'velocity', name: 'is.ui.project.charts.projectVelocity', 'view': 'project'},
                    {id: 'velocityCapacity', name: 'is.ui.project.charts.projectVelocityCapacity', 'view': 'project'},
                    {id: 'parkingLot', name: 'is.ui.project.charts.projectParkingLot', 'view': 'project'},
                    {id: 'flowCumulative', name: 'is.ui.project.charts.projectCumulativeFlow', 'view': 'project'}
                ],
                release: [
                    {id: 'burndown', name: 'is.chart.releaseBurndown', 'view': 'planning'},
                    {id: 'parkingLot', name: 'is.chart.releaseParkingLot', 'view': 'planning'}
                ],
                sprint: [
                    {id: 'burndownRemaining', name: 'is.ui.sprintPlan.charts.sprintBurndownRemainingChart', 'view': 'taskBoard'},
                    {id: 'burnupTasks', name: 'is.ui.sprintPlan.charts.sprintBurnupTasksChart', 'view': 'taskBoard'},
                    {id: 'burnupPoints', name: 'is.ui.sprintPlan.charts.sprintBurnupPointsChart', 'view': 'taskBoard'},
                    {id: 'burnupStories', name: 'is.ui.sprintPlan.charts.sprintBurnupStoriesChart', 'view': 'taskBoard'}
                ]
            }
        };
    })
    .provider('itemTabs', function() {
        this.$get = function() {
            return this.itemTabs;
        };
        this.itemTabs = {
            backlog: {
                details: {}
            },
            task: {
                details: {
                    resolve: ['$stateParams', 'AttachmentService', 'detailsTask', function($stateParams, AttachmentService, detailsTask) {
                        if (!$stateParams.taskTabId) {
                            return AttachmentService.list(detailsTask);
                        }
                    }]
                },
                comments: {
                    resolve: ['$stateParams', 'CommentService', 'detailsTask', function($stateParams, CommentService, detailsTask) {
                        if ($stateParams.taskTabId == 'comments') {
                            return CommentService.list(detailsTask);
                        }
                    }],
                    templateUrl: 'comment.list.html'
                },
                activities: {
                    resolve: ['$stateParams', 'ActivityService', 'detailsTask', function($stateParams, ActivityService, detailsTask) {
                        if ($stateParams.taskTabId == 'activities') {
                            return ActivityService.activities(detailsTask, false);
                        }
                    }],
                    templateUrl: 'activity.list.html'
                }
            },
            story: {
                details: {
                    resolve: ['$stateParams', 'AttachmentService', 'detailsStory', function($stateParams, AttachmentService, detailsStory) {
                        if (!$stateParams.storyTabId) {
                            return AttachmentService.list(detailsStory);
                        }
                    }]
                },
                tests: {
                    resolve: ['$stateParams', 'AcceptanceTestService', 'detailsStory', function($stateParams, AcceptanceTestService, detailsStory) {
                        if ($stateParams.storyTabId == 'tests') {
                            return AcceptanceTestService.list(detailsStory);
                        }
                    }],
                    templateUrl: 'story.acceptanceTests.html'
                },
                tasks: {
                    resolve: ['$stateParams', 'TaskService', 'detailsStory', function($stateParams, TaskService, detailsStory) {
                        if ($stateParams.storyTabId == 'tasks') {
                            return TaskService.list(detailsStory);
                        }
                    }],
                    templateUrl: 'story.tasks.html'
                },
                comments: {
                    resolve: ['$stateParams', 'CommentService', 'detailsStory', function($stateParams, CommentService, detailsStory) {
                        if ($stateParams.storyTabId == 'comments') {
                            return CommentService.list(detailsStory);
                        }
                    }],
                    templateUrl: 'comment.list.html'
                },
                activities: {
                    resolve: ['$stateParams', 'ActivityService', 'detailsStory', function($stateParams, ActivityService, detailsStory) {
                        if ($stateParams.storyTabId == 'activities') {
                            return ActivityService.activities(detailsStory, false);
                        }
                    }],
                    templateUrl: 'activity.list.html'
                }
            },
            feature: {
                details: {
                    resolve: ['$stateParams', 'AttachmentService', 'detailsFeature', function($stateParams, AttachmentService, detailsFeature) {
                        if (!$stateParams.featureTabId) {
                            return AttachmentService.list(detailsFeature);
                        }
                    }]
                },
                stories: {
                    resolve: ['$stateParams', 'StoryService', 'detailsFeature', function($stateParams, StoryService, detailsFeature) {
                        if ($stateParams.featureTabId == 'stories') {
                            StoryService.listByType(detailsFeature);
                        }
                    }],
                    templateUrl: 'nested.stories.html'
                },
                activities: {
                    resolve: ['$stateParams', 'ActivityService', 'detailsFeature', function($stateParams, ActivityService, detailsFeature) {
                        if ($stateParams.featureTabId == 'activities') {
                            return ActivityService.activities(detailsFeature, false);
                        }
                    }],
                    templateUrl: 'activity.list.html'
                }
            },
            release: {
                details: {
                    resolve: ['$stateParams', 'AttachmentService', 'detailsRelease', function($stateParams, AttachmentService, detailsRelease) {
                        if (!$stateParams.releaseTabId) {
                            return AttachmentService.list(detailsRelease);
                        }
                    }]
                },
                notes: {
                    resolve: ['$stateParams', 'TimeBoxNotesTemplateService', 'Session', function($stateParams, TimeBoxNotesTemplateService, Session) {
                        if ($stateParams.releaseTabId == 'notes') {
                            return TimeBoxNotesTemplateService.list(Session.getProject());
                        }
                    }],
                    templateUrl: 'timeBoxNotesTemplates.timeBox.notes.html'
                }
            },
            sprint: {
                details: {
                    resolve: ['$stateParams', 'AttachmentService', 'detailsSprint', function($stateParams, AttachmentService, detailsSprint) {
                        if (!$stateParams.sprintTabId) {
                            return AttachmentService.list(detailsSprint);
                        }
                    }]
                },
                notes: {
                    resolve: ['$stateParams', 'TimeBoxNotesTemplateService', 'Session', function($stateParams, TimeBoxNotesTemplateService, Session) {
                        if ($stateParams.sprintTabId == 'notes') {
                            return TimeBoxNotesTemplateService.list(Session.getProject());
                        }
                    }],
                    templateUrl: 'timeBoxNotesTemplates.timeBox.notes.html'
                }
            }
        };
    })
    .provider('isState', ['itemTabsProvider', function(itemTabsProvider) {
        this.$get = angular.noop;
        this.getDetailsModalState = function(detailsType, options) {
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
        this.getBacklogDetailsState = function(viewContext) {
            var backlogTabs = itemTabsProvider.itemTabs.backlog;
            var tabNames = _.keys(backlogTabs);
            var backlogState = {
                name: 'details',
                url: "/details",
                views: {},
                resolve: {},
                data: {
                    displayTabs: tabNames.length > 1
                },
                children: [
                    {
                        name: 'tab',
                        url: '/{backlogTabId:(?:' + _.join(tabNames, '|') + ')}',
                        resolve: {},
                        views: {
                            "details-tab": {
                                templateUrl: function($stateParams) {
                                    if ($stateParams.backlogTabId) {
                                        return backlogTabs[$stateParams.backlogTabId].templateUrl;
                                    }
                                },
                                controller: ['$scope', 'detailsBacklog', function($scope, detailsBacklog) {
                                    $scope.selected = detailsBacklog;
                                }]
                            }
                        }
                    }
                ]
            };
            // Default tab (without tabId)
            if (backlogTabs.details.resolve) {
                backlogState.resolve['details'] = backlogTabs.details.resolve;
            }
            var backlogTabState = backlogState.children[0];
            _.each(backlogTabs, function(value, key) {
                backlogTabState.resolve['data' + key] = value.resolve;
            });
            backlogState.views['details' + (viewContext ? viewContext : '')] = {
                templateUrl: 'backlog.details.html',
                controller: 'backlogDetailsCtrl'
            };
            return backlogState;
        };
        this.getTaskDetailsState = function(viewContext) {
            var taskTabs = itemTabsProvider.itemTabs.task;
            var tabNames = _.keys(taskTabs);
            var taskState = {
                name: 'details',
                url: "/{taskId:int}",
                resolve: {
                    detailsTask: ['$stateParams', 'taskContext', 'TaskService', function($stateParams, taskContext, TaskService) {
                        return TaskService.get($stateParams.taskId, taskContext);
                    }]
                },
                views: {},
                children: [
                    {
                        name: 'tab',
                        url: '/{taskTabId:(?:' + _.join(tabNames, '|') + ')}',
                        resolve: {},
                        views: {
                            "details-tab": {
                                templateUrl: function($stateParams) {
                                    if ($stateParams.taskTabId) {
                                        return taskTabs[$stateParams.taskTabId].templateUrl;
                                    }
                                },
                                controller: ['$scope', 'detailsTask', function($scope, detailsTask) {
                                    $scope.selected = detailsTask;
                                }]
                            }
                        }
                    }
                ]
            };
            // Default tab (without tabId)
            taskState.resolve.details = taskTabs.details.resolve;
            var taskTabState = taskState.children[0];
            _.each(taskTabs, function(value, key) {
                taskTabState.resolve['data' + key] = value.resolve;
            });
            taskState.views['details' + (viewContext ? viewContext : '')] = {
                templateUrl: 'task.details.html',
                controller: 'taskDetailsCtrl'
            };
            return taskState;
        };
        this.getFeatureDetailsState = function(viewContext, isModal) {
            var featureTabs = itemTabsProvider.itemTabs.feature;
            var tabNames = _.keys(featureTabs);
            var featureState = {
                name: 'details',
                url: "/{featureId:int}",
                resolve: {
                    // Inject "features" to wait for resolution from parent state so FeatureService.get is ensured to find the feature in the cache
                    detailsFeature: ['FeatureService', '$stateParams', 'features', function(FeatureService, $stateParams, features) {
                        return FeatureService.get($stateParams.featureId);
                    }]
                },
                views: {},
                children: [
                    {
                        name: 'tab',
                        url: '/{featureTabId:(?:' + _.join(tabNames, '|') + ')}',
                        resolve: {},
                        views: {
                            "details-tab": {
                                templateUrl: function($stateParams) {
                                    if ($stateParams.featureTabId) {
                                        return featureTabs[$stateParams.featureTabId].templateUrl;
                                    }
                                },
                                controller: ['$scope', 'detailsFeature', function($scope, detailsFeature) {
                                    $scope.selected = detailsFeature;
                                }]
                            }
                        }
                    }
                ]
            };
            // Default tab (without tabId)
            featureState.resolve.details = featureTabs.details.resolve;
            var featureTabState = featureState.children[0];
            _.each(featureTabs, function(value, key) {
                featureTabState.resolve['data' + key] = value.resolve;
            });
            featureState.views['details' + (viewContext ? viewContext : '')] = {
                templateUrl: 'feature.details.html',
                controller: 'featureDetailsCtrl'
            };
            if (!isModal) {
                featureTabState.children = [
                    this.getDetailsModalState('story', {
                        children: [this.getStoryDetailsState('@', true)]
                    })
                ];
            }
            return featureState;
        };
        this.getStoryDetailsState = function(viewContext, isModal) {
            var storyTabs = itemTabsProvider.itemTabs.story;
            var tabNames = _.keys(storyTabs);
            var storyState = {
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
                        url: '/{storyTabId:(?:' + _.join(tabNames, '|') + ')}',
                        resolve: {},
                        views: {
                            "details-tab": {
                                templateUrl: function($stateParams) {
                                    if ($stateParams.storyTabId) {
                                        return storyTabs[$stateParams.storyTabId].templateUrl;
                                    }
                                },
                                controller: ['$scope', 'detailsStory', function($scope, detailsStory) {
                                    $scope.selected = detailsStory;
                                }]
                            }
                        }
                    }
                ]
            };
            // Default tab (without tabId)
            storyState.resolve.details = storyTabs.details.resolve;
            var storyTabState = storyState.children[0];
            _.each(storyTabs, function(value, key) {
                storyTabState.resolve['data' + key] = value.resolve;
            });
            storyState.views['details' + (viewContext ? viewContext : '')] = {
                templateUrl: 'story.details.html',
                controller: 'storyDetailsCtrl'
            };
            if (!isModal) {
                storyTabState.children = [
                    this.getDetailsModalState('task', {
                        resolve: {
                            taskContext: ['detailsStory', function(detailsStory) {
                                return detailsStory;
                            }]
                        },
                        children: [this.getTaskDetailsState('@')]
                    })
                ];
                storyState.children.push(this.getDetailsModalState('feature', {
                    resolve: {
                        features: ['FeatureService', function(FeatureService) {
                            return FeatureService.list();
                        }]
                    },
                    children: [this.getFeatureDetailsState('@', true)]
                }));
            }
            return storyState;
        };
        this.getReleaseDetailsState = function(viewContext) {
            var releaseTabs = itemTabsProvider.itemTabs.release;
            var tabNames = _.keys(releaseTabs);
            var releaseState = {
                name: 'details',
                url: "/details",
                views: {},
                resolve: {},
                data: {
                    displayTabs: tabNames.length > 1
                },
                children: [
                    {
                        name: 'tab',
                        url: '/{releaseTabId:(?:' + _.join(tabNames, '|') + ')}',
                        resolve: {},
                        views: {
                            "details-tab": {
                                templateUrl: function($stateParams) {
                                    if ($stateParams.releaseTabId) {
                                        return releaseTabs[$stateParams.releaseTabId].templateUrl;
                                    }
                                },
                                controller: ['$scope', 'detailsRelease', function($scope, detailsRelease) {
                                    $scope.selected = detailsRelease;
                                }]
                            }
                        }
                    }
                ]
            };
            // Default tab (without tabId)
            releaseState.resolve.details = releaseTabs.details.resolve;
            var releaseTabState = releaseState.children[0];
            _.each(releaseTabs, function(value, key) {
                releaseTabState.resolve['data' + key] = value.resolve;
            });
            releaseState.views['details' + (viewContext ? viewContext : '')] = {
                templateUrl: 'release.details.html',
                controller: 'releaseDetailsCtrl'
            };
            return releaseState;
        };
        this.getSprintDetailsState = function(viewContext) {
            var sprintTabs = itemTabsProvider.itemTabs.sprint;
            var tabNames = _.keys(sprintTabs);
            var sprintState = {
                name: 'details',
                url: "/details",
                resolve: {
                    detailsSprint: ['sprint', function(sprint) {
                        return sprint;
                    }],
                    detailsRelease: ['releases', 'detailsSprint', function(releases, detailsSprint) {
                        return _.find(releases, {id: detailsSprint.parentRelease.id});
                    }]
                },
                views: {},
                data: {
                    displayTabs: tabNames.length > 1
                },
                children: [
                    {
                        name: 'tab',
                        url: '/{sprintTabId:(?:' + _.join(tabNames, '|') + ')}',
                        resolve: {},
                        views: {
                            "details-tab": {
                                templateUrl: function($stateParams) {
                                    if ($stateParams.sprintTabId) {
                                        return sprintTabs[$stateParams.sprintTabId].templateUrl;
                                    }
                                },
                                controller: ['$scope', 'detailsSprint', function($scope, detailsSprint) {
                                    $scope.selected = detailsSprint;
                                }]
                            }
                        }
                    }
                ]
            };
            // Default tab (without tabId)
            sprintState.resolve.details = sprintTabs.details.resolve;
            var sprintTabState = sprintState.children[0];
            _.each(sprintTabs, function(value, key) {
                sprintTabState.resolve['data' + key] = value.resolve;
            });
            sprintState.views['details' + (viewContext ? viewContext : '')] = {
                templateUrl: 'sprint.details.html',
                controller: 'sprintDetailsCtrl'
            };
            return sprintState;
        };
        this.getBacklogStoryState = function() {
            return {
                name: 'story',
                url: "/story",
                children: [
                    {
                        name: 'new',
                        url: "/new",
                        data: {
                            authorize: {
                                roles: ['inProject or stakeHolder']
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
                            this.getDetailsModalState('feature', {
                                resolve: {
                                    features: ['FeatureService', function(FeatureService) {
                                        return FeatureService.list();
                                    }]
                                },
                                children: [this.getFeatureDetailsState('@', true)]
                            })
                        ]
                    },
                    this.getStoryDetailsState('@backlog')
                ]
            }
        };
    }]).config(['$stateProvider', function($stateProvider) {
        // Must be done in isCore to avoid doing it in isApplication + each plugin defining new states
        $stateProvider.decorator('parent', function(state, parentFn) {
            state.self.$$state = function() {
                return state;
            };
            state.self.isSecured = function() {
                return angular.isDefined(state.data) && angular.isDefined(state.data.authorize);
            };
            return parentFn(state);
        });
    }]);