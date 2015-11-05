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
    $scope.unPlan = function(sprint) {
        SprintService.unPlan(sprint, $scope.project).then(function() {
            $scope.notifySuccess('todo.is.ui.sprint.unPlanned');
        });
    };
    $scope['delete'] = function(sprint) {
        SprintService.delete(sprint, $scope.release)
            .then(function() {
                $scope.goToNewSprint();
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

controllers.controller('sprintNewCtrl', ['$scope', '$controller', '$state', 'SprintService', 'ReleaseService', 'ReleaseStatesByName', 'hotkeys', function($scope, $controller, $state, SprintService, ReleaseService, ReleaseStatesByName, hotkeys) {
    $controller('sprintCtrl', { $scope: $scope }); // inherit from sprintCtrl
    // Functions
    $scope.resetSprintForm = function() {
        $scope.sprint = {parentRelease: {}};
        $scope.resetFormValidation($scope.formHolder.sprintForm);
    };
    $scope.save = function(sprint, andContinue) {
        SprintService.save(sprint, $scope.release)
            .then(function(sprint) {
                if (andContinue) {
                    $scope.resetSprintForm();
                } else {
                    $scope.setEditableMode(true);
                    $state.go('^.details', { id: sprint.id });
                }
                $scope.notifySuccess('todo.is.ui.sprint.saved');
            });
    };
    $scope.selectRelease = function(releaseId) {
        $scope.release = _.find($scope.releases, {id: parseInt(releaseId)});
    };
    // Init
    $scope.$watchCollection('release.sprints', function(sprints) {
        if (!_.isUndefined(sprints)) {
            if (_.isEmpty(sprints)) {
                $scope.minStartDate = $scope.release.startDate;
            } else {
                $scope.minStartDate =  $scope.immutableAddDaysToDate(_.max(_.pluck($scope.release.sprints, 'endDate')), 1);
            }
            $scope.sprint.startDate = $scope.minStartDate;
            var sprintDuration = $scope.project.preferences.estimatedSprintsDuration;
            var hypotheticalEndDate = $scope.immutableAddDaysToDate($scope.sprint.startDate, sprintDuration);
            $scope.sprint.endDate = _.min([hypotheticalEndDate, $scope.release.endDate]);
        }
    });
    $scope.$watchCollection('[sprint.startDate, sprint.endDate]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        if (startDate) {
            $scope.minEndDate = $scope.immutableAddDaysToDate(startDate, 1);
        }
        if (endDate) {
            $scope.maxStartDate = $scope.immutableAddDaysToDate(endDate, -1);
        }
    });
    $scope.releases = [];
    $scope.formHolder = {};
    $scope.resetSprintForm();
    ReleaseService.list($scope.project).then(function(releases) {
        $scope.releases = _.sortBy(_.filter(releases, function(release) {
            return release.state < ReleaseStatesByName.DONE;
        }), 'orderNumber');
        if (!_.isEmpty($scope.releases)) {
            var release = _.first($scope.releases);
            $scope.sprint.parentRelease = { id: release.id };
            $scope.release = release;
        }
    });
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetSprintForm
    });
}]);

controllers.controller('sprintDetailsCtrl', ['$scope', '$state', '$stateParams', '$controller', 'SprintService', 'ReleaseService', 'FormService', function($scope, $state, $stateParams, $controller, SprintService, ReleaseService, FormService) {
    $controller('sprintCtrl', { $scope: $scope }); // inherit from sprintCtrl
    // Functions
    $scope.isDirty = function() {
        return !_.isEqual($scope.editableSprint, $scope.editableSprintReference);
    };
    $scope.update = function(sprint) {
        SprintService.update(sprint, $scope.release).then(function(sprint) {
            $scope.resetSprintForm();
            $scope.notifySuccess('todo.is.ui.sprint.updated');
        });
    };
    $scope.editForm = function(value) {
        if (value != $scope.getEditableMode()) {
            $scope.setEditableMode(value); // global
            $scope.resetSprintForm();
        }
    };
    $scope.getShowSprintForm = function(sprint) {
        return ($scope.getEditableMode() || $scope.formHolder.formHover) && $scope.authorizedSprint('update', sprint);
    };
    $scope.resetSprintForm = function() {
        if ($scope.getEditableMode()) {
            $scope.editableSprint = angular.copy($scope.sprint);
            $scope.editableSprintReference = angular.copy($scope.sprint);
        } else {
            $scope.editableSprint = $scope.sprint;
            $scope.editableSprintReference = $scope.sprint;
        }
        $scope.resetFormValidation($scope.formHolder.sprintForm);
    };
    $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
        if ($scope.mustConfirmStateChange && fromParams.id != toParams.id) {
            event.preventDefault(); // cancel the state change
            $scope.mustConfirmStateChange = false;
            $scope.confirm({
                message: 'todo.is.ui.dirty.confirm',
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
    $scope.attachmentQuery = function($flow, sprint) {
        $scope.flow = $flow;
        $flow.opts.target = 'attachment/sprint/' + sprint.id + '/flow';
        $flow.upload();
    };
    $scope.formHover = function(value) {
        $scope.formHolder.formHover = value;
    };
    // Init
    $scope.$watchCollection('release.sprints', function(sprints) {
        if (!_.isUndefined(sprints)) {
            var previousSprint = _.findLast(_.sortBy(sprints, 'orderNumber'), function(sprint) {
                return sprint.orderNumber < $scope.sprint.orderNumber;
            });
            if (_.isEmpty(previousSprint)) {
                $scope.minStartDate = $scope.release.startDate;
            } else {
                $scope.minStartDate =  $scope.immutableAddDaysToDate(previousSprint.endDate, 1);
            }
        }
    });
    $scope.$watchCollection('[editableSprint.startDate, editableSprint.endDate]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        if (startDate) {
            $scope.minEndDate = $scope.immutableAddDaysToDate(startDate, 1);
        }
        if (endDate) {
            $scope.maxStartDate = $scope.immutableAddDaysToDate(endDate, -1);
        }
    });
    $scope.formHolder = {};
    $scope.sprint = {};
    $scope.editableSprint = {};
    $scope.editableSprintReference = {};
    $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $state.go
    $scope.clazz = 'sprint'; // for attachments
    SprintService.get($stateParams.id, $scope.project).then(function(sprint) {
        $scope.sprint = sprint;
        $scope.selected = sprint;
        $scope.resetSprintForm();
        ReleaseService.get(sprint.parentRelease.id, $scope.project).then(function (release) {
            $scope.release = release;
            var sortedSprints = _.sortBy($scope.release.sprints, 'orderNumber');
            $scope.previous = FormService.previous(sortedSprints, $scope.sprint);
            $scope.next = FormService.next(sortedSprints, $scope.sprint);
        });
    }).catch(function(e){
        $state.go('^');
        $scope.notifyError(e.message)
    });
}]);
