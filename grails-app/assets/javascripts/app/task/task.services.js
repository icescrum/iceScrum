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
services.factory('Task', [ 'Resource', function($resource) {
    return $resource('task/:type/:typeId/:id/:action');
}]);

services.service("TaskService", ['$q', '$state', '$rootScope', 'Task', 'Session', 'IceScrumEventType', 'PushService', 'TaskStatesByName', 'SprintStatesByName', 'StoryStatesByName', 'StoryService', function($q, $state, $rootScope, Task, Session, IceScrumEventType, PushService, TaskStatesByName, SprintStatesByName, StoryStatesByName, StoryService) {
    var self = this;
    this.getCrudMethods = function(taskContext) {
        var crudMethods = {};
        crudMethods[IceScrumEventType.CREATE] = function(task) {
            if (taskContext.class == 'Story' ? task.parentStory.id == taskContext.id : task.sprint.id == taskContext.id) {
                var existingTask = _.find(taskContext.tasks, {id: task.id});
                if (existingTask) {
                    angular.extend(existingTask, task);
                } else {
                    taskContext.tasks.push(task);
                    taskContext.tasks_count = taskContext.tasks.length;
                }
            }
        };
        crudMethods[IceScrumEventType.UPDATE] = function(task) {
            angular.extend(_.find(taskContext.tasks, { id: task.id }), task);
            if(task.parentStory){
                StoryService.refresh(task.parentStory.id);
            }
        };
        crudMethods[IceScrumEventType.DELETE] = function(task) {
            if ($state.includes("taskBoard.task.details", {taskId: task.id}) ||
                ($state.includes("taskBoard.task.multiple") && _.contains($state.params.taskListId.split(','), task.id.toString()))) {
                $state.go('taskBoard');
            }
            _.remove(taskContext.tasks, { id: task.id });
            taskContext.tasks_count = taskContext.tasks.length;
        };
        return crudMethods;
    };
    this.save = function(task, taskContext) {
        task.class = 'task';
        return Task.save(task, self.getCrudMethods(taskContext)[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(task, taskContext) {
        return task.$update(self.getCrudMethods(taskContext)[IceScrumEventType.UPDATE]);
    };
    this.block = function(task, taskContext) {
        task.blocked = true;
        return self.update(task, taskContext);
    };
    this.unBlock = function(task, taskContext) {
        task.blocked = false;
        return self.update(task, taskContext);
    };
    this.take = function(task, taskContext) {
        return Task.update({id: task.id, action: 'take'}, {}, self.getCrudMethods(taskContext)[IceScrumEventType.UPDATE]).$promise;
    };
    this.release = function(task, taskContext) {
        return Task.update({id: task.id, action: 'unassign'}, {}, self.getCrudMethods(taskContext)[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(task, taskContext) {
        return task.$delete(self.getCrudMethods(taskContext)[IceScrumEventType.DELETE]);
    };
    this.copy = function(task, taskContext) {
        return Task.update({id: task.id, action: 'copy'}, {}, self.getCrudMethods(taskContext)[IceScrumEventType.CREATE]).$promise;
    };
    this.list = function(taskContext) {
        var params = {typeId: taskContext.id, type: taskContext.class.toLowerCase()};
        if ($rootScope.app.context) {
            _.merge(params, {'context.type': $rootScope.app.context.type, 'context.id': $rootScope.app.context.id});
        }
        return Task.query(params, function(data) {
            taskContext.tasks = data;
            taskContext.tasks_count = taskContext.tasks.length;
            var crudMethods = self.getCrudMethods(taskContext);
            _.each(crudMethods, function(crudMethod, eventType) {
                PushService.registerListener('task', eventType, crudMethod);
            });
        }).$promise;
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