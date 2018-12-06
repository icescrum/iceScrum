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

controllers.controller('backlogChartWidgetCtrl', ['$scope', 'BacklogService', 'ProjectService', 'CacheService', '$controller', '$element', function($scope, BacklogService, ProjectService, CacheService, $controller, $element) {
    $controller('chartWidgetCtrl', {$scope: $scope, $element: $element});
    var widget = $scope.widget; // $scope.widget is inherited
    $scope.widgetReady = function(widget) {
        return !!(widget.settings && widget.settings.backlog && widget.settings.chartType && widget.settings.chartUnit);
    };
    $scope.getTitle = function() {
        return $scope.holder.title;
    };
    $scope.getUrl = function() {
        return $scope.widgetReady(widget) ? 'p/' + widget.settings.backlog.project.pkey + '/#/backlog/' + widget.settings.backlog.code : '';
    };
    $scope.refreshProjects = function(term) {
        if (widget.settings && widget.settings.backlog && widget.settings.backlog.project && !$scope.holder.projectResolved) {
            ProjectService.get(widget.settings.backlog.project.id).then(function(project) {
                $scope.holder.projectResolved = true;
                $scope.holder.project = project;
            });
        }
        ProjectService.listByUser({term: term}).then(function(projectsAndCount) {
            $scope.projects = projectsAndCount.projects;
            if (!term && widget.settings && widget.settings.backlog && !_.find($scope.projects, {id: widget.settings.backlog.project.id})) {
                $scope.projects.unshift(widget.settings.backlog.project);
            }
        });
    };
    $scope.refreshBacklogs = function() {
        if (widget.settings && widget.settings.backlog && !$scope.holder.backlogResolved) {
            BacklogService.get(widget.settings.backlog.id, widget.settings.backlog.project).then(function(backlog) {
                $scope.holder.backlogResolved = true;
                $scope.holder.backlog = backlog;
            });
        }
        BacklogService.list($scope.holder.project).then(function(backlogs) {
            $scope.holder.backlogs = backlogs;
        });
    };
    $scope.projectChanged = function() {
        $scope.holder.backlog = null;
        widget.settings.backlog = null;
        $scope.holder.backlogs = null;
        $scope.refreshBacklogs();
    };
    $scope.backlogChanged = function() { // Use callback instead of direct model linking to filter data before sending it
        widget.type = 'backlog';
        widget.typeId = $scope.holder.backlog.id;
        widget.settings.backlog = {
            id: $scope.holder.backlog.id,
            code: $scope.holder.backlog.code,
            project: {
                id: $scope.holder.project.id,
                pkey: $scope.holder.project.pkey
            }
        };
    };
    $scope.display = function(widget) {
        if ($scope.widgetReady(widget)) {
            var chartWidgetOptions = _.merge($scope.getChartWidgetOptions(widget), {
                chart: {
                    height: function($element) {
                        return $element ? $element.find('.card-body')[0].getBoundingClientRect().height : 0;
                    },
                    margin: {top: 0, right: 0, bottom: 0, left: 0}
                },
                title: {
                    enable: false
                },
                caption: {
                    enable: false
                }
            });
            var unit = widget.settings.chartUnit;
            var chartName = widget.settings.chartType + (unit ? '-' + unit : ''); // Hack to preserve the chartLoaderInterface while using an additional parameter
            $scope.openChart('backlog', chartName, widget.settings.backlog, chartWidgetOptions).then(function(data) {
                $scope.holder.title = data.options.title.text;
                $scope.holder.caption = data.options.caption.text;
            });
        }
    };
    // Init
    if (!widget.settings) {
        widget.settings = {
            chartType: 'type'
        };
    }
    if (!widget.settings.chartUnit) {
        widget.settings.chartUnit = 'story';
    }
    $scope.holder = {
        title: ''
    };
}]);
