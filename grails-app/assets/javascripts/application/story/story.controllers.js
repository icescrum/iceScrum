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

// Depends on TaskService to instantiate Task push listeners (necessary to maintain counts). We should think of a better way to systematically register the listeners
extensibleController('storyCtrl', ['$scope', '$uibModal', '$filter', '$window', 'TagService', 'StoryService', 'TaskService', 'StoryStatesByName', 'AcceptanceTestStatesByName', function($scope, $uibModal, $filter, $window, TagService, StoryService, TaskService, StoryStatesByName, AcceptanceTestStatesByName) {
    // Functions
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            TagService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.acceptToBacklog = function(story) {
        StoryService.updateState(story, 'accept').then(function() {
            $scope.notifySuccess($scope.message('is.ui.story.state.markAs.success', [$scope.storyStateName(StoryStatesByName.ACCEPTED)]) + ' ' + $scope.message('is.ui.story.state.backlog.success'));
        });
    };
    $scope.turnInto = function(story, target) {
        StoryService.turnInto(story, target).then(function() {
            $scope.notifySuccess('is.ui.story.turnInto' + target + '.success');
        });
    };
    $scope.returnToSandbox = function(story) {
        StoryService.updateState(story, 'returnToSandbox').then(function() {
            $scope.notifySuccess($scope.message('is.ui.story.state.markAs.success', [$scope.storyStateName(StoryStatesByName.SUGGESTED)]) + ' ' + $scope.message('is.ui.story.state.sandbox.success'));
        });
    };
    $scope.unPlan = function(story) {
        StoryService.unPlan(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.unplanned');
        });
    };
    $scope.shiftToNext = function(story) {
        StoryService.shiftToNext(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.shiftedToNext');
        });
    };
    $scope.updateState = function(story, action, state) {
        StoryService.updateState(story, action).then(function() {
            $scope.notifySuccess($scope.message('is.ui.story.state.markAs.success', [$scope.storyStateName(state)]));
        });
    };
    $scope.follow = function(story) {
        StoryService.follow(story);
    };
    $scope.copy = function(story) {
        StoryService.copy(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.copied');
        });
    };
    $scope['delete'] = function(story) {
        StoryService.delete(story).then(function() {
            $scope.notifySuccess('todo.is.ui.deleted');
        });
    };
    $scope.authorizedStory = StoryService.authorizedStory;
    $scope.storyStateName = function(state) {
        return $filter('i18n')(state, 'StoryStates');
    };
    $scope.i18nMarkAs = function(state) {
        return $scope.message('is.ui.story.state.markAs') + ' ' + $scope.storyStateName(state);
    };
    $scope.menus = [
        {
            name: 'todo.is.ui.details',
            priority: function(story, defaultPriority, viewType) {
                return viewType === 'list' ? 100 : defaultPriority;
            },
            visible: function(story, viewType) { return viewType !== 'details'; },
            action: function(story) { $window.location.hash = $scope.openStoryUrl(story.id); } // Inherited
        },
        {
            name: function() { return $scope.i18nMarkAs(StoryStatesByName.ACCEPTED); },
            visible: function(story) { return $scope.authorizedStory('accept', story) },
            action: function(story) { $scope.acceptToBacklog(story); }
        },
        {
            name: 'is.ui.story.turnIntoFeature',
            visible: function(story) { return $scope.authorizedStory('accept', story) },
            action: function(story) { $scope.confirm({message: $scope.message('is.ui.story.turnIntoFeature.confirm'), callback: $scope.turnInto, args: [story, 'Feature']}); }
        },
        {
            name: 'is.ui.story.turnIntoTask',
            visible: function(story) { return $scope.authorizedStory('accept', story) },
            action: function(story) { $scope.confirm({message: $scope.message('is.ui.story.turnIntoTask.confirm'), callback: $scope.turnInto, args: [story, 'Task']}); }
        },
        {
            name: function() { return $scope.i18nMarkAs(StoryStatesByName.DONE); },
            visible: function(story) { return $scope.authorizedStory('done', story) },
            action: function(story) {
                var remainingAcceptanceTests = story.testState != AcceptanceTestStatesByName.SUCCESS && story.acceptanceTests_count;
                var remainingTasks = story.countDoneTasks != story.tasks_count;
                if (remainingAcceptanceTests || remainingTasks) {
                    var messages = [];
                    if (remainingAcceptanceTests) {
                        messages.push($scope.message('todo.is.ui.story.done.acceptanceTest.confirm', [$scope.storyStateName(StoryStatesByName.DONE)]));
                    }
                    if (remainingTasks) {
                        messages.push($scope.message('todo.is.ui.story.done.task.confirm', [$scope.storyStateName(StoryStatesByName.DONE)]));
                    }
                    $scope.confirm({
                        message: _.map(messages, $scope.message).join('<br/><br/>'),
                        callback: $scope.updateState,
                        args: [story, 'done', StoryStatesByName.DONE]
                    });
                } else {
                    $scope.updateState(story, 'done', StoryStatesByName.DONE);
                }
            }
        },
        {
            name: function() { return $scope.i18nMarkAs(StoryStatesByName.IN_PROGRESS); },
            visible: function(story) { return $scope.authorizedStory('unDone', story) },
            action: function(story) { $scope.updateState(story, 'unDone', StoryStatesByName.IN_PROGRESS); }
        },
        {
            name: 'is.ui.sprintPlan.menu.postit.shiftToNext',
            visible: function(story) { return $scope.authorizedStory('shiftToNext', story)},
            action: function(story) { $scope.shiftToNext(story); }
        },
        {
            name: 'todo.is.ui.story.plan',
            visible: function(story) { return $scope.authorizedStory('plan', story) },
            action: function(story) { $scope.showPlanModal(story); }
        },
        {
            name: 'is.ui.backlog.menu.estimate',
            visible: function(story) { return $scope.authorizedStory('updateEstimate', story) },
            action: function(story) { $scope.showEditEffortModal(story); }
        },
        {
            name: 'is.ui.backlog.menu.split',
            visible: function(story) { return $scope.authorizedStory('split', story) },
            action: function(story) { $scope.showStorySplitModal(story); }
        },
        {
            name: 'is.ui.releasePlan.menu.story.clone',
            visible: function(story) { return $scope.authorizedStory('copy', story) },
            action: function(story) { $scope.copy(story); }
        }, {
            name: 'todo.is.ui.permalink.copy',
            visible: function(story) { return true },
            action: function(story) { $scope.showCopyModal($scope.message('is.permalink'), ($filter('permalink')(story.uid, 'story'))); }
        },
        {
            name: 'is.ui.releasePlan.menu.story.dissociate',
            visible: function(story) { return $scope.authorizedStory('unPlan', story) },
            action: function(story) { $scope.unPlan(story); }
        },
        {
            name: function() { return $scope.i18nMarkAs(StoryStatesByName.SUGGESTED); },
            visible: function(story) { return $scope.authorizedStory('returnToSandbox', story) },
            action: function(story) { $scope.returnToSandbox(story); }
        },
        {
            name: 'is.ui.backlog.menu.delete',
            visible: function(story) { return $scope.authorizedStory('delete', story) },
            action: function(story) { $scope.confirmDelete({callback: $scope.delete, args: [story]}); }
        }
    ];
    $scope.showStoryProgress = function(story) {
        return story.tasks_count > 0 && story.state >= StoryStatesByName.PLANNED;
    };
    $scope.isEffortCustom = function() {
        return $scope.getProjectFromState().planningPokerGameType == 2;
    };
    $scope.effortSuite = function(isNullable) {
        if (isNullable) {
            return $scope.getProjectFromState().planningPokerGameType == 0 ? $scope.integerSuiteNullable : $scope.fibonacciSuiteNullable;
        } else {
            return $scope.getProjectFromState().planningPokerGameType == 0 ? $scope.integerSuite : $scope.fibonacciSuite;
        }
    };
    $scope.isEffortNullable = function(story) {
        return story.state <= StoryStatesByName.ESTIMATED;
    };
    var scrollTable = function(dontAnimate, nbItems) {
        var ths = angular.element('.table-scrollable').find('th');
        var titleWidth = angular.element(ths[0]).prop('offsetWidth');
        var tableWidth = ths.size() > 0 ? angular.element(angular.element('.table-scrollable').find('th')[1]).prop('offsetWidth') : titleWidth;
        var scrollLeft = titleWidth + (nbItems - 1) * tableWidth;
        if (dontAnimate) {
            $('.table-scrollable').scrollLeft(scrollLeft);
        } else {
            $('.table-scrollable').animate({
                scrollLeft: scrollLeft
            }, 400);
        }
    };
    $scope.showPlanModal = function(story) {
        $uibModal.open({
            size: 'sm',
            templateUrl: 'story.plan.html',
            controller: ['$scope', function($scope) {
                // Functions
                $scope.submit = function(sprint) {
                    if (sprint) {
                        StoryService.plan(story, sprint).then(function() {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.story.plan.success');
                        });
                    }
                };
                $scope.hasSprint = function() {
                    return !_.isArray($scope.parentSprintEntries) || $scope.parentSprintEntries.length != 0;
                };
                // Init
                $scope.holder = {};
                $scope.formHolder = {};
                $scope.parentSprintEntries = undefined;
                StoryService.getParentSprintEntries($scope.getProjectFromState().id).then(function(parentSprintEntries) {
                    $scope.parentSprintEntries = parentSprintEntries;
                    if (parentSprintEntries) {
                        $scope.holder.parentSprint = _.first(parentSprintEntries);
                    }
                });
            }]
        });
    };
    $scope.showEditEffortModal = function(story, $event) {
        if (StoryService.authorizedStory('updateEstimate', story)) {
            var parentScope = $scope;
            $uibModal.open({
                size: 'lg',
                templateUrl: 'story.effort.html',
                controller: ['$scope', '$timeout', function($scope, $timeout) {
                    $scope.editableStory = angular.copy(story);
                    if ($scope.editableStory.effort == undefined) {
                        $scope.editableStory.effort = '?';
                    }
                    $scope.initialEffort = $scope.editableStory.effort;
                    var initialEfforts = [];
                    var initialStoriesByEffort = [];
                    var initialCount = [];
                    $scope.efforts = [];
                    $scope.storyRows = [];
                    $scope.count = [];
                    $scope.isEffortCustom = parentScope.isEffortCustom;
                    if (!$scope.isEffortCustom()) {
                        $scope.effortSuiteValues = parentScope.effortSuite(parentScope.isEffortNullable);
                        $scope.sliderEffort = {
                            min: 0,
                            step: 1,
                            max: $scope.effortSuiteValues.length - 1,
                            labelValue: $scope.effortSuiteValues.indexOf($scope.initialEffort),
                            formatter: function(val) {
                                return $scope.effortSuiteValues[val.value];
                            },
                            sliderid: "slider-effort"
                        };
                        if ($scope.effortSuiteValues.length < 30) {
                            $scope.sliderEffort.rangeHighlights = [
                                {start: 0, end: $scope.effortSuiteValues.indexOf(5)},
                                {start: $scope.effortSuiteValues.indexOf(5), end: $scope.effortSuiteValues.indexOf(13)},
                                {start: $scope.effortSuiteValues.indexOf(13), end: $scope.effortSuiteValues.length - 1}
                            ]
                        }
                        $scope.$watch('sliderEffort.labelValue', function(newVal) {
                            $scope.editableStory.effort = $scope.effortSuiteValues[newVal];
                        });
                    }
                    StoryService.listByField('effort', $scope.getProjectFromState().id).then(function(effortsAndStories) {
                        initialEfforts = effortsAndStories.fieldValues;
                        var indexOfNull = initialEfforts.indexOf(null);
                        if (indexOfNull != -1) {
                            initialEfforts.splice(indexOfNull, 1, '?');
                        }
                        initialStoriesByEffort = effortsAndStories.stories;
                        initialCount = effortsAndStories.count;
                        $scope.updateTable(true)
                    });
                    $scope.updateTable = function(dontAnimate) {
                        var effort = $scope.editableStory.effort;
                        $scope.efforts = angular.copy(initialEfforts);
                        var storiesByEffort = angular.copy(initialStoriesByEffort);
                        $scope.count = angular.copy(initialCount);
                        // Required because of mix of strings (native select options) and numbers returned by the server
                        var effortIndex = _.findIndex($scope.efforts, function(effort2) {
                            return effort2 == effort;
                        });
                        if (effortIndex == -1) {
                            effortIndex = _.sortedIndex($scope.efforts, effort);
                            $scope.efforts.splice(effortIndex, 0, effort);
                            storiesByEffort.splice(effortIndex, 0, []);
                            $scope.count.splice(effortIndex, 0, 0);
                        }
                        var initialEffortIndex = $scope.efforts.indexOf($scope.initialEffort);
                        _.remove(storiesByEffort[initialEffortIndex], {id: $scope.editableStory.id});
                        storiesByEffort[effortIndex].unshift($scope.editableStory);
                        $scope.storiesByEffort = storiesByEffort;
                        $timeout(function() {
                            scrollTable(dontAnimate, effortIndex);
                        });
                    };
                    $scope.setEffort = function(effort) {
                        $scope.editableStory.effort = effort;
                        $scope.sliderEffort.labelValue = $scope.effortSuiteValues.indexOf(effort);
                        $scope.updateTable();
                    };
                    $scope.submit = function(story) {
                        StoryService.update(story).then(function() {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.story.effort.updated');
                        });
                    };
                }]
            });
            if ($event) {
                $event.stopPropagation();
            }
        }
    };
    $scope.showEditValueModal = function(story, $event) {
        if (StoryService.authorizedStory('update', story)) {
            $uibModal.open({
                size: 'lg',
                templateUrl: 'story.value.html',
                controller: ["$scope", '$timeout', function($scope, $timeout) {
                    $scope.editableStory = angular.copy(story);
                    $scope.initialValue = $scope.editableStory.value;
                    var initialValues = [];
                    var initialStoriesByValue = [];
                    var initialCount = [];
                    $scope.values = [];
                    $scope.storyRows = [];
                    $scope.count = [];
                    StoryService.listByField('value', $scope.getProjectFromState().id).then(function(valuesAndStories) {
                        initialValues = valuesAndStories.fieldValues;
                        initialStoriesByValue = valuesAndStories.stories;
                        initialCount = valuesAndStories.count;
                        $scope.updateTable(true)
                    });
                    $scope.updateTable = function(dontAnimate) {
                        var value = $scope.editableStory.value;
                        $scope.values = angular.copy(initialValues);
                        var storiesByValue = angular.copy(initialStoriesByValue);
                        $scope.count = angular.copy(initialCount);
                        var valueIndex = $scope.values.indexOf(value);
                        if (valueIndex == -1) {
                            valueIndex = _.sortedIndex($scope.values, value);
                            $scope.values.splice(valueIndex, 0, value);
                            storiesByValue.splice(valueIndex, 0, []);
                            $scope.count.splice(valueIndex, 0, 0);
                        }
                        var initialValueIndex = $scope.values.indexOf($scope.initialValue);
                        _.remove(storiesByValue[initialValueIndex], {id: $scope.editableStory.id});
                        storiesByValue[valueIndex].unshift($scope.editableStory);
                        $scope.storiesByValue = storiesByValue;
                        $timeout(function() {
                            scrollTable(dontAnimate, valueIndex);
                        });
                    };
                    $scope.setValue = function(value) {
                        $scope.editableStory.value = value;
                        $scope.sliderEffort.labelValue = $scope.values.indexOf($scope.value);
                        $scope.updateTable();
                    };
                    $scope.submit = function(story) {
                        StoryService.update(story).then(function() {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.story.value.updated');
                        });
                    };
                }]
            });
            if ($event) {
                $event.stopPropagation();
            }
        }
    };
    $scope.retrieveParentSprintEntries = function() {
        if (_.isEmpty($scope.parentSprintEntries)) {
            StoryService.getParentSprintEntries($scope.getProjectFromState().id).then(function(parentSprintEntries) {
                $scope.parentSprintEntries = parentSprintEntries;
            });
        }
    };
    $scope.showStorySplitModal = function(story) {
        $uibModal.open({
            keyboard: false,
            backdrop: 'static',
            templateUrl: 'story.split.html',
            controller: 'storySplitCtrl',
            resolve: {story: story}
        });
    };
    // Init
    $scope.storyStatesByName = StoryStatesByName;
    $scope.tags = [];
}]);

extensibleController('storySplitCtrl', ['$scope', '$controller', '$q', 'StoryService', 'StoryStatesByName', 'story', function($scope, $controller, $q, StoryService, StoryStatesByName, story) {
    $controller('storyCtrl', {$scope: $scope});
    $controller('storyAtWhoCtrl', {$scope: $scope});
    // Functions
    $scope.onChangeSplitNumber = function() {
        if ($scope.stories.length < $scope.splitCount) {
            while ($scope.stories.length < $scope.splitCount) {
                var newStory = angular.copy($scope.storyReference);
                newStory.name = '';
                newStory.id = null;
                newStory.notes = '';
                newStory.description = '';
                newStory.origin = $scope.storyReference.name;
                newStory.state = $scope.storyReference.state >= StoryStatesByName.ACCEPTED ? StoryStatesByName.ACCEPTED : StoryStatesByName.SUGGESTED;
                $scope.stories.push(newStory);
            }
        } else if ($scope.stories.length > $scope.splitCount) {
            while ($scope.stories.length > $scope.splitCount) {
                $scope.stories.splice($scope.stories.length - 1, 1);
            }
        }
        // Split effort from original story
        if ($scope.storyReference.effort > 0) {
            var effort = parseInt($scope.storyReference.effort / $scope.splitCount);
            effort = effort >= 1 ? effort : 1;
            _.each($scope.stories, function(story) {
                story.effort = effort;
            });
        }
        if ($scope.storyReference.value > 0) {
            var value = parseInt($scope.storyReference.value / $scope.splitCount);
            value = value >= 1 ? value : 1;
            _.each($scope.stories, function(story) {
                story.value = value;
            });
        }
    };
    $scope.submit = function(stories) {
        var tasks = [];
        var lastRank = null;
        _.each(stories, function(story) {
            if (story.id) {
                lastRank = story.rank;
                tasks.push(function() {
                    return StoryService.update(story)
                });
            } else {
                var effort = story.effort;
                tasks.push({
                    success: function() {
                        return StoryService.save(story, $scope.getProjectFromState().id);
                    }
                });
                if (lastRank != null) {
                    tasks.push({
                        success: function(createdStory) {
                            createdStory.rank = lastRank + 1;
                            lastRank++;
                            return StoryService.update(createdStory);
                        }
                    })
                }
                if (effort >= 0) {
                    tasks.push({
                        success: function(createdStory) {
                            createdStory.effort = effort;
                            return StoryService.update(createdStory);
                        }
                    })
                }
            }
        });
        tasks.push({
            success: function() {
                $scope.$close();
                $scope.notifySuccess('is.ui.backlog.menu.split.success');
                return $q.when();
            }
        });
        $q.serial(tasks);
    };
    $scope.getCheckStoryNameUrl = function(story) {
        return '/p/' + $scope.getProjectFromState().id + '/story' + (story.id ? ('/' + story.id) : '') + '/available';
    };
    $scope.validateStoryName = function(newName, story) {
        return !newName || !story || _.find($scope.stories, function(otherStory) {
            return story !== otherStory && newName.toLowerCase() === otherStory.name.toLowerCase();
        }) == null;
    };
    // Init
    $scope.storyReference = angular.copy(story);
    $scope.formHolder = {};
    $scope.loadAtWhoActors();
    $scope.stories = [];
    $scope.stories.push(angular.copy($scope.storyReference));
    $scope.splitCount = 2;
    $scope.onChangeSplitNumber();
}]);

controllers.controller('storyAtWhoCtrl', ['$scope', '$controller', 'ActorService', function($scope, $controller, ActorService) {
    // Functions
    $scope.loadAtWhoActors = function() {
        return ActorService.list($scope.getProjectFromState().id).then(function(actors) {
            _.each($scope.atOptions, function(options) {
                if (options.actors) {
                    options.data = _.map(actors, function(actor) {
                        return {uid: actor.uid, name: actor.name};
                    });
                }
            });
        });
    };
    // Init
    var actorTag = 'A[${uid}-${name}]';
    var atWhoLimit = 100;
    $scope.atOptions = [
        {
            insertTpl: '${atwho-at}' + actorTag,
            at: $scope.message('is.story.template.as') + ' ',
            limit: atWhoLimit,
            actors: true
        },
        {
            insertTpl: actorTag,
            at: '@',
            limit: atWhoLimit,
            actors: true
        }
    ];
}]);

extensibleController('storyDetailsCtrl', ['$scope', '$controller', '$state', '$timeout', '$filter', 'TaskConstants', "StoryTypesByName", "TaskStatesByName", 'AcceptanceTestStatesByName', 'Session', 'StoryService', 'FormService', 'FeatureService', 'ProjectService', 'UserService', 'ActorService', 'detailsStory', 'project',
    function($scope, $controller, $state, $timeout, $filter, TaskConstants, StoryTypesByName, TaskStatesByName, AcceptanceTestStatesByName, Session, StoryService, FormService, FeatureService, ProjectService, UserService, ActorService, detailsStory, project) {
        $controller('storyCtrl', {$scope: $scope});
        $controller('storyAtWhoCtrl', {$scope: $scope});
        $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsStory, clazz: 'story', project: project});
        // Functions
        $scope.searchCreator = function($select) {
            if ($scope.formHolder.editing && $select.open) {
                UserService.search($select.search).then(function(users) {
                    $scope.creators = _.map(users, function(member) {
                        member.name = $filter('userFullName')(member);
                        return member;
                    });
                });
            }
        };
        $scope.update = function(story) {
            if (story.effort == undefined) {
                story.effort = '?';
            }
            StoryService.update(story).then(function() {
                $scope.resetStoryForm();
                $scope.notifySuccess('todo.is.ui.story.updated');
            });
        };
        $scope.clickDescriptionPreview = function($event, template) {
            if ($event.target.nodeName != 'A' && $scope.formEditable()) {
                $scope.loadAtWhoActors();
                $scope.showDescriptionTextarea = true;
                var $el = angular.element($event.currentTarget);
                $el.prev().css('height', $el.outerHeight());
                $scope.editForm(true);
                if (!$scope.editableStory.description && $scope.editableStory.type == StoryTypesByName.USER_STORY) {
                    ($scope.editableStory.description = template);
                }
            }
        };
        $scope.focusDescriptionPreview = function($event) {
            if (!$scope.descriptionPreviewMouseDown) {
                $timeout(function() {
                    angular.element($event.target).triggerHandler('click');
                });
            }
        };
        $scope.blurDescription = function(template) {
            if (!$('.atwho-view:visible').length && $scope.formHolder.storyForm.description.$valid) { // ugly hack on atwho
                $scope.showDescriptionTextarea = false;
                if ($scope.editableStory.description == null || $scope.editableStory.description.trim() == template.trim()) {
                    $scope.editableStory.description = '';
                }
            }
        };
        $scope.searchDependenceEntries = function(story, $select) {
            if ($scope.formHolder.editing && $select.open) {
                StoryService.getDependenceEntries(story, $select.search).then(function(dependenceEntries) {
                    $scope.dependenceEntries = dependenceEntries;
                });
            }
        };
        $scope.retrieveVersions = function() {
            if (_.isEmpty($scope.versions)) {
                ProjectService.getVersions(project.id).then(function(versions) {
                    $scope.versions = versions;
                });
            }
        };
        $scope.tabUrl = function(storyTabId) {
            var stateName = $state.params.storyTabId ? (storyTabId ? '.' : '^') : (storyTabId ? '.tab' : '.');
            return $state.href(stateName, {storyTabId: storyTabId});
        };
        $scope.toggleFocusUrl = function() {
            return $state.href($scope.application.focusedDetailsView ? ($state.params.storyTabId ? '^.^.tab' : '^') : $state.params.storyTabId ? '^.focus.tab' : '.focus', {storyTabId: $state.params.storyTabId});
        };
        $scope.currentStateUrl = function(id) {
            return $state.href($state.current.name, {storyId: id});
        };
        $scope.closeUrl = function() {
            var stateName = $state.params.storyTabId ? '^.^' : '^';
            if ($state.current.name.indexOf('.story.') != '-1') {
                stateName += '.^'
            }
            return $state.href(stateName);
        };
        $scope.storyFeatureUrl = function(story) {
            return $state.href('.feature.details', {storyId: story.id, featureId: story.feature.id});
        };
        $scope.listFeatures = function() {
            FeatureService.list(project);
        };
        $scope.previousStory = function() {
            if ($scope.findPreviousOrNextStory) {
                return $scope.findPreviousOrNextStory('previous', detailsStory);
            }
        };
        $scope.nextStory = function() {
            if ($scope.findPreviousOrNextStory) {
                return $scope.findPreviousOrNextStory('next', detailsStory);
            }
        };
        $scope.getAcceptanceTestClass = function(story) {
            return (story.testState == AcceptanceTestStatesByName.FAILED ? 'text-danger' :
                    story.testState == AcceptanceTestStatesByName.SUCCESS ? 'text-success' : '') +
                   ($state.params.storyTabId == 'tests' || $scope.application.focusedDetailsView ? ' active' : '');
        };
        $scope.hasSameProject = function(story1, story2) {
            return !story2 || !story2.project || (story1.project.id == story2.project.id)
        };
        // Init
        $controller('updateFormController', {$scope: $scope, item: detailsStory, type: 'story'});
        $scope.dependenceEntries = [];
        $scope.parentSprintEntries = [];
        $scope.versions = [];
        $scope.creators = [];
        $scope.features = project.features;
        $scope.project = project;
        // For header
        $scope.tasksOrderBy = TaskConstants.ORDER_BY;
        $scope.storyTypesByName = StoryTypesByName;
        $scope.taskStatesByName = TaskStatesByName;
        if (detailsStory.actors_ids && detailsStory.actors_ids.length) {
            ActorService.list(project.id).then(function(actors) {
                $scope.actors = actors;
            });
        }
    }]);

extensibleController('storyMultipleCtrl', ['$scope', '$controller', '$filter', 'StoryService', 'storyListId', 'Session', 'FeatureService', 'StoryStatesByName', 'project', function($scope, $controller, $filter, StoryService, storyListId, Session, FeatureService, StoryStatesByName, project) {
    $controller('storyCtrl', {$scope: $scope}); // inherit from storyCtrl
    // Functions
    $scope.deleteMultiple = function() {
        StoryService.deleteMultiple(storyListId, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.multiple.deleted');
        });
    };
    $scope.copyMultiple = function() {
        StoryService.copyMultiple(storyListId, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.story.multiple.copied');
        });
    };
    $scope.updateMultiple = function(updatedFields) {
        StoryService.updateMultiple(storyListId, updatedFields, project.id).then(function() {
            $scope.notifySuccess('todo.is.ui.story.multiple.updated');
        });
    };
    $scope.acceptToBacklogMultiple = function() {
        StoryService.updateStateMultiple(storyListId, project.id, 'accept').then(function() {
            $scope.notifySuccess($scope.message('is.ui.story.state.markAs.success.multiple', [$scope.storyStateName(StoryStatesByName.ACCEPTED)]) + ' ' + $scope.message('is.ui.story.state.backlog.success.multiple'));
        });
    };
    $scope.returnToSandboxMultiple = function() {
        StoryService.updateStateMultiple(storyListId, project.id, 'returnToSandbox').then(function() {
            $scope.notifySuccess($scope.message('is.ui.story.state.markAs.success.multiple', [$scope.storyStateName(StoryStatesByName.SUGGESTED)]) + ' ' + $scope.message('is.ui.story.state.sandbox.success.multiple'));
        });
    };
    $scope.followMultiple = function(follow) {
        StoryService.followMultiple(storyListId, follow, project.id).then(function() {
            refreshStories();
        });
    };
    $scope.turnIntoMultiple = function(target) {
        StoryService.turnIntoMultiple(storyListId, target, project.id).then(function() {
            $scope.notifySuccess('is.ui.story.turnInto' + target + '.success.multiple');
        });
    };
    $scope.storyStateName = function(state) {
        return $filter('i18n')(state, 'StoryStates');
    };
    $scope.authorizedStories = StoryService.authorizedStories;
    // Init
    $scope.selectableOptions.selectingMultiple = true;
    $scope.topStory = {};
    $scope.storyPreview = {};
    $scope.stories = [];
    $scope.storyListId = storyListId; // For child controllers
    $scope.features = project.features;
    FeatureService.list(project);
    $scope.allFollowed = function(stories) {
        return _.every(stories, function(story) {
            return $filter('followedByUser')(story);
        });
    };
    $scope.noneFollowed = function(stories) {
        return !_.some(stories, function(story) {
            return $filter('followedByUser')(story);
        });
    };

    function refreshStories() {
        StoryService.getMultiple(storyListId, project.id).then(function(stories) {
            $scope.topStory = _.head(stories);
            $scope.storyPreview = {
                value: _.every(stories, {value: $scope.topStory.value}) ? $scope.topStory.value : null,
                effort: _.every(stories, {effort: $scope.topStory.effort}) ? $scope.topStory.effort : null,
                feature: _.every(stories, {feature: $scope.topStory.feature}) ? $scope.topStory.feature : null,
                type: _.every(stories, {type: $scope.topStory.type}) ? $scope.topStory.type : null,
                tags: _.intersection.apply(null, _.map(stories, 'tags'))
            };
            $scope.stories = stories;
        });
    }

    refreshStories();
}]);

extensibleController('storyNewCtrl', ['$scope', '$state', '$timeout', '$controller', 'Session', 'StoryService', 'FeatureService', 'hotkeys', 'StoryStatesByName', 'postitSize', 'screenSize', 'project', function($scope, $state, $timeout, $controller, Session, StoryService, FeatureService, hotkeys, StoryStatesByName, postitSize, screenSize, project) {
    $controller('storyCtrl', {$scope: $scope}); // inherit from storyCtrl
    // Functions
    $scope.resetStoryForm = function() {
        $scope.story = {
            state: $scope.story ? $scope.story.state : StoryStatesByName.SUGGESTED,
            feature: $scope.story && $scope.story.feature ? $scope.story.feature : undefined
        };
        $scope.resetFormValidation($scope.formHolder.storyForm);
    };
    $scope.save = function(story, andContinue) {
        StoryService.save(story, project.id).then(function(story) {
            if (andContinue) {
                $scope.resetStoryForm();
            } else {
                $scope.setInEditingMode(true);
                $state.go('^.details', {storyId: story.id, elementId: _.includes([StoryStatesByName.ACCEPTED, StoryStatesByName.ESTIMATED], story.state) ? 'backlog' : 'sandbox'});
            }
            $scope.notifySuccess('todo.is.ui.story.saved');
        });
    };
    $scope.findDuplicates = function(term) {
        if (term == null || term.length <= 5) {
            $scope.messageDuplicate = '';
        } else if (term.length >= 5) {
            var trimmedTerm = term.trim();
            //TODO maybe local search ?
            $timeout.cancel($scope.timerDuplicate);
            $scope.timerDuplicate = $timeout(function() {
                if ($scope.lastSearchedTerm != trimmedTerm) {
                    StoryService.findDuplicates(trimmedTerm, project.id).then(function(messageDuplicate) {
                        $scope.lastSearchedTerm = trimmedTerm;
                        $scope.messageDuplicate = messageDuplicate ? messageDuplicate : '';
                    });
                }
            }, 500);
        }
    };
    $scope.featureChanged = function() {
        $scope.storyPreview.feature = $scope.story.feature;
    };
    // Init
    $scope.formHolder = {};
    $scope.storyPreview = {};
    $scope.resetStoryForm();
    $scope.newStoryStates = [StoryStatesByName.SUGGESTED, StoryStatesByName.ACCEPTED];
    $scope.features = project.features;
    FeatureService.list(project);
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetStoryForm
    });
    var getStandalonePostitClass = function() {
        $scope.postitClass = postitSize.standalonePostitClass($scope.viewName, 'grid-group size-sm');
    };
    getStandalonePostitClass();
    screenSize.on('xs, sm', getStandalonePostitClass, $scope);
    $scope.$watch(function() { return postitSize.currentPostitSize($scope.viewName); }, getStandalonePostitClass);
}]);

controllers.controller('storyBacklogCtrl', ['$controller', '$scope', '$filter', 'postitSize', 'screenSize', function($controller, $scope, $filter, postitSize, screenSize) {
    $controller('storyCtrl', {$scope: $scope}); // inherit from storyCtrl
    // Don't use orderBy filter on ng-repeat because it triggers sort on every single digest on the page, which happens all the time...
    // We are only interested in story updates
    var updateOrder = function() {
        $scope.backlogStories = $scope.orderBy ? $filter('orderBy')($scope.backlog.stories, $scope.orderBy.current.value, $scope.orderBy.reverse) : $scope.backlog.stories;
    };
    $scope.$watch('backlog.stories', updateOrder, true);
    $scope.$watch('orderBy', updateOrder, true);
    var getPostitClass = function() {
        $scope.postitClass = postitSize.postitClass($scope.viewName, 'grid-group size-sm');
    };
    getPostitClass();
    screenSize.on('xs, sm', getPostitClass, $scope);
    $scope.$watch(function() { return postitSize.currentPostitSize($scope.viewName); }, getPostitClass);
    // Hack to provide all the lists of stories to the current view
    // So it can look for previous / next story from a details view
    if ($scope.storyListGetters) {
        var storyListGetter = function() {
            return $filter('search')($scope.backlogStories); // Needs to be in a function because it can change
        };
        $scope.storyListGetters.push(storyListGetter);
        $scope.$on('$destroy', function() {
            _.remove($scope.storyListGetters, function(storyListGetter2) {
                return storyListGetter2 === storyListGetter;
            });
        })
    }
}]);

controllers.controller('featureStoriesCtrl', ['$controller', '$scope', '$filter', 'StoryStatesByName', 'ActorService', function($controller, $scope, $filter, StoryStatesByName, ActorService) {
    // Init
    $scope.storyEntries = [];
    $scope.$watch(function() {
        return $scope.selected.stories; // $scope.selected is inherited
    }, function(newStories) {
        $scope.storyEntries = _.chain(newStories)
            .groupBy(function(story) {
                if (story.parentSprint) {
                    return 'sprint' + story.parentSprint.id;
                } else if (_.includes([StoryStatesByName.ACCEPTED, StoryStatesByName.ESTIMATED], story.state)) {
                    return 'backlog';
                } else {
                    return story.state;
                }
            })
            .map(function(stories) {
                var label;
                var state = stories[0].state;
                var sprint = stories[0].parentSprint;
                if (sprint) {
                    label = sprint.parentReleaseName + ' - ' + $filter('sprintName')(sprint)
                } else if (state == StoryStatesByName.SUGGESTED) {
                    label = $scope.message('is.ui.sandbox');
                } else if (_.includes([StoryStatesByName.ACCEPTED, StoryStatesByName.ESTIMATED], state)) {
                    label = $scope.message('is.ui.backlog');
                } else {
                    label = $filter('i18n')(state, 'StoryStates');
                }
                label += ' (' + stories.length;
                var totalEffort = _.sumBy(stories, 'effort');
                if (totalEffort) {
                    label += ' - ' + totalEffort + '<i class="fa fa-dollar fa-small"></i></small>'
                }
                label += ')';
                return {
                    label: label,
                    stories: _.sortBy(stories, [function(story) {
                        return story.state === StoryStatesByName.ESTIMATED ? StoryStatesByName.ACCEPTED : story.state;
                    }, 'rank'])
                };
            })
            .orderBy(['stories[0].parentSprint.parentReleaseOrderNumber', 'stories[0].parentSprint.orderNumber', 'stories[0].state'], ['asc', 'asc', 'desc'])
            .value();
    }, true);
    ActorService.list($scope.getProjectFromState().id).then(function(actors) {
        $scope.actors = actors;
    });
}]);

extensibleController('featureStoryCtrl', ['$scope', '$controller', '$timeout', 'StoryService', function($scope, $controller, $timeout, StoryService) {
    $controller('storyCtrl', {$scope: $scope});
    $controller('storyAtWhoCtrl', {$scope: $scope});
    // Functions
    $scope.resetStoryForm = function() {
        $scope.editableStory = {
            feature: {id: $scope.selected.id}
        };
        $scope.resetFormValidation($scope.formHolder.storyForm);
    };
    $scope.save = function(story) {
        StoryService.save(story, $scope.getProjectFromState().id).then(function() {
            $scope.resetStoryForm();
            $scope.notifySuccess('todo.is.ui.story.saved');
        });
    };
    $scope.clickDescriptionPreview = function($event, template) {
        $scope.loadAtWhoActors();
        $scope.showDescriptionTextarea = true;
        if (!$scope.editableStory.description) {
            ($scope.editableStory.description = template);
        }
    };
    $scope.focusDescriptionPreview = function($event) {
        if (!$scope.descriptionPreviewMouseDown) {
            $timeout(function() {
                angular.element($event.target).triggerHandler('click');
            });
        }
    };
    $scope.blurDescription = function(template) {
        if (!$('.atwho-view:visible').length && $scope.formHolder.storyForm.description.$valid) { // ugly hack on atwho
            $scope.showDescriptionTextarea = false;
            if ($scope.editableStory.description == null || $scope.editableStory.description.trim() == template.trim()) {
                $scope.editableStory.description = '';
            }
        }
    };
    // Init
    $scope.formHolder = {};
    $scope.resetStoryForm();
}]);
