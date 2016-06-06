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

controllers.controller('sprintCtrl', ['$scope', 'Session', 'SprintService', function($scope, Session, SprintService) {
    // Functions
    $scope.showSprintMenu = function() {
        return Session.poOrSm();
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    $scope.activate = function(sprint) {
        SprintService.activate(sprint, $scope.project).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.activated');
        });
    };
    $scope.close = function(sprint) {
        SprintService.close(sprint, $scope.project).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.closed');
        });
    };
    $scope.autoPlan = function(sprint, capacity) {
        SprintService.autoPlan(sprint, capacity, $scope.project).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.autoPlanned');
        });
    };
    $scope.unPlan = function(sprint) {
        SprintService.unPlan(sprint, $scope.project).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.unPlanned');
        });
    };
    $scope['delete'] = function(sprint) {
        SprintService.delete(sprint, $scope.release)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    // Init
    $scope.project = Session.getProject();
    $scope.startDateOptions = {
        opened: false
    };
    $scope.endDateOptions = angular.copy($scope.startDateOptions);
}]);

controllers.controller('sprintBacklogCtrl', ['$scope', 'StoryService', 'SprintStatesByName', 'StoryStatesByName', 'BacklogCodes', function($scope, StoryService, SprintStatesByName, StoryStatesByName, BacklogCodes) {
    // Functions
    $scope.isSortingSprint = function(sprint) {
        return StoryService.authorizedStory('rank') && sprint.state < SprintStatesByName.DONE;
    };
    // Init
    var fixStoryRank = function(stories) {
        _.each(stories, function(story, index) {
            story.rank = index + 1;
        });
    };
    $scope.sprintSortableOptions = {
        itemMoved: function(event) {
            var destScope = event.dest.sortableScope;
            fixStoryRank(event.source.sortableScope.modelValue);
            fixStoryRank(destScope.modelValue);
            var story = event.source.itemScope.modelValue;
            var newRank = event.dest.index + 1;
            StoryService.plan(story, destScope.sprint, newRank);
        },
        orderChanged: function(event) {
            fixStoryRank(event.dest.sortableScope.modelValue);
            var story = event.source.itemScope.modelValue;
            story.rank = event.dest.index + 1;
            StoryService.update(story);
        },
        accept: function(sourceItemHandleScope, destSortableScope) {
            var sameSortable = sourceItemHandleScope.itemScope.sortableScope.sortableId === destSortableScope.sortableId;
            return sameSortable && destSortableScope.isSortingSprint(destSortableScope.sprint);
        }
    };
    $scope.planStories = {
        filter: {
            state: StoryStatesByName.ESTIMATED,
            order: ['rank', 'id']// Order by id is crucial to ensure stable order regardles
        },
        callback: function(sprint, selectedIds) {
            if (selectedIds.length > 0) {
                // Will refresh sprint.stories which will in turn refresh sprint backlog stories through the watch
                StoryService.updateMultiple(selectedIds, {parentSprint: sprint}).then(function() {
                    $scope.notifySuccess('todo.is.ui.story.multiple.updated');
                });
            }
        }
    };
    $scope.sortableId = 'sprint';
    $scope.backlogCodes = BacklogCodes;
    $scope.sprintStatesByName = SprintStatesByName;
    $scope.backlog = {stories: [], code: 'sprint'};
    $scope.$watchCollection('sprint.stories', function(newStories) {
        $scope.backlog.stories = _.sortBy(newStories, 'rank');
    });
    StoryService.listByType($scope.sprint); // will trigger the update automatically through the watch
}]);

controllers.controller('sprintNewCtrl', ['$scope', '$controller', '$state', 'DateService', 'SprintService', 'ReleaseService', 'ReleaseStatesByName', 'hotkeys', 'releases', 'detailsRelease', function($scope, $controller, $state, DateService, SprintService, ReleaseService, ReleaseStatesByName, hotkeys, releases, detailsRelease) {
    $controller('sprintCtrl', {$scope: $scope}); // inherit from sprintCtrl
    // Functions
    $scope.resetSprintForm = function() {
        $scope.sprint = {parentRelease: {}};
        if ($scope.release) {
            $scope.sprint.parentRelease = $scope.release;
        }
        $scope.resetFormValidation($scope.formHolder.sprintForm);
    };
    $scope.save = function(sprint, andContinue) {
        SprintService.save(sprint, $scope.release)
            .then(function(sprint) {
                if (andContinue) {
                    $scope.resetSprintForm();
                } else {
                    $scope.setInEditingMode(true);
                    $state.go('^.withId.details', {releaseId: $scope.release.id, sprintId: sprint.id});
                }
                $scope.notifySuccess('todo.is.ui.sprint.saved');
            });
    };
    $scope.selectRelease = function(release) {
        $scope.release = _.find($scope.editableReleases, {id: release.id});
    };
    // Init
    var sprintWatcher = function() {
        var sprints = $scope.release.sprints;
        if (!_.isUndefined(sprints)) {
            if (_.isEmpty(sprints)) {
                $scope.startDateOptions.minDate = $scope.release.startDate;
            } else {
                $scope.startDateOptions.minDate = DateService.immutableAddDaysToDate(_.max(_.map($scope.release.sprints, 'endDate')), 1);
            }
            $scope.sprint.startDate = $scope.startDateOptions.minDate;
            var sprintDuration = $scope.project.preferences.estimatedSprintsDuration;
            var hypotheticalEndDate = DateService.immutableAddDaysToDate($scope.sprint.startDate, sprintDuration);
            $scope.sprint.endDate = _.min([hypotheticalEndDate, $scope.release.endDate]);
        }
    };
    $scope.$watchCollection('release.sprints', sprintWatcher);
    $scope.$watch('release', sprintWatcher);
    $scope.$watchCollection('[sprint.startDate, sprint.endDate]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        if (startDate) {
            $scope.endDateOptions.minDate = DateService.immutableAddDaysToDate(startDate, 1);
        }
        if (endDate) {
            $scope.startDateOptions.maxDate = DateService.immutableAddDaysToDate(endDate, -1);
        }
    });
    $scope.formHolder = {};
    $scope.resetSprintForm();
    $scope.editableReleases = _.sortBy(_.filter(releases, function(release) {
        return release.state < ReleaseStatesByName.DONE;
    }), 'orderNumber');
    $scope.sprint.parentRelease = detailsRelease;
    $scope.release = detailsRelease;
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetSprintForm
    });
}]);

controllers.controller('sprintDetailsCtrl', ['$scope', '$controller', 'SprintStatesByName', 'DateService', 'SprintService', 'ReleaseService', 'FormService', 'detailsSprint', 'detailsRelease', function($scope, $controller, SprintStatesByName, DateService, SprintService, ReleaseService, FormService, detailsSprint, detailsRelease) {
    $controller('sprintCtrl', {$scope: $scope}); // inherit from sprintCtrl
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsSprint, clazz: 'sprint'});
    // Functions
    $scope.update = function(sprint) {
        SprintService.update(sprint, $scope.release).then(function() {
            $scope.resetSprintForm();
            $scope.notifySuccess('todo.is.ui.sprint.updated');
        });
    };
    // Init
    $scope.$watchCollection('release.sprints', function(sprints) {
        if (!_.isUndefined(sprints)) {
            var previousSprint = _.findLast(_.sortBy(sprints, 'orderNumber'), function(sprint) {
                return sprint.orderNumber < $scope.sprint.orderNumber;
            });
            $scope.startDateOptions.minDate = _.isEmpty(previousSprint) ? $scope.release.startDate : DateService.immutableAddDaysToDate(previousSprint.endDate, 1);
        }
    });
    $scope.$watchCollection('[editableSprint.startDate, editableSprint.endDate]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        if (startDate) {
            $scope.endDateOptions.minDate = DateService.immutableAddDaysToDate(startDate, 1);
        }
        if (endDate) {
            $scope.startDateOptions.maxDate = DateService.immutableAddDaysToDate(endDate, -1);
        }
    });
    $controller('updateFormController', {$scope: $scope, item: detailsSprint, type: 'sprint', resetOnProperties: []});
    $scope.sprintStatesByName = SprintStatesByName;
    $scope.release = detailsRelease;
    $scope.endDateOptions.maxDate = $scope.release.endDate;
    var sortedSprints = _.sortBy($scope.release.sprints, 'orderNumber');
    $scope.previousSprint = FormService.previous(sortedSprints, $scope.sprint);
    $scope.nextSprint = FormService.next(sortedSprints, $scope.sprint);
}]);

controllers.controller('sprintMultipleCtrl', ['$scope', 'SprintService', 'detailsRelease', function($scope, SprintService, detailsRelease) {
    // Functions
    $scope.authorizedSprints = function(action, sprints) {
        return SprintService.authorizedSprints(action, sprints);
    };
    $scope.autoPlanMultiple = function(sprints, capacity) {
        SprintService.autoPlanMultiple(sprints, capacity, $scope.release).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.autoPlanned');
        });
    };
    $scope.unPlanMultiple = function(sprints) {
        SprintService.unPlanMultiple(sprints, $scope.release).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.unPlanned');
        });
    };
    // Init
    $scope.release = detailsRelease;
    $scope.$watch('sprints', function(sprints) {
        if (sprints.length) {
            $scope.startDate = _.head(sprints).startDate;
            $scope.endDate = _.last(sprints).endDate;
            var storyCounts = _.map(sprints, function(sprint) {
                return sprint.stories_ids ? sprint.stories_ids.length : 0;
            });
            $scope.sumStory = _.sum(storyCounts);
            $scope.meanStory = _.round(_.mean(storyCounts));
            $scope.meanVelocity = _.round(_.meanBy(sprints, 'velocity'));
            $scope.meanCapacity = _.round(_.meanBy(sprints, 'capacity'));
        }
    }, true);  // Be careful of circular objects, it will blow up the stack when comparing equality by value
}]);