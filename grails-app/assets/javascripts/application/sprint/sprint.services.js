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

services.service("SprintService", ['$q', '$state', 'Sprint', 'SprintStatesByName', 'IceScrumEventType', 'Session', 'PushService', 'CacheService', 'ReleaseService', 'FormService', function($q, $state, Sprint, SprintStatesByName, IceScrumEventType, Session, PushService, CacheService, ReleaseService, FormService) {
    var self = this;
    var crudMethods = {};
    this.crudMethods = crudMethods; // Access from outside
    crudMethods[IceScrumEventType.CREATE] = function(sprint) {
        CacheService.addOrUpdate('sprint', sprint);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(sprint) {
        CacheService.addOrUpdate('sprint', sprint);
    };
    crudMethods[IceScrumEventType.DELETE] = function(sprint) {
        if ($state.includes("planning.release.sprint.withId.details", {sprintId: sprint.id})) {
            $state.go('planning.release', {}, {location: 'replace'});
        } else if ($state.includes('taskBoard', {sprintId: sprint.id})) {
            $state.go('taskBoard', {sprintId: null}, {location: 'replace'});
        } else if ($state.includes('roadmap.roadmap.sprint', {sprintId: sprint.id})) {
            $state.go('roadmap.roadmap', {}, {location: 'replace'});
        }
        CacheService.remove('sprint', sprint.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('sprint', eventType, crudMethod);
    });
    this.mergeSprints = function(sprints) {
        _.each(sprints, crudMethods[IceScrumEventType.CREATE]);
    };
    this.list = function(release) {
        if (_.isEmpty(release.sprints)) {
            return Sprint.query({projectId: release.parentProject.id, type: 'release', id: release.id}, function(sprints) {
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
        return Sprint.update({id: sprint.id, projectId: release.parentProject.id}, sprint, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.save = function(sprint, release) {
        sprint.class = 'sprint';
        return Sprint.save({projectId: release.parentProject.id}, sprint, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.generateSprints = function(release) {
        return Sprint.saveArray({type: 'release', id: release.id, projectId: release.parentProject.id, action: 'generateSprints'}, {}, self.mergeSprints).$promise;
    };
    this.get = function(id) {
        var cachedSprint = CacheService.get('sprint', id);
        return cachedSprint ? $q.when(cachedSprint) : self.refresh(id);
    };
    this.refresh = function(id, projectId) {
        return Sprint.get({id: id, projectId: projectId}, crudMethods[IceScrumEventType.CREATE]).$promise
    };
    this.getCurrentOrLastSprint = function(project) {
        return ReleaseService.getCurrentOrLastRelease(project).then(function(release) {
            if (release && release.id) {
                return self.list(release).then(function() {
                    var sprints = _.orderBy(release.sprints, 'orderNumber', 'desc');
                    return _.find(sprints, function(sprint) {
                        return sprint.state > SprintStatesByName.TODO;
                    });
                });
            } else {
                return $q.when(null);
            }
        });
    };
    this.getLastSprint = function(project) {
        return ReleaseService.getCurrentOrLastRelease(project).then(function(release) {
            if (release && release.id) {
                return self.list(release).then(function() {
                    return _.findLast(release.sprints, {state: SprintStatesByName.DONE});
                });
            } else {
                return $q.when(null);
            }
        });
    };
    this.getCurrentOrNextSprint = function(project) {
        return ReleaseService.getCurrentOrNextRelease(project).then(function(release) {
            if (release && release.id) {
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
    this.reactivate = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'reactivate'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
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
        return Sprint.delete({id: sprint.id, projectId: release.parentProject.id}, {}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.autoPlanMultiple = function(sprints, capacity, release) {
        return Sprint.updateArray({id: _.map(sprints, 'id'), projectId: release.parentProject.id, action: 'autoPlan'}, {capacity: capacity}, self.mergeSprints).$promise;
    };
    this.unPlanMultiple = function(sprints, release) {
        return Sprint.updateArray({id: _.map(sprints, 'id'), projectId: release.parentProject.id, action: 'unPlan'}, {}, self.mergeSprints).$promise;
    };
    this.openChart = function(sprint, project, chart) {
        return FormService.httpGet('p/' +  project.id + '/sprint/' + sprint.id + '/' + chart, null, true);
    };
    this.copyRecurrentTasks = function(sprint, project) {
        return Sprint.update({id: sprint.id, projectId: project.id, action: 'copyRecurrentTasks'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.authorizedSprint = function(action, sprint) {
        switch (action) {
            case 'create':
            case 'update':
            case 'upload':
                return Session.poOrSm();
            case 'activate':
                return Session.poOrSm() && sprint.state == SprintStatesByName.TODO && sprint.activable;
            case 'reactivate':
                return Session.poOrSm() && sprint.state == SprintStatesByName.DONE && sprint.reactivable;
            case 'delete':
            case 'autoPlan':
                return Session.poOrSm() && sprint.state == SprintStatesByName.TODO;
            case 'close':
                return Session.poOrSm() && sprint.state == SprintStatesByName.IN_PROGRESS;
            case 'updateStartDate':
                return Session.poOrSm() && sprint.state < SprintStatesByName.IN_PROGRESS;
            case 'updateEndDate':
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
