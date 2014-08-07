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
    return $resource('task/:type/:typeId/:id/:action',
        {},
        {
            activities: {method: 'GET', isArray: true, params: {action: 'activities'}}
        });
}]);

services.service("TaskService", ['Task', function(Task) {
    this.save = function(task, obj) {
        task.class = 'task';
        if (obj.class == 'Story') {
            task.parentStory = {id: obj.id};
        } else {
            task.backlog = {id: obj.id};
        }
        return Task.save(task, function(task) {
            obj.tasks.push(task);
            obj.tasks_count = obj.tasks.length;
        }).$promise;
    };
    this['delete'] = function(task, obj) {
        return task.$delete(function() {
            _.remove(obj.tasks, { id: task.id });
            obj.tasks_count = obj.tasks.length;
        });
    };
    this.list = function(obj) {
        return Task.query({ typeId: obj.id, type: obj.class.toLowerCase() }, function(data) {
            obj.tasks = data;
        }).$promise;
    }
}]);