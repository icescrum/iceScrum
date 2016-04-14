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
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

var services = angular.module('services', ['restResource']);

services.factory('AuthService', ['$http', '$rootScope', 'FormService', function($http, $rootScope, FormService) {
    return {
        login: function(credentials) {
            return $http.post($rootScope.serverUrl + '/j_spring_security_check', credentials, {
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: function(data) {
                    return angular.isObject(data) && String(data) !== '[object File]' ? FormService.formObjectData(data) : data;
                }
            }).then(function(response) {
                return response.data;
            });
        }
    };
}])
.service('Session', ['$timeout', '$http', '$rootScope', '$q', 'UserService', 'USER_ROLES', 'User', 'Project', 'PushService', 'IceScrumEventType', 'FormService', function($timeout, $http, $rootScope, $q, UserService, USER_ROLES, User, Project, PushService, IceScrumEventType, FormService) {
    var self = this;
    self.user = new User();
    self.project = new Project();
    self.isProjectResolved = $q.defer();
    self.unreadActivitiesCount = 0;
    var defaultRoles = {
        productOwner: false,
        scrumMaster: false,
        teamMember: false,
        stakeHolder: false,
        admin: false
    };
    self.roles = _.clone(defaultRoles);
    var reload = function() {
        $timeout(function() {
            document.location.reload(true);
        }, 2000);
    };
    this.create = function() {
        return UserService.getCurrent()
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
    this.setUser = function(user) {
        _.extend(self.user, user);
        PushService.registerListener('activity', IceScrumEventType.CREATE, function() {
            self.unreadActivitiesCount += 1;
        });
        PushService.registerListener('user', IceScrumEventType.UPDATE, function(user) {
            if (user.updatedRole) {
                var updatedRole = user.updatedRole;
                var updatedProject = updatedRole.product;
                if (updatedRole.role == undefined) {
                    $rootScope.notifyWarning($rootScope.message('is.user.role.removed.product') + ' ' + updatedProject.name);
                    if (updatedProject.id == self.project.id) {
                        $timeout(function() {
                            document.location = $rootScope.serverUrl
                        }, 2000);
                    }
                } else if (updatedRole.oldRole == undefined) {
                    $rootScope.notifySuccess($rootScope.message('is.user.role.added.product') + ' ' + updatedProject.name);
                    if (updatedProject.id == self.project.id) {
                        reload();
                    }
                } else {
                    $rootScope.notifySuccess($rootScope.message('is.user.role.updated.product') + ' ' + updatedProject.name);
                    if (updatedProject.id == self.project.id) {
                        reload();
                    }
                }
            }
        });
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
    this.admin = function() {
        return self.roles.admin;
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
        return this.authenticated && !_.isEmpty(item) && !_.isEmpty(item.creator) && self.user.id == item.creator.id;
    };
    this.responsible = function(item) {
        return this.authenticated && !_.isEmpty(item) && !_.isEmpty(item.responsible) && self.user.id == item.responsible.id;
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
    this.initProject = function(project) {
        _.extend(self.project, project);
        self.isProjectResolved.resolve();
        PushService.registerListener('product', IceScrumEventType.UPDATE, function(updatedProject) {
            if (updatedProject.pkey != self.project.pkey) {
                $rootScope.notifyWarning('todo.is.ui.project.updated.pkey');
                document.location = document.location.href.replace(self.project.pkey, updatedProject.pkey);
            } else if (updatedProject.preferences.hidden && !self.project.preferences.hidden && !self.inProduct()) {
                $rootScope.notifyWarning('todo.is.ui.project.updated.visibility');
                reload();
            } else if (updatedProject.preferences.archived != self.project.preferences.archived) {
                if (updatedProject.preferences.archived == true) {
                    $rootScope.notifyWarning('todo.is.ui.project.updated.archived');
                } else {
                    $rootScope.notifyWarning('todo.is.ui.project.updated.unarchived');
                }
                reload();
            } else {
                self.updateProject(updatedProject);
            }
        });
        PushService.registerListener('product', IceScrumEventType.DELETE, function() {
            $rootScope.notifyWarning('todo.is.ui.project.deleted');
            reload();
        });
    };
    this.updateProject = function(project) {
        _.extend(self.project, project);
    };
    this.getProject = function() {
        return self.project;
    };
    this.getProjectPromise = function() {
        return self.isProjectResolved.promise.then(function() {
            return self.project;
        });
    };
    this.getLanguages = function() {
        return FormService.httpGet('scrumOS/languages', { cache: true });
    };
    this.getTimezones = function() {
        return FormService.httpGet('scrumOS/timezones', { cache: true });
    };
}])
.service('FormService', ['$filter', '$http', '$rootScope', function($filter, $http, $rootScope) {
    var self = this;
    this.previous = function(list, element) {
        var ind = _.findIndex(list, { id: element.id });
        return ind > 0 ? list[ind - 1] : null;
    };
    this.next = function(list, element) {
        var ind = _.findIndex(list, { id: element.id });
        return ind + 1 <= list.length ? list[ind + 1] : null;
    };
    this.formObjectData = function(obj, prefix) {
        var query = '', name, value, fullSubName, subName, subValue, innerObj, i, _prefix;
        _prefix = prefix ? prefix : (obj['class'] ? obj['class'] + '.' : '');
        _prefix = _.lowerFirst(_prefix);
        for (name in obj) {
            value = obj[name];
            if (value instanceof Array && !_.endsWith(name, '_ids')) {
                for (i = 0; i < value.length; ++i) {
                    subValue = value[i];
                    innerObj = {};
                    innerObj[name] = subValue;
                    query += self.formObjectData(innerObj, _prefix) + '&';
                }
            } else if (value instanceof Date) {
                var encodedDate = $filter('dateToIso')(value);
                query += encodeURIComponent(_prefix + name) + '=' + encodeURIComponent(encodedDate) + '&';
            } else if (value instanceof Object) {
                for (subName in value) {
                    if (subName != 'class' && !_.startsWith(subName, '$')) {
                        subValue = value[subName];
                        fullSubName = name + '.' + subName;
                        innerObj = {};
                        innerObj[fullSubName] = subValue;
                        query += self.formObjectData(innerObj, _prefix) + '&';
                    }
                }
            } else if (value === undefined) {
                query += encodeURIComponent(_prefix + name) + '=null&'; // HACK: an undefined property (e.g. select cleared makes the model undefined) set the null value in Grails data binding
            } else if (value !== null
                    //no class info needed
                && !_.includes(['class', 'uid', 'lastUpdated', 'dateCreated'], name)
                    //no angular object
                && !_.startsWith(name, '$')
                    //no custom count / html values
                && !_.endsWith(name, '_count') && !_.endsWith(name, '_html')) {
                query += encodeURIComponent(_prefix + name) + '=' + encodeURIComponent(value) + '&';
            }
        }
        return query.length ? query.substr(0, query.length - 1) : query;
    };
    this.httpGet = function(path, params, isAbsolute) {
        var fullPath = isAbsolute ? $rootScope.serverUrl + '/' + path : path;
        var paramObj = params || {};
        return $http.get(fullPath, paramObj).then(function(response) {
            return response.data;
        });
    };
    this.addStateChangeDirtyFormListener = function($scope, type, isModal) {
        var triggerConfirmModal = function(event, confirmCallback) {
            event.preventDefault(); // cancel the state change
            $scope.mustConfirmStateChange = false;
            $scope.confirm({
                message: $scope.message('todo.is.ui.dirty.confirm'),
                condition: $scope.isDirty() || ($scope.flow != undefined && $scope.flow.isUploading()),
                callback: function() {
                    if ($scope.flow != undefined && $scope.flow.isUploading()) {
                        $scope.flow.cancel();
                    }
                    confirmCallback();
                },
                closeCallback: function() {
                    $scope.app.loading = false;
                    $scope.mustConfirmStateChange = true;
                }
            });
        };
        $scope.mustConfirmStateChange = true; // to prevent infinite recursion when calling $stage.go
        $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
            if ($scope.mustConfirmStateChange && fromParams[type + 'Id'] != toParams[type + 'Id']) {
                triggerConfirmModal(event, function() {
                    $scope.$state.go(toState, toParams);
                });
            }
        });
        if (isModal) {
            $scope.$on('modal.closing', function(event) {
                if ($scope.mustConfirmStateChange) {
                    triggerConfirmModal(event, function() {
                        $scope.$close();
                    });
                }
            });
        }
    };
}])
.service('BundleService', [function() {
    this.bundles = {};
    this.initBundles = function(bundles) {
        this.bundles = bundles;
    };
    this.getBundle = function(bundleName) {
        return this.bundles[bundleName];
    }
}])
.service('CacheService', ['$injector', function($injector) {
    var self = this;
    var caches = {};
    this.getCache = function(cacheName) {
        if (!_.isString(cacheName)) {
           throw Error("This cache name is not a string: " + cacheName);
        }
        if (!_.isArray(caches[cacheName])) {
            caches[cacheName] = [];
        }
        return caches[cacheName];
    };
    this.emptyCache = function(cacheName) {
        var cache = self.getCache(cacheName);
        cache.splice(0, cache.length);
    };
    this.addOrUpdate = function(cacheName, item) {
        var cachedItem = self.get(cacheName, item.id);
        $injector.get('SyncService').sync(cacheName, cachedItem, item);
        if (cachedItem) {
            _.merge(cachedItem, item);
        } else {
            self.getCache(cacheName).push(item);
        }
    };
    this.get = function(cacheName, id) {
        return _.find(self.getCache(cacheName), {id: parseInt(id)});
    };
    this.remove = function(cacheName, id) {
        var cachedItem = self.get(cacheName, id);
        $injector.get('SyncService').sync(cacheName, cachedItem, null);
        _.remove(self.getCache(cacheName), {id: parseInt(id)});
    };
}]).service('SyncService', ['$q', 'CacheService', 'Session', 'StoryService', 'ReleaseService', 'SprintService', function($q, CacheService, Session, StoryService, ReleaseService, SprintService) {
    var syncFunctions = {
        story: function(oldStory, newStory) {
            var oldSprint = (oldStory && oldStory.parentSprint) ? oldStory.parentSprint.id : null;
            var newSprint = (newStory && newStory.parentSprint) ? newStory.parentSprint.id : null;
            if (Session.getProject().releases && (oldSprint || newSprint)) { // No need to do anything if releases are not loaded or no parent sprint
                if (oldSprint != newSprint || oldStory.effort != newStory.effort || oldStory.state != newStory.state) {
                    ReleaseService.list(Session.getProject()).then(function(releases) { // Refreshes all the releases & sprints, which is probably overkill
                        $q.all(_.map(releases, SprintService.list)).then(function(sprintsGroupedByRelease) {
                            _.each(_.filter(_.flatten(sprintsGroupedByRelease), function(sprint) {
                                return sprint.id == oldSprint || sprint.id == newSprint;
                            }), self.listByType);
                        });
                    });
                }
            }
        },
        task: function(oldTask, newTask) {
            var oldStory = (oldTask && oldTask.parentStory) ? oldTask.parentStory.id : null;
            var newStory = (newTask && newTask.parentStory) ? newTask.parentStory.id : null;
            if (newStory) {
                StoryService.refresh(newStory);
            }
            if (oldStory) {
                StoryService.refresh(oldStory);
            }
        },
        feature: function(oldFeature, newFeature) {
            _.each(CacheService.getCache('story'), function(story) {
                var featureId = newFeature ? newFeature.id : oldFeature.id;
                if (story.feature && story.feature.id == featureId) {
                    story.feature = newFeature;
                }
            });
        }
    };
    this.sync = function(clazz, oldItem, newItem) {
        syncFunctions[clazz](oldItem, newItem);
    }
}]);

var restResource = angular.module('restResource', ['ngResource']);
restResource.factory('Resource', ['$resource', 'FormService', function($resource, FormService) {
    return function(url, params, methods) {
        var defaultParams = {
            id: '@id'
        };
        var transformStringToDate = function(item) {
            if (item.hasOwnProperty('startDate')) {
                item.startDate = new Date(item.startDate);
            }
            if (item.hasOwnProperty('endDate')) {
                item.endDate = new Date(item.endDate);
            }
        };
        var arrayInterceptor = {
            response: function(response) {
                _.each(response.resource, transformStringToDate);
                return response.resource;
            }
        };
        var singleInterceptor = {
            response: function(response) {
                transformStringToDate(response.resource);
                return response.resource;
            }
        };
        var transformRequest = function(data) {
            return angular.isObject(data) && String(data) !== '[object File]' ? FormService.formObjectData(data) : data;
        };
        var transformQueryParams = function(resolve) { // Magical hack found here: http://stackoverflow.com/questions/24082468/how-to-intercept-resource-requests
            var originalParamSerializer = this.paramSerializer;
            this.paramSerializer = function(params) {
                var isDeepObject = _.isObject(params) && _.some(_.values(params), _.isObject);
                return isDeepObject ? FormService.formObjectData(params) : originalParamSerializer(params);
            };
            this.then = null;
            resolve(this);
        };
        var defaultMethods = {
            save: {
                method: 'post',
                isArray: false,
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: transformRequest,
                interceptor: singleInterceptor
            },
            updateArray: {
                method: 'post',
                isArray: true,
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                transformRequest: transformRequest,
                interceptor: arrayInterceptor
            },
            get: {
                method: 'get',
                interceptor: singleInterceptor,
                then: transformQueryParams
            },
            query: {
                method: 'get',
                isArray: true,
                interceptor: arrayInterceptor,
                then: transformQueryParams
            },
            deleteArray: {
                method: 'delete',
                isArray: true
            }
        };
        defaultMethods.update = angular.copy(defaultMethods.save); // for the moment there is no difference between save & update
        return $resource(url, angular.extend(defaultParams, params), angular.extend(defaultMethods, methods));
    };
}]);