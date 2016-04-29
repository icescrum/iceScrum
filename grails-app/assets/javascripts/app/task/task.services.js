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
    return $resource('task/:type/:typeId/:id/:action');
}]);

services.service("TaskService", ['$q', '$state', '$rootScope', 'Task', 'Session', 'IceScrumEventType', 'CacheService', 'PushService', 'TaskStatesByName', 'SprintStatesByName', 'StoryStatesByName', function($q, $state, $rootScope, Task, Session, IceScrumEventType, CacheService, PushService, TaskStatesByName, SprintStatesByName, StoryStatesByName) {
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
            $state.go('taskBoard');
        }
        CacheService.remove('task', task.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('task', eventType, crudMethod);
    });
    this.mergeTasks = function(tasks) {
        _.each(tasks, function(task) {
            crudMethods[IceScrumEventType.CREATE](task);
        });
    };
    this.save = function(task) {
        task.class = 'task';
        return Task.save(task, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(task, removeRank) {
        var taskData = removeRank ? _.omit(task, 'rank') : task; // Don't send the rank when we want the server to pick the right rank (e.g. update estimate to 0 => task will get a new rank in done state)
        return Task.update(taskData, crudMethods[IceScrumEventType.UPDATE]).$promise;
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
        return Task.update({id: task.id, action: 'take'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.release = function(task) {
        return Task.update({id: task.id, action: 'unassign'}, {}, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(task) {
        return Task.delete({id: task.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.copy = function(task) {
        return Task.update({id: task.id, action: 'copy'}, {}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.list = function(taskContext) {
        if (_.isEmpty(taskContext.tasks)) {
            var params = {typeId: taskContext.id, type: taskContext.class.toLowerCase()};
            if ($rootScope.app.context) {
                _.merge(params, {'context.type': $rootScope.app.context.type, 'context.id': $rootScope.app.context.id});
            }
            return Task.query(params, function(tasks) {
                if (angular.isArray(taskContext.tasks)) {
                    _.each(tasks, function(task) {
                        var existingSprint = _.find(taskContext.tasks, {id: task.id});
                        if (existingSprint) {
                            angular.extend(existingSprint, task);
                        } else {
                            taskContext.tasks.push(task);
                        }
                    });
                } else {
                    taskContext.tasks = tasks;
                }
                taskContext.tasks_count = tasks.length;
                self.mergeTasks(tasks);
            }).$promise;
        } else {
            return $q.when(taskContext.tasks);
        }
    };
    this.authorizedTask = function(action, task) {
        switch (action) {
            case 'create':
            case 'copy':
                return Session.inProduct() &&
                      (!task || !task.parentStory && task.sprint && task.sprint.state != SprintStatesByName.DONE || task.parentStory && task.parentStory.state != StoryStatesByName.DONE);
            case 'rank':
                return Session.sm() || Session.responsible(task) || Session.creator(task); // no check on sprint & story state because rank cannot be called from there
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
                return !Session.responsible(task) && task.state != TaskStatesByName.DONE;
            case 'release':
                return Session.responsible(task) && task.state != TaskStatesByName.DONE;
            default:
                return false;
        }
    };
    this.listByUser = function() {
        return Task.query({action: 'listByUser'}).$promise;
    };
}]);