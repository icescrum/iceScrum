/*
 * Copyright (c) 2014 Kagilum SAS.
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
 *
 */
services.factory('Project', ['Resource', function($resource) {
    return $resource('/project/:id/:action');
}]);

services.service("ProjectService", ['Project', 'Session', 'FormService', function(Project, Session, FormService) {
    this.save = function(project) {
        project.class = 'product';
        return Project.save(project).$promise;
    };
    this.countMembers = function(project) { // Requires the team to be loaded !
        return _.union(_.map(project.team.scrumMasters, 'id'), _.map(project.team.members, 'id'), _.map(project.productOwners, 'id')).length;
    };
    this.updateTeam = function(project) {
        // Wrap the product inside a "productd" because by default the formObjectData function will turn it into a "product" object
        // The "product" object conflicts with the "product" attribute expected by a filter which expects it to be either a number (id) or string (pkey)
        return Project.update({id: project.id, action: 'updateTeam'}, {productd: project}).$promise;
    };
    this.update = function(project) {
        return Project.update({id: project.id}, {productd: project}).$promise;
    };
    this.leaveTeam = function(project) {
        return Project.update({id: project.id, action: 'leaveTeam'}, {}).$promise;
    };
    this.archive = function(project) {
        return Project.update({id: project.id, action: 'archive'}, {}).$promise;
    };
    this['delete'] = function(project) {
        return Project.delete({id: project.id}).$promise;
    };
    this.listPublic = function(term, offset) {
        return Project.get({action: 'listPublic', term: term, offset: offset}).$promise;
    };
    this.listByUser = function(term, offset) {
        return Project.get({action: 'listByUser', term: term, offset: offset}).$promise;
    };
    this.getActivities = function(project) {
        return Project.query({action: 'activities', id: project.id}).$promise;
    };
    this.openChart = function(project, chart) {
        return Project.get({id: project.id, action: chart}).$promise;
    };
    this.authorizedProject = function(action, project) {
        switch (action) {
            case 'update':
            case 'updateTeamMembers': // Should rather be in a team service but depends on the project...
            case 'updateProjectMembers':
                return Session.sm();
            case 'delete':
                return Session.owner(project);
            case 'edit':
                return Session.authenticated();
            default:
                return false;
        }
    };
    this.getVersions = function() {
        return FormService.httpGet('project/versions');
    };
    this.getTags = function() {
        return FormService.httpGet('search/tag');
    };
}]);