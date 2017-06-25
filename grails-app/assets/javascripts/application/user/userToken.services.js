/*
 * Copyright (c) 2017 Kagilum SAS.
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
services.factory('UserToken', ['Resource', function($resource) {
    return $resource('/user/:userId/token/:id');
}]);

services.service("UserTokenService", ['User', 'IceScrumEventType', 'UserToken', function(User, IceScrumEventType, UserToken) {
    var self = this;
    this.getCrudMethods = function(user) {
        var crudMethods = {};
        crudMethods[IceScrumEventType.CREATE] = function(token) {
            if (token.user.id === user.id) {
                var existingToken = _.find(user.tokens, {id: token.id});
                if (existingToken) {
                    angular.extend(existingToken, token);
                } else {
                    user.tokens.push(token);
                    user.tokens_count = user.tokens.length;
                }
            }
        };
        crudMethods[IceScrumEventType.UPDATE] = function(token) {
            var foundToken = _.find(user.tokens, {id: token.id});
            angular.extend(foundToken, token);
        };
        crudMethods[IceScrumEventType.DELETE] = function(token) {
            _.remove(user.tokens, {id: token.id});
            user.tokens_count = user.tokens.length;
        };
        return crudMethods;
    };
    this.save = function(token, user) {
        token.class = 'userToken';
        var userToken = new UserToken(token);
        return userToken.$save({userId: user.id}, self.getCrudMethods(user)[IceScrumEventType.CREATE]);
    };
    this['delete'] = function(userToken, user) {
        return userToken.$delete({userId:user.id, id: userToken.id}, self.getCrudMethods(user)[IceScrumEventType.DELETE]);
    };
    this.list = function(user) {
        return UserToken.query({userId: user.id}, function(data) {
            user.tokens = data;
            user.tokens_count = user.tokens.length;
        }).$promise;
    };
}]);
