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

controllers.controller('releaseCtrl', ['$scope', '$state', 'ReleaseService', function($scope, $state, ReleaseService) {
    $scope.authorizedRelease = function(action, release) {
        return ReleaseService.authorizedRelease(action, release);
    };
    $scope.startDateOptions = {
        opened: false
    };
    $scope.endDateOptions = angular.copy($scope.startDateOptions);
}]);

controllers.controller('releaseNewCtrl', ['$scope', '$controller', '$state', '$filter', 'Session', 'ReleaseService', 'hotkeys', function($scope, $controller, $state, $filter, Session, ReleaseService, hotkeys) {
    $controller('releaseCtrl', { $scope: $scope }); // inherit from releaseCtrl
    // Functions
    $scope.resetReleaseForm = function() {
        $scope.release = {};
        $scope.resetFormValidation($scope.formHolder.releaseForm);
    };
    $scope.save = function(release, andContinue) {
        release.startDate = $filter('dateToIso')(release.startDate);
        release.endDate = $filter('dateToIso')(release.endDate);
        ReleaseService.save(release, Session.getProject())
            .then(function(release) {
                if (andContinue) {
                    $scope.resetReleaseForm();
                } else {
                    $scope.setEditableMode(true);
                    $state.go('^.details', { id: release.id });
                }
                $scope.notifySuccess('todo.is.ui.release.saved');
            });
    };
    // Init
    $scope.formHolder = {};
    $scope.resetReleaseForm();
    hotkeys.bindTo($scope).add({
        combo: 'esc',
        allowIn: ['INPUT'],
        callback: $scope.resetReleaseForm
    });
}]);

controllers.controller('releaseDetailsCtrl', ['$scope', '$state', '$filter', '$stateParams', '$controller', 'Session', 'ReleaseService', 'FormService', function($scope, $state, $filter, $stateParams, $controller, Session, ReleaseService, FormService) {
    $controller('releaseCtrl', { $scope: $scope }); // inherit from releaseCtrl
    // Functions
    $scope.isDirty = function() {
        return !_.isEqual($scope.editableRelease, $scope.editableReleaseReference);
    };
    $scope.update = function(release) {
        release.startDate = $filter('dateToIso')(release.startDate);
        release.endDate = $filter('dateToIso')(release.endDate);
        ReleaseService.update(release, Session.getProject()).then(function(release) {
            $scope.resetReleaseForm();
            $scope.notifySuccess('todo.is.ui.release.updated');
        });
    };
    $scope.editForm = function(value) {
        if (value != $scope.getEditableMode()) {
            $scope.setEditableMode(value); // global
            $scope.resetReleaseForm();
        }
    };
    $scope.getShowReleaseForm = function(release) {
        return ($scope.getEditableMode() || $scope.formHolder.formHover) && $scope.authorizedRelease('update', release);
    };
    $scope.resetReleaseForm = function() {
        if ($scope.getEditableMode()) {
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
    $scope.attachmentQuery = function($flow, release) {
        $scope.flow = $flow;
        $flow.opts.target = 'attachment/release/' + release.id + '/flow';
        $flow.upload();
    };
    $scope.formHover = function(value) {
        $scope.formHolder.formHover = value;
    };
    // Init
    $scope.formHolder = {};
    $scope.release = {};
    $scope.editableRelease = {};
    $scope.editableReleaseReference = {};
    $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $state.go
    $scope.clazz = 'release'; // for attachments
    var project = Session.getProject();
    ReleaseService.get(project, $stateParams.id).then(function(release) {
        $scope.release = release;
        $scope.selected = release;
        $scope.resetReleaseForm();
        $scope.previous = FormService.previous(project.releases, $scope.release);
        $scope.next = FormService.next(project.releases, $scope.release);
    }).catch(function(e){
        $state.go('^');
        $scope.notifyError(e.message)
    });
}]);
