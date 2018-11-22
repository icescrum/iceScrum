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
extensibleController('quickProjectsListCtrl', ['$scope', 'PushService', 'Session', 'ProjectService', 'IceScrumEventType', function($scope, PushService, Session, ProjectService, IceScrumEventType) {
    $scope.getProjectUrl = function(project, viewName) {
        return $scope.serverUrl + '/p/' + project.pkey + '/' + (viewName ? "#/" + viewName : '');
    };
    // Init
    $scope.projectCreationEnabled = isSettings.projectCreationEnabled || Session.admin();
    $scope.projectsLoaded = false;
    $scope.projects = [];
    ProjectService.listByUser({count: 9, light: true}).then(function(projectsAndCount) {
        $scope.projectsLoaded = true;
        $scope.projects = projectsAndCount.projects;
    });
    PushService.registerScopedListener('user', IceScrumEventType.UPDATE, function(user) {
        if (user.updatedRole) {
            var updatedRole = user.updatedRole;
            var project = updatedRole.project;
            if (updatedRole.role == undefined) {
                _.remove($scope.projects, {id: project.id});
            } else if (updatedRole.oldRole == undefined && !_.includes($scope.projects, {id: project.id})) {
                $scope.projects.push(project);
            }
        }
    }, $scope);
}]);
