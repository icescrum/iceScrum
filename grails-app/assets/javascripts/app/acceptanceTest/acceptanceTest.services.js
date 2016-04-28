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
    return $resource('acceptanceTest/:type/:storyId/:id');
}]);

services.service("AcceptanceTestService", ['$q', 'AcceptanceTest', 'StoryStatesByName', 'Session', 'IceScrumEventType', 'PushService', function($q, AcceptanceTest, StoryStatesByName, Session, IceScrumEventType, PushService) {
    var self = this;
    this.getCrudMethods = function(story) {
        var crudMethods = {};
        crudMethods[IceScrumEventType.CREATE] = function(acceptanceTest) {
            if (acceptanceTest.parentStory.id == story.id) {
                var existingAcceptanceTest = _.find(story.acceptanceTests, {id: acceptanceTest.id});
                if (existingAcceptanceTest) {
                    angular.extend(existingAcceptanceTest, acceptanceTest);
                } else {
                    story.acceptanceTests.push(acceptanceTest);
                    story.acceptanceTests_count = story.acceptanceTests.length;
                }
            }
        };
        crudMethods[IceScrumEventType.UPDATE] = function(acceptanceTest) {
            var foundAcceptanceTest = _.find(story.acceptanceTests, {id: acceptanceTest.id});
            angular.extend(foundAcceptanceTest, acceptanceTest);
        };
        crudMethods[IceScrumEventType.DELETE] = function(acceptanceTest) {
            _.remove(story.acceptanceTests, {id: acceptanceTest.id});
            story.acceptanceTests_count = story.acceptanceTests.length;
        };
        return crudMethods;
    };
    this.save = function(acceptanceTest, story) {
        acceptanceTest.class = 'acceptanceTest';
        acceptanceTest.parentStory = {id: story.id};
        return AcceptanceTest.save(acceptanceTest, self.getCrudMethods(story)[IceScrumEventType.CREATE]).$promise;
    };
    this['delete'] = function(acceptanceTest, story) {
        return AcceptanceTest.delete({id: acceptanceTest.id}, self.getCrudMethods(story)[IceScrumEventType.DELETE]).$promise;
    };
    this.update = function(acceptanceTest, story) {
        return acceptanceTest.$update(self.getCrudMethods(story)[IceScrumEventType.UPDATE]);
    };
    this.list = function(story) {
        if (_.isEmpty(story.acceptanceTests)) {
            return AcceptanceTest.query({storyId: story.id, type: 'story'}, function(data) {
                story.acceptanceTests = data;
                story.acceptanceTests_count = story.acceptanceTests.length;
                var crudMethods = self.getCrudMethods(story);
                _.each(crudMethods, function(crudMethod, eventType) {
                    PushService.registerListener('acceptanceTest', eventType, crudMethod);
                });
            }).$promise;
        } else {
            return $q.when(story.acceptanceTests);
        }
    };
    this.authorizedAcceptanceTest = function(action, acceptanceTest) {
        switch (action) {
            case 'create':
            case 'update':
            case 'delete':
                return acceptanceTest.parentStory.state < StoryStatesByName.DONE && Session.inProduct();
            case 'updateState':
                return acceptanceTest.parentStory.state == StoryStatesByName.IN_PROGRESS && Session.inProduct();
            default:
                return false;
        }
    };
}]);