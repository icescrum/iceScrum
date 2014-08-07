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

services.service("AcceptanceTestService", ['AcceptanceTest', function(AcceptanceTest) {
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
    this.readOnly = function(story) {
        return story.state == 7; // TODO use constants, not hardcoded values
    };
    this.stateReadOnly = function(story) {
        return this.readOnly(story) || (story.state < 4); // TODO use constants, not hardcoded values
    };
    this.initAcceptanceTest = function(existingAcceptanceTest) {
        return existingAcceptanceTest ? angular.copy(existingAcceptanceTest) : { state: 1 }; // TODO use constants, not hardcoded values
    };
}]);