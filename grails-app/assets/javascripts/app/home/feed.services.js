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
    return $resource('/home/feed/:id/:action');
}]);

services.service("FeedService", ['Feed', 'FormService', function(Feed, FormService) {
    this.save = function(feed) {
        feed.class = 'feed';
        return Feed.save(feed).$promise;
    };
    this.list = function() {
        return Feed.query().$promise;
    };
    this.userFeed = function() {
        return Feed.get({action: 'userFeed'}).$promise;
    };
    this.delete = function(feed) {
        return Feed.delete({id: feed.id}).$promise;
    };
    this.merged = function() {
        return FormService.httpGet('home/feed/merged');
    };
    this.content = function(feed) {
        return FormService.httpGet('home/feed/' + feed.id + '/content');
    };
}]);

