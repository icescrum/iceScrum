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
 * Nicolas Noullet (nnoullet@kagilum.com)
 * Vincent Barrier (vbarrier@kagilum.com)
 *
 */
services.factory('Team', ['Resource', function($resource) {
    return $resource('/team/:type/:id/:action',
        {},
        {
            listByUser: {method: 'GET', params: {action: 'listByUser'}}
        });
}]);

services.service("TeamService", ['$q', 'Team', 'Session', 'FormService', function($q, Team, Session, FormService) {
    this.save = function(team) {
        team.class = 'team';
        return Team.save(team).$promise;
    };
    this.update = function(team) {
        return Team.update({id: team.id}, {team: team}).$promise;
    };
    this['delete'] = function(team) {
        return Team.delete({id: team.id}).$promise;
    };
    this.authorizedTeam = function(action, team) {
        switch (action) {
            case 'delete':
                return Session.owner(team);
            case 'changeOwner':
                return Session.admin();
            default:
                return false;
        }
    };
    this.get = function(project) {
        if (_.isEmpty(project.team)) {
            return Team.get({id: project.id, type: 'project'}, function(team) {
                project.team = team;
            }).$promise;
        } else {
            return $q.when(project.team);
        }
    };
    this.search = function(term, create) {
        return Team.query({term: term, create: create}).$promise;
    };
    this.listByUser = function(term, offset) {
        return Team.query({action: 'listByUser', term: term, offset: offset}).$promise;
    };
    this.countByUser = function(term) {
        return FormService.httpGet('team/countByUser', {params: {term: term}}, true);
    };
}]);