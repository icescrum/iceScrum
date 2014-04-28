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
services.factory( 'Task', [ 'Resource', function( $resource ) {
    return $resource( 'task/:type/:typeId/:id/:action',
        { id: '@id' } ,
        {
            query:           {method:'GET', isArray:true, cache: true},
            activities:      {method:'GET', isArray:true, params:{action:'activities'}}
        });
}]);

services.service("TaskService", ['Task', '$q', function(Task, $q) {
    this.save = function(task, obj){
        task.class = 'task';
        if (obj.class == 'Story'){
            task.parentStory = {id:obj.id};
        } else {
            task.backlog = {id:obj.id};
        }
        Task.save(task, function(task){
            obj.tasks.push(task);
            obj.tasks_count += 1;
        });
    };
    this['delete'] = function(task, obj){
        task.$delete(function(){
            if (obj){
                var index = obj.tasks.indexOf(task);
                if (index != -1){
                    obj.tasks.splice(index, 1);
                    obj.tasks_count -= 1;
                }
            }
        });
    };
    this.list = function(obj){
        Task.query({ typeId: obj.id, type:obj.class.toLowerCase() }, function(data){
            obj.tasks = data;
        });
    }
}]);