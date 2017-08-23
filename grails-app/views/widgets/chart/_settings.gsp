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
        <label>${message(code: 'is.ui.widget.chart.project')}</label>
        <ui-select class="form-control"
                   search-enabled="true"
                   append-to-body="true"
                   ng-change="projectChanged()"
                   ng-model="holder.project">
            <ui-select-match placeholder="${message(code: 'is.ui.widget.chart.no.project')}">{{ $select.selected.name }}</ui-select-match>
            <ui-select-choices repeat="proj in projects track by $index"
                               refresh="refreshProjects($select.search)"
                               refresh-delay="150">{{proj.name}}</ui-select-choices>
        </ui-select>
    </div>
    <div ng-if="holder.project"
         ng-controller="projectChartCtrl"
         class="form-group">
        <label>${message(code: 'is.ui.widget.chart.chart')}</label>
        <ui-select class="form-control"
                   search-enabled="true"
                   append-to-body="true"
                   ng-change="settingsChanged()"
                   ng-model="holder.chart">
            <ui-select-match placeholder="${message(code: 'is.ui.widget.chart.no.chart')}">{{ $select.selected.name }}</ui-select-match>
            <ui-select-choices group-by="'group'"
                               refresh="initChartTypeSelected(projectChartEntries)"
                               repeat="chart in projectChartEntries">{{chart.name}}</ui-select-choices>
        </ui-select>
    </div>
    <div class="form-group">
        <label>${message(code: 'is.ui.widget.height')}</label>
        <ui-select class="form-control"
                   append-to-body="true"
                   ng-change="settingsChanged()"
                   ng-model="holder.height">
            <ui-select-match>{{ $select.selected }}</ui-select-match>
            <ui-select-choices repeat="height in heights">{{ height }}</ui-select-choices>
        </ui-select>
    </div>
    <div class="form-group">
        <label>${message(code: 'is.ui.widget.width')}</label>
        <ui-select class="form-control"
                   append-to-body="true"
                   ng-change="settingsChanged()"
                   ng-model="holder.width">
            <ui-select-match>{{ $select.selected }}</ui-select-match>
            <ui-select-choices repeat="width in widths">{{ width }}</ui-select-choices>
        </ui-select>
    </div>
</div>
