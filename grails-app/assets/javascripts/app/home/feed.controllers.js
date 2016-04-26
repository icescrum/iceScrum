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
            if (_.isEmpty($scope.holder.selectedFeed)) {
                if (_.isEmpty($scope.feeds)) {
                    $scope.holder.selectedFeed = savedFeed;
                    $scope.selectFeed(savedFeed);
                } else {
                    $scope.selectFeed();
                }
                $scope.showSettings = false;
            }
            $scope.feeds.push(savedFeed);
            $scope.feed = {};
            $scope.notifySuccess('todo.is.ui.feed.saved');
        });
    };
    $scope.selectFeed = function(selectedFeed) {
        var handleError = function(error) {
            $scope.holder.errorMessage = error.data.text;
        };
        if (_.isEmpty(selectedFeed)) {
            FeedService.merged().then(function(mergedFeed) {
                $scope.feedChannel = {};
                $scope.feedItems = $filter('orderBy')(mergedFeed, '-pubDate');
                $scope.disableDeleteButton = true;
                $scope.holder.errorMessage = null;
            }).catch(handleError);
        } else {
            $scope.disableDeleteButton = selectedFeed.id == "defaultFeed";
            FeedService.content(selectedFeed).then(function(feed) {
                $scope.feedChannel = feed;
                $scope.feedItems = feed.items;
                $scope.holder.errorMessage = null;
            }).catch(handleError);
        }
    };
    $scope.delete = function(feed) {
        FeedService.delete(feed).then(function() {
            _.remove($scope.feeds, {id: feed.id});
            $scope.feedItems = [];
            $scope.feedChannel = {};
            $scope.holder.selectedFeed = null;
            $scope.selectFeed();
            $scope.notifySuccess('todo.is.ui.feed.delete');
        })
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
    $scope.holder = {}; // Holder required to share the references across the ctrl chain, otherwise primitive values are copied and changes are not propagated
    $scope.feeds = [];
    FeedService.userFeed().then(function(feed) {
        if (feed.id) {
            $scope.holder.selectedFeed = feed;
        }
        $scope.selectFeed($scope.holder.selectedFeed);
    });
    FeedService.list().then(function(feeds) {
        $scope.feeds = feeds;
    });
}]);
