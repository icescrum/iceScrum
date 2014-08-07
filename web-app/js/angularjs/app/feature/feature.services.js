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
services.factory('Feature', [ 'Resource', function($resource) {
    return $resource('feature/:id/:action');
}]);

services.service("FeatureService", ['Feature', function(Feature) {
    var self = this;
    this.list = Feature.query();
    this.get = function(id) {
        return self.list.$promise.then(function(list) {
            return _.find(list, function(rw) {
                return rw.id == id;
            });
        });
    };
    this.update = function(feature) {
        return feature.$update(function(data) {
            var index = self.list.indexOf(_.findWhere(self.list, { id: feature.id }));
            if (index != -1) {
                self.list.splice(index, 1, data);
            }
        });
    };
    this['delete'] = function(feature) {
        return feature.$delete(function() {
            _.remove(self.list, { id: feature.id });
        });
    };
}]);
