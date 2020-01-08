/*
 * Copyright (c) 2019 Kagilum SAS.
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

controllers.controller('leadTimeChartWidgetCtrl', ['$scope', '$element', '$controller', '$timeout', 'Session', 'StoryStatesByName', function($scope, $element, $controller, $timeout, Session, StoryStatesByName) {
    $controller('chartWidgetCtrl', {$scope: $scope, $element: $element});
    var widget = $scope.widget; // $scope.widget is inherited
    $scope.widgetReady = function(widget) {
        return !!(widget.settings && widget.settings.startState);
    };
    // Functions
    $scope.display = function(widget) {
        if ($scope.widgetReady(widget)) {
            var chartWidgetOptions = _.merge($scope.getChartWidgetOptions(widget), {
                chart: {
                    height: function($element) {
                        return $element ? ($element.find('.card-body')[0].getBoundingClientRect().height - 30) : 0;
                    },
                    margin: {top: 0, right: 0, bottom: 0, left: 0},
                    type: 'pieChart',
                    donut: true,
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    duration: 500
                },
                title: {
                    enable: false
                },
                caption: {
                    enable: false
                }
            });
            var chartName = 'leadTime/' + widget.settings.startState; // Hack to provide param in the chart URL
            $scope.openChart('project', chartName, $scope.project, chartWidgetOptions).then(function(chart) {
                $timeout(function() {
                    var cycleTime = _.sumBy(chart.data, '[1]');
                    $scope.options.chart.title = cycleTime ? moment.duration(cycleTime, 'days').humanize() : '?';
                }, 100); // Hack, as a lower delay does not work...
            });
        }
    };
    // Init
    $scope.holder = {};
    if ($scope.workspaceType === 'project') {
        $scope.holder.project = Session.getWorkspace();
    }
    $scope.storyStartStates = [StoryStatesByName.SUGGESTED, StoryStatesByName.ACCEPTED, StoryStatesByName.ESTIMATED];
}]);
