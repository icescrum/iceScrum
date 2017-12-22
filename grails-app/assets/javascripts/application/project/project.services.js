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
services.factory('Project', ['Resource', function($resource) {
    return $resource('/project/:id/:action',
        {id: '@id'},
        {
            listByUserAndRole: {
                url: '/project/user/:userId/:role',
                isArray: true,
                method: 'get'
            },
            listByPortfolio: {
                url: '/project/portfolio/:portfolioId',
                isArray: true,
                method: 'get'
            }
        });
}]);

services.service("ProjectService", ['Project', 'Session', 'FormService', 'CacheService', 'IceScrumEventType', 'PushService', '$rootScope', '$q', function(Project, Session, FormService, CacheService, IceScrumEventType, PushService, $rootScope, $q) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(project) {
        CacheService.addOrUpdate('project', project);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(project) {
        if (Session.workspaceType == 'project') {
            var workspace = Session.getWorkspace();
            if (workspace.id == project.id) {
                if (project.pkey != workspace.pkey) {
                    $rootScope.notifyWarning('todo.is.ui.project.updated.pkey');
                    document.location = document.location.href.replace(workspace.pkey, project.pkey);
                } else if (project.preferences.hidden && !workspace.preferences.hidden && !Session.inProject()) {
                    $rootScope.notifyWarning('todo.is.ui.project.updated.visibility');
                    Session.reload();
                } else if (project.preferences.archived != workspace.preferences.archived) {
                    $rootScope.notifyWarning('todo.is.ui.project.updated.' + (project.preferences.archived ? 'archived' : 'unarchived'));
                    Session.reload();
                }
            }
        }
        CacheService.addOrUpdate('project', project);
    };
    crudMethods[IceScrumEventType.DELETE] = function(project) {
        if (Session.workspaceType == 'project') {
            var workspace = Session.getWorkspace();
            if (workspace.id == project.id) {
                $rootScope.notifyWarning('todo.is.ui.project.deleted');
                document.location = $rootScope.serverUrl;
            }
        }
        CacheService.remove('project', project.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('project', eventType, crudMethod);
    });
    this.get = function(id) {
        var cachedProject = CacheService.get('project', id);
        return cachedProject ? $q.when(cachedProject) : self.refresh(id);
    };
    this.refresh = function(id) {
        return Project.get({id: id}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.save = function(project) {
        project.class = 'project';
        return Project.save(project, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.updateTeam = function(project) {
        // Wrap the project inside a "projectd" because by default the formObjectData function will turn it into a "project" object
        // The "project" object conflicts with the "project" attribute expected by a filter which expects it to be either a number (id) or string (pkey)
        return Project.update({id: project.id, action: 'updateTeam'}, {projectd: project}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.update = function(project) {
        return Project.update({id: project.id}, {projectd: project}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.leaveTeam = function(project) {
        return Project.update({id: project.id, action: 'leaveTeam'}, {}).$promise;
    };
    this.archive = function(project) {
        return Project.update({id: project.id, action: 'archive'}, {}).$promise;
    };
    this.unArchive = function(project) {
        return Project.update({id: project.id, action: 'unArchive'}, {}).$promise;
    };
    this['delete'] = function(project) {
        return Project.delete({id: project.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.mergeProjects = function(projects) {
        _.each(projects, crudMethods[IceScrumEventType.CREATE]);
    };
    this.list = function(params) {
        if (!params) {
            params = {};
        }
        params.paginate = true;
        return Project.get(params, function(data) {
            self.mergeProjects(data.projects);
        }).$promise;
    };
    this.listPublic = function(params) {
        if (!params) {
            params = {};
        }
        params.action = 'listPublic';
        params.paginate = true;
        params.paginate = true;
        return Project.get(params, function(data) {
            self.mergeProjects(data.projects)
        }).$promise;
    };
    this.listPublicWidget = function() {
        return Project.query({action: 'listPublicWidget'}, self.mergeProjects).$promise;
    };
    this.listByUser = function(params) {
        if (!params) {
            params = {};
        }
        params.action = 'user';
        params.paginate = true;
        params.paginate = true;
        return Project.get(params, function(data) {
            if (!params.light) {
                self.mergeProjects(data.projects);
            }
        }).$promise;
    };
    this.listByUserAndRole = function(userId, role, params) {
        if (!params) {
            params = {};
        }
        params.userId = userId;
        params.role = role;
        return Project.listByUserAndRole(params, function(data) {
            if (!params.light) {
                self.mergeProjects(data.projects);
            }
        }).$promise;
    };
    this.listByPortfolio = function(portfolioId) {
        return Project.listByPortfolio({portfolioId: portfolioId}, function(projects) {
            self.mergeProjects(projects);
        }).$promise
    };
    this.getActivities = function(project) {
        return FormService.httpGet('project/' + project.id + '/activities', null, true);
    };
    this.openChart = function(project, chart) {
        return FormService.httpGet('project/' + project.id + '/' + chart, null, true);
    };
    this.authorizedProject = function(action, project) {
        switch (action) {
            case 'unArchive':
                return Session.admin();
            case 'upload':
                return Session.poOrSm();
            case 'update':
            case 'updateProjectMembers':
                return Session.sm();
            case 'delete':
                return Session.owner(project);
            case 'edit':
                return Session.authenticated();
            default:
                return false;
        }
    };
    this.getVersions = function() {
        return FormService.httpGet('project/versions');
    };
    this.getTags = function() {
        return FormService.httpGet('search/tag');
    };
    this.countMembers = function(project) { // Requires the team to be loaded !
        return _.union(_.map(project.team.scrumMasters, 'id'), _.map(project.team.members, 'id'), _.map(project.productOwners, 'id')).length;
    };
}]);
