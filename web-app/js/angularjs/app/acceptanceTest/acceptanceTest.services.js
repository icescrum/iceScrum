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
services.factory('AcceptanceTest', [ 'Resource', function($resource) {
    return $resource('acceptanceTest/:type/:storyId/:id');
}]);

services.service("AcceptanceTestService", ['AcceptanceTest', 'StoryStatesByName', 'Session', function(AcceptanceTest, StoryStatesByName, Session) {
    this.save = function(acceptanceTest, story) {
        acceptanceTest.class = 'acceptanceTest';
        acceptanceTest.parentStory = { id: story.id };
        return AcceptanceTest.save(acceptanceTest, function(acceptanceTest) {
            story.acceptanceTests.push(acceptanceTest);
            story.acceptanceTests_count = story.acceptanceTests.length;
        }).$promise;
    };
    this['delete'] = function(acceptanceTest, story) {
        return acceptanceTest.$delete(function() {
            _.remove(story.acceptanceTests, { id: acceptanceTest.id });
            story.acceptanceTests_count = story.acceptanceTests.length;
        });
    };
    this.update = function(acceptanceTest, story) {
        return acceptanceTest.$update(function(data) {
            var index = story.acceptanceTests.indexOf(_.findWhere(story.acceptanceTests, { id: acceptanceTest.id }));
            if (index != -1) {
                story.acceptanceTests.splice(index, 1, data);
            }
        });
    };
    this.list = function(story) {
        return AcceptanceTest.query({ storyId: story.id, type: 'story' }, function(data) {
            story.acceptanceTests = data;
            story.acceptanceTests_count = story.acceptanceTests.length;
        }).$promise;
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