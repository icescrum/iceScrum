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

<script type="text/ng-template" id="story.light.html">
<div fast-tooltip
     ng-style="(story.feature ? story.feature.color : '#f9f157') | createGradientBackground"
     class="postit story {{ ((story.feature ? story.feature.color : '#f9f157') | contrastColor) + ' ' + (story.type | storyType) }}">
    <div>
        <div class="head">
            <div class="head-left">
                <span class="id">{{ ::story.uid }}</span>
                <a href
                   class="follow {{:: story | followedByUser:'active' }}"
                   uib-tooltip="{{ story.followers_ids.length }} ${message(code: 'todo.is.ui.followers')}"
                   ng-click="follow(story)"><i class="fa" ng-class="story | followedByUser:'fa-star':'fa-star-o'"></i></a>
                <entry:point id="story-head-left"/>
            </div>
            <div class="head-right">
                <entry:point id="story-head-right"/>
                <span class="value editable"
                      ng-click="showEditValueModal(story, $event)"
                      ng-if="story.value">
                    {{ story.value }} <i class="fa fa-line-chart" fast-tooltip-el="${message(code: 'is.story.value')}"></i>
                </span>
                <span class="estimation editable"
                      ng-if="story.state > 1"
                      ng-click="showEditEffortModal(story, $event)">
                    {{ story.effort != undefined ? story.effort : '?' }} <i class="fa fa-dollar" fast-tooltip-el="${message(code: 'is.story.effort')}"></i>
                </span>
            </div>
        </div>
        <div class="content" ng-class="{'without-description':!story.description}">
            <h3 class="title"><a href="{{ link }}" style="color: #555555; text-decoration:none;" ng-if="link">{{ story.name }}</a></h3>
            <h3 class="title" ng-if="!link">{{ story.name }}</h3>
            <div class="description"
                 ng-bind-html="story.description | lineReturns | actorTag"></div>
        </div>
        <div class="footer">
            <div class="tags">
                <a ng-repeat="tag in story.tags"
                   href="{{ tagContextUrl(tag) }}">
                    <span class="tag">{{ tag }}</span>
                </a>
            </div>
            <div class="actions">
                <span class="action" ng-class="{'active':story.attachments_count}">
                    <a href="{{ link ? link : openStoryUrl(story.id) }}">
                        <i class="fa fa-paperclip" fast-tooltip-el="${message(code: 'todo.is.ui.backlogelement.attachments')}"></i>
                        <span class="badge">{{ story.attachments_count || '' }}</span>
                    </a>
                </span>
                <span class="action" ng-class="{'active':story.comments_count}">
                    <a href="{{ link ? link : openStoryUrl(story.id) }}/comments">
                        <i class="fa" ng-class="story.comments_count ? 'fa-comment' : 'fa-comment-o'" fast-tooltip-el="${message(code: 'todo.is.ui.comments')}"></i>
                        <span class="badge">{{ story.comments_count  || '' }}</span>
                    </a>
                </span>
                <span class="action" ng-class="{'active':story.tasks_count}">
                    <a href="{{ link ? link : openStoryUrl(story.id) }}/tasks">
                        <i class="fa fa-tasks" fast-tooltip-el="${message(code: 'todo.is.ui.tasks')}"></i>
                        <span class="badge">{{ story.tasks_count || '' }}</span>
                    </a>
                </span>
                <span class="action" ng-class="{'active':story.acceptanceTests_count}">
                    <a href="{{ link ? link : openStoryUrl(story.id) }}/tests">
                        <i class="fa" ng-class="story.acceptanceTests_count ? 'fa-check-square' : 'fa-check-square-o'" fast-tooltip-el="${message(code: 'todo.is.ui.acceptanceTests')}"></i>
                        <span class="badge">{{ story.acceptanceTests_count  || '' }}</span>
                    </a>
                </span>
            </div>
            <div class="state-progress">
                <div ng-if="tasksProgress(story)" class="progress">
                    <span class="status">{{ story.countDoneTasks + '/' + story.tasks_count }}</span>
                    <div class="progress-bar"
                         ng-class="'bg-'+(story.testState | acceptanceTestColor)"
                         ng-style="{width: (story.countDoneTasks | percentProgress:story.tasks_count) + '%'}">
                    </div>
                </div>
                <div class="state" ng-class="{'hover-progress':tasksProgress(story)}">
                    <!-- special case hide state if shifted and ghost story -->
                    <span ng-if="!sprint || sprint.id == story.parentSprint.id">{{ story.state | i18n:'StoryStates' }}</span>
                    <span ng-if="sprint && sprint.id != story.parentSprint.id">{{ message('todo.is.ui.story.shifted') }}</span>
                </div>
            </div>
        </div>
    </div>
</div>
</script>