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
<div class="sticky-note"
     sticky-note-color="{{:: story.feature.color }}"
     ng-class=":: [((story.feature ? story.feature.color : '#f9f157') | contrastColor), (story.type | storyType)]">
    <div as-sortable-item-handle>
        <div class="sticky-note-head">
            <span class="id">{{:: story.uid }}</span>
            <div class="sticky-note-type-icon"></div>
        </div>
        <div class="sticky-note-content" ng-class="::{'has-description':!!story.description}">
            <div class="item-values">
                <span ng-if=":: story.state > 1"
                      ng-click="showEditEffortModal(story, $event)">
                    ${message(code: 'is.story.effort')} <strong>{{:: story.effort != undefined ? story.effort : '?' }}</strong>
                </span>
                <span ng-if=":: story.state > 1 && story.value">|</span>
                <span ng-click="showEditValueModal(story, $event)"
                      ng-if=":: story.value">
                    ${message(code: 'is.story.value')} <strong>{{:: story.value }}</strong>
                </span>
            </div>
            <div class="title">{{:: story.name }}</div>
            <div class="description"
                 ng-bind-html=":: story.description | lineReturns | actorTag"></div>
        </div>
        <div class="sticky-note-tags">
            <icon-badge class="float-right" tooltip="${message(code: 'is.backlogelement.tags')}"
                        href="{{:: openStoryUrl(story.id)}}"
                        icon="fa-tags"
                        max="3"
                        hide="true"
                        count="{{:: story.tags.length }}"/>
            <a ng-repeat="tag in ::story.tags"
               href="{{:: tagContextUrl(tag) }}">
                <span class="tag {{ getTagColor(tag, 'story') | contrastColor }}"
                      ng-style="{'background-color': getTagColor(tag, 'story') }">{{:: tag }}</span>
            </a>
        </div>
        <div class="sticky-note-actions">
            <icon-badge tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}"
                        href="{{:: openStoryUrl(story.id)}}"
                        icon="attach"
                        count="{{:: story.attachments_count }}"/>
            <icon-badge classes="comments"
                        tooltip="${message(code: 'todo.is.ui.comments')}"
                        href="{{:: openStoryUrl(story.id) }}/comments"
                        icon="comment"
                        count="{{:: story.comments_count }}"/>
            <icon-badge tooltip="${message(code: 'todo.is.ui.tasks')}"
                        href="{{:: openStoryUrl(story.id) }}/tasks"
                        icon="task"
                        count="{{:: story.tasks_count }}"/>
            <icon-badge classes="acceptances-tests"
                        tooltip="${message(code: 'todo.is.ui.acceptanceTests')}"
                        href="{{:: openStoryUrl(story.id) }}/tests"
                        icon="test"
                        count="{{:: story.acceptanceTests_count }}"/>
            <span sticky-note-menu="item.menu.html" ng-init="itemType = 'story'" class="action"><a class="action-link"><span class="action-icon action-icon-menu"></span></a></span>
        </div>
        <div class="sticky-note-state-progress">
            <div ng-if="::showStoryProgress(story)" class="progress">
                <span class="status">{{:: story.countDoneTasks + '/' + story.tasks_count }}</span>
                <div class="progress-bar"
                     ng-class="::['bg-'+(story.testState | acceptanceTestColor)]"
                     ng-style="::{width: (story.countDoneTasks | percentProgress:story.tasks_count) + '%'}">
                </div>
            </div>
            <div class="state"
                 ng-class="::{'hover-progress':showStoryProgress(story)}">{{:: story.state | i18n:'StoryStates' }}
            </div>
        </div>
    </div>
</div>
</script>