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

controllers.controller('storyCtrl', ['$scope', '$uibModal', 'StoryService', '$state', 'Session', 'StoryStatesByName', function($scope, $uibModal, StoryService, $state, Session, StoryStatesByName) {
    // Functions
    $scope.acceptToBacklog = function(story) {
        StoryService.acceptToBacklog(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.accepted');
        });
    };
    $scope.acceptAs = function(story, target) {
        StoryService.acceptAs(story, target).then(function() {
            $scope.notifySuccess('todo.is.ui.story.acceptedAs' + target);
        });
    };
    $scope.returnToSandbox = function(story) {
        StoryService.returnToSandbox(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.returnedToSandbox');
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
    $scope.done = function(story) {
        StoryService.done(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.done');
        });
    };
    $scope.unDone = function(story) {
        StoryService.unDone(story).then(function() {
            $scope.notifySuccess('todo.is.ui.story.unDone');
        });
    };
    $scope.follow = function(story) {
        StoryService.follow(story);
    };
    $scope.copy = function(story) {
        StoryService.copy(story)
    };
    $scope['delete'] = function(story) {
        //fake delete
        _.remove(StoryService.list, {id: story.id});
        var notif = $scope.notifySuccess('todo.is.ui.deleted', {
            actions: [{
                label: $scope.message('todo.is.ui.undo'),
                fn: function() {
                    notif.data.close = angular.noop;
                    StoryService.list.push(story);
                    $state.go('backlog.details', {id: story.id});
                    $scope.notifySuccess('todo.is.ui.deleted.cancelled');
                }
            }],
            close: function() {
                StoryService.delete(story);
            },
            duration: 5000
        });
    };
    $scope.authorizedStory = function(action, story) {
        return StoryService.authorizedStory(action, story);
    };
    $scope.tasksProgress = function(story) {
        return story.tasks_count > 0 && story.state < StoryStatesByName.DONE && story.state >= StoryStatesByName.PLANNED;
    };
    $scope.showNewTemplateModal = function(story) {
        $uibModal.open({
            templateUrl: 'story.template.new.html',
            size: 'sm',
            controller: ["$scope", function($scope) {
                $scope.submit = function(template) {
                    StoryService.saveTemplate(story, template.name).then(function() {
                        $scope.$close();
                        $scope.notifySuccess('todo.is.ui.story.template.saved');
                    });
                };
            }]
        });
    };
    $scope.isEffortCustom = function() {
        return Session.getProject().planningPokerGameType == 2;
    };
    $scope.effortSuite = function(isNullable) {
        if (isNullable) {
            return Session.getProject().planningPokerGameType == 0 ? $scope.integerSuiteNullable : $scope.fibonacciSuiteNullable;
        } else {
            return Session.getProject().planningPokerGameType == 0 ? $scope.integerSuite : $scope.fibonacciSuite;
        }
    };
    $scope.isEffortNullable = function(story) {
        return story.state <= StoryStatesByName.ESTIMATED;
    };
    var scrollTable = function(dontAnimate, nbItems) {
        var tableWidth = angular.element(angular.element('.table-scrollable').find('th')[0]).prop('offsetWidth');
        var scrollLeft = (nbItems - 1) * tableWidth;
        if (dontAnimate) {
            $('.table-scrollable').scrollLeft(scrollLeft);
        } else {
            $('.table-scrollable').animate({
                scrollLeft: scrollLeft
            }, 400);
        }
    };
    var makeRows = function(storiesByField) {
        var nbRows = _.max(storiesByField, function(stories) {
            return stories.length;
        }).length;
        var nbColumns = storiesByField.length;
        var rows = [];
        for (var i = 0; i < nbRows; i++) {
            var row = [];
            for (var j = 0; j < nbColumns; j++) {
                row = [];
                angular.forEach(storiesByField, function(stories) {
                    if (stories[i]) {
                        row.push(stories[i]);
                    } else {
                        row.push({});
                    }
                });
            }
            rows.push(row);
        }
        return rows;
    };
    $scope.showEditEffortModal = function(story) {
        if (StoryService.authorizedStory('updateEstimate', story)) {
            var parentScope = $scope;
            $uibModal.open({
                templateUrl: 'story.effort.html',
                controller: ['$scope', '$timeout', function($scope, $timeout) {
                    $scope.editableStory = angular.copy(story);
                    $scope.isEffortCustom = parentScope.isEffortCustom;
                    $scope.effortSuite = parentScope.effortSuite;
                    $scope.isEffortNullable = parentScope.isEffortNullable;
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
                    StoryService.listByField('effort').then(function(effortsAndStories) {
                        initialEfforts = effortsAndStories.fieldValues;
                        initialEfforts.splice(0, 1, '?');
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
                        $scope.storyRows = makeRows(storiesByEffort);
                        $timeout(function() {
                            scrollTable(dontAnimate, effortIndex);
                        });
                    };
                    $scope.submit = function(story) {
                        StoryService.update(story).then(function() {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.story.effort.updated');
                        });
                    };
                }]
            });
        }
    };
    $scope.showEditValueModal = function(story) {
        if (StoryService.authorizedStory('update', story)) {
            $uibModal.open({
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
                    StoryService.listByField('value').then(function(valuesAndStories) {
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
                        $scope.storyRows = makeRows(storiesByValue);
                        $timeout(function() {
                            scrollTable(dontAnimate, valueIndex);
                        });
                    };
                    $scope.submit = function(story) {
                        StoryService.update(story).then(function() {
                            $scope.$close();
                            $scope.notifySuccess('todo.is.ui.story.value.updated');
                        });
                    };
                }]
            });
        }
    };
}]);

controllers.controller('storyDetailsCtrl', ['$scope', '$controller', '$state', '$timeout', '$uibModal', 'StoryService', 'StoryCodesByState', 'FormService', 'ActorService', 'FeatureService', 'ProjectService', 'detailsStory',
    function($scope, $controller, $state, $timeout, $uibModal, StoryService, StoryCodesByState, FormService, ActorService, FeatureService, ProjectService, detailsStory) {
        $controller('storyCtrl', {$scope: $scope}); // inherit from storyCtrl
        $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsStory, clazz: 'story'});
        // Functions
        $scope.update = function(story) {
            StoryService.update(story).then(function() {
                $scope.resetStoryForm();
                $scope.notifySuccess('todo.is.ui.story.updated');
            });
        };
        $scope.like = function(story) {
            StoryService.like(story);
        };
        $scope.isDirty = function() {
            return !_.isEqual($scope.editableStory, $scope.editableStoryReference);
        };
        $scope.editForm = function(value) {
            if (value != $scope.formHolder.editing) {
                $scope.setInEditingMode(value); // global
                $scope.resetStoryForm();
            }
        };
        $scope.resetStoryForm = function() {
            $scope.formHolder.editing = $scope.isInEditingMode();
            $scope.formHolder.editable = $scope.authorizedStory('update', $scope.story);
            if ($scope.formHolder.editable) {
                $scope.editableStory = angular.copy($scope.story);
                $scope.editableStoryReference = angular.copy($scope.story);
            } else {
                $scope.editableStory = $scope.story;
                $scope.editableStoryReference = $scope.story;
            }
            $scope.resetFormValidation($scope.formHolder.storyForm);
        };
        $scope.clickDescriptionPreview = function($event, template) {
            if ($event.target.nodeName != 'A' && $scope.formHolder.editable) {
                $scope.showDescriptionTextarea = true;
                var $el = angular.element($event.currentTarget);
                $el.prev().css('height', $el.outerHeight());
                $scope.editForm(true);
                if (!$scope.editableStory.description) {
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
                if ($scope.editableStory.description.trim() == template.trim()) {
                    $scope.editableStory.description = '';
                }
            }
        };
        $scope.groupSprintByParentRelease = function(sprint) {
            return sprint.parentRelease.name;
        };
        $scope.retrieveDependenceEntries = function(story) {
            if (_.isEmpty($scope.dependenceEntries)) {
                StoryService.getDependenceEntries(story).then(function(dependenceEntries) {
                    $scope.dependenceEntries = dependenceEntries;
                });
            }
        };
        $scope.retrieveParentSprintEntries = function() {
            if (_.isEmpty($scope.parentSprintEntries)) {
                StoryService.getParentSprintEntries().then(function(parentSprintEntries) {
                    $scope.parentSprintEntries = parentSprintEntries;
                });
            }
        };
        $scope.retrieveTags = function() {
            if (_.isEmpty($scope.tags)) {
                ProjectService.getTags().then(function(tags) {
                    $scope.tags = tags;
                });
            }
        };
        $scope.retrieveVersions = function() {
            if (_.isEmpty($scope.versions)) {
                ProjectService.getVersions().then(function(versions) {
                    $scope.versions = versions;
                });
            }
        };
        $scope.urlTab = function(tabId) {
            var stateName = $state.params.tabId ? (tabId ? '.' : '^') : (tabId ? '.tab' : '.');
            return $state.href(stateName, {tabId: tabId});
        };
        // Init
        $scope.story = detailsStory;
        $scope.editableStory = {};
        $scope.editableStoryReference = {};
        $scope.formHolder = {};
        $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $stage.go
        $scope.dependenceEntries = [];
        $scope.parentSprintEntries = [];
        $scope.tags = [];
        $scope.versions = [];
        $scope.atOptions = {
            tpl: "<li data-value='A[${uid}-${name}]'>${name}</li>",
            at: 'a'
        };
        $scope.features = [];
        FeatureService.list.$promise.then(function(features) {
            $scope.features = features;
        });
        var mapActors = function(actors) {
            return _.map(actors, function(actor) {
                return {uid: actor.uid, name: actor.name};
            });
        };
        if (ActorService.list.$resolved) {
            $scope.atOptions.data = mapActors(ActorService.list);
        } else {
            ActorService.list.$promise.then(function(actors) {
                $scope.atOptions.data = mapActors(actors);
            });
        }
        $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
            if ($scope.mustConfirmStateChange && fromParams.id != toParams.id) {
                event.preventDefault(); // cancel the state change
                $scope.mustConfirmStateChange = false;
                $scope.confirm({
                    message: $scope.message('todo.is.ui.dirty.confirm'),
                    condition: $scope.isDirty() || ($scope.flow != undefined && $scope.flow.isUploading()),
                    callback: function() {
                        if ($scope.flow != undefined && $scope.flow.isUploading()) {
                            $scope.flow.cancel();
                        }
                        $state.go(toState, toParams)
                    },
                    closeCallback: function() {
                        $scope.mustConfirmStateChange = true;
                    }
                });
            }
        });
        $scope.resetStoryForm();
        // For header
        var list = StoryService.list;
        $scope.previousStory = FormService.previous(list, $scope.story);
        $scope.nextStory = FormService.next(list, $scope.story);
        $scope.progressStates = [];
        var width = 100 / _.filter(_.keys(StoryCodesByState), function(key) { return key > 0 }).length;
        _.each(StoryCodesByState, function(code, state) {
            var date = $scope.story[code.toLowerCase() + 'Date'];
            if (date != null) {
                $scope.progressStates.push({
                    state: state,
                    date: date,
                    code: code,
                    width: width
                });
            }
        });
    }]);

controllers.controller('storyMultipleCtrl', ['$scope', '$controller', 'StoryService', 'listId', 'FeatureService', function($scope, $controller, StoryService, listId, FeatureService) {
    $controller('storyCtrl', {$scope: $scope}); // inherit from storyCtrl
    // Functions
    $scope.sumPoints = function(stories) {
        return _.sum(stories, 'effort');
    };
    $scope.sumTasks = function(stories) {
        return _.sum(stories, 'tasks_count');
    };
    $scope.sumAcceptanceTests = function(stories) {
        return _.sum(stories, 'acceptanceTests_count');
    };
    $scope.deleteMultiple = function() {
        StoryService.deleteMultiple(listId).then(function() {
            $scope.notifySuccess('todo.is.ui.multiple.deleted');
        });
    };
    $scope.copyMultiple = function() {
        StoryService.copyMultiple(listId);
    };
    $scope.updateMultiple = function(updatedFields) {
        StoryService.updateMultiple(listId, updatedFields).then(function() {
            $scope.notifySuccess('todo.is.ui.story.multiple.updated');
        });
    };
    $scope.acceptMultiple = function() {
        StoryService.acceptMultiple(listId).then(function() {
            $scope.notifySuccess('todo.is.ui.story.multiple.accepted');
        });
    };
    $scope.followMultiple = function(follow) {
        StoryService.followMultiple(listId, follow).then(function() {
            refreshStories();
        });
    };
    $scope.acceptAsMultiple = function(target) {
        StoryService.acceptAsMultiple(listId, target).then(function() {
            $scope.notifySuccess('todo.is.ui.story.multiple.acceptedAs' + target);
        });
    };
    $scope.authorizedStories = function(action, stories) {
        return StoryService.authorizedStories(action, stories);
    };
    // Init
    $scope.app.selectableMultiple = true;
    $scope.topStory = {};
    $scope.storyPreview = {};
    $scope.stories = [];
    $scope.features = [];
    FeatureService.list.$promise.then(function(features) {
        $scope.features = features;
    });
    $scope.allFollowed = function(stories) {
        return _.every(stories, 'followed');
    };
    $scope.noneFollowed = function(stories) {
        return !_.some(stories, 'followed');
    };
    function refreshStories() {
        StoryService.getMultiple(listId).then(function(stories) {
            $scope.topStory = _.first(stories);
            $scope.storyPreview = {
                value: _.every(stories, {value: $scope.topStory.value}) ? $scope.topStory.value : null,
                effort: _.every(stories, {value: $scope.topStory.effort}) ? $scope.topStory.effort : null,
                feature: _.every(stories, {feature: $scope.topStory.feature}) ? $scope.topStory.feature : null,
                type: _.every(stories, {type: $scope.topStory.type}) ? $scope.topStory.type : null
            };
            $scope.stories = stories;
        });
    }
    refreshStories();
}]);

controllers.controller('storyNewCtrl', ['$scope', '$state', '$uibModal', '$timeout', '$controller', 'StoryService', 'hotkeys',
    function($scope, $state, $uibModal, $timeout, $controller, StoryService, hotkeys) {
        $controller('storyCtrl', {$scope: $scope}); // inherit from storyCtrl
        // Functions
        $scope.resetStoryForm = function() {
            var defaultStory = {};
            if ($scope.story && $scope.story.template) {
                defaultStory.template = $scope.story.template
            }
            $scope.story = defaultStory;
            $scope.resetFormValidation($scope.formHolder.storyForm);
        };
        $scope.templateSelected = function() {
            if ($scope.story.template) {
                StoryService.getTemplatePreview($scope.story.template.id).then(function(storyPreview) {
                    $scope.storyPreview = storyPreview;
                });
            } else {
                $scope.storyPreview = {}
            }
        };
        $scope.showEditTemplateModal = function(story) {
            var parentScope = $scope;
            $uibModal.open({
                templateUrl: 'story.template.edit.html',
                size: 'sm',
                controller: ["$scope", function($scope) {
                    $scope.templateEntries = parentScope.templateEntries;
                    $scope.deleteTemplate = function(templateEntry) {
                        StoryService.deleteTemplate(templateEntry.id).then(function() {
                            $scope.notifySuccess('todo.is.ui.deleted');
                        });
                    }
                }]
            });
        };
        $scope.save = function(story, andContinue) {
            StoryService.save(story).then(function(story) {
                if (andContinue) {
                    $scope.resetStoryForm();
                } else {
                    $scope.setInEditingMode(true);
                    $state.go('^.details', {id: story.id});
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
                        StoryService.findDuplicates(trimmedTerm).then(function(messageDuplicate) {
                            $scope.lastSearchedTerm = trimmedTerm;
                            $scope.messageDuplicate = messageDuplicate ? messageDuplicate : '';
                        });
                    }
                }, 500);
            }
        };
        // Init
        $scope.formHolder = {};
        $scope.resetStoryForm();
        hotkeys.bindTo($scope).add({
            combo: 'esc',
            allowIn: ['INPUT'],
            callback: $scope.resetStoryForm
        });
        $scope.templateEntries = [];
        StoryService.getTemplateEntries().then(function(templateEntries) {
            $scope.templateEntries = templateEntries;
        });
    }]);