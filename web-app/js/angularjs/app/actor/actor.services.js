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
services.factory('Actor', [ 'Resource', function ($resource) {
    return $resource('actor/:id/:action', { id: '@id' }, { query: {method: 'GET', isArray: true, cache: true} });
}]);

services.service("ActorService", ['Actor', '$q', function (Actor, $q) {
    var list = Actor.query();
    this.list = list;
    this.get = function (id) {
        var actor;
        var deferred = $q.defer();
        this.list.$promise.then(function (list) {
            actor = _.find(list, function (rw) {
                return rw.id == id
            });
            deferred.resolve(actor);
        });
        return deferred.promise;
    };
    this.update = function (actor, callback) {
        actor.$update(function (data) {
            var index = list.indexOf(_.find(list, function (st) {
                return st.id == actor.id
            }));
            if (index) {
                list.splice(index, 1, data);
            }
        });
    };
    this['delete'] = function (actor) {
        actor.$delete(function () {
            var index = list.indexOf(actor);
            if (index) {
                list.splice(index, 1);
            }
        });
    };
}]);
