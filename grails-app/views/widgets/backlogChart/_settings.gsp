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
<div class="col-md-12">
    <div class="form-group">
        <label for="chartType">${message(code: 'is.backlogs.ui.backlog.chartType')}</label>
        <ui-select class="form-control"
                   name="chartType"
                   append-to-body="true"
                   ng-change="settingsChanged()"
                   ng-model="holder.chartType">
            <ui-select-match>{{ $select.selected | i18n:'BacklogChartTypes' }}</ui-select-match>
            <ui-select-choices repeat="chartType in backlogChartTypes">{{ ::chartType | i18n:'BacklogChartTypes' }}</ui-select-choices>
        </ui-select>
    </div>
    <div class="form-group">
        <label>${message(code: 'is.ui.widget.chart.project')}</label>
        <ui-select class="form-control"
                   search-enabled="true"
                   append-to-body="true"
                   ng-model="holder.project">
            <ui-select-match placeholder="${message(code: 'is.ui.widget.chart.no.project')}">{{ $select.selected.name }}</ui-select-match>
            <ui-select-choices repeat="proj in projects track by $index"
                               refresh="refreshProjects($select.search)"
                               refresh-delay="150">{{proj.name}}</ui-select-choices>
        </ui-select>
    </div>
    <div ng-if="holder.project"
         class="form-group">
        <label>${message(code: 'is.ui.backlog')}</label>
        <ui-select class="form-control"
                   search-enabled="true"
                   append-to-body="true"
                   ng-change="settingsChanged()"
                   ng-model="holder.backlog">
            <ui-select-match placeholder="${message(code: 'is.ui.widget.backlog.no.backlog')}">{{ message($select.selected.name) }}</ui-select-match>
            <ui-select-choices refresh="refreshBacklogs()"
                               repeat="backlog in holder.backlogs">{{ message(backlog.name) }}</ui-select-choices>
        </ui-select>
    </div>
</div>
