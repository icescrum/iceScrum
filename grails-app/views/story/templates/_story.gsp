%{--
- Copyright (c) 2014 Kagilum.
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

<script type="text/ng-template" id="story.html">
<div ng-class="{ 'ui-selected': isSelected(story) }"
     data-id="{{ story.id }}"
     ng-repeat="story in filteredAndSortedStories"
     ng-controller="storyCtrl"
     class="postit-container">
    <div style="{{ (story.feature ? story.feature.color : '#f9f157') | createGradientBackground }}"
         class="postit story {{ (story.feature ? story.feature.color : '#f9f157') | contrastColor }} {{ story.type | storyType }}">
        <div class="head">
            <a href
               class="follow"
               tooltip="{{ story.followers_count }} ${message(code: 'todo.is.ui.followers')}"
               tooltip-append-to-body="true"
               ng-click="follow(story)"
               ng-switch="story.followed"><i class="fa fa-star-o" ng-switch-default></i><i class="fa fa-star" ng-switch-when="true"></i></a>
            <span class="id">{{ story.id }}</span>
            <span class="value editable ui-selectable-cancel"
                  tooltip="${message(code: 'is.story.value')}"
                  tooltip-append-to-body="true"
                  ng-click="showEditValueModal(story)"
                  ng-if="story.value">
                    {{ story.value }} <i class="fa fa-line-chart"></i>
            </span>
            <span class="estimation editable ui-selectable-cancel"
                  tooltip="${message(code: 'is.story.effort')}"
                  tooltip-append-to-body="true"
                  ng-if="story.state > 1"
                  ng-click="showEditEffortModal(story)">
                {{ story.effort != undefined ? story.effort : '?' }} <i class="fa fa-dollar"></i>
            </span>
        </div>
        <div class="content">
            <h3 class="title"
                ng-model="story.name"
                ng-bind-html="story.name | sanitize"
                ellipsis></h3>
            <div class="description"
                 ng-model="story.description"
                 ng-bind-html="story.description | sanitize"
                 ellipsis></div>
        </div>
        <div class="footer">
            <div class="tags">
                <a ng-repeat="tag in story.tags" href="#"><span class="tag">{{ tag }}</span></a>
            </div>
            <div class="actions">
                <span dropdown class="action">
                    <a dropdown-toggle
                       tooltip="${message(code: 'todo.is.ui.actions')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-cog"></i>
                    </a>
                    <ul class="dropdown-menu" ng-include="'story.menu.html'"></ul>
                </span>
                <span class="action"
                      ng-class="{'active':story.attachments.length}"
                      tooltip="{{ story.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                      tooltip-append-to-body="true">
                    <a><i class="fa fa-paperclip"></i></a>
                    <span class="badge" ng-show="story.attachments.length">{{ story.attachments.length }}</span>
                </span>
                <span class="action" ng-class="{'active':story.comments_count}">
                    <a href
                       ng-click="goToTab(story, 'comments')"
                       tooltip="{{ story.comments_count }} ${message(code:'todo.is.story.comments')}"
                       tooltip-append-to-body="true"
                       ng-switch="story.comments_count">
                        <i class="fa fa-comment-o" ng-switch-when="0"></i>
                        <i class="fa fa-comment" ng-switch-default></i>
                        <span class="badge" ng-show="story.comments_count">{{ story.comments_count }}</span>
                    </a>
                </span>
                <span class="action" ng-class="{'active':story.tasks_count}">
                    <a href
                       ng-click="goToTab(story, 'tasks')"
                       tooltip="{{ story.tasks_count }} ${message(code:'todo.is.story.tasks')}"
                       tooltip-append-to-body="true">
                        <i class="fa fa-tasks"></i>
                        <span class="badge" ng-show="story.tasks_count">{{ story.tasks_count }}</span>
                    </a>
                </span>
                <span class="action" ng-class="{'active':story.acceptanceTests_count}">
                    <a href
                       ng-click="goToTab(story, 'tests')"
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
        <div ng-if="story.state > 1" class="progress">
            <span class="status">{{ story.state < 6 ? story.state : 6 }}/6</span>
            <div class="progress-bar" style="width: {{ story.state | stateProgress }}%">
            </div>
        </div>
        <div ng-if="story.state > 1" class="state" title="{{ story.state | i18n:'storyState' }}">{{ story.state | i18n:'storyState' }}</div>
    </div>
</div>
</script>
