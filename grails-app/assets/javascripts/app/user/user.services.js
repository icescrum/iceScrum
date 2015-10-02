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
    return $resource(icescrum.grailsServer + '/user/:id/:action',
        {},
        {
            current: {method: 'GET', params: {action: 'current'}},
            activities: {method: 'GET', isArray: true, params: {action: 'activities'}},
            unreadActivitiesCount: {method: 'GET', params: {action: 'unreadActivitiesCount'}}
        });
}]);

services.service("UserService", ['User', '$http', '$rootScope', '$injector', function(User, $http, $rootScope, $injector) {
    this.getCurrent = function() {
        var Session = $injector.get('Session');
        return User.current( (Session.project ? { product: Session.project.pkey } : null) ).$promise;
    };
    this.getActivities = function(user) {
        return User.activities({ id: user.id }, {}).$promise;
    };
    this.getUnreadActivities = function(user) {
        return User.unreadActivitiesCount({ id: user.id }, {}).$promise;
    };
    this.update = function(user) {
        user.class = 'user';
        return user.$update(user);
    };
    this.save = function(user) {
        user.class = 'user';
        return user.$save();
    };
    this.retrievePassword = function(user) {
        return $http.post($rootScope.serverUrl + '/user/retrieve?user.username='+user.username);
    };
    this.getInvitationUserMock = function(token) {
        return $http.get($rootScope.serverUrl + '/user/invitationUserMock?token='+token).then(function(response) {
            return response.data;
        });
    };
}]);
