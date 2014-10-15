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
             class="postit story {{ feature.color | contrastColor }}">
            <div class="head">
                <span class="id">{{ feature.id }}</span>
                <span class="estimation">{{ feature.value ? feature.value : '' }}</span>
            </div>
            <div class="content">
                <h3 class="title" ng-bind-html="feature.name | sanitize" ellipsis></h3>
                <div class="description" ng-bind-html="feature.description | sanitize" ellipsis></div>
            </div>
            <div class="tags">
                <a ng-repeat="tag in feature.tags" href="#"><span class="tag">{{ tag }}</span></a>
            </div>
            <div class="actions">
                <span class="action">
                    <a data-toggle="dropdown"
                       ng-class="{ disabled: !authorizedFeature('menu') }"
                       tooltip="${message(code: 'todo.is.ui.actions')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-cog"></i>
                    </a>
                    <ul class="dropdown-menu"
                        ng-include="'feature.menu.html'"></ul>
                </span>
                <span class="action" ng-class="{'active':feature.attachments_count}">
                    <a href="#/feature/{{ feature.id }}/attachments"
                       tooltip="{{ feature.attachments_count }} ${message(code:'todo.is.backlogelement.attachments')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-paperclip"></i>
                        <span class="badge" ng-show="feature.attachments_count">{{ feature.attachments_count }}</span>
                    </a>
                </span>
                <span class="action" ng-class="{'active':feature.stories_count}">
                    <a href="#/feature/{{ feature.id }}/stories"
                       tooltip="{{ feature.stories_count }} ${message(code:'todo.is.feature.stories')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-tasks"></i>
                        <span class="badge" ng-show="feature.stories_count">{{ feature.stories_count }}</span>
                    </a>
                </span>
            </div>
            <div class="progress">
                <span class="status">3/6</span>
                <div class="progress-bar" style="width:16.666666666666668%">
                </div>
            </div>
            <div class="state">{{ feature.state | i18n:'featureState' }}</div>
        </div>
    </div>
</div>