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
            isAlreadySavedToday: {method: 'GET', params: {action: 'isAlreadySavedToday'}},
            chart: {method: 'GET', params: {action: 'chart'}},
            chartUserRelease : {method: 'GET', params: {action: 'chartUserRelease '}},
            chartUser  : {method: 'GET', params: {action: 'chartUser  '}},
            chartTeam: {method: 'GET', params: {action: 'chartTeam  '}},
            chartTeamRelease: {method: 'GET', params: {action: 'chartTeamRelease  '}}
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
    this.chart = function() {
        return Mood.chart().$promise;
    };
    this.chartUser = function(project) {
        return Mood.chartUser({product: project.id}).$promise;
    };
    this.chartUserRelease = function(project) {
        return Mood.chartUserRelease ({product: project.id}).$promise;
    }
    this.chartTeam = function(project) {
        return Mood.chartTeam ({product: project.id}).$promise;
    }
    this.chartTeamRelease = function(project) {
        return Mood.chartTeamRelease ({product: project.id}).$promise;
    }


}]);
