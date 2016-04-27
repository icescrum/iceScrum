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
services.factory('User', ['Resource', function($resource) {
    return $resource('/user/:id/:action');
}]);

services.service("UserService", ['User', '$http', '$rootScope', '$injector', 'FormService', function(User, $http, $rootScope, $injector, FormService) {
    this.getCurrent = function() {
        var Session = $injector.get('Session');
        var params = {action: 'current'};
        if (Session.getProject()) {
            params.product = Session.getProject().pkey;
        }
        return User.get(params).$promise;
    };
    this.getActivities = function(user) {
        return User.query({action: 'activities', id: user.id}).$promise;
    };
    this.getUnreadActivities = function(user) {
        return User.get({action: 'unreadActivitiesCount', id: user.id}).$promise;
    };
    this.getWidgets = function(user) {
        return User.get({action: 'widgets', id: user.id}).$promise;
    };
    this.getMenus = function(user, project) {
        //product is used to get menu for a particular product
        return User.query({action: 'menus', id: user.id, product: project ? project.id : null}).$promise;
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
        return $http.post($rootScope.serverUrl + '/user/retrieve?user.username=' + user.username);
    };
    this.getInvitationUserMock = function(token) {
        return FormService.httpGet('user/invitationUserMock', {params: {token: token}}, true);
    };
    this.updateMenuPreferences = function(info) {
        var Session = $injector.get('Session');
        $http({
            url: $rootScope.serverUrl + '/user/'+Session.user.id+'/menu',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            transformRequest: function(data) {
                return FormService.formObjectData(data, '');
            },
            data: info
        });
    };
    this.updateWidgetPosition = function(info) {
        var Session = $injector.get('Session');
        $http({
            url: $rootScope.serverUrl + '/user/'+Session.user.id+'/widget',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            transformRequest: function(data) {
                return FormService.formObjectData(data, '');
            },
            data: info
        });
    };
    this.search = function(term) {
        return FormService.httpGet('user/search', {params: {value: term, invit: true}}, true);
    }
}]);
