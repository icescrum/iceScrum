/*
 * Copyright (c) 2016 Kagilum SAS.
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

controllers.controller('chartCtrl', ['$scope', '$element', '$filter', 'Session', 'ProjectService', 'SprintService', 'ReleaseService', 'MoodService', function($scope, $element, $filter, Session, ProjectService, SprintService, ReleaseService, MoodService) {
    var defaultOptions = {
        chart: {
            height: 350
        },
        title: {
            enable: true
        }
    };
    $scope.openProjectChart = function(chartName, project) {
        var options = {};
        if (chartName == 'flowCumulative') {
            options = {
                chart: {
                    type: 'stackedAreaChart'
                }
            }
        } else if (chartName == 'burndown' || chartName == 'velocity') {
            options = {
                chart: {
                    type: 'multiBarChart',
                    stacked: true
                }
            }
        } else if (chartName == 'parkingLot') {
            options = {
                chart: {
                    type: 'multiBarHorizontalChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showValues: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return entry;
                        }
                    }
                }
            }
        }
        var defaultProjectOptions = {
            chart: {
                type: 'lineChart',
                x: function(entry, index) { return index; },
                y: function(entry) { return entry[0]; },
                xAxis: {
                    tickFormat: function(entry) {
                        return $scope.labelsX[entry];
                    }
                }
            }
        };
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, defaultProjectOptions, options);
        ProjectService.openChart(project ? project : Session.getProject(), chartName).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX) {
                $scope.labelsX = chart.labelsX;
            }
        });
    };
    $scope.openReleaseChart = function(chartName, release) {
        var options = {};
        if (chartName == 'parkingLot') {
            options = {
                chart: {
                    type: 'multiBarHorizontalChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showValues: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return entry;
                        }
                    }
                }
            };
        } else if (chartName == 'burndown') {
            options = {
                chart: {
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    type: 'multiBarChart',
                    stacked: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsX[entry];
                        }
                    }
                }
            };
        }
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, options);
        ReleaseService.openChart(release, chartName).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX) {
                $scope.labelsX = chart.labelsX;
            }
        });
    };
    $scope.openSprintChart = function(chartName, sprint) {
        var defaultSprintOptions = {
            chart: {
                type: 'lineChart',
                x: function(entry) { return entry[0]; },
                y: function(entry) { return entry[1]; },
                xScale: d3.time.scale.utc(),
                xAxis: {
                    tickFormat: $filter('dateShorter')
                }
            }
        };
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, defaultSprintOptions);
        SprintService.openChart(sprint, $scope.currentProject ? $scope.currentProject : Session.getProject(), chartName).then(function(chart) {
            $scope.options = _.merge($scope.options, chart.options);
            $scope.data = chart.data;
        });
    };
    $scope.saveChart = function() {
        var title = $element.find('.title.h4');
        saveChartAsPng($element.find('svg')[0], {}, title[0], function(imageBase64) {
            // Server side "attachment" content type is needed because the a.download HTML5 feature is not supported in crappy browsers (safari & co).
            jQuery.download($scope.serverUrl + '/saveImage', {'image': imageBase64, 'title': title.text()});
        });
    };
    $scope.openMoodChart = function(chartName) {
        var options = {};
        if (chartName == 'sprintUserMood') {
            options = {
                chart: {
                    type: 'lineChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    xScale: d3.time.scale.utc(),
                    xAxis: {
                        tickFormat: $filter('dateShorter')
                    },
                    yAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsY[entry];
                        }
                    }
                }
            };
        } else if (chartName == 'releaseUserMood') {
            options = {
                chart: {
                    type: 'lineChart',
                    x: function(entry, index) {
                        return index;
                    },
                    y: function(entry) {
                        return entry[0];
                    },
                    xAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsX[entry];
                        }
                    },
                    yAxis: {
                        tickFormat: function(d) {
                            return $scope.labelsY[d];
                        }
                    }
                }
            };
        }
        $scope.cleanData();
        $scope.options = _.merge({}, defaultOptions, options);
        MoodService.openChart(chartName, $scope.currentProject ? $scope.currentProject : Session.getProject()).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX || chart.labelsY) {
                $scope.labelsX = chart.labelsX;
                $scope.labelsY = chart.labelsY;
            }
        });
    };
    $scope.cleanData = function() {
        $scope.data = [];
        $scope.labelsX = [];
        $scope.labelsY = [];
        $scope.options = {};
    };
    // Init
    $scope.cleanData();
}]);