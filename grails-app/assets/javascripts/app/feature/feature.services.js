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
services.factory('Feature', ['Resource', function($resource) {
    return $resource('feature/:id/:action');
}]);

services.service("FeatureService", ['$state', 'Feature', 'Session', 'PushService', 'IceScrumEventType', function($state, Feature, Session, PushService, IceScrumEventType) {
    var self = this;
    this.list = Feature.query();
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(feature) {
        var existingFeature = _.find(self.list, {id: feature.id});
        if (existingFeature) {
            angular.extend(existingFeature, feature);
        } else {
            self.list.push(feature);
        }
    };
    crudMethods[IceScrumEventType.UPDATE] = function(feature) {
        angular.extend(_.find(self.list, {id: feature.id}), feature);
    };
    crudMethods[IceScrumEventType.DELETE] = function(feature) {
        if ($state.includes("feature.details", {id: feature.id}) ||
            ($state.includes("feature.multiple") && _.contains($state.params.listId.split(','), feature.id.toString()))) {
            $state.go('feature');
        }
        _.remove(self.list, {id: feature.id});
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('feature', eventType, crudMethod);
    });
    this.get = function(id) {
        return self.list.$promise.then(function(list) {
            var feature = _.find(list, function(rw) {
                return rw.id == id;
            });
            if (feature) {
                return feature;
            } else {
                throw Error('todo.is.ui.feature.does.not.exist');
            }
        });
    };
    this.save = function(feature) {
        feature.class = 'feature';
        return Feature.save(feature, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(feature) {
        return feature.$update(crudMethods[IceScrumEventType.UPDATE]);
    };
    this.copyToBacklog = function(feature) {
        return Feature.update({id: feature.id, action: 'copyToBacklog'}, {}).$promise;
    };
    this['delete'] = function(feature) {
        return feature.$delete(crudMethods[IceScrumEventType.DELETE]);
    };
    this.getMultiple = function(ids) {
        return self.list.$promise.then(function() {
            return _.filter(self.list, function(feature) {
                return _.contains(ids, feature.id.toString());
            });
        });
    };
    this.updateMultiple = function(ids, updatedFields) {
        return Feature.updateArray({id: ids}, {feature: updatedFields}, function(features) {
            _.each(features, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.copyToBacklogMultiple = function(ids) {
        return Feature.updateArray({id: ids, action: 'copyToBacklog'}, {}).$promise;
    };
    this.deleteMultiple = function(ids) {
        return Feature.deleteArray({id: ids}, function() {
            _.each(ids, function(stringId) {
                crudMethods[IceScrumEventType.DELETE]({id: parseInt(stringId)});
            });
        }).$promise;
    };
    this.authorizedFeature = function(action) {
        switch (action) {
            case 'create':
            case 'copyToBacklog':
            case 'upload':
            case 'update':
            case 'rank':
            case 'delete':
                return Session.po();
            default:
                return false;
        }
    };
}]);
