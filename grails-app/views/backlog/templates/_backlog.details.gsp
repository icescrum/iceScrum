%{--
- Copyright (c) 2017 Kagilum.
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
<script type="text/ng-template" id="backlog.details.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-inbox"></i> <span class="item-name" title="{{ backlog | i18nName }}">{{ backlog | i18nName }}</span>
                <i class="fa fa-share-alt"
                   ng-if="backlog.shared && !backlog.isDefault"
                   defer-tooltip="${message(code: 'is.ui.backlog.share')}"></i>
            </div>
            <div class="right-title">
                <entry:point id="backlog-details-right-title"/>
                <span ng-if="backlog.owner" defer-tooltip="${message(code: 'is.story.creator')} {{ backlog.owner | userFullName }}">
                    <img ng-src="{{ backlog.owner | userAvatar }}" alt="{{ backlog.owner | userFullName }}" class="{{ backlog.owner | userColorRoles }}" height="30px"/>
                </span>
                <details-layout-buttons ng-if="!isModal"/>
            </div>
        </h3>
        <div class="col-md-6">
            <div ng-if="backlog.isDefault" ng-bind-html="backlog.notes_html"></div>
            <div ng-include="'story.table.multiple.sum.html'"></div>
        </div>
        <entry:point id="backlog-details-chart-before"/>
        <div class="col-md-6 backlogCharts chart" ng-controller="backlogChartCtrl">
            <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
        </div>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified disable-active-link" ng-if="$state.current.data.displayTabs">
        <entry:point id="backlog-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <entry:point id="backlog-details-tab-details"/>
    </div>
</div>
</script>