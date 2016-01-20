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
 *
 */
services.factory('Backlog', ['Resource', function($resource) {
    return $resource('backlog/:id');
}]);

services.service("BacklogService", ['Backlog', 'Session', function(Backlog) {
    this.list = function() {
        return Backlog.query({shared: true}).$promise;
    };
    // The functions below are a hack to identify "known" backlogs, we should do better (e.g. new attribute)
    this.isAll = function(backlog) {
        return backlog.filter == '{"story":{}}'
    };
    this.isSandbox = function(backlog) {
        return backlog.filter == '{"story":{"state":1}}'
    };
    this.isBacklog = function(backlog) {
        return backlog.filter == '{"story":{"state":[2,3]}}'
    };
}]);