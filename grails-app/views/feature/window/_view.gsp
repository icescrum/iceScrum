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
<div ui-selectable
     id="backlog-layout-window-${controllerName}"
     class="postits list-group">
    <div ng-repeat="feature in features"
         class="postit-container item grid-group-item">
        <div style="{{ feature.color | createGradientBackground }}"
             class="postit story {{ feature.color | contrastColor }}">
            <div class="head">
                <span class="id">{{ feature.id }}</span>
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
                    <a href="#" tooltip="${message(code: 'todo.is.feature.actions')}" tooltip-append-to-body="true">
                        <i class="fa fa-cog"></i>
                    </a>
                </span>
                <span class="action" ng-class="{'active':feature.attachments_count}">
                    <a href="#/feature/{{ feature.id }}/attachments"
                       tooltip="{{ feature.attachments_count }} ${message(code:'todo.is.backlogelement.attachments')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-paperclip"></i>
                    </a>
                </span>
                <span class="action" ng-class="{'active':feature.stories_count}">
                    <a href="#/feature/{{ feature.id }}/tasks"
                       tooltip="{{ feature.stories_count }} ${message(code:'todo.is.feature.stories')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-tasks"></i>
                        <span class="badge" ng-show="feature.stories_count">{{ feature.stories_count }}</span>
                    </a>
                </span>
            </div>
        </div>
    </div>
</div>