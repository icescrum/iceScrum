%{--
- Copyright (c) 2016 Kagilum.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<form ng-switch-when="true"
      ng-controller="ChartWidgetCtrl"
      ng-submit="update(widget)"
      class="form-horizontal">
    <div class="form-group">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.charts.title')}">{{ $select.selected.id }}</ui-select-match>
                <ui-select-choices repeat="chart in charts">{{chart.id}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
    <div class="form-group" ng-if="widget.settings.chart.project">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.projects.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.chart.projects.title')}">{{ $select.selected.name }}</ui-select-match>
                <ui-select-choices repeat="project in projects">{{project.name}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
    <div class="form-group" ng-if="widget.settings.chart.release">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.releases.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.chart.releases.title')}">{{ $select.selected.name }}</ui-select-match>
                <ui-select-choices repeat="release in releases">{{release.name}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
    <div class="form-group" ng-if="widget.settings.chart.sprint">
        <label class="col-sm-2">${message(code: 'todo.is.ui.widget.chart.sprints.list')}</label>
        <div class="col-sm-7">
            <ui-select class="form-control"
                       ng-model="widget.settings.chart">
                <ui-select-match allow-clear="true" placeholder="${message(code: 'todo.is.ui.widget.chart.sprints.title')}">{{ $select.selected.name }}</ui-select-match>
                <ui-select-choices repeat="release in releases">{{sprint.name}}</ui-select-choices>
            </ui-select>
        </div>
    </div>
</form>