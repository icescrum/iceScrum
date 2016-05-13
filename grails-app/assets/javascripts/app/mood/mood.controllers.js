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

controllers.controller('moodCtrl', ['$scope', 'MoodService', 'MoodFeelingsByName', function($scope, MoodService, MoodFeelingsByName) {
    $scope.save = function(feelingString) {
        MoodService.save({feeling: MoodFeelingsByName[feelingString]}).then(function(mood) {
            $scope.mood = mood;
        });
    };
    // Init
    $scope.mood = null;
    MoodService.get().then(function(mood) {
        if (mood.id) {
            $scope.mood = mood
        }
    });
}]);

controllers.controller('moodChartCtrl', ['$scope', 'MoodService', '$element', '$filter', function($scope, MoodService, $element, $filter) {
    $scope.options = {
        chart: {
            height: 350,
            type: 'lineChart',
            x: function(d) {
                return d[0];
            },
            y: function(d) {
                return d[1];
            },
            xScale: d3.time.scale.utc(),
            xAxis: {
                tickFormat: $filter('dateShorter')
            },
            yAxis: {
                tickFormat: function(d) {
                    return $scope.labelsY[d];
                }
            }
        }
    };
    $scope.data = [];
    MoodService.openChart('chart')
        .then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsY) {
                $scope.labelsY = chart.labelsY;
            }
        });
}]);

