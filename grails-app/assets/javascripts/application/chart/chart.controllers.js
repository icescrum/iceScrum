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

extensibleController('chartCtrl', ['$scope', '$element', '$filter', '$uibModal', '$timeout', 'ProjectService', 'SprintService', 'ReleaseService', 'BacklogService', function($scope, $element, $filter, $uibModal, $timeout, ProjectService, SprintService, ReleaseService, BacklogService) {
    $scope.defaultOptions = {
        chart: {
            height: 350
        }
    };
    $scope.chartLoaders = {
        project: function(chartName, project) {
            return ProjectService.openChart(project, chartName);
        },
        release: function(chartName, release) {
            return ReleaseService.openChart(release, chartName);
        },
        sprint: function(chartName, sprint) {
            return SprintService.openChart(sprint, $scope.project ? $scope.project : $scope.getResolvedProjectFromState(), chartName);
        },
        backlog: function(chartName, backlog) {
            return BacklogService.openChart(backlog, backlog.project, chartName);
        }
    };
    var addMargin = function(number) {
        return Math.ceil(number * 0.05) + number;
    };
    $scope.chartOptions = {
        project: {
            default: {
                chart: {
                    type: 'lineChart',
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    xAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsX[entry];
                        }
                    }
                },
                computeMaxY: function(data) {
                    var max = 0;
                    _.each(data, function(line) {
                        var values = _.map(line["values"], function(o) { return o[0]; });
                        var tmpMax = _.max(values);
                        max = tmpMax > max ? tmpMax : max;
                    });
                    return addMargin(max);
                }
            },
            flowCumulative: {
                chart: {
                    type: 'stackedAreaChart',
                    margin: {right: 45}
                },
                computeMaxY: null
            },
            burndown: {
                chart: {
                    type: 'multiBarChart',
                    stacked: true
                },
                computeMaxY: null
            },
            burnup: {
                chart: {
                    margin: {right: 45}
                }
            },
            velocity: {
                chart: {
                    type: 'multiBarChart',
                    stacked: true
                },
                computeMaxY: null
            },
            parkingLot: {
                chart: {
                    type: 'multiBarHorizontalChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showValues: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return _.truncate(entry, {length: 16});
                        }
                    },
                    margin: {
                        left: 125
                    },
                    showControls: false
                },
                computeMaxY: null
            }
        },
        release: {
            parkingLot: {
                chart: {
                    type: 'multiBarHorizontalChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showValues: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return _.truncate(entry, {length: 16});
                        }
                    },
                    margin: {
                        left: 125
                    },
                    showControls: false
                }
            },
            burndown: {
                chart: {
                    type: 'multiBarChart',
                    x: function(entry, index) { return index; },
                    y: function(entry) { return entry[0]; },
                    stacked: true,
                    xAxis: {
                        tickFormat: function(entry) {
                            return $scope.labelsX[entry];
                        }
                    }
                }
            }
        },
        sprint: {
            default: {
                chart: {
                    type: 'lineChart',
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    xScale: d3.time.scale.utc(),
                    xAxis: {
                        tickFormat: $filter('dayShorter'),
                        showMaxMin: false
                    }
                },
                computeMaxY: function(data) {
                    var max = 0;
                    _.each(data, function(line) {
                        var values = _.map(line["values"], function(o) { return o[1]; });
                        var tmpMax = _.max(values);
                        max = tmpMax > max ? tmpMax : max;
                    });
                    return addMargin(max);
                }
            }
        },
        backlog: {
            default: {
                chart: {
                    type: 'pieChart',
                    donut: true,
                    height: 200,
                    x: function(entry) { return entry[0]; },
                    y: function(entry) { return entry[1]; },
                    showLabels: true,
                    duration: 500,
                    showLegend: false,
                    margin: {
                        top: 0,
                        right: 0,
                        bottom: 0,
                        left: 0
                    }
                },
                title: {
                    enable: false
                },
                caption: {
                    enable: true
                }
            }
        }
    };
    $scope.openChart = function(itemType, chartName, item, options) {
        $scope.cleanData();
        $scope.chartParams = {
            item: item,
            itemType: itemType,
            chartName: chartName
        };
        $scope.options = _.merge({}, $scope.defaultOptions);
        $scope.options = _.merge($scope.options, $scope.chartOptions[itemType]['default']);
        $scope.options = _.merge($scope.options, $scope.chartOptions[itemType][chartName] ? $scope.chartOptions[itemType][chartName] : {});
        $scope.options = _.merge($scope.options, options ? options : {});
        return $scope.chartLoaders[itemType](chartName, item).then(function(chart) {
            // Timeout is required for new options to be taken into account correctly when chartLoader is too fast
            return $timeout(function() {
                $scope.data = chart.data;
                $scope.options = _.merge($scope.options, chart.options);
                $scope.options = _.merge($scope.options, options);
                if ($scope.options.computeMaxY) {
                    var max = $scope.options.computeMaxY(chart.data);
                    $scope.options.chart.yDomain = [0, max];
                }
                $scope.options.title.enable = !_.isEmpty($scope.options.title) && $scope.options.title.enable !== false;
                if (chart.labelsX) {
                    $scope.labelsX = chart.labelsX;
                }
                if (chart.labelsY) {
                    $scope.labelsY = chart.labelsY;
                }
                if (angular.isFunction($scope.options.chart.height)) {
                    $scope.options.chart.height = $scope.options.chart.height($element);
                }
                return chart;
            });
        });
    };
    $scope.processSaveChart = function() {
        var title = $element.find('.title.h4');
        saveChartAsPng($element.find('svg')[0], {}, title[0], function(imageBase64) {
            // Server side "attachment" content type is needed because the a.download HTML5 feature is not supported in crappy browsers (safari & co).
            jQuery.download($scope.serverUrl + '/saveImage', {'image': imageBase64, 'title': title.text()});
        });
    };

    $scope.openChartInModal = function(chartParams) {
        $uibModal.open({
            templateUrl: 'chart.modal.html',
            size: 'wide',
            controller: ["$scope", "$controller", "hotkeys", "$window", function($scope, $controller, hotkeys, $window) {
                $element = angular.element('.modal-wide');
                $controller('chartCtrl', {$scope: $scope, $element: $element});
                $scope.defaultOptions.chart.height = ($window.innerHeight * 75 / 100);
                $scope.openChart(chartParams.itemType, chartParams.chartName, chartParams.item);
                $scope.submit = function() {
                    $scope.$close(true);
                };
                // Required because there is not input so the form cannot be submitted by "return"
                hotkeys.bindTo($scope).add({
                    combo: 'return',
                    callback: function(event) {
                        event.preventDefault(); // Prevents propagation of click to unwanted places
                        $scope.submit();
                    }
                });
            }]
        });
    };
    $scope.saveChart = function(chartParams) {
        $uibModal.open({
            templateUrl: 'chart.modal.html',
            size: 'chart invisible',
            controller: ["$scope", "$controller", "$window", "$timeout", function($scope, $controller, $window, $timeout) {
                $timeout(function() {
                    angular.element('body').addClass('process-chart');
                    $element = angular.element('.modal-chart');
                    $controller('chartCtrl', {$scope: $scope, $element: $element});
                    $scope.defaultOptions.chart.width = 1600;
                    $scope.defaultOptions.chart.height = 800;
                    $scope.openChart(chartParams.itemType, chartParams.chartName, chartParams.item);
                    $timeout(function() {
                        $scope.processSaveChart();
                        $scope.$close(true);
                    }, 500);
                }, 500);
            }]
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

controllers.controller('chartWidgetCtrl', ['$scope', 'WidgetService', 'FormService', 'ProjectService', '$controller', '$element', function($scope, WidgetService, FormService, ProjectService, $controller, $element) {
    $controller('widgetCtrl', {$scope: $scope});
    $controller('chartCtrl', {$scope: $scope, $element: $element});
    $scope.getChartWidgetOptions = function(widget) {
        var chartWidgetOptions = {
            chart: {
                height: function($element) {
                    return $element ? $element.parents('.panel-body')[0].getBoundingClientRect().height : 0;
                }
            },
            title: {
                enable: false
            }
        };
        if (widget.width === 1 || widget.height === 1) {
            chartWidgetOptions = _.merge(chartWidgetOptions, {
                chart: {
                    showXAxis: false,
                    showYAxis: false,
                    showLegend: false,
                    margin: {top: 30, right: 0, bottom: 15, left: 0}
                },
                title: {
                    enable: false
                }
            });
        }
        return chartWidgetOptions;
    }
}]);