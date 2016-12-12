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
    this.save = function(actor) {
        actor.class = 'actor';
        return Actor.save(actor).$promise;
    };
    this.update = function(actor) {
        return Actor.update(actor).$promise;
    };
    this.delete = function(actor) {
        return Actor.delete(actor).$promise;
    };
    this.list = function() {
        return Actor.query().$promise;
    };
    this.authorizedActor = function(action, actor) {
        switch (action) {
            case 'create':
            case 'update':
                return Session.po();
            case 'delete':
                return Session.po() && actor.stories_count == 0;
            default:
                return false;
        }
    };
}]);
