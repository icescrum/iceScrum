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
<div class="form-group">
    <label class="col-sm-2">${message(code: 'is.ui.widget.chart.project')}</label>
    <div class="col-sm-6">
        <ui-select class="form-control"
                   search-enabled="true"
                   ng-model="widget.settings.project">
            <ui-select-match placeholder="${message(code: 'is.ui.widget.chart.no.project')}">{{ $select.selected.name }}</ui-select-match>
            <ui-select-choices repeat="proj in projects track by $index"
                               refresh="listProjects($select.search)"
                               refresh-delay="150">{{proj.name}}</ui-select-choices>
        </ui-select>
    </div>
</div>
<div class="form-group" ng-if="widget.settings.project">
    <label class="col-sm-2">${message(code: 'is.ui.widget.chart.chart')}</label>
    <div class="col-sm-6">
        <ui-select class="form-control"
                   search-enabled="true"
                   ng-model="widget.settings.chart">
            <ui-select-match placeholder="${message(code: 'is.ui.widget.chart.no.chart')}">{{ $select.selected.name }}</ui-select-match>
            <ui-select-choices repeat="chart in charts">{{chart.name}}</ui-select-choices>
        </ui-select>
    </div>
</div>
