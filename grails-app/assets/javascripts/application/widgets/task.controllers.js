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
controllers.controller('taskWidgetCtrl', ['$scope', 'TaskService', '$controller', 'postitSize', 'screenSize', function($scope, TaskService, $controller, postitSize, screenSize) {
    $controller('widgetCtrl', {$scope: $scope});
    // Functions
    $scope.display = function(widget) {
        $scope.postitClass = postitSize.postitClass($scope.viewName, widget.settings.postitSize);
        if ($scope.postitClass != widget.settings.postitSize) {
            postitSize.cleanPostitSize($scope.viewName);
            $scope.postitClass = postitSize.postitClass($scope.viewName, widget.settings.postitSize);
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
    widget.settings = widget.settings ? widget.settings : {postitSize: 'list-group'};
    $scope.viewName = 'taskWidget';
    $scope.display(widget);
    screenSize.on('xs, sm', function() {$scope.display(widget)});
    $scope.$watch(function() { return postitSize.currentPostitSize($scope.viewName); }, function() {$scope.display(widget)});
}]);