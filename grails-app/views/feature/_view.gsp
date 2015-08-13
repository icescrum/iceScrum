<%@ page import="org.icescrum.core.domain.Story; grails.converters.JSON" %>
%{--
- Copyright (c) 2014 Kagilum SAS.
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
<div id="backlog-layout-window-${controllerName}"
     ui-selectable="selectableOptions"
     ui-selectable-list="features"
     ng-class="view.asList ? 'list-group' : 'grid-group'"
     class="postits">
    <div ng-class="{ 'ui-selected': isSelected(feature) }"
         data-id="{{ feature.id }}"
         ng-repeat="feature in features | orderBy:orderBy.current.id:orderBy.reverse"
         ng-controller="featureCtrl"
         class="postit-container">
        <div style="{{ feature.color | createGradientBackground }}"
             class="postit story {{ feature.color | contrastColor }} {{ feature.type | featureType }}">
            <div class="head">
                <span class="id">{{ feature.id }}</span>
                <span class="value" ng-if="feature.value">{{ feature.value }} <i class="fa fa-line-chart"></i></span>
            </div>
            <div class="content">
                <h3 class="title"
                    ng-model="feature.name"
                    ng-bind-html="feature.name | sanitize"
                    ellipsis></h3>
                <div class="description"
                     ng-model="feature.description"
                     ng-bind-html="feature.description | sanitize"
                     ellipsis></div>
            </div>
            <div class="tags">
                <a ng-repeat="tag in feature.tags" href="#"><span class="tag">{{ tag }}</span></a>
            </div>
            <div class="actions">
                <span dropdown class="action">
                    <a dropdown-toggle
                       tooltip="${message(code: 'todo.is.ui.actions')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-cog"></i>
                    </a>
                    <ul class="dropdown-menu"
                        ng-include="'feature.menu.html'"></ul>
                </span>
                <span class="action"
                      ng-class="{'active':feature.attachments.length}"
                      tooltip="{{ feature.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                      tooltip-append-to-body="true">
                    <a><i class="fa fa-paperclip"></i></a>
                    <span class="badge" ng-show="feature.attachments.length">{{ feature.attachments.length }}</span>
                </span>
                <span class="action" ng-class="{'active':feature.stories_ids.length}">
                    <a href="#/feature/{{ feature.id }}/stories"
                       tooltip="{{ feature.stories_ids.length }} ${message(code:'todo.is.feature.stories')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-tasks"></i>
                        <span class="badge" ng-show="feature.stories_ids.length">{{ feature.stories_ids.length }}</span>
                    </a>
                </span>
            </div>
            <div class="progress">
                <span class="status">3/6</span>
                <div class="progress-bar" style="width:16.666666666666668%">
                </div>
            </div>
            <div class="state">{{ feature.state | i18n:'FeatureStates' }}</div>
        </div>
    </div>
</div>