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
}]).service('Session',['$q','User', 'USER_ROLES', function ($q, User, USER_ROLES) {
    var self = this;
    self.user = {};
    var defaultRoles = {
        productOwner: false,
        scrumMaster: false,
        teamMember: false,
        stakeHolder: false
    };
    self.roles = _.clone(defaultRoles);
    this.destroy = function () {
        _.merge(self.roles, defaultRoles);
        // TODO WARNING this removes the binding, not a problem for the moment because the logout is followed by a refresh
        // If we want to keep the window active we will need to remove the properties and keep the object reference
        // Or maybe there is another way to preserve the binding while changing the reference...
        self.user = {};
    };
    this.create = function (){
        User.current().$promise.then(function(data) {
            _.extend(self.user, data.user);
            _.merge(self.roles, data.roles);
        });
    };
    this.poOrSm = function() {
        return self.roles.productOwner || self.roles.scrumMaster;
    };
    this.creator = function(item) {
        return self.user.id == item.creator.id;
    };
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
        simple_tags: true,
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
                method: 'put',
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
    _prefix = toLowerCaseFirstLetter(_prefix);

    // TODO consider making it available at top level or replacing it
    // Custom functions because the real ones aren't available yet (apart from firefox)
    function startsWith(str, start) {
        return str.lastIndexOf(start, 0) === 0
    }
    function endsWith(str, end) {
        return str.indexOf(end, str.length - end.length) !== -1;
    }
    function toLowerCaseFirstLetter(str) {
        return str.charAt(0).toLowerCase() + str.substring(1);
    }

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
            && !startsWith(name, '$')
            //no custom count / html values
            && !endsWith(name, '_count') && !endsWith(name, '_html')) {
            query += encodeURIComponent(_prefix + name) + '=' + encodeURIComponent(value) + '&';
        }
    }

    return query.length ? query.substr(0, query.length - 1) : query;
};