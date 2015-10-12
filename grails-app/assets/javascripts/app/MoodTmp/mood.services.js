/*
 * Copyright (c) 2015 Kagilum .
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
 * Authors:Marwah Soltani (msoltani@kagilum.com)
 *
 *
 */

services.factory('Mood', ['Resource', function ($resource) {
    return $resource(icescrum.grailsServer + '/mood/:id/:action',
        {},
        {
            listByUser: {method: 'GET', isArray: true, params: {action: 'listByUser'}},
            isAlreadySavedToday: {method: 'GET', params: {action: 'isAlreadySavedToday'}}
        });
}]);

services.service("MoodService", ['Mood', function (Mood) {
    this.save = function (mood) {
        mood.class = 'mood';
        return Mood.save({action: 'save'}, mood).$promise;
    };
    this.listByUser = function () {
        return Mood.listByUser().$promise;
    };
    this.isAlreadySavedToday = function(){
        return Mood.isAlreadySavedToday().$promise;
    };
    this.openChart = function(chart, project) {
        var settings = { action: chart };
        if (project) {
            settings.product = project.id;
        }
        return Mood.get(settings, {}).$promise;
    };
}]);