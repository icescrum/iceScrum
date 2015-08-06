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
     ui-selectable-list="actors"
     ng-class="view.asList ? 'list-group' : 'grid-group'"
     class="postits">
    <div ng-class="{ 'ui-selected': isSelected(actor) }"
         data-id="{{ actor.id }}"
         ng-repeat="actor in actors | orderBy:orderBy.current.id:orderBy.reverse"
         ng-controller="actorCtrl"
         class="postit-container">
        <div style="{{ '#f9f157' | createGradientBackground }}"
             class="postit actor #f9f157">
            <div class="head">
                <span class="id">{{ actor.id }}</span>
            </div>
            <div class="content">
                <h3 class="title"
                    ng-model="actor.name"
                    ng-bind-html="actor.name | sanitize"
                    ellipsis></h3>
                <div class="description"
                     ng-model="actor.description"
                     ng-bind-html="actor.description | sanitize"
                     ellipsis></div>
            </div>
            <div class="tags">
                <a ng-repeat="tag in actor.tags" href="#"><span class="tag">{{ tag }}</span></a>
            </div>
            <div class="actions">
                <span dropdown class="action">
                    <a dropdown-toggle
                       tooltip="${message(code: 'todo.is.ui.actions')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-cog"></i>
                    </a>
                    <ul class="dropdown-menu" ng-include="'actor.menu.html'"></ul>
                </span>
                <span class="action" ng-class="{'active':actor.attachments.length}"
                      tooltip="{{ actor.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                      tooltip-append-to-body="true">
                    <a><i class="fa fa-paperclip"></i></a>
                    <span class="badge" ng-show="actor.attachments.length">{{ actor.attachments.length }}</span>
                </span>
                <span class="action" ng-class="{'active':actor.stories_ids.length}">
                    <a href="#/actor/{{ actor.id }}/stories"
                       tooltip="{{ actor.stories_ids.length }} ${message(code:'todo.is.actor.stories')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-tasks"></i>
                        <span class="badge" ng-show="actor.stories_ids.length">{{ actor.stories_ids.length }}</span>
                    </a>
                </span>
            </div>
        </div>
    </div>
</div>