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
services.factory('Feature', [ 'Resource', function ($resource) {
    return $resource('feature/:id/:action', { id: '@id' }, { query: {method: 'GET', isArray: true, cache: true} });
}]);

services.service("FeatureService", ['Feature', '$q', function (Feature, $q) {
    var list = Feature.query();
    this.list = list;
    this.get = function (id) {
        var feature;
        var deferred = $q.defer();
        this.list.$promise.then(function (list) {
            feature = _.find(list, function (rw) {
                return rw.id == id
            });
            deferred.resolve(feature);
        });
        return deferred.promise;
    };
    this.update = function (feature, callback) {
        feature.$update(function (data) {
            var index = list.indexOf(_.find(list, function (st) {
                return st.id == feature.id
            }));
            if (index) {
                list.splice(index, 1, data);
            }
        });
    };
    this['delete'] = function (feature) {
        feature.$delete(function () {
            var index = list.indexOf(feature);
            if (index) {
                list.splice(index, 1);
            }
        });
    };
}]);
