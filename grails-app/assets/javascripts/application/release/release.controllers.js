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

controllers.controller('releaseCtrl', ['$scope', '$state', '$rootScope', 'Session', 'ReleaseService', 'SprintService', function($scope, $state, $rootScope, Session, ReleaseService, SprintService) {
    // Functions
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.authorizedSprint = function(action, sprint) {
        return SprintService.authorizedSprint(action, sprint);
    };
    $scope.showReleaseMenu = function() {
        return Session.poOrSm();
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
        SprintService.generateSprints(release).then(function() {
            $scope.notifySuccess('todo.is.ui.release.generatedSprints');
        });
    };
    $scope.autoPlan = function(release, capacity) {
        $rootScope.uiWorking();
        ReleaseService.autoPlan(release, capacity).then(function() {
            $rootScope.uiReady();
            $scope.notifySuccess('todo.is.ui.release.autoPlanned');
        });
    };
    $scope.unPlan = function(release) {
        $rootScope.uiWorking();
        ReleaseService.unPlan(release).then(function() {
            $rootScope.uiReady();
            $scope.notifySuccess('todo.is.ui.release.unPlanned');
        });
    };
    $scope['delete'] = function(release) {
        ReleaseService.delete(release, $scope.project)
            .then(function() {
                $scope.notifySuccess('todo.is.ui.deleted');
            });
    };
    $scope.menus = [
        {
            name: 'is.ui.timeline.menu.activate',
            visible: function(release) { return $scope.authorizedRelease('activate', release); },
            action: function(release) { $scope.confirm({message: $scope.message('is.ui.timeline.menu.activate.confirm'), callback: $scope.activate, args: [release]}); }
        },
        {
            name: 'todo.is.ui.sprint.new',
            visible: function(release) { return $scope.authorizedSprint('create'); },
            url: function(release) { return '#' + $scope.viewName + '/' + release.id + '/sprint/new'; }
        },
        {
            name: 'todo.is.ui.release.new',
            priority: function(release, defaultPriority, viewType) { return viewType !== 'details' ? 100 : defaultPriority; },
            visible: function(release) { return $scope.authorizedRelease('create'); },
            url: function(release) { return '#' + $scope.viewName + '/new'; }
        },
        {
            name: 'is.ui.releasePlan.toolbar.generateSprints',
            visible: function(release) { return $scope.authorizedSprint('create'); },
            action: function(release) { $scope.generateSprints(release); }
        },
        {
            name: 'is.ui.releasePlan.toolbar.autoPlan',
            visible: function(release) { return $scope.authorizedRelease('autoPlan', release); },
            action: function(release) { $scope.showAutoPlanModal({callback: $scope.autoPlan, args: [release]}); }
        },
        {
            name: 'is.ui.releasePlan.toolbar.dissociateAll',
            visible: function(release) { return $scope.authorizedRelease('unPlan', release); },
            action: function(release) { $scope.confirm({message: $scope.message('is.ui.releasePlan.toolbar.warning.dissociateAll'), callback: $scope.unPlan, args: [release]}); }
        },
        {
            name: 'is.ui.timeline.menu.delete',
            visible: function(release) { return $scope.authorizedRelease('delete', release); },
            action: function(release) { $scope.confirm({message: $scope.message('is.ui.timeline.menu.delete.confirm'), callback: $scope.delete, args: [release]}); }
        },
        {
            name: 'is.ui.timeline.menu.close',
            visible: function(release) { return $scope.authorizedRelease('close', release); },
            action: function(release) { $scope.confirm({message: $scope.message('is.ui.timeline.menu.close.confirm'), callback: $scope.close, args: [release]}); }
        }
    ];
    // Init
    $scope.project = Session.getProject();
    $scope.startDateOptions = {
        opened: false
    };
    $scope.endDateOptions = angular.copy($scope.startDateOptions);
}]);

controllers.controller('releaseNewCtrl', ['$scope', '$controller', '$state', 'DateService', 'ReleaseService', 'hotkeys', function($scope, $controller, $state, DateService, ReleaseService, hotkeys) {
    $controller('releaseCtrl', {$scope: $scope}); // inherit from releaseCtrl
    // Functions
    $scope.resetReleaseForm = function() {
        $scope.release = {};
        $scope.resetFormValidation($scope.formHolder.releaseForm);
    };
    $scope.save = function(release, andContinue) {
        ReleaseService.save(release, $scope.project).then(function(release) {
            if (andContinue) {
                $scope.resetReleaseForm();
                initReleaseDates($scope.project.releases);
            } else {
                $scope.setInEditingMode(true);
                $state.go('^.release.details', {releaseId: release.id});
            }
            $scope.notifySuccess('todo.is.ui.release.saved');
        });
    };
    var initReleaseDates = function(releases) {
        if (!_.isUndefined(releases)) {
            if (_.isEmpty(releases)) {
                $scope.startDateOptions.minDate = $scope.project.startDate;
            } else {
                $scope.startDateOptions.minDate = DateService.immutableAddDaysToDate(_.max(_.map($scope.project.releases, 'endDate')), 1);
            }
            $scope.release.startDate = $scope.startDateOptions.minDate;
            $scope.release.endDate = DateService.immutableAddMonthsToDate($scope.release.startDate, 3);
        }
    };
    // Init
    $scope.$watchCollection('project.releases', initReleaseDates);
    $scope.$watchCollection('[release.startDate, release.endDate]', function(newValues) {
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
    $scope.resetReleaseForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetReleaseForm
    });
}]);

controllers.controller('releaseDetailsCtrl', ['$scope', '$controller', 'ReleaseStatesByName', 'DateService', 'ReleaseService', 'FormService', 'detailsRelease', function($scope, $controller, ReleaseStatesByName, DateService, ReleaseService, FormService, detailsRelease) {
    $controller('releaseCtrl', {$scope: $scope}); // inherit from releaseCtrl
    $controller('attachmentCtrl', {$scope: $scope, attachmentable: detailsRelease, clazz: 'release'});
    // Functions
    $scope.update = function(release) {
        $scope.formHolder.submitting = true;
        ReleaseService.update(release).then(function() {
            $scope.resetReleaseForm();
            $scope.notifySuccess('todo.is.ui.release.updated');
        });
    };
    // Init
    $scope.$watchCollection('project.releases', function(releases) {
        if (!_.isUndefined(releases)) {
            if (_.isEmpty($scope.previousRelease)) {
                $scope.startDateOptions.minDate = $scope.project.startDate;
            } else {
                $scope.startDateOptions.minDate = DateService.immutableAddDaysToDate($scope.previousRelease.endDate, 1);
            }
        }
    });
    $scope.$watchCollection('[editableRelease.startDate, editableRelease.endDate]', function(newValues) {
        var startDate = newValues[0];
        var endDate = newValues[1];
        if (startDate) {
            $scope.endDateOptions.minDate = DateService.immutableAddDaysToDate(startDate, 1);
        }
        if (endDate) {
            $scope.startDateOptions.maxDate = DateService.immutableAddDaysToDate(endDate, -1);
        }
    });
    $controller('updateFormController', {$scope: $scope, item: detailsRelease, type: 'release'});
    $scope.releaseStatesByName = ReleaseStatesByName;
    $scope.previousRelease = FormService.previous($scope.project.releases, $scope.release);
    $scope.nextRelease = FormService.next($scope.project.releases, $scope.release);
}]);

controllers.controller('releaseTimelineCtrl', ['$scope', 'DateService', function($scope, DateService) {
    // Functions
    $scope.computeReleaseParts = function(release) {
        var parts = [];
        var latestDate = release.startDate;
        _.each(release.sprints, function(sprint) {
            var gapDuration = DateService.daysBetweenDates(latestDate, sprint.startDate);
            if (gapDuration > 1) {
                parts.push({duration: gapDuration - 1});
            }
            latestDate = sprint.endDate;
            parts.push(sprint);
        });
        return parts;
    };
    // Init
    $scope.releaseParts = [];
    $scope.$watch('release', function(newRelease) {
        if (newRelease) {
            $scope.releaseParts = $scope.computeReleaseParts(newRelease);
        }
    }, true);
}]);