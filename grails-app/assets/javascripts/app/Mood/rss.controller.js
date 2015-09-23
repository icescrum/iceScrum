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
 * Authors:
 *
 * Marwah Soltani (msoltani@kagilum.com)
 */

controllers.controller("FeedCtrl", ['$scope', '$filter', 'RssService', function ($scope, $filter, RssService) {
    $scope.save = function (rss) {
        RssService.save(rss).then(function (savedRss) {
            $scope.rss = savedRss;
            $scope.rssList.push(savedRss);
            $scope.notifySuccess('todo.is.ui.rssUrl.saved');
        });
    };
    $scope.selectRss = function(selectedRss){
        if(selectedRss == "all") {
            RssService.getAllFeeds().then(function (allFeedsItems) {
                $scope.feed = {};
                $scope.feedItems = $filter('orderBy')(allFeedsItems, '-item.pubDate');
            });
        } else {
            RssService.getFeed(selectedRss).then(function (feed) {
                $scope.feed = feed.channel;
                $scope.feedItems = feed.channel.items;
            });
        }
    };
    $scope.delete = function(rssToDelete){
        RssService.delete(rssToDelete).then(function(){
            $scope.notifySuccess('todo.is.ui.rssUrl.delete');
        })
    };
    $scope.view = true;
    $scope.click = function() {
        $scope.view = $scope.view === false ? true: false;
    };
    // Init
    // Feeds
    $scope.feed = {};
    $scope.feedItems = [];
    $scope.selectedRss = 'all';
    $scope.selectRss($scope.selectedRss);
    // URL
    $scope.rssList = [];
    $scope.rss = {};
    RssService.rssByUser()
        .then(function (rssList) {
            $scope.rssList = rssList;
        });
}]);


