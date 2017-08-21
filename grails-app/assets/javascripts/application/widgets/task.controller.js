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
controllers.controller('taskWidgetCtrl', ['$scope', 'TaskService', '$controller', function($scope, TaskService, $controller) {
    $controller('widgetCtrl', {$scope: $scope});

    TaskService.listByUser().then(function(tasksByProject) {
        $scope.tasksByProject = tasksByProject;
    });

    $scope.display = function(widget){
        var current = $scope.currentPostitSize($scope.viewName, widget.settings.postitSize);
        if(current != widget.settings.postitSize){
            $scope.cleanPostitSize($scope.viewName);
            $scope.currentPostitSize($scope.viewName, widget.settings.postitSize);
        }
    };

    $scope.taskUrl = function(task, project){
        return "p/" + project.pkey + "/#/taskBoard/" + task.sprint.id + "/task/" + task.id;
    };

    //init
    var widget = $scope.widget;
    $scope.tasksByProject = [];
    widget.settings = widget.settings ? widget.settings : { postitSize:'list-group' };
    $scope.viewName = 'taskWidget';
    $scope.display(widget);
}]);