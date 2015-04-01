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

var services = angular.module('services', [ 'restResource' ]);

services.factory('AuthService',['$http', '$rootScope', 'Session', function ($http, $rootScope, Session) {
    return {
        login: function (credentials) {
            return $http.post($rootScope.serverUrl + '/j_spring_security_check', credentials, {
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: function (data) {
                    return angular.isObject(data) && String(data) !== '[object File]' ? formObjectData(data) : data;
                }
            })
        }
    };
}]).service('Session',['UserService', 'USER_ROLES', 'User', 'Project', function (UserService, USER_ROLES, User, Project) {
    var self = this;
    self.user = new User();
    self.project = new Project();
    self.unreadActivitiesCount = 0;

    var defaultRoles = {
        productOwner: false,
        scrumMaster: false,
        teamMember: false,
        stakeHolder: false
    };
    self.roles = _.clone(defaultRoles);

    this.create = function() {
        UserService.getCurrent()
            .then(function(data) {
                if (data.user != "null") {
                    _.extend(self.user, data.user);
                    _.merge(self.roles, data.roles);
                    UserService.getUnreadActivities(self.user)
                        .then(function(data) {
                            self.unreadActivitiesCount = data.unreadActivitiesCount;
                        });
                }
            });
    };

    this.setUser = function(user){
        _.extend(self.user, user);
    };

    this.poOrSm = function() {
        return self.roles.productOwner || self.roles.scrumMaster;
    };
    this.po = function() {
        return self.roles.productOwner;
    };
    this.sm = function() {
        return self.roles.scrumMaster;
    };
    this.authenticated = function() {
        return !_.isEmpty(self.user);
    };
    this.inProduct = function() {
        return self.roles.productOwner || self.roles.scrumMaster || self.roles.teamMember;
    };
    this.tmOrSm = function() {
        return self.roles.scrumMaster || self.roles.teamMember;
    };
    this.creator = function(item) {
        return this.authenticated  && !_.isEmpty(item) && !_.isEmpty(item.creator) && self.user.id == item.creator.id;
    };
    this.owner = function(item) {
        return !_.isEmpty(item) && !_.isEmpty(item.owner) && self.user.id == item.owner.id;
    };
    // TODO remove, user role change for dev only
    this.changeRole = function(newUserRole) {
        var newRoles = {};
        switch (newUserRole) {
            case USER_ROLES.PO_SM:
                newRoles.productOwner = true;
                newRoles.scrumMaster = true;
                break;
            case USER_ROLES.PO:
                newRoles.productOwner = true;
                break;
            case USER_ROLES.SM:
                newRoles.scrumMaster = true;
                break;
            case USER_ROLES.TM:
                newRoles.teamMember = true;
                break;
        }
        newRoles.stakeHolder = true;
        _.merge(self.roles, defaultRoles, newRoles);
    };

    this.setProject = function(project){
        _.extend(self.project, project);
    };

    this.getProject = function(){
        return self.project;
    };

}]).service('FormService', [function() {
    this.previous = function (list, element) {
        var ind = list.indexOf(element);
        return ind > 0 ? list[ind - 1] : null;
    };
    this.next = function (list, element) {
        var ind = list.indexOf(element);
        return ind + 1 <= list.length ? list[ind + 1] : null;
    };
    this.selectTagsOptions = {
        tags: [],
        multiple: true,
        array_tags: true,
        tokenSeparators: [",", " "],
        createSearchChoice: function (term) {
            return { id: term, text: term };
        },
        formatSelection: function (object) {
            return '<a href="#finder/?tag=' + object.text + '" onclick="document.location=this.href;"> <i class="fa fa-tag"></i> ' + object.text + '</a>';
        },
        ajax: {
            url: 'finder/tag',
            cache: 'true',
            data: function (term) {
                return {term: term};
            },
            results: function (data) {
                var results = [];
                angular.forEach(data, function (result) {
                    results.push({id: result, text: result});
                });
                return {results: results};
            }
        }
    };
}]);

var restResource = angular.module('restResource', [ 'ngResource' ]);
restResource.factory('Resource', ['$resource', function ($resource) {
    return function (url, params, methods) {
        var defaultParams = {
            id: '@id'
        };
        var defaultMethods = {
            save: {
                method: 'post',
                isArray: false,
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: function (data) {
                    return angular.isObject(data) && String(data) !== '[object File]' ? formObjectData(data) : data;
                }
            },
            query: {
                method: 'get',
                isArray: true,
                cache: true
            }
        };
        defaultMethods.update = angular.copy(defaultMethods.save); // for the moment there is no difference between save & update
        var updateArrayOptions = angular.copy(defaultMethods.save);
        updateArrayOptions.isArray = true;
        defaultMethods.updateArray = updateArrayOptions;
        return $resource(url, angular.extend(defaultParams, params), angular.extend(defaultMethods, methods));
    };
}]);

var formObjectData = function (obj, prefix) {
    var query = '', name, value, fullSubName, subName, subValue, innerObj, i, _prefix;
    _prefix = prefix ? prefix : (obj['class'] ? obj['class'] + '.' : '');

    function decapitalize(str) {
        return str.charAt(0).toLowerCase() + str.substring(1);
    }
    _prefix = decapitalize(_prefix);

    for (name in obj) {
        value = obj[name];
        if (value instanceof Array && !_.endsWith(name, '_ids')) {
            for (i = 0; i < value.length; ++i) {
                subValue = value[i];
                innerObj = {};
                innerObj[name] = subValue;
                query += formObjectData(innerObj, _prefix) + '&';
            }
        }
        else if (value instanceof Object) {
            for (subName in value) {
                if (subName != 'class' && !_.startsWith(subName, '$')) {
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
            && !_.startsWith(name, '$')
            //no custom count / html values
            && !_.endsWith(name, '_count') && !_.endsWith(name, '_html')) {
            query += encodeURIComponent(_prefix + name) + '=' + encodeURIComponent(value) + '&';
        }
    }

    return query.length ? query.substr(0, query.length - 1) : query;
};