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

services.factory('Feed', ['Resource',  function($resource) {
    return $resource(icescrum.grailsServer + '/home/feed/:id/:action',
        {},
        {
            content: {method: 'GET', params: {action: 'content'}},
            list:    {method: 'GET',isArray: true, params: {action: 'list'}},
            merged:  {method: 'GET', isArray:true, params: {action: 'merged'}}
        });
}]);

services.service("FeedService", ['Feed',function (Feed) {
    this.save = function (feed) {
        feed.class = 'feed';
        return Feed.save(feed).$promise;
    };
    this.list = function(){
        return Feed.list().$promise;
    };
    this.content = function(feedUserSelect){
        return Feed.content({id: feedUserSelect}).$promise;
    };
    this.merged = function() {
        return Feed.merged().$promise;
    };
    this.delete = function(feedToDelete) {
        return Feed.delete({id: feedToDelete}).$promise;
    };
}]);

