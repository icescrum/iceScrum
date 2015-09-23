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
 *
 */

services.factory('Rss', ['Resource',  function($resource) {
    return $resource(icescrum.grailsServer + '/rss/:id/:action',
        {},
        {
            getFeed: {method: 'GET', params: {action: 'getFeed'}},
            rssByUser: {method: 'GET',isArray: true, params: {action: 'rssByUser'}},
            getAllFeeds: {method: 'GET',isArray: true, params: {action: 'getAllFeeds'}}
        });
}]);

services.service("RssService", ['Rss',function (Rss) {
    this.save = function (rss) {
        rss.class = 'rss';
        return Rss.save(rss).$promise;
    };
    this.rssByUser = function(){
        return Rss.rssByUser().$promise;
    };
    this.getFeed = function(rssUserSelect){
        return Rss.getFeed({id: rssUserSelect}).$promise;
    };
    this.getAllFeeds = function() {
        return Rss.getAllFeeds().$promise;
    };
    this.delete = function(rssToDelete) {
        return Rss.delete({id: rssToDelete}).$promise;
    };
}]);

