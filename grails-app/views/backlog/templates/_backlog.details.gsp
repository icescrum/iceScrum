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
                <i class="fa fa-inbox"></i> {{ backlog | i18nName }}
                <i class="fa fa-share-alt"
                   ng-if="backlog.shared && !backlog.isDefault"
                   uib-tooltip="${message(code: 'is.ui.backlog.share')}"></i>
                <entry:point id="backlog-details-left-title"/>
            </div>
            <div class="right-title">
                <entry:point id="backlog-details-right-title"/>
                <span ng-if="backlog.owner" uib-tooltip="${message(code: 'is.story.creator')} {{ backlog.owner | userFullName }}">
                    <img ng-src="{{ backlog.owner | userAvatar }}" alt="{{ backlog.owner | userFullName }}" class="{{ backlog.owner | userColorRoles }}" height="30px"/>
                </span>
                <div class="btn-group">
                    <button class="btn btn-default minimizable"
                            ng-click="toggleMinimizedDetailsView()"
                            uib-tooltip="${message(code: 'is.ui.window.minimize')}">
                        <i ng-class="['fa', {'fa-window-minimize': !application.minimizedDetailsView, 'fa-window-maximize': application.minimizedDetailsView}]"></i>
                    </button>
                    <button class="btn btn-default detachable"
                            ng-click="toggleDetachedDetailsView()"
                            uib-tooltip="${message(code: 'is.ui.window.detach')}">
                        <i class="fa fa-window-restore"></i>
                    </button>
                    <a class="btn btn-default"
                       ui-sref=".^"
                       uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                        <i class="fa fa-times"></i>
                    </a>
                </div>
            </div>
        </h3>
        <div class="col-md-6">
            <div ng-if="backlog.isDefault" ng-bind-html="backlog.notes_html"></div>
            <div ng-include="'story.table.multiple.sum.html'"></div>
        </div>
        <div class="col-md-6 backlogCharts chart" ng-controller="chartCtrl" ng-init="openChart('backlog', backlog.chartType, backlog)">
            <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
        </div>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified" ng-if="$state.current.data.displayTabs">
        <entry:point id="backlog-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <entry:point id="backlog-details-tab-details"/>
    </div>
</div>
</script>