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

services.service("ActivityService", ['FormService', '$rootScope', function(FormService, $rootScope) {
    this.activities = function(fluxiable, all, projectId) {
        var params = {paginate: true};
        if (all) {
            params.all = true;
        }
        var url = $rootScope.serverUrl + '/p/' + projectId + '/activity/' + _.lowerFirst(fluxiable.class) + '/' + fluxiable.id;
        return FormService.httpGet(url, {params: params}).then(function(activitiesAndCount) {
            fluxiable.activities = activitiesAndCount.activities;
            fluxiable.activities_total = activitiesAndCount.activitiesCount; // Don't use activities_count which already exists but does not represent the same activities (aggregated versus owned)
            return fluxiable.activities;
        });
    };
}]);
