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
controllers.controller('taskWidgetCtrl', ['$scope', 'TaskService', '$controller', 'stickyNoteSize', 'screenSize', function($scope, TaskService, $controller, stickyNoteSize, screenSize) {
    $controller('widgetCtrl', {$scope: $scope});
    // Functions
    $scope.display = function(widget) {
        $scope.stickyNoteClass = stickyNoteSize.stickyNoteClass($scope.viewName, widget.settings.stickyNoteSize);
        if ($scope.stickyNoteClass != widget.settings.stickyNoteSize) {
            stickyNoteSize.cleanStickyNoteSize($scope.viewName);
            $scope.stickyNoteClass = stickyNoteSize.stickyNoteClass($scope.viewName, widget.settings.stickyNoteSize);
        }
    };
    $scope.taskUrl = function(task, project) {
        return "p/" + project.pkey + "/#/taskBoard/" + task.sprint.id + "/task/" + task.id;
    };
    // Init
    var widget = $scope.widget;
    $scope.tasksByProject = [];
    TaskService.listByUser().then(function(tasksByProject) {
        $scope.tasksByProject = tasksByProject;
    });
    widget.settings = widget.settings ? widget.settings : {stickyNoteSize: 'list-group'};
    $scope.viewName = 'taskWidget';
    $scope.display(widget);
    screenSize.on('xs, sm', function() {$scope.display(widget)}, $scope);
    $scope.$watch(function() { return stickyNoteSize.currentStickyNoteSize($scope.viewName); }, function() {$scope.display(widget)});
}]);