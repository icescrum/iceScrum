%{--
- Copyright (c) 2015 Kagilum.
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
<script type="text/ng-template" id="feature.details.html">
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, feature)"
     flow-drop-enabled="authorizedFeature('upload', feature)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedFeature('upload', feature) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-puzzle-piece" ng-style="{color: feature.color}"></i> <strong>{{ ::feature.uid }}</strong>&nbsp;<span class="item-name" title="{{ feature.name }}">{{ feature.name }}</span>
                <entry:point id="feature-details-left-title"/>
            </div>
            <div class="right-title">
                <div style="margin-bottom:10px">
                    <entry:point id="feature-details-right-title"/>
                    <div class="btn-group">
                        <a ng-if="previousFeature && !isModal"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           ui-sref=".({featureId: previousFeature.id})"><i class="fa fa-caret-left" title="${message(code: 'is.ui.backlogelement.toolbar.previous')}"></i></a>
                        <a ng-if="nextFeature && !isModal"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           ui-sref=".({featureId: nextFeature.id})"><i class="fa fa-caret-right" title="${message(code: 'is.ui.backlogelement.toolbar.next')}"></i></a>
                    </div>
                    <details-layout-buttons ng-if="!isModal" remove-ancestor="!$state.includes('feature.**')"/>
                </div>
                <div class="btn-group shortcut-menu" role="group">
                    <shortcut-menu ng-model="feature" model-menus="menus" view-type="'details'"></shortcut-menu>
                    <div ng-class="['btn-group dropdown', {'dropup': application.minimizedDetailsView}]" uib-dropdown>
                        <button type="button" class="btn btn-default" uib-dropdown-toggle>
                            <i ng-class="['fa', application.minimizedDetailsView ? 'fa-caret-up' : 'fa-caret-down']"></i>
                        </button>
                        <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'feature'" template-url="item.menu.html"></ul>
                    </div>
                </div>
            </div>
        </h3>
        <visual-states ng-model="feature" model-states="featureStatesByName"/>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified">
        <li role="presentation" ng-class="{'active':!$state.params.featureTabId}">
            <a href="{{ tabUrl() }}">
                <i class="fa fa-lg fa-edit"></i> ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.featureTabId == 'activities'}">
            <a href="{{ tabUrl('activities') }}">
                <i class="fa fa-lg fa-clock-o"></i> ${message(code: 'todo.is.ui.history')}
            </a>
        </li>
        <li role="presentation" ng-if="workspaceType == 'project'" ng-class="{'active':$state.params.featureTabId == 'stories'}">
            <a href="{{ tabUrl('stories') }}">
                <i class="fa fa-lg fa-sticky-note"></i> ${message(code: 'todo.is.ui.stories')} {{ feature.stories_ids.length | parens }}
            </a>
        </li>
        <entry:point id="feature-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <g:include view="feature/templates/_feature.properties.gsp"/>
    </div>
</div>
</script>
