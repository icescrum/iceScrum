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
services.factory('Actor', ['Resource', function($resource) {
    return $resource('actor/:id/:action');
}]);

services.service("ActorService", ['Actor', 'Session', function(Actor, Session) {
    var self = this;
    this.list = Actor.query();
    this.get = function(id) {
        return self.list.$promise.then(function(list) {
            var actor = _.find(list, function(rw) {
                return rw.id == id;
            });
            if (actor) {
                return actor;
            } else {
                throw Error('todo.is.ui.actor.does.not.exist');
            }
        });
    };
    this.save = function(actor) {
        actor.class = 'actor';
        return Actor.save(actor, function(actor) {
            self.list.push(actor);
        }).$promise;
    };
    this.update = function(actor) {
        return actor.$update(function(data) {
            var index = self.list.indexOf(_.find(self.list, { 'id': actor.id }));
            if (index != -1) {
                self.list.splice(index, 1, data);
            }
        });
    };
    this['delete'] = function(actor) {
        return actor.$delete(function() {
            _.remove(self.list, { id: actor.id });
        });
    };
    this.getMultiple = function(ids) {
        return self.list.$promise.then(function() {
            return _.filter(self.list, function(actor) {
                return _.contains(ids, actor.id.toString());
            });
        });
    };
    this.deleteMultiple = function(ids) {
        return Actor.delete({id: ids}, function() {
            _.remove(self.list, function(actor) {
                return _.contains(ids, actor.id.toString());
            });
        }).$promise;
    };
    this.authorizedActor = function(action) {
        switch (action) {
            case 'create':
            case 'upload':
            case 'update':
            case 'delete':
                return Session.po();
            default:
                return false;
        }
    };
}]);
