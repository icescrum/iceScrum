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
services.factory('Sprint', ['Resource', function($resource) {
    return $resource(icescrum.grailsServer + '/p/:projectId/sprint/:type/:id/:action');
}]);

services.service("SprintService", ['$q', '$state', 'Sprint', 'SprintStatesByName', 'Session', function($q, $state, Sprint, SprintStatesByName, Session) {
    this.list = function(release) {
        if (_.isEmpty(release.sprints)) {
            return Sprint.query({ projectId: release.parentProduct.id, type: 'release', id: release.id }, function(data) {
                release.sprints = data;
                release.sprints_count = release.sprints.length;
            }).$promise;
        } else {
            return $q.when(release.sprints);
        }
    };
    this.getCurrentOrLastSprint = function(project) {
        return Sprint.get({ projectId: project.id, action: 'findCurrentOrLastSprint' }).$promise;
    };
    this.getCurrentOrNextSprint = function(project) {
        return Sprint.get({ projectId: project.id, action: 'findCurrentOrNextSprint' }).$promise;
    };
    this.update = function(sprint, release) {
        return Sprint.update({id: sprint.id, projectId: release.parentProduct.id}, sprint, function(sprint) {
            angular.extend(_.find(release.sprints, { id: sprint.id }), sprint);
        }).$promise;
    };
    this.save = function(sprint, release) {
        sprint.class = 'sprint';
        return Sprint.save({projectId: release.parentProduct.id}, sprint, function(sprint) {
            var existingSprint = _.find(release.sprints, {id: sprint.id});
            if (existingSprint) {
                angular.extend(existingSprint, sprint);
            } else {
                release.sprints.push(new Sprint(sprint));
            }
            release.sprints_count = release.sprints.length;
        }).$promise;
    };
    this.get = function(id, project) {
        return Sprint.get({id: id, projectId: project.id}).$promise;
    };
    this.activate = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'activate'}, {}).$promise;
    };
    this.close = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'close'}, {}).$promise;
    };
    this.unPlan = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'unPlan'}, {}).$promise;
    };
    this['delete'] = function(sprint, release) {
        return sprint.$delete({projectId: release.parentProduct.id}, function() {
            if ($state.includes("releasePlan.sprint.details", {id: sprint.id})) {
                $state.go('releasePlan');
            }
            _.remove(release.sprints, {id: sprint.id});
        });
    };
    this.openChart = function(sprint, project, chart) {
        return Sprint.get({ id: sprint.id, projectId: project.id, action: chart}).$promise;
    };
    this.authorizedSprint = function(action, sprint) {
        switch (action) {
            case 'create':
                return Session.poOrSm();
            case 'activate':
                return Session.poOrSm() && sprint.state == SprintStatesByName.WAIT && sprint.activable;
            case 'delete':
                return Session.poOrSm() && sprint.state == SprintStatesByName.WAIT;
            case 'close':
                return Session.poOrSm() && sprint.state == SprintStatesByName.IN_PROGRESS;
            case 'unPlan':
            case 'update':
                return Session.poOrSm() && sprint.state != SprintStatesByName.DONE;
            default:
                return false;
        }
    };
}]);