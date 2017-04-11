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

extensibleController('chartCtrl', ['$scope', '$element', '$filter', 'Session', 'ProjectService', 'SprintService', 'ReleaseService', function($scope, $element, $filter, Session, ProjectService, SprintService, ReleaseService) {
    $scope.defaultOptions = {
        chart: {
            height: 350
        },
        title: {
            enable: true
        }
    };
    $scope.chartLoaders = {
        project: function(chartName, item) {
            return ProjectService.openChart(item ? item : Session.getProject(), chartName);
        },
        release: function(chartName, item) {
            return ReleaseService.openChart(item, chartName);
        },
        sprint: function(chartName, item) {
            return SprintService.openChart(item, $scope.project ? $scope.project : Session.getProject(), chartName);
        }
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
                }
            },
            flowCumulative: {
                chart: {
                    type: 'stackedAreaChart'
                }
            },
            burndown: {
                chart: {
                    type: 'multiBarChart',
                    stacked: true
                }
            },
            velocity: {
                chart: {
                    type: 'multiBarChart',
                    stacked: true
                }
            },
            parkingLot: {
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
        },
        release: {
            default: {},
            parkingLot: {
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
                        tickFormat: $filter('dayShorter')
                    }
                }
            }
        }
    };
    $scope.openChart = function(itemType, chartName, item) {
        $scope.cleanData();
        $scope.options = _.merge({}, $scope.defaultOptions, $scope.chartOptions[itemType]['default'], $scope.chartOptions[itemType][chartName] ? $scope.chartOptions[itemType][chartName] : {});
        $scope.chartLoaders[itemType](chartName, item).then(function(chart) {
            $scope.data = chart.data;
            $scope.options = _.merge($scope.options, chart.options);
            if (chart.labelsX) {
                $scope.labelsX = chart.labelsX;
            }
            if (chart.labelsY) {
                $scope.labelsY = chart.labelsY;
            }
        });
    };
    $scope.saveChart = function() {
        var title = $element.find('.title.h4');
        saveChartAsPng($element.find('svg')[0], {}, title[0], function(imageBase64) {
            // Server side "attachment" content type is needed because the a.download HTML5 feature is not supported in crappy browsers (safari & co).
            jQuery.download($scope.serverUrl + '/saveImage', {'image': imageBase64, 'title': title.text()});
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

controllers.controller('chartWidgetCtrl', ['$scope', 'WidgetService', 'FormService', 'ProjectService', function($scope, WidgetService, FormService, ProjectService) {
    var widget = $scope.widget; // $scope.widget is inherited
    $scope.refreshProjects = function(term) {
        ProjectService.listByUser({term: term, paginate: true}).then(function(projectsAndCount) {
            $scope.projects = projectsAndCount.projects;
            if (!term && widget.settings && widget.settings.project && !_.find($scope.projects, {id: widget.settings.project.id})) {
                $scope.projects.unshift(widget.settings.project);
            }
        });
    };
    $scope.refreshCharts = function() {
        if (!$scope.charts.length) {
            FormService.httpGet('charts/project').then(function(charts) {
                $scope.charts = charts;
            });
        }
    };
    $scope.widgetReady = function(widget) {
        return widget.settings && widget.settings.project && widget.settings.chart ? true : false;
    };
    $scope.getTitle = function() {
        return $scope.widgetReady(widget) ? widget.settings.project.name + ' - ' + (widget.settings.chart.group ? widget.settings.chart.group + ' ' : '') + widget.settings.chart.name : '';
    };
    $scope.projectChanged = function() {
        if (!widget.settings) {
            widget.settings = {};
        }
        widget.settings.project = _.pick($scope.holder.project, ['id', 'name']);
        widget.type = 'project';
        widget.typeId = $scope.holder.project.id;
    };
    $scope.chartChanged = function() {
        widget.settings.chart = _.pick($scope.holder.chart, ['id', 'name', 'type', 'group']);
    };
    // Init
    $scope.holder = {};
    $scope.charts = [];
    $scope.projects = [];
    $scope.$watch('widget.settings.project', function(newProject) {
        $scope.holder.project = newProject;
    });
    $scope.$watch('widget.settings.chart', function(newChart) {
        $scope.holder.chart = newChart;
    })
}]);


controllers.controller('chartWidgetChartCtrl', ['$scope', '$element', '$controller', 'ReleaseService', 'SprintService', function($scope, $element, $controller, ReleaseService, SprintService) {
    $controller('chartCtrl', {$scope: $scope, $element: $element});
    $scope.project = $scope.widget.settings.project;
    switch ($scope.widget.settings.chart.type) {
        case 'release':
            ReleaseService.getCurrentOrNextRelease($scope.project).then(function(release) {
                if (release && release.id) {
                    $scope.openChart('release', $scope.widget.settings.chart.id, release);
                }
            });
            break;
        case 'sprint':
            SprintService.getCurrentOrLastSprint($scope.project).then(function(sprint) {
                if (sprint && sprint.id) {
                    $scope.openChart('sprint', $scope.widget.settings.chart.id, sprint);
                }
            });
            break;
        default:
            $scope.openChart('project', $scope.widget.settings.chart.id, $scope.project);
            break;
    }
}]);