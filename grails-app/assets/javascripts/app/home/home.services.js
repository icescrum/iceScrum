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
 *
 */
services.service("HomeService", ['User','$http', '$rootScope', function(User, $http, $rootScope) {
    this.getPanels = function () {
        return $http.get($rootScope.serverUrl + '/home/panel/list');
    };

    this.updatePositionPanel = function(_data){
        $http({ url: $rootScope.serverUrl + '/home/panel',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            transformRequest: function (data) { return formObjectData(data, '');},
            data:_data});
    }
}]);