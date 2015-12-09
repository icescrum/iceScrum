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

services.service("TaskService", ['$q', 'Task', 'Session', 'IceScrumEventType', 'PushService', 'TaskStatesByName', 'SprintStatesByName', 'StoryStatesByName', function($q, Task, Session, IceScrumEventType, PushService, TaskStatesByName, SprintStatesByName, StoryStatesByName) {
    var self = this;
    this.getCrudMethods = function(obj) {
        var crudMethods = {};
        crudMethods[IceScrumEventType.CREATE] = function(task) {
            if (obj.class == 'Story' ? task.parentStory.id == obj.id : task.backlog.id == obj.id) {
                var existingTask = _.find(obj.tasks, {id: task.id});
                if (existingTask) {
                    angular.extend(existingTask, task);
                } else {
                    obj.tasks.push(new Task(task));
                    obj.tasks_count = obj.tasks.length;
                }
            }
        };
        crudMethods[IceScrumEventType.UPDATE] = function(task) {
            angular.extend(_.find(obj.tasks, { id: task.id }), task);
        };
        crudMethods[IceScrumEventType.DELETE] = function(task) {
            _.remove(obj.tasks, { id: task.id });
            obj.tasks_count = obj.tasks.length;
        };
        return crudMethods;
    };
    this.save = function(task, obj) {
        task.class = 'task';
        return Task.save(task, self.getCrudMethods(obj)[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(task, obj) {
        return task.$update(self.getCrudMethods(obj)[IceScrumEventType.UPDATE]);
    };
    this.block = function(task, obj) {
        task.blocked = true;
        return self.update(task, obj);
    };
    this.unBlock = function(task, obj) {
        task.blocked = false;
        return self.update(task, obj);
    };
    this.take = function(task, obj) {
        return Task.update({id: task.id, action: 'take'}, {}, self.getCrudMethods(obj)[IceScrumEventType.UPDATE]).$promise;
    };
    this.release = function(task, obj) {
        return Task.update({id: task.id, action: 'unassign'}, {}, self.getCrudMethods(obj)[IceScrumEventType.UPDATE]).$promise;
    };
    this['delete'] = function(task, obj) {
        return task.$delete(self.getCrudMethods(obj)[IceScrumEventType.DELETE]);
    };
    this.copy = function(task, obj) {
        return Task.update({id: task.id, action: 'copy'}, {}, self.getCrudMethods(obj)[IceScrumEventType.CREATE]).$promise;
    };
    this.list = function(obj) {
        if (_.isEmpty(obj.tasks)) {
            return Task.query({ typeId: obj.id, type: obj.class.toLowerCase() }, function(data) {
                obj.tasks = data;
                obj.tasks_count = obj.tasks.length;
                var crudMethods = self.getCrudMethods(obj);
                _.each(crudMethods, function(crudMethod, eventType) {
                    PushService.registerListener('task', eventType, crudMethod);
                });
            }).$promise;
        } else {
            return $q.when(obj.tasks);
        }
    };
    this.authorizedTask = function(action, task) {
        switch (action) {
            case 'create':
            case 'copy':
                return Session.inProduct() && (!task || !task.parentStory || task.parentStory.state != StoryStatesByName.DONE);
            case 'rank':
                return Session.sm() || Session.responsible(task) || Session.creator(task) && task.backlog.state == SprintStatesByName.IN_PROGRESS;
            case 'update':
                return (Session.sm() || Session.responsible(task) || Session.creator(task)) && task.state != TaskStatesByName.DONE;
            case 'delete':
                return (Session.sm() || Session.responsible(task) || Session.creator(task));
            case 'block':
                return !task.blocked && (Session.sm() || Session.responsible(task)) && task.state != TaskStatesByName.DONE && task.backlog.state == SprintStatesByName.IN_PROGRESS;
            case 'unBlock':
                return task.blocked && (Session.sm() || Session.responsible(task)) && task.state != TaskStatesByName.DONE && task.backlog.state == SprintStatesByName.IN_PROGRESS;
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