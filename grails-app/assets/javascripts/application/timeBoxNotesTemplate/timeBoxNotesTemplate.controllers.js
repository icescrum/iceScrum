/*
 * Copyright (c) 2017 Kagilum SAS.
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
 * Colin Bontemps (cbontemps@kagilum.com)
 *
 */

controllers.controller('releaseNotesCtrl', ['$scope', '$uibModal', 'TimeBoxNotesTemplateService', 'Session', function($scope, $uibModal, TimeBoxNotesTemplateService, Session) {
    // Functions
    $scope.computeReleaseNotes = function() {
        $scope.template = this.template;
        TimeBoxNotesTemplateService.getReleaseNotes($scope.release, $scope.template).then(function(releaseNotes) {
            $scope.releaseNotes = releaseNotes.releaseNotes
        });
    };
    $scope.showEditTemplateModal = function(template) {
        $uibModal.open({
            templateUrl: 'timeBoxNotesTemplate.html',
            controller: 'timeBoxNotesTemplateCtrl',
            resolve: {template: template}
        }).result.then(
            function() {
                $scope.computeReleaseNotes();
            }
        );
    };
    // Init
    $scope.project = Session.getProject();
    $scope.templates = $scope.project.timeBoxNotesTemplates;
    if ($scope.templates.length > 0) {
        $scope.template = $scope.templates[0];
        $scope.computeReleaseNotes();
    }
}]);

controllers.controller('timeBoxNotesTemplateCtrl', ['$scope', 'Session', 'TimeBoxNotesTemplateService', 'ProjectService', 'template', function($scope, Session, TimeBoxNotesTemplateService, ProjectService, template) {
    // Functions
    $scope.retrieveTags = function() {
        if (_.isEmpty($scope.tags)) {
            ProjectService.getTags().then(function(tags) {
                $scope.tags = tags;
            });
        }
    };
    $scope.update = function(timeBoxNotesTemplate) {
        $scope.formHolder.submitting = true;
        TimeBoxNotesTemplateService.update(timeBoxNotesTemplate).then(function() {
            _.merge(template, timeBoxNotesTemplate);
            $scope.notifySuccess('todo.is.ui.timeBoxNoteTemplate.updated');
            $scope.$close(true);
        });
    };
    // Init
    $scope.project = Session.getProject();
    $scope.editableTimeBoxNotesTemplate = angular.copy(template);
    _.forEach($scope.editableTimeBoxNotesTemplate.configs, function(config) {
        if (typeof config.storyTags == 'undefined') {
            config.storyTags = [];
        }
    });
}]);

controllers.controller('timeBoxNotesTemplateNewCtrl', ['$scope', '$controller', 'TimeBoxNotesTemplateStatesByName', 'DateService', 'TimeBoxNotesTemplateService', 'FormService', 'detailsTimeBoxNotesTemplate', function($scope, $controller, TimeBoxNotesTemplateStatesByName, DateService, TimeBoxNotesTemplateService, FormService, detailsTimeBoxNotesTemplate) {
    $controller('timeBoxNotesTemplateCtrl', {$scope: $scope}); // inherit from timeBoxNotesTemplateCtrl
    // Functions

    // Init
}]);

