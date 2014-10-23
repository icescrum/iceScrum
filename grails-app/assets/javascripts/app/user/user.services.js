/*
 * Copyright (c) 2014 Kagilum SAS.
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
services.factory('User', [ 'Resource', function($resource) {
    return $resource(icescrum.grailsServer + '/' + 'user/:id/:action',
        {},
        {
            current: {method: 'GET', params: {action: 'current'}}
        });
}]);

services.service("UserService", ['User', '$http', '$rootScope', function(User, $http, $rootScope) {
    this.getCurrent = function() {
        return User.current({ product: icescrum.product }).$promise;
    };
    this.update = function(user) {
        user.class = 'user';
        return user.$update();
    };
    this.save = function(user) {
        user.class = 'user';
        return user.$save();
    };
    this.retrievePassword = function(user) {
        return $http.post($rootScope.serverUrl + '/' + 'user/retrieve?user.username='+user.username)
    }
}]);
