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

services.service("FeatureService", ['Feature', 'Session', function(Feature, Session) {
    var self = this;
    this.list = Feature.query();
    this.get = function(id) {
        return self.list.$promise.then(function(list) {
            return _.find(list, function(rw) {
                return rw.id == id;
            });
        });
    };
    this.save = function(feature) {
        feature.class = 'feature';
        return Feature.save(feature, function(feature) {
            self.list.push(feature);
        }).$promise;
    };
    this.update = function(feature) {
        return feature.$update(function(data) {
            var index = self.list.indexOf(_.findWhere(self.list, { id: feature.id }));
            if (index != -1) {
                self.list.splice(index, 1, data);
            }
        });
    };
    this.copyToBacklog = function(feature) {
        return feature.$update({ action: 'copyToBacklog' });
    };
    this['delete'] = function(feature) {
        return feature.$delete(function() {
            _.remove(self.list, { id: feature.id });
        });
    };
    this.getMultiple = function(ids) {
        return self.list.$promise.then(function() {
            return _.filter(self.list, function(feature) {
                return _.contains(ids, feature.id.toString());
            });
        });
    };
    this.updateMultiple = function(ids, updatedFields) {
        return Feature.updateArray({ id: ids }, { feature: updatedFields }, function(features) {
            angular.forEach(features, function(feature) {
                var index = self.list.indexOf(_.findWhere(self.list, { id: feature.id }));
                if (index != -1) {
                    self.list.splice(index, 1, feature);
                }
            });
        }).$promise;
    };
    this.copyToBacklogMultiple = function(ids) {
        return Feature.updateArray({ id: ids, action: 'copyToBacklog' }, {}).$promise;
    };
    this.deleteMultiple = function(ids) {
        return Feature.delete({id: ids}, function() {
            _.remove(self.list, function(feature) {
                return _.contains(ids, feature.id.toString());
            });
        }).$promise;
    };
    this.authorizedFeature = function(action) {
        switch (action) {
            case 'create':
            case 'updateMultiple':
            case 'copyToBacklog':
            case 'copyToBacklogMultiple':
            case 'upload':
            case 'update':
            case 'delete':
            case 'deleteMultiple':
                return Session.po();
            case 'menu':
                return this.authorizedFeature('copyToBacklog') || this.authorizedFeature('delete');
            default:
                return false;
        }
    };
}]);
