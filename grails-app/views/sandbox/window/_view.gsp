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
     ui-selectable-list="stories"
     ng-class="view.asList ? 'list-group' : 'grid-group'"
     class="postits">
    <div ng-class="{ 'ui-selected': isSelected(story) }"
         data-id="{{ story.id }}"
         ng-repeat="story in stories | filter: $state.current.data.filterListParams | orderBy:orderBy.current.id:orderBy.reverse"
         ng-controller="storyCtrl"
         class="postit-container">
        <div style="{{ (story.feature ? story.feature.color : '#f9f157') | createGradientBackground }}"
             class="postit story {{ (story.feature ? story.feature.color : '#f9f157') | contrastColor }}">
            <div class="head">
                <a href
                   class="follow"
                   tooltip="{{ story.followers_count }} ${message(code: 'todo.is.ui.followers')}"
                   tooltip-append-to-body="true"
                   ng-click="follow(story)"
                   ng-switch="story.followed"><i class="fa fa-star-o" ng-switch-default></i><i class="fa fa-star" ng-switch-when="true"></i></a>
                <span class="id">{{ story.id }}</span>
                <span class="estimation">{{ story.effort ? story.effort + ' pt' : '' }}</span>
            </div>
            <div class="content">
                <h3 class="title" ng-bind-html="story.name | sanitize" ellipsis></h3>
                <div class="description" ng-bind-html="story.description | sanitize" ellipsis></div>
            </div>
            <div class="footer">
                <div class="tags">
                    <a ng-repeat="tag in story.tags" href="#"><span class="tag">{{ tag }}</span></a>
                </div>
                <div class="actions">
                    <span class="action">
                        <a data-toggle="dropdown"
                           tooltip="${message(code: 'todo.is.ui.actions')}"
                           tooltip-append-to-body="true">
                            <i class="fa fa-cog"></i>
                        </a>
                        <ul class="dropdown-menu" ng-include="'story.menu.html'"></ul>
                    </span>
                    <span class="action" ng-class="{'active':story.attachments_count}">
                        <a href="#/sandbox/{{ story.id }}/attachments"
                           tooltip="{{ story.attachments_count }} ${message(code:'todo.is.backlogelement.attachments')}"
                           tooltip-append-to-body="true">
                            <i class="fa fa-paperclip"></i>
                            <span class="badge" ng-show="story.attachments_count">{{ story.attachments_count }}</span>
                        </a>
                    </span>
                    <span class="action" ng-class="{'active':story.comments_count}">
                        <a href="#/sandbox/{{ story.id }}/comments"
                           tooltip="{{ story.comments_count }} ${message(code:'todo.is.story.comments')}"
                           tooltip-append-to-body="true"
                           ng-switch="story.comments_count">
                            <i class="fa fa-comment-o" ng-switch-when="0"></i>
                            <i class="fa fa-comment" ng-switch-default></i>
                            <span class="badge" ng-show="story.comments_count">{{ story.comments_count }}</span>
                        </a>
                    </span>
                    <span class="action" ng-class="{'active':story.tasks_count}">
                        <a href="#/sandbox/{{ story.id }}/tasks"
                           tooltip="{{ story.tasks_count }} ${message(code:'todo.is.story.tasks')}"
                           tooltip-append-to-body="true">
                            <i class="fa fa-tasks"></i>
                            <span class="badge" ng-show="story.tasks_count">{{ story.tasks_count }}</span>
                        </a>
                    </span>
                    <span class="action" ng-class="{'active':story.acceptanceTests_count}">
                        <a href="#/sandbox/{{ story.id }}/tests"
                           tooltip="{{ story.acceptanceTests_count }} ${message(code:'todo.is.acceptanceTests')}"
                           tooltip-append-to-body="true"
                           ng-switch="story.acceptanceTests_count">
                            <i class="fa fa-check-square-o" ng-switch-when="0"></i>
                            <i class="fa fa-check-square" ng-switch-default></i>
                            <span class="badge" ng-if="story.acceptanceTests_count">{{ story.acceptanceTests_count }}</span>
                        </a>
                    </span>
                </div>
            </div>
            <!-- TODO remove
                <div class="progress">
                <span class="status">3/6</span>
                <div class="progress-bar" style="width:16.666666666666668%">
                </div>
            </div>
            <div class="state" title="{{ story.state | i18n:'storyState' }}">{{ story.state | i18n:'storyState' }}</div>-->
        </div>
    </div>
</div>
<script>
    angular.element(document).injector().get('StoryService').addStories(${stories as JSON});
</script>