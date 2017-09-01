/*
 * Copyright (c) 2017 Kagilum SAS.
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

controllers.controller('projectChartWidgetCtrl', ['$scope', 'ProjectService', 'ReleaseService', 'SprintService', '$controller', '$element', function($scope, ProjectService, ReleaseService, SprintService, $controller, $element) {
    $controller('chartWidgetCtrl', {$scope: $scope, $element: $element});
    var widget = $scope.widget; // $scope.widget is inherited
    // Functions
    $scope.widgetReady = function(widget) {
        // Hack to force to keep sync values after drag & drop
        widget.width = widget.settings.width;
        widget.height = widget.settings.height;
        return !!(widget.settings && widget.settings.project && widget.settings.chart);
    };
    $scope.getTitle = function() {
        return $scope.widgetReady(widget) && $scope.holder.title ? widget.settings.project.pkey + ' - ' + $scope.holder.title : '';
    };
    $scope.getUrl = function() {
        return $scope.widgetReady(widget) ? 'p/' + widget.settings.project.pkey + '/#/' + widget.settings.chart.view : '';
    };
    $scope.refreshProjects = function(term) {
        if (widget.settings && widget.settings.project && !$scope.holder.projectResolved) {
            ProjectService.get(widget.settings.project.id).then(function(project) {
                $scope.holder.projectResolved = true;
                $scope.holder.project = project;
                //$scope.project = project; // Required for projectChartCtrl
            });
        }
        ProjectService.listByUser({term: term, paginate: true}).then(function(projectsAndCount) {
            $scope.projects = projectsAndCount.projects;
            if (!term && widget.settings && widget.settings.project && !_.find($scope.projects, {id: widget.settings.project.id})) {
                $scope.projects.unshift(widget.settings.project);
            }
        });
    };
    $scope.initChartTypeSelected = function(projectChartEntries) {
        if (!$scope.holder.chartResolved) {
            $scope.holder.chartResolved = true;
            if (widget.settings && widget.settings.chart) {
                $scope.holder.chart = _.find(projectChartEntries, widget.settings.chart);
            }
        }
    };
    $scope.projectChanged = function() { // Use callback instead of direct model linking to filter data before sending it
        widget.settings.project = _.pick($scope.holder.project, ['id', 'pkey']);
        //$scope.project = $scope.holder.project; // Required for projectChartCtrl
        widget.type = 'project';
        widget.typeId = $scope.holder.project.id;
    };
    $scope.chartChanged = function() { // Use callback instead of direct model linking to filter data before sending it
        widget.settings.chart = _.pick($scope.holder.chart, ['id', 'type', 'group', 'view']);
    };
    var addTitleAndCaption = function(data) {
        $scope.holder.title = data.options.title.text;
    };
    $scope.display = function(widget) {
        if ($scope.widgetReady(widget)) {
            var chartWidgetOptions = _.merge($scope.getChartWidgetOptions(widget), {
                chart: {
                    height: function($element) {
                        return $element ? $element.find('.panel-body')[0].getBoundingClientRect().height : 0;
                    }
                },
                title: {
                    enable: false
                },
                caption: {
                    enable: false
                }
            });
            switch (widget.settings.chart.type) {
                case 'release':
                    ReleaseService.getCurrentOrNextRelease(widget.settings.project).then(function(release) {
                        if (release && release.id) {
                            $scope.openChart('release', widget.settings.chart.id, release, chartWidgetOptions).then(addTitleAndCaption);
                        }
                    });
                    break;
                case 'sprint':
                    SprintService.getCurrentOrLastSprint(widget.settings.project).then(function(sprint) {
                        if (sprint && sprint.id) {
                            sprint.parentRelease.parentProject = widget.settings.project;
                            $scope.openChart('sprint', widget.settings.chart.id, sprint, chartWidgetOptions).then(addTitleAndCaption);
                        }
                    });
                    break;
                default:
                    $scope.openChart('project', widget.settings.chart.id, widget.settings.project, chartWidgetOptions).then(addTitleAndCaption);
                    break;
            }
        }
    };
    // Init
    if (!widget.settings) {
        widget.settings = {};
    }
    if (!widget.settings.height) {
        widget.settings.height = 2;
    }
    if (!widget.settings.width) {
        widget.settings.width = 2;
    }
    $scope.holder = {};
    $scope.projects = [];
    $scope.widths = [1, 2, 3];
    $scope.heights = [1, 2, 3];
}]);
