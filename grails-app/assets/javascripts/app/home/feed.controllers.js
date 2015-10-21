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

controllers.controller("FeedCtrl", ['$scope', '$filter', 'FeedService', function($scope, $filter, FeedService) {
    $scope.save = function(feed) {
        FeedService.save(feed).then(function(savedFeed) {
            $scope.feeds.push(savedFeed);
            $scope.feed = {};
            $scope.notifySuccess('todo.is.ui.feed.saved');
        });
    };
    $scope.selectFeed = function(selectedFeed) {
        if (selectedFeed == "all") {
            FeedService.merged().then(function(allFeedsItems) {
                $scope.feedChannel = {};
                $scope.feedItems = $filter('orderBy')(allFeedsItems, '-item.pubDate');
                $scope.disableDeleteButton = true;

            });
        } else {
            $scope.disableDeleteButton = false;
            FeedService.content(selectedFeed).then(function(feed) {
                $scope.feedChannel = feed.channel;
                $scope.feedItems = feed.channel.items;
            });
        }
    };
    $scope.delete = function(feedToDelete) {
        FeedService.delete(feedToDelete).then(function() {
            _.remove($scope.feeds, { id: parseInt(feedToDelete) });
            $scope.notifySuccess('todo.is.ui.feed.delete');
        })
    };
    $scope.toggleSettings = function() {
        $scope.showSettings = !$scope.showSettings;
    };
    $scope.hasFeeds = function() {
        return $scope.feeds.length != 0;
    };
    $scope.hasFeedChannel = function() {
        return !_.isEmpty($scope.feedChannel);
    };
    // Init
    $scope.feedItems = [];
    $scope.feedChannel = {};
    $scope.feed = {};
    $scope.selectedFeed = 'all';
    $scope.feeds = [];
    $scope.selectFeed($scope.selectedFeed);
    FeedService.list()
        .then(function(feeds) {
            $scope.feeds = feeds;
            $scope.showSettings = !$scope.hasFeeds();
        });
}]);


