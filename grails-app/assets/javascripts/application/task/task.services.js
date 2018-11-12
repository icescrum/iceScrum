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
services.factory('Task', ['Resource', function($resource) {
        return $resource('/p/:projectId/task/:type/:typeId/:id/:action',
            {id: '@id'},
            {
                listByUser: {
                    url: '/task/listByUser',
                    isArray: true,
                    params: {},
                    method: 'get'
                }
            })
    }]
);

services.service("TaskService", ['$q', '$state', '$rootScope', 'Task', 'Session', 'IceScrumEventType', 'CacheService', 'PushService', 'StoryService', 'FormService', 'TaskStatesByName', 'SprintStatesByName', 'StoryStatesByName', function($q, $state, $rootScope, Task, Session, IceScrumEventType, CacheService, PushService, StoryService, FormService, TaskStatesByName, SprintStatesByName, StoryStatesByName) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(task) {
        CacheService.addOrUpdate('task', task);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(task) {
        CacheService.addOrUpdate('task', task);
    };
    crudMethods[IceScrumEventType.DELETE] = function(task) {
        if ($state.includes("taskBoard.task.details", {taskId: task.id}) ||
            ($state.includes("taskBoard.task.multiple") && _.includes($state.params.taskListId.split(','), task.id.toString()))) {
            $state.go('taskBoard', {}, {location: 'replace'});
        }
        CacheService.remove('task', task.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('task', eventType, crudMethod);
    });
    this.mergeTasks = function(tasks) {
        _.each(tasks, crudMethods[IceScrumEventType.UPDATE]);
    };
    this.save = function(task, projectId) {
        task.class = 'task';
        return Task.save({projectId: projectId}, task, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(task, removeRank) {
        _.each(['estimation', 'spent'], function(property) {
            if (task.hasOwnProperty(property) && task[property] === null) {
                task[property] = '?';
            }
        });
        var taskData = removeRank ? _.omit(task, 'rank') : task; // Don't send the rank when we want the server to pick the right rank (e.g. update estimate to 0 => task will get a new rank in done state)
        return Task.update({projectId: task.parentProject.id}, taskData, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.block = function(task) {
        task.blocked = true;
        return self.update(task);
    };
    this.unBlock = function(task) {
        task.blocked = false;
        return self.update(task);
    };
    this.take = function(task) {
        return Task.update({projectId: task.parentProject.id, id: task.id, action: 'take'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.release = function(task) {
        return Task.update({projectId: task.parentProject.id, id: task.id, action: 'unassign'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(task) {
        return Task.delete({projectId: task.parentProject.id}, {id: task.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.makeStory = function(task) {
        return Task.update({projectId: task.parentProject.id, id: task.id, action: 'makeStory'}, {}, function() {
            crudMethods[IceScrumEventType.DELETE](task);
        }).$promise;
    };
    this.copy = function(task) {
        return Task.update({projectId: task.parentProject.id, id: task.id, action: 'copy'}, {}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.updateState = function(task, state) {
        var editableTask = angular.copy(task);
        editableTask.state = state;
        return self.update(editableTask, true);
    };
    this.list = function(obj, projectId) {
        if (!_.isArray(obj.tasks)) {
            obj.tasks = [];
        }
        var params = {projectId: projectId, typeId: obj.id, type: obj.class.toLowerCase()};
        if ($rootScope.application.context) {
            _.merge(params, {'context.type': $rootScope.application.context.type, 'context.id': $rootScope.application.context.id});
        }
        var promise = Task.query(params, function(tasks) {
            self.mergeTasks(tasks);
            _.each(tasks, function(task) {
                if (!_.find(obj.tasks, {id: task.id})) {
                    obj.tasks.push(CacheService.get('task', task.id));
                }
            });
            obj.tasks_count = tasks.length;
        }).$promise;
        return obj.tasks.length === 0 ? promise : $q.when(obj.tasks);
    };
    this.get = function(id, taskContext, projectId) {
        return self.list(taskContext, projectId).then(function(tasks) {
            return _.find(tasks, {id: id});
        });
    };
    this.authorizedTask = function(action, task) {
        switch (action) {
            case 'create':
            case 'copy':
                return Session.inProject() &&
                       (!task || !task.parentStory && task.sprint && task.sprint.state != SprintStatesByName.DONE || task.parentStory && task.parentStory.state != StoryStatesByName.DONE);
            case 'rank':
                return Session.sm() ||
                       Session.responsible(task) ||
                       Session.creator(task) ||
                       !task.responsible && Session.inProject() && $rootScope.getProjectFromState() && $rootScope.getProjectFromState().preferences.assignOnBeginTask && task.state == TaskStatesByName.TODO; // No check on sprint & story state because rank cannot be called from there
            case 'upload':
            case 'update':
                return (Session.sm() || Session.responsible(task) || Session.creator(task)) && task.state != TaskStatesByName.DONE;
            case 'delete':
                return (Session.sm() || Session.responsible(task) || Session.creator(task)) && (!task.sprint || task.sprint.state != SprintStatesByName.DONE);
            case 'block':
                return !task.blocked && (Session.sm() || Session.responsible(task)) && task.state != TaskStatesByName.DONE && task.sprint && task.sprint.state == SprintStatesByName.IN_PROGRESS;
            case 'unBlock':
                return task.blocked && (Session.sm() || Session.responsible(task)) && task.state != TaskStatesByName.DONE;
            case 'take':
                return !Session.responsible(task) && task.state != TaskStatesByName.DONE && task.sprint;
            case 'release':
                return Session.responsible(task) && task.state != TaskStatesByName.DONE;
            case 'setResponsible':
                return Session.sm();
            case 'showUrgent':
                return $rootScope.getProjectFromState() && $rootScope.getProjectFromState().preferences.displayUrgentTasks;
            case 'showRecurrent':
                return $rootScope.getProjectFromState() && $rootScope.getProjectFromState().preferences.displayRecurrentTasks;
            case 'makeStory':
                return self.authorizedTask('delete', task) && task.state != TaskStatesByName.DONE && StoryService.authorizedStory('create');
            case 'updateState':
                return self.authorizedTask('rank', task) && task.sprint && task.sprint.state == SprintStatesByName.IN_PROGRESS && (!task.parentStory || task.parentStory.state >= StoryStatesByName.IN_PROGRESS && task.parentStory.state < StoryStatesByName.DONE);
            default:
                return false;
        }
    };
    this.listByUser = function() {
        return Task.listByUser(function(data) {
            _.each(data, function(dataByProject) {
                self.mergeTasks(dataByProject.tasks);
            });
        }).$promise;
    };
    this.getMostUsedColors = function() {
        return FormService.httpGet('task/colors');
    };
}]);
