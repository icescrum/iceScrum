/*
 * Copyright (c) 2015 Kagilum.
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
 * Authors:Marwah Soltani (msoltani@kagilum.com)
 *
 */

services.factory('Feed', ['Resource', function($resource) {
    return $resource(icescrum.grailsServer + '/home/feed/:id/:action');
}]);

services.service("FeedService", ['Feed', function(Feed) {
    this.save = function(feed) {
        feed.class = 'feed';
        return Feed.save(feed).$promise;
    };
    this.list = function() {
        return Feed.query().$promise;
    };
    this.merged = function() {
        return Feed.query({action: 'merged'}).$promise;
    };
    this.content = function(feedUserSelect) {
        return Feed.get({id: feedUserSelect, action: 'content'}).$promise;
    };
    this.userFeed = function() {
        return Feed.get({action: 'userFeed'}).$promise;
    };
    this.delete = function(feedToDelete) {
        return Feed.delete({id: feedToDelete}).$promise;
    };
}]);

