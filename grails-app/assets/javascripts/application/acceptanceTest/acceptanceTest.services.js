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
services.factory('AcceptanceTest', ['Resource', function($resource) {
    return $resource('/p/:projectId/acceptanceTest/:type/:storyId/:id');
}]);

services.service("AcceptanceTestService", ['$q', 'AcceptanceTest', 'StoryStatesByName', 'Session', 'IceScrumEventType', 'PushService', 'CacheService', function($q, AcceptanceTest, StoryStatesByName, Session, IceScrumEventType, PushService, CacheService) {
    var self = this;
    var crudMethods = {};
    crudMethods[IceScrumEventType.CREATE] = function(acceptanceTest) {
        CacheService.addOrUpdate('acceptanceTest', acceptanceTest);
    };
    crudMethods[IceScrumEventType.UPDATE] = function(acceptanceTest) {
        CacheService.addOrUpdate('acceptanceTest', acceptanceTest);
    };
    crudMethods[IceScrumEventType.DELETE] = function(acceptanceTest) {
        CacheService.remove('acceptanceTest', acceptanceTest.id);
    };
    _.each(crudMethods, function(crudMethod, eventType) {
        PushService.registerListener('acceptanceTest', eventType, crudMethod);
    });
    this.mergeAcceptanceTests = function(acceptanceTests) {
        _.each(acceptanceTests, crudMethods[IceScrumEventType.UPDATE]);
    };
    this.save = function(acceptanceTest, story) {
        acceptanceTest.class = 'acceptanceTest';
        acceptanceTest.parentStory = {id: story.id};
        return AcceptanceTest.save({projectId: story.backlog.id}, acceptanceTest, crudMethods[IceScrumEventType.CREATE]).$promise;
    };
    this['delete'] = function(acceptanceTest, story) {
        return AcceptanceTest.delete({projectId: story.backlog.id}, {id: acceptanceTest.id}, crudMethods[IceScrumEventType.DELETE]).$promise;
    };
    this.update = function(acceptanceTest, story) {
        return AcceptanceTest.update({projectId: story.backlog.id}, acceptanceTest, crudMethods[IceScrumEventType.UPDATE]).$promise;
    };
    this.list = function(story) {
        var promise = AcceptanceTest.query({projectId: story.backlog.id, storyId: story.id, type: 'story'}, self.mergeAcceptanceTests).$promise.then(function() {
            return story.acceptanceTests;
        });
        return _.isEmpty(story.acceptanceTests) ? promise : $q.when(story.acceptanceTests);
    };
    this.authorizedAcceptanceTest = function(action, story) {
        switch (action) {
            case 'create':
            case 'update':
            case 'delete':
                return story.state < StoryStatesByName.DONE && Session.inProject();
            case 'rank':
                return story.state < StoryStatesByName.DONE && Session.po();
            case 'updateState':
                return story.state == StoryStatesByName.IN_PROGRESS && Session.inProject();
            default:
                return false;
        }
    };
}]);
