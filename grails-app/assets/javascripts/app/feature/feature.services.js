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

services.service("FeatureService", ['$state', '$q', 'Feature', 'Session', 'CacheService', 'PushService', 'IceScrumEventType', function($state, $q, Feature, Session, CacheService, PushService, IceScrumEventType) {
    var self = this;
    Session.getProject().features = CacheService.getCache('feature');
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(feature) {
        CacheService.addOrUpdate('feature', feature);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(feature) {
        CacheService.addOrUpdate('feature', feature);
    };
    crudMethods[IceScrumEventType.DELETE] = function(feature) {
        if ($state.includes("feature.details", {id: feature.id}) ||
            ($state.includes("feature.multiple") && _.includes($state.params.listId.split(','), feature.id.toString()))) {
            $state.go('feature');
        }
        CacheService.remove('feature', feature.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('feature', eventType, crudMethod);
    });
    this.mergeFeatures = function(features) {
        _.each(features, function(feature) {
            crudMethods[IceScrumEventType.CREATE](feature);
        });
    };
    this.get = function(id) {
        var cachedFeature = CacheService.get('feature', id);
        return cachedFeature ? $q.when(cachedFeature) : Feature.get({id: id}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.list = function() {
        var cachedFeatures = CacheService.getCache('feature');
        return _.isEmpty(cachedFeatures) ? Feature.query().$promise.then(function(features) {
            self.mergeFeatures(features);
            return CacheService.getCache('feature');
        }) : $q.when(cachedFeatures);
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
        ids = _.map(ids, function(id) {
            return parseInt(id);
        });
        var cachedFeatures = _.filter(_.map(ids, function(id) {
            return CacheService.get('feature', id);
        }), _.identity);
        var notFoundFeatureIds = _.difference(ids, _.map(cachedFeatures, 'id'));
        if (notFoundFeatureIds.length > 0) {
            var promise;
            if (notFoundFeatureIds.length == 1) {
                promise = self.get(notFoundFeatureIds[0]).then(function(feature) { return [feature]; });
            } else {
                promise = Feature.query({id: notFoundFeatureIds}, self.mergeFeatures).$promise;
            }
            return promise.then(function(features) {
                return _.concat(cachedFeatures, features);
            });
        } else {
            return $q.when(cachedFeatures);
        }
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
