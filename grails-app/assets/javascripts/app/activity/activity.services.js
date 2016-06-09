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

services.service("ActivityService", ['FormService', function(FormService) {
    this.activities = function(fluxiable, all) {
        var params = all ? {params: {all: true}} : {};
        var url = 'activity/' + _.lowerFirst(fluxiable.class) + '/' + fluxiable.id;
        return FormService.httpGet(url, params).then(function(activities) {
            fluxiable.activities = activities;
            return activities;
        });
    };
}]);
