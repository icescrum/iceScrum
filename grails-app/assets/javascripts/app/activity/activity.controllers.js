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

controllers.controller('activityCtrl', ['$scope', '$state', 'DateService', 'ActivityService', 'selected', function($scope, $state, DateService, ActivityService, selected) {
    //activities are ugly but it's working..
    $scope.activities = function(fluxiable, all) {
        $scope.allActivities = all;
        ActivityService.activities(fluxiable, all).then(manageActivities);
    };
    var manageActivities = function(activities) {
        var groupedActivities = [];
        angular.forEach(activities, function(activity) {
            var selectedType = selected.class.toLowerCase();
            var tabId;
            if (activity.code == 'comment') {
                tabId = 'comments'
            } else if (activity.code.indexOf("acceptanceTest") > -1 && selectedType == 'story') {
                tabId = 'tests'
            } else if (activity.code.indexOf("task") > -1 && selectedType == 'story') {
                tabId = 'tasks'
            }
            if (tabId) {
                activity.onClick = function() {
                    var tabIdParamName = selectedType + 'TabId';
                    var newStateParams = _.merge({}, $state.params);
                    newStateParams[tabIdParamName] = tabId;
                    $state.go($state.params[tabIdParamName] ? '.' : '.tab', newStateParams);
                }
            }
            activity.count = 1;
            if (_.isEmpty(groupedActivities) ||
                _.last(groupedActivities).poster.id != activity.poster.id ||
                DateService.daysBetweenDates(_.last(groupedActivities).dateCreated, activity.dateCreated) > 0) {
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