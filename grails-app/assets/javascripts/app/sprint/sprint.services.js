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
        var promise = Sprint.query({ projectId: release.parentProduct.id, type: 'release', id: release.id }, function(newSprints) {
            if (angular.isArray(release.sprints)) {
                _.each(newSprints, function(newSprint) {
                    var existingSprint = _.find(release.sprints, {id: newSprint.id});
                    if (existingSprint) {
                        angular.extend(existingSprint, newSprint);
                    } else {
                        release.sprints.push(new Sprint(newSprint));
                    }
                });
            } else {
                release.sprints = newSprints;
            }
            release.sprints_count = release.sprints.length;
        }).$promise;
        return _.isEmpty(release.sprints) ? promise : $q.when(release.sprints);
    };
    this.getCurrentOrLastSprint = function(project) {
        return Sprint.get({ projectId: project.id, action: 'findCurrentOrLastSprint' }).$promise;
    };
    this.getCurrentOrNextSprint = function(project) {
        return Sprint.get({ projectId: project.id, action: 'findCurrentOrNextSprint' }).$promise;
    };
    this.update = function(sprint, release) {
        return Sprint.update({id: sprint.id, projectId: release.parentProduct.id}, sprint, function(sprint) {
            var existingSprint = _.find(release.sprints, {id: sprint.id});
            if (existingSprint) {
                angular.extend(existingSprint, sprint);
            }
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
    this.autoPlan = function(sprint, capacity, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'autoPlan'}, {capacity: capacity}).$promise;
    };
    this.unPlan = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'unPlan'}, {}).$promise;
    };
    this['delete'] = function(sprint, release) {
        return sprint.$delete({projectId: release.parentProduct.id}, function() {
            if ($state.includes("planning.release.sprint.withId.details", {releaseId: release.id, sprintId: sprint.id})) {
                $state.go('planning.release', {releaseId: release.id});
            }
            _.remove(release.sprints, {id: sprint.id});
        });
    };
    this.autoPlanMultiple = function(sprints, capacity, release) {
        return Sprint.updateArray({id: _.map(sprints, 'id'), projectId: release.parentProduct.id, action: 'autoPlan'}, {capacity: capacity}).$promise;
    };
    this.unPlanMultiple = function(sprints, release) {
        return Sprint.updateArray({id: _.map(sprints, 'id'), projectId: release.parentProduct.id, action: 'unPlan'}, {}).$promise;
    };
    this.openChart = function(sprint, project, chart) {
        return Sprint.get({ id: sprint.id, projectId: project.id, action: chart}).$promise;
    };
    this.authorizedSprint = function(action, sprint) {
        switch (action) {
            case 'create':
            case 'update':
                return Session.poOrSm();
            case 'activate':
                return Session.poOrSm() && sprint.state == SprintStatesByName.WAIT && sprint.activable;
            case 'delete':
                return Session.poOrSm() && sprint.state == SprintStatesByName.WAIT;
            case 'close':
                return Session.poOrSm() && sprint.state == SprintStatesByName.IN_PROGRESS;
            case 'updateStartDate':
                return Session.poOrSm() && sprint.state < SprintStatesByName.IN_PROGRESS;
            case 'updateEndDate':
            case 'autoPlan':
            case 'unPlan':
                return Session.poOrSm() && sprint.state != SprintStatesByName.DONE;
            default:
                return false;
        }
    };
    this.authorizedSprints = function(action, sprints) {
        var self = this;
        return _.every(sprints, function(sprint) {
            return self.authorizedSprint(action, sprint);
        });
    };
}]);