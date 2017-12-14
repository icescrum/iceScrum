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

services.service("ReleaseService", ['$q', '$state', '$injector', 'Release', 'ReleaseStatesByName', 'IceScrumEventType', 'Session', 'CacheService', 'PushService', 'FormService', function($q, $state, $injector, Release, ReleaseStatesByName, IceScrumEventType, Session, CacheService, PushService, FormService) {
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
            $state.go('planning', {}, {location: 'replace'});
        }
        CacheService.remove('release', release.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('release', eventType, crudMethod);
    });
    this.mergeReleases = function(releases) {
        _.each(releases, crudMethods[IceScrumEventType.CREATE]);
    };
    this.list = function(project) {
        return _.isEmpty(project.releases) ? Release.query({projectId: project.id}, self.mergeReleases).$promise : $q.when(project.releases);
    };
    this.getCurrentOrLastRelease = function(project) {
        return self.list(project).then(function(releases) {
            return _.find(_.orderBy(releases, 'orderNumber', 'desc'), function(release) {
                return release.state > ReleaseStatesByName.TODO;
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
        return Release.update({id: release.id, projectId: release.parentProject.id}, releaseToUpdate, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.save = function(release, project) {
        release.class = 'release';
        return Release.save({projectId: project.id}, release, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.activate = function(release) {
        return Release.update({id: release.id, projectId: release.parentProject.id, action: 'activate'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.reactivate = function(release) {
        return Release.update({id: release.id, projectId: release.parentProject.id, action: 'reactivate'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.close = function(release) {
        return Release.update({id: release.id, projectId: release.parentProject.id, action: 'close'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.autoPlan = function(release, capacity) {
        return FormService.httpPost('release/' + release.id + '/autoPlan', {capacity: capacity}).then(function(result) {
            _.each(result.stories, $injector.get('StoryService').crudMethods[IceScrumEventType.UPDATE]);
        });
    };
    this.unPlan = function(release) {
        return FormService.httpGet('release/' + release.id + '/unPlan').then(function(result) {
            _.each(result.sprints, function(sprint) {
                FormService.transformStringToDate(sprint);
                $injector.get('SprintService').crudMethods[IceScrumEventType.UPDATE](sprint);
            });
            _.each(result.stories, $injector.get('StoryService').crudMethods[IceScrumEventType.UPDATE]);
        });
    };
    this['delete'] = function(release, project) {
        return Release.delete({id: release.id, projectId: project.id}, {}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.openChart = function(release, chart) {
        return Release.get({id: release.id, projectId: release.parentProject.id, action: chart}).$promise;
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
                return Session.poOrSm() && release.state == ReleaseStatesByName.TODO && release.activable;
            case 'reactivate':
                return Session.poOrSm() && release.state == ReleaseStatesByName.DONE && release.reactivable;
            case 'close':
                return Session.poOrSm() && release.state == ReleaseStatesByName.IN_PROGRESS && release.closable;
            case 'delete':
                return Session.poOrSm() && release.state == ReleaseStatesByName.TODO;
            case 'create':
            case 'update':
                return Session.poOrSm();
            case 'upload':
                return Session.inProject();
            default:
                return false;
        }
    };
}]);
