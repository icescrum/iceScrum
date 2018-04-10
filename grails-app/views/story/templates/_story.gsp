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

<script type="text/ng-template" id="story.html">
<div fast-tooltip
     ng-style="(story.feature ? story.feature.color : '#f9f157') | createGradientBackground:disabledGradient ? disabledGradient : isAsListPostit(viewName)"
     class="postit story"
     ng-class="[((story.feature ? story.feature.color : '#f9f157') | contrastColor), (story.type | storyType)]" is-watch="story">
    <div as-sortable-item-handle>
        <div class="head">
            <div class="head-left">
                <span class="id">{{:: story.uid }}</span>
                <a href
                   class="follow {{:: story | followedByUser:'active' }}"
                   fast-tooltip-el="{{:: story.followers_ids.length }} ${message(code: 'todo.is.ui.followers')}"
                   ng-click="follow(story)">
                    <i class="fa fa-star"></i>
                    <i class="fa fa-star-o"></i>
                </a>
                <entry:point id="story-head-left"/>
            </div>
            <div class="head-right">
                <entry:point id="story-head-right"/>
                <span class="value editable"
                      ng-click="showEditValueModal(story, $event)"
                      ng-if=":: story.value">
                    {{:: story.value }} <i class="fa fa-line-chart" fast-tooltip-el="${message(code: 'is.story.value')}"></i>
                </span>
                <span class="estimation editable"
                      ng-if=":: story.state > 1"
                      ng-click="showEditEffortModal(story, $event)">
                    {{:: story.effort != undefined ? story.effort : '?' }} <i class="fa fa-dollar" fast-tooltip-el="${message(code: 'is.story.effort')}"></i>
                </span>
            </div>
        </div>
        <div class="content" ng-class="::{'without-description':!story.description}">
            <h3 class="title">{{:: story.name }}</h3>
            <div class="description"
                 ng-bind-html=":: story.description | lineReturns | actorTag"></div>
        </div>
        <div class="footer">
            <div class="tags">
                <icon-badge class="pull-right" tooltip="${message(code: 'is.backlogelement.tags')}"
                            href="{{:: openStoryUrl(story.id)}}"
                            icon="fa-tags"
                            max="3"
                            hide="true"
                            count="story.tags.length"/>
                <a ng-repeat="tag in ::story.tags"
                   href="{{:: tagContextUrl(tag) }}">
                    <span class="tag">{{:: tag }}</span>
                </a>
            </div>
            <div class="actions">
                <icon-badge tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}"
                            href="{{:: openStoryUrl(story.id)}}"
                            icon="fa-paperclip"
                            count="story.attachments_count"/>
                <icon-badge classes="comments"
                            tooltip="${message(code: 'todo.is.ui.comments')}"
                            href="{{:: openStoryUrl(story.id) }}/comments"
                            icon="fa-comment"
                            icon-empty="fa-comment-o"
                            count="story.comments_count"/>
                <icon-badge tooltip="${message(code: 'todo.is.ui.tasks')}"
                            href="{{:: openStoryUrl(story.id) }}/tasks"
                            icon="fa-tasks"
                            count="story.tasks_count"/>
                <icon-badge classes="acceptances-tests"
                            tooltip="${message(code: 'todo.is.ui.acceptanceTests')}"
                            href="{{:: openStoryUrl(story.id) }}/tests"
                            icon="fa-check-square"
                            icon-empty="fa-check-square-o"
                            count="story.acceptanceTests_count"/>
                <span postit-menu="item.menu.html" ng-init="itemType = 'story'" class="action"><a><i class="fa fa-ellipsis-h"></i></a></span>
            </div>
            <div class="state-progress">
                <div ng-if="::tasksProgress(story)" class="progress">
                    <span class="status">{{:: story.countDoneTasks + '/' + story.tasks_count }}</span>
                    <div class="progress-bar"
                         ng-class="::['bg-'+(story.testState | acceptanceTestColor)]"
                         ng-style="::{width: (story.countDoneTasks | percentProgress:story.tasks_count) + '%'}">
                    </div>
                </div>
                <div class="state"
                     ng-class="::{'hover-progress':tasksProgress(story)}">{{:: story.state | i18n:'StoryStates' }}
                </div>
            </div>
        </div>
    </div>
</div>
</script>