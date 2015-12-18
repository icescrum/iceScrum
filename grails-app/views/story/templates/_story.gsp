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
<div ellipsis
     style="{{ (story.feature ? story.feature.color : '#f9f157') | createGradientBackground }}"
     class="postit {{ (story.feature ? story.feature.color : '#f9f157') | contrastColor }} {{ story.type | storyType }}">
    <div class="head">
        <a href
           class="follow"
           uib-tooltip="{{ story.followers_count }} ${message(code: 'todo.is.ui.followers')}"
           ng-click="follow(story)"
           ng-switch="story.followed"><i class="fa fa-star-o" ng-switch-default></i><i class="fa fa-star" ng-switch-when="true"></i></a>
        <span class="id">{{ ::story.uid }}</span>
        <span class="value editable"
              uib-tooltip="${message(code: 'is.story.value')}"
              ng-click="showEditValueModal(story)"
              ng-if="story.value">
            {{ story.value }} <i class="fa fa-line-chart"></i>
        </span>
        <span class="estimation editable"
              uib-tooltip="${message(code: 'is.story.effort')}"
              ng-if="story.state > 1"
              ng-click="showEditEffortModal(story)">
            {{ story.effort != undefined ? story.effort : '?' }} <i class="fa fa-dollar"></i>
        </span>
    </div>
    <div class="content" as-sortable-item-handle-if="sortableStory">
        <h3 class="title ellipsis-el"
            ng-model="story.name"
            ng-bind-html="story.name | sanitize"></h3>
        <div class="description ellipsis-el"
             ng-model="story.description"
             ng-bind-html="story.description | sanitize"></div>
    </div>
</div>
</script>