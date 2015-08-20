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

services.service("SprintService", ['$q', '$filter', 'Sprint', 'Session', function($q, $filter, Sprint, Session) {
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
        return Sprint.get({ projectId: project.id, action: 'findCurrentOrLastSprint' }, {}).$promise;
    };
    this.update = function (sprint, projectId) {
        return Sprint.update({ id: sprint.id, projectId: projectId }, sprint).$promise;
    };
    this.authorizedSprint = function(action, sprint) {
        switch (action) {
            case 'updateRetrospective':
            case 'updateDoneDefinition':
                return Session.poOrSm();
            default:
                return false;
        }
    };
}]);