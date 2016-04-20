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
    return $resource('/p/:projectId/sprint/:type/:id/:action');
}]);

services.service("SprintService", ['$q', '$state', 'Sprint', 'SprintStatesByName', 'IceScrumEventType', 'Session', 'PushService', 'CacheService', 'ReleaseService', function($q, $state, Sprint, SprintStatesByName, IceScrumEventType, Session, PushService, CacheService, ReleaseService) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(sprint) {
        CacheService.addOrUpdate('sprint', sprint);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(sprint) {
        CacheService.addOrUpdate('sprint', sprint);
    };
    crudMethods[IceScrumEventType.DELETE] = function(sprint) {
        if ($state.includes("planning.release.sprint.withId.details", {sprintId: sprint.id})) {
            $state.go('planning.release');
        }
        CacheService.remove('sprint', sprint.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('sprint', eventType, crudMethod);
    });
    this.mergeSprints = function(sprints) {
        _.each(sprints, function(sprint) {
            crudMethods[IceScrumEventType.CREATE](sprint);
        });
    };
    this.list = function(release) {
        if (_.isEmpty(release.sprints)) {
            return Sprint.query({projectId: release.parentProduct.id, type: 'release', id: release.id}, function(sprints) {
                if (angular.isArray(release.sprints)) {
                    _.each(sprints, function(sprint) {
                        var existingSprint = _.find(release.sprints, {id: sprint.id});
                        if (existingSprint) {
                            angular.extend(existingSprint, sprint);
                        } else {
                            release.sprints.push(sprint);
                        }
                    });
                } else {
                    release.sprints = sprints;
                }
                release.sprints_count = release.sprints.length;
                self.mergeSprints(sprints);
            }).$promise;
        } else {
            return $q.when(release.sprints);
        }
    };
    this.update = function(sprint, release) {
        return Sprint.update({id: sprint.id, projectId: release.parentProduct.id}, sprint, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.save = function(sprint, release) {
        sprint.class = 'sprint';
        return Sprint.save({projectId: release.parentProduct.id}, sprint, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.generateSprints = function(release) {
        return Sprint.saveArray({type: 'release', id: release.id, projectId: release.parentProduct.id, action: 'generateSprints'}, {}, self.mergeSprints).$promise;
    };
    this.get = function(id, project) {
        var sprint = _.find(ReleaseService.getAllSprints(project.releases), {id: id});
        return sprint ? $q.when(sprint) : self.refresh(id, project.id);
    };
    this.refresh = function(id, projectId) {
        return Sprint.get({id: id, projectId: projectId}, crudMethods[IceScrumEventType.CREATE]).$promise
    };
    this.getCurrentOrLastSprint = function(project) {
        return ReleaseService.getCurrentOrLastRelease(project).then(function(release) {
            if (release.id) {
                return self.list(release).then(function() {
                    var sprints = _.orderBy(release.sprints, 'orderNumber', 'desc');
                    return _.find(sprints, function(sprint) {
                        return sprint.state > SprintStatesByName.WAIT;
                    });
                });
            } else {
                return $q.when(null);
            }
        });
    };
    this.getCurrentOrNextSprint = function(project) {
        return ReleaseService.getCurrentOrNextRelease(project).then(function(release) {
            if (release.id) {
                return self.list(release).then(function() {
                    return _.find(_.sortBy(release.sprints, 'orderNumber'), function(sprint) {
                        return sprint.state < SprintStatesByName.DONE;
                    });
                });
            } else {
                return $q.when(null);
            }
        });
    };
    this.activate = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'activate'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.close = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'close'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.autoPlan = function(sprint, capacity, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'autoPlan'}, {capacity: capacity}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.unPlan = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'unPlan'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(sprint, release) {
        return Sprint.delete({id: sprint.id, projectId: release.parentProduct.id}, {}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.autoPlanMultiple = function(sprints, capacity, release) {
        return Sprint.updateArray({id: _.map(sprints, 'id'), projectId: release.parentProduct.id, action: 'autoPlan'}, {capacity: capacity}, self.mergeSprints).$promise;
    };
    this.unPlanMultiple = function(sprints, release) {
        return Sprint.updateArray({id: _.map(sprints, 'id'), projectId: release.parentProduct.id, action: 'unPlan'}, {}, self.mergeSprints).$promise;
    };
    this.openChart = function(sprint, project, chart) {
        return Sprint.get({id: sprint.id, projectId: project.id, action: chart}).$promise;
    };
    this.authorizedSprint = function(action, sprint) {
        switch (action) {
            case 'create':
            case 'update':
            case 'upload':
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
            case 'plan':
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