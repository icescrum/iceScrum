/*
 * Copyright (c) 2015 Kagilum SAS.
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

controllers.controller('activityCtrl', ['$scope','$state', 'ActivityService', 'selected', function($scope, $state, ActivityService, selected) {
    //activities are ugly but it's working..
    $scope.activities = function(fluxiable, all) {
        $scope.allActivities = all;
        ActivityService.activities(fluxiable, all).then(manageActivities);
    };
    var manageActivities = function(activities) {
        var groupedActivities = [];
        angular.forEach(activities, function(activity) {
            var tabId;
            if (activity.code == 'comment') {
                tabId = 'comments'
            } else if (activity.code.indexOf("acceptanceTest") > -1 && selected.class == 'Story') {
                tabId = 'tests'
            } else if (activity.code.indexOf("task") > -1 && selected.class == 'Story') {
                tabId = 'tasks'
            }
            if (tabId) {
                activity.onClick = function() {
                    var newStateParams = _.merge({}, $state.params, {tabId: tabId});
                    if ($state.params.tabId) {
                        $state.go('.', newStateParams);
                    } else {
                        $state.go('.tab', newStateParams);
                    }
                }
            }
            activity.count = 1;
            if (_.isEmpty(groupedActivities) ||
                _.last(groupedActivities).poster.id != activity.poster.id ||
                new Date(_.last(groupedActivities).dateCreated).getTime() - 86400000 > new Date(activity.dateCreated).getTime()) {
                groupedActivities.push({
                    poster: activity.poster,
                    dateCreated: activity.dateCreated,
                    activities: [activity]
                });
            } else {
                var lastActivity = _.last(_.last(groupedActivities).activities);
                if (activity.code == lastActivity.code
                    && activity.parentType == lastActivity.parentType
                    && activity.field == lastActivity.field) {
                    lastActivity.count += 1;
                    lastActivity.beforeValue = activity.beforeValue;
                } else {
                    _.last(groupedActivities).activities.push(activity);
                }
            }
        });
        $scope.groupedActivities = groupedActivities;
    };
    //init
    $scope.allActivities = false;
    $scope.groupedActivities = {};
    manageActivities(selected.activities);
}]);