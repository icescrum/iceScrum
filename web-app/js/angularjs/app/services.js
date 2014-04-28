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
 *
 */

var services = angular.module('services', [ 'restResource' ]);

services.factory('AuthService',['$http', 'Session', '$state', function ($http, Session) {
    return {
        login: function (credentials) {
            return $http
                .post('j_spring_security_check', credentials, {
                    headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                    transformRequest: function (data) {
                        return angular.isObject(data) && String(data) !== '[object File]' ? formObjectData(data) : data;
                    }
                })
                .then(function () {
                    Session.create();
                });
        }
    };
}]).service('Session',['$q','User', function ($q, User) {
    var self = this;
    self.user = {};
    self.authenticated = false;
    self.roles = {};

    this.destroy = function () {
        self.user = {};
        self.authenticated = false;
        self.roles = {};
    };

    this.create = function (){
        User.current().$promise.then(function(data){
            self.user = data.user;
            self.roles = data.roles;
            self.authenticated = self.user ? true : false;
        })
    };
}]);

//extend default resource to be more RESTFul compliant
var restResource = angular.module('restResource', [ 'ngResource' ]);
restResource.factory('Resource', [ '$resource', function ($resource) {
    return function (url, params, methods) {
        var defaults = {
            save: {
                method: 'post',
                isArray: false,
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: function (data) {
                    return angular.isObject(data) && String(data) !== '[object File]' ? formObjectData(data) : data;
                }
            },
            update: {
                method: 'post',
                isArray: false,
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: function (data) {
                    return angular.isObject(data) && String(data) !== '[object File]' ? formObjectData(data) : data;
                }
            },
            create: { method: 'post' }
        };

        methods = angular.extend(defaults, methods);

        var resource = $resource(url, params, methods);

        resource.prototype.$save = function () {
            if (!this.id) {
                return this.$create();
            }
            else {
                return this.$update();
            }
        };

        return resource;
    };
}]);

var formObjectData = function (obj, prefix) {
    var query = '', name, value, fullSubName, subName, subValue, innerObj, i, _prefix;
    _prefix = prefix ? prefix : (obj['class'] ? obj['class'] + '.' : '');
    _prefix = _prefix.toLowerCase();

    for (name in obj) {
        value = obj[name];
        if (value instanceof Array) {
            for (i = 0; i < value.length; ++i) {
                subValue = value[i];
                fullSubName = name + '[' + i + ']';
                innerObj = {};
                innerObj[fullSubName] = subValue;
                query += formObjectData(innerObj, _prefix) + '&';
            }
        }
        else if (value instanceof Object) {
            for (subName in value) {
                if (subName != 'class' && !subName.startsWith('$')) {
                    subValue = value[subName];
                    fullSubName = name + '.' + subName;
                    innerObj = {};
                    innerObj[fullSubName] = subValue;
                    query += formObjectData(innerObj, _prefix) + '&';
                }
            }
        }
        else if (value !== undefined
            && value !== null
            //no class info needed
            && !_.contains(['class', 'uid', 'lastUpdated', 'dateCreated'], name)
            //no angular object
            && !name.startsWith('$')
            //no custom count / html values
            && !name.endsWith('_count') && !name.endsWith('_html'))
            query += encodeURIComponent(_prefix + name) + '=' + encodeURIComponent(value) + '&';
    }

    return query.length ? query.substr(0, query.length - 1) : query;
};