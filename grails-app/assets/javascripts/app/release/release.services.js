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
services.factory('Release', ['Resource', function($resource) {
    return $resource('/p/:projectId/release/:id/:action');
}]);

services.service("ReleaseService", ['$q', '$state', 'Release', 'ReleaseStatesByName', 'IceScrumEventType', 'Session', 'CacheService', 'PushService', function($q, $state, Release, ReleaseStatesByName, IceScrumEventType, Session, CacheService, PushService) {
    var self = this;
    Session.getProject().releases = CacheService.getCache('release');
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(release) {
        CacheService.addOrUpdate('release', release);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(release) {
        CacheService.addOrUpdate('release', release);
    };
    crudMethods[IceScrumEventType.DELETE] = function(release) {
        if ($state.includes("planning.release.details", {releaseId: release.id})) {
            $state.go('planning');
        }
        CacheService.remove('release', release.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('release', eventType, crudMethod);
    });
    this.mergeReleases = function(releases) {
        _.each(releases, function(release) {
            crudMethods[IceScrumEventType.CREATE](release);
        });
    };
    this.list = function(project) {
        return _.isEmpty(project.releases) ? Release.query({projectId: project.id}, self.mergeReleases).$promise : $q.when(project.releases);
    };
    this.getCurrentOrLastRelease = function(project) {
        return self.list(project).then(function(releases) {
            return _.find(_.orderBy(releases, 'orderNumber', 'desc'), function(release) {
                return release.state > ReleaseStatesByName.WAIT;
            });
        });
    };
    this.getCurrentOrNextRelease = function(project) {
        return self.list(project).then(function(releases) {
            return _.find(_.sortBy(releases, 'orderNumber'), function(release) {
                return release.state < ReleaseStatesByName.DONE;
            });
        });
    };
    this.update = function(release) {
        var releaseToUpdate = _.omit(release, 'sprints');
        return Release.update({id: release.id, projectId: release.parentProduct.id}, releaseToUpdate, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.save = function(release, project) {
        release.class = 'release';
        return Release.save({projectId: project.id}, release, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.activate = function(release) {
        return Release.update({id: release.id, projectId: release.parentProduct.id, action: 'activate'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.close = function(release) {
        return Release.update({id: release.id, projectId: release.parentProduct.id, action: 'close'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.autoPlan = function(release, capacity) {
        return Release.updateArray({id: release.id, projectId: release.parentProduct.id, action: 'autoPlan'}, {capacity: capacity}).$promise; // TODO release resource returns stories, this is not good
    };
    this.unPlan = function(release) {
        return Release.update({id: release.id, projectId: release.parentProduct.id, action: 'unPlan'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(release, project) {
        return Release.delete({id: release.id, projectId: project.id}, {}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.openChart = function(release, chart) {
        return Release.get({id: release.id, projectId: release.parentProduct.id, action: chart}).$promise;
    };
    this.findAllSprints = function(releases) {
        return _.filter(_.flatMap(releases, 'sprints'), _.identity);
    };
    this.authorizedRelease = function(action, release) {
        switch (action) {
            case 'generateSprints':
            case 'autoPlan':
            case 'unPlan':
            case 'updateDates':
                return Session.poOrSm() && release.state != ReleaseStatesByName.DONE;
            case 'activate':
                return Session.poOrSm() && release.state == ReleaseStatesByName.WAIT && release.activable;
            case 'close':
                return Session.poOrSm() && release.state == ReleaseStatesByName.IN_PROGRESS && release.closable;
            case 'delete':
                return Session.poOrSm() && release.state == ReleaseStatesByName.WAIT;
            case 'create':
            case 'update':
                return Session.poOrSm();
            case 'upload':
                return Session.inProduct();
            default:
                return false;
        }
    };
}]);