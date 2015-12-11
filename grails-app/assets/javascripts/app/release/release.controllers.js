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

controllers.controller('releaseCtrl', ['$scope', 'Session', 'ReleaseService', function($scope, Session, ReleaseService) {
    // Functions
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.activate = function(release) {
        ReleaseService.activate(release).then(function() {
            $scope.notifySuccess('todo.is.ui.release.activated');
        });
    };
    $scope.close = function(release) {
        ReleaseService.close(release).then(function() {
            $scope.notifySuccess('todo.is.ui.release.closed');
        });
    };
    $scope.generateSprints = function(release) {
        ReleaseService.generateSprints(release).then(function(sprints) {
            $scope.notifySuccess('todo.is.ui.release.generatedSprints');
        });
    };
    $scope.autoPlan = function(release) {
        ReleaseService.autoPlan(release).then(function() {
            $scope.notifySuccess('todo.is.ui.release.autoPlanned');
        });
    };
    $scope.unPlan = function(release) {
        ReleaseService.unPlan(release).then(function() {
            $scope.notifySuccess('todo.is.ui.release.unPlanned');
        });
    };
    $scope['delete'] = function(release) {
        ReleaseService.delete(release, $scope.project)
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

controllers.controller('releaseNewCtrl', ['$scope', '$controller', '$state', 'ReleaseService', 'hotkeys', function($scope, $controller, $state, ReleaseService, hotkeys) {
    $controller('releaseCtrl', { $scope: $scope }); // inherit from releaseCtrl
    // Functions
    $scope.resetReleaseForm = function() {
        $scope.release = {};
        $scope.resetFormValidation($scope.formHolder.releaseForm);
    };
    $scope.save = function(release, andContinue) {
        ReleaseService.save(release, $scope.project)
            .then(function(release) {
                if (andContinue) {
                    $scope.resetReleaseForm();
                } else {
                    $scope.setInEditingMode(true);
                    $state.go('^.details', { id: release.id });
                }
                $scope.notifySuccess('todo.is.ui.release.saved');
            });
    };
    // Init
    $scope.$watchCollection('project.releases', function(releases) {
        if (!_.isUndefined(releases)) {
            if (_.isEmpty(releases)) {
                $scope.minStartDate = $scope.project.startDate;
            } else {
                $scope.minStartDate =  $scope.immutableAddDaysToDate(_.max(_.pluck($scope.project.releases, 'endDate')), 1);
            }
            $scope.release.startDate = $scope.minStartDate;
            $scope.release.endDate = $scope.immutableAddMonthsToDate($scope.release.startDate, 3);
        }
    });
    $scope.$watchCollection('[release.startDate, release.endDate]', function(newValues) {
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
    $scope.resetReleaseForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetReleaseForm
    });
}]);

controllers.controller('releaseDetailsCtrl', ['$scope', '$state', '$controller', 'ReleaseService', 'FormService', 'detailsRelease', function($scope, $state, $controller, ReleaseService, FormService, detailsRelease) {
    $controller('releaseCtrl', { $scope: $scope }); // inherit from releaseCtrl
    $controller('attachmentCtrl', { $scope: $scope, attachmentable: detailsRelease, clazz: 'release' });
    // Functions
    $scope.isDirty = function() {
        return !_.isEqual($scope.editableRelease, $scope.editableReleaseReference);
    };
    $scope.update = function(release) {
        ReleaseService.update(release, $scope.project).then(function(release) {
            $scope.resetReleaseForm();
            $scope.notifySuccess('todo.is.ui.release.updated');
        });
    };
    $scope.editForm = function(value) {
        if (value != $scope.formHolder.editing) {
            $scope.setInEditingMode(value); // global
            $scope.resetReleaseForm();
        }
    };
    $scope.resetReleaseForm = function() {
        $scope.formHolder.editing = $scope.isInEditingMode();
            $scope.formHolder.editable = $scope.authorizedRelease('update', $scope.release);
        if ($scope.formHolder.editable) {
            $scope.editableRelease = angular.copy($scope.release);
            $scope.editableReleaseReference = angular.copy($scope.release);
        } else {
            $scope.editableRelease = $scope.release;
            $scope.editableReleaseReference = $scope.release;
        }
        $scope.resetFormValidation($scope.formHolder.releaseForm);
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
    // Init
    $scope.$watchCollection('project.releases', function(releases) {
        if (!_.isUndefined(releases)) {
            var previousRelease = _.findLast(_.sortBy(releases, 'orderNumber'), function(release) {
                return release.orderNumber < $scope.release.orderNumber;
            });
            if (_.isEmpty(previousRelease)) {
                $scope.minStartDate = $scope.project.startDate;
            } else {
                $scope.minStartDate =  $scope.immutableAddDaysToDate(previousRelease.endDate, 1);
            }
        }
    });
    $scope.$watchCollection('[editableRelease.startDate, editableRelease.endDate]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        if (startDate) {
            $scope.minEndDate = $scope.immutableAddDaysToDate(startDate, 1);
        }
        if (endDate) {
            $scope.maxStartDate = $scope.immutableAddDaysToDate(endDate, -1);
        }
    });
    $scope.release = detailsRelease;
    $scope.editableRelease = {};
    $scope.editableReleaseReference = {};
    $scope.formHolder = {};
    $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $state.go
    $scope.resetReleaseForm();
    var sortedReleases = _.sortBy($scope.project.releases, 'orderNumber');
    $scope.previousRelease = FormService.previous(sortedReleases, $scope.release);
    $scope.nextRelease = FormService.next(sortedReleases, $scope.release);
}]);
