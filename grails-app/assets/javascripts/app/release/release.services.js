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

services.service("ReleaseService", ['$q', '$filter', 'Release', 'ReleaseStatesByName', 'Session', function($q, $filter, Release, ReleaseStatesByName, Session) {
    this.list = function(project) {
        if (_.isEmpty(project.releases)) {
            return Release.query({ projectId: project.id }, function(data) {
                project.releases = data;
                project.releases_count = project.releases.length;
            }).$promise;
        } else {
            return $q.when(project.releases);
        }
    };
    this.getCurrentOrNextRelease = function(project) {
        return Release.get({ projectId: project.id, action: 'findCurrentOrNextRelease' }, {}).$promise;
    };
    this.update = function (release) {
        var releaseToUpdate = _.omit(release, 'sprints');
        return Release.update({ id: release.id, projectId: release.parentProduct.id }, releaseToUpdate).$promise;
    };
    this.authorizedRelease = function(action, release) {
        switch (action) {
            case 'update':
                return Session.po() && release.state != ReleaseStatesByName.DONE;
            default:
                return false;
        }
    };
}]);