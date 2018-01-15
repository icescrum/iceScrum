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
    return $resource('/p/:projectId/feature/:id/:action');
}]);

services.service("FeatureService", ['$state', '$q', 'Feature', 'Session', 'CacheService', 'PushService', 'IceScrumEventType', 'FormService', function($state, $q, Feature, Session, CacheService, PushService, IceScrumEventType, FormService) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(feature) {
        CacheService.addOrUpdate('feature', feature);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(feature) {
        CacheService.addOrUpdate('feature', feature);
    };
    crudMethods[IceScrumEventType.DELETE] = function(feature) {
        if ($state.includes("feature.details", {id: feature.id}) ||
            ($state.includes("feature.multiple") && _.includes($state.params.featureListId.split(','), feature.id.toString()))) {
            $state.go('feature', {}, {location: 'replace'});
        } else if ($state.includes('roadmap.roadmap.feature', {featureId: feature.id})) {
            $state.go('roadmap.roadmap', {}, {location: 'replace'});
        }
        CacheService.remove('feature', feature.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('feature', eventType, crudMethod);
    });
    this.mergeFeatures = function(features) {
        _.each(features, crudMethods[IceScrumEventType.CREATE]);
    };
    this.get = function(id, projectId) {
        var cachedFeature = CacheService.get('feature', id);
        return cachedFeature ? $q.when(cachedFeature) : self.refresh(id, projectId);
    };
    this.refresh = function(id, projectId) {
        return Feature.get({id: id, projectId: projectId}, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.list = function(project) {
        return Feature.query({projectId: project.id}).$promise.then(function(features) {
            self.mergeFeatures(features);
            return project.features;
        });
    };
    this.save = function(feature, projectId) {
        feature.class = 'feature';
        return Feature.save({projectId: projectId}, feature, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this.update = function(feature) {
        return Feature.update({projectId: feature.backlog.id}, _.omit(feature, 'stories'), crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.createStoryEpic = function(feature) {
        return Feature.update({id: feature.id, projectId: feature.backlog.id, action: 'createStoryEpic'}, {}).$promise;
    };
    this['delete'] = function(feature) {
        return Feature.delete({id: feature.id, projectId: feature.backlog.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.getMultiple = function(ids, projectId) {
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
                promise = self.get(notFoundFeatureIds[0], projectId).then(function(feature) { return [feature]; });
            } else {
                promise = Feature.query({id: notFoundFeatureIds, projectId: projectId}, self.mergeFeatures).$promise;
            }
            return promise.then(function(features) {
                return _.concat(cachedFeatures, features);
            });
        } else {
            return $q.when(cachedFeatures);
        }
    };
    this.updateMultiple = function(ids, updatedFields, projectId) {
        return Feature.updateArray({id: ids, projectId: projectId}, {feature: updatedFields}, function(features) {
            _.each(features, crudMethods[IceScrumEventType.UPDATE]);
        }).$promise;
    };
    this.createStoryEpicMultiple = function(ids, projectId) {
        return Feature.updateArray({id: ids, projectId: projectId, action: 'createStoryEpic'}, {}).$promise;
    };
    this.deleteMultiple = function(ids, projectId) {
        return Feature.deleteArray({id: ids, projectId: projectId}, function() {
            _.each(ids, function(stringId) {
                crudMethods[IceScrumEventType.DELETE]({id: parseInt(stringId)});
            });
        }).$promise;
    };
    this.authorizedFeature = function(action, project) {
        switch (action) {
            case 'create':
            case 'createStoryEpic':
            case 'upload':
            case 'update':
            case 'delete':
                return Session.po();
            case 'rank':
                return (project && project.portfolio) ? Session.bo() : Session.po();
            default:
                return false;
        }
    };
    this.getAvailableColors = function(projectId) {
        return projectId ? FormService.httpGet('p/' + projectId + '/feature/colors', null, true) : $q.when([]);
    };
}]);
