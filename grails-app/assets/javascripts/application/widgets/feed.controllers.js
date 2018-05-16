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
controllers.controller("feedWidgetCtrl", ['$scope', '$filter', 'FormService', 'WidgetService', '$controller', function($scope, $filter, FormService, WidgetService, $controller) {
    $controller('widgetCtrl', {$scope: $scope});
    //$scope.widget inherited
    var widget = $scope.widget;
    $scope.display = function(widget) {
        $scope.holder.feed = {};
        return FormService.httpGet('widget/feed', {widgetId: widget.id}, true).then(function(feedWithContent) {
            $scope.holder.errorMessage = null;
            $scope.holder.feed = feedWithContent;
        }).catch(function(error) {
            $scope.holder.errorMessage = error.data.text;
        });
    };
    $scope.add = function(url) {
        if (!widget.settings.feeds) {
            widget.settings.feeds = {};
        }
        widget.settings.feeds.push({url: url});
        WidgetService.update(widget).then(function() {
            $scope.holder.feedUrl = '';
        });
    };
    $scope.deleteFeed = function(feed) {
        _.remove(widget.settings.feeds, {url: feed.url});
        WidgetService.update(widget).then(function() {
            $scope.holder.selected = null;
        });
    };
    $scope.onSelect = function($item, $model) {
        _.each(widget.settings.feeds, function(feed) {
            if ($model && $model.url == feed.url) {
                $model.selected = true;
                feed.selected = true;
            } else {
                feed.selected = false;
            }
        });
    };
    $scope.getTitle = function() {
        return $scope.holder.feed && $scope.holder.feed.title ? $scope.holder.feed.title : '';
    };
    // Init
    $scope.holder = {
        feed: {},
        errorMessage: false,
        feeds: widget.settings.feeds,
        selected: _.find(widget.settings.feeds, {selected: true})
    };
    $scope.display(widget);
}]);
