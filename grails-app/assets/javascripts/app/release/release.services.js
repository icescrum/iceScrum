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
    return $resource(icescrum.grailsServer + '/p/:projectId/release/:id/:action');
}]);

services.service("ReleaseService", ['$q', 'Release', 'ReleaseStatesByName', 'Session', function($q, Release, ReleaseStatesByName, Session) {
    var self = this;
    this.list = function(project) {
        if (_.isEmpty(project.releases)) {
            return Release.query({projectId: project.id}, function(data) {
                project.releases = data;
                project.releases_count = project.releases.length;
            }).$promise;
        } else {
            return $q.when(project.releases);
        }
    };
    this.getCurrentOrNextRelease = function(project) {
        return Release.get({projectId: project.id, action: 'findCurrentOrNextRelease'}).$promise;
    };
    this.update = function(release, project) {
        var releaseToUpdate = _.omit(release, 'sprints');
        return Release.update({id: release.id, projectId: release.parentProduct.id}, releaseToUpdate, function(release) {
            angular.extend(_.find(project.releases, { id: release.id }), release);
        }).$promise;
    };
    this.save = function(release, project) {
        release.class = 'release';
        return Release.save({projectId: project.id}, release, function(release) {
            var existingRelease = _.find(project.releases, {id: release.id});
            if (existingRelease) {
                angular.extend(existingRelease, release);
            } else {
                project.releases.push(new Release(release));
            }
            project.releases_count = project.releases.length;
        }).$promise;
    };
    this.get = function(id, project) {
        return self.list(project).then(function(releases) {
            var release = _.find(releases, function(rw) {
                return rw.id == id;
            });
            if (release) {
                return release;
            } else {
                throw Error('todo.is.ui.release.does.not.exist');
            }
        });
    };
    this.activate = function(release) {
        return Release.update({id: release.id, projectId: release.parentProduct.id, action: 'activate'}, {}).$promise;
    };
    this.close = function(release) {
        return Release.update({id: release.id, projectId: release.parentProduct.id, action: 'close'}, {}).$promise;
    };
    this.generateSprints = function(release) {
        return Release.updateArray({id: release.id, projectId: release.parentProduct.id, action: 'generateSprints'}, {}).$promise.then(function(sprints){
            release.sprints = sprints;
        });
    };
    this.autoPlan = function(release) {
        return Release.updateArray({id: release.id, projectId: release.parentProduct.id, action: 'autoPlan'}, {}).$promise;
    };
    this.unPlan = function(release) {
        return Release.update({id: release.id, projectId: release.parentProduct.id, action: 'unPlan'}, {}).$promise;
    };
    this['delete'] = function(release, project) {
        return release.$delete({projectId: project.id}, function() {
            _.remove(project.releases, {id: release.id});
        });
    };
    this.openChart = function(release, chart) {
        return Release.get({id: release.id, projectId: release.parentProduct.id, action: chart}).$promise;
    };
    this.authorizedRelease = function(action, release) {
        switch (action) {
            case 'update':
            case 'generateSprints':
            case 'autoPlan':
            case 'unPlan':
                return Session.poOrSm() && release.state != ReleaseStatesByName.DONE;
            case 'activate':
                return Session.poOrSm() && release.state == ReleaseStatesByName.WAIT && release.activable;
            case 'close':
                return Session.poOrSm() && release.state == ReleaseStatesByName.IN_PROGRESS && release.closable;
            case 'delete':
                return Session.poOrSm() && release.state == ReleaseStatesByName.WAIT;
            case 'create':
                return Session.poOrSm();
            case 'upload':
                return Session.inProduct();
            default:
                return false;
        }
    };
}]);