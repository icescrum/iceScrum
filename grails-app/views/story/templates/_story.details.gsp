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
<script type="text/ng-template" id="story.details.html">
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, story)"
     flow-drop-enabled="authorizedStory('upload', story)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedStory('upload', story) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-sticky-note" ng-style="{color: story.feature ? story.feature.color : '#f9f157'}"></i>
                <strong>{{ ::story.uid }}</strong>
                <span uib-tooltip="{{ story.followers_count }} ${message(code: 'todo.is.ui.followers')}"
                      ng-click="follow(story)">
                    <i class="fa" ng-class="story.followed ? 'fa-star' : 'fa-star-o'"></i>
                </span>
                <span class="item-name" title="{{ story.name }}">{{ story.name }}</span>&nbsp;<small ng-show="story.origin">${message(code: 'is.story.origin')}: {{ story.origin }}</small>
                <div style="margin-top:10px">
                    <entry:point id="story-details-left-title"/>
                </div>
            </div>
            <div class="right-title">
                <div style="margin-bottom:10px">
                    <entry:point id="story-details-right-title"/>
                    <span uib-tooltip="${message(code: 'is.story.creator')} {{ story.creator | userFullName }}">
                        <img ng-src="{{ story.creator | userAvatar }}" alt="{{ story.creator | userFullName }}" class="{{ story.creator | userColorRoles }}"
                             height="30px"/>
                    </span>
                    <a ng-if="previousStory"
                       class="btn btn-default"
                       role="button"
                       tabindex="0"
                       href="{{:: currentStateUrl(previousStory.id) }}"><i class="fa fa-caret-left" title="${message(code: 'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="nextStory"
                       class="btn btn-default"
                       role="button"
                       tabindex="0"
                       href="{{:: currentStateUrl(nextStory.id) }}"><i class="fa fa-caret-right" title="${message(code: 'is.ui.backlogelement.toolbar.next')}"></i></a>
                    <details-layout-buttons ng-if="!isModal" close-url="closeDetailsView(true)"/>
                </div>
                <div class="btn-group shortcut-menu" role="group">
                    <shortcut-menu ng-model="story" model-menus="menus" view-type="'details'"></shortcut-menu>
                    <div ng-class="['btn-group dropdown', {'dropup': application.minimizedDetailsView}]" uib-dropdown>
                        <button type="button" class="btn btn-default" uib-dropdown-toggle>
                            <i ng-class="['fa', application.minimizedDetailsView ? 'fa-caret-up' : 'fa-caret-down']"></i>
                        </button>
                        <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'story'" template-url="item.menu.html"></ul>
                    </div>
                </div>
            </div>
        </h3>
        <visual-states ng-model="story" model-states="storyStatesByName"/>
        <entry:point id="story-details-before-tabs"/>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified">
        <li role="presentation" ng-class="{'active':!$state.params.storyTabId}">
            <a href="{{ tabUrl() }}">
                <i class="fa fa-lg fa-edit"></i> ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.storyTabId == 'activities'}">
            <a href="{{ tabUrl('activities') }}">
                <i class="fa fa-lg fa-clock-o"></i> ${message(code: 'todo.is.ui.history')}
            </a>
        </li>
        <li role="presentation"
            class="hidden-sm"
            ng-class="{'active':$state.params.storyTabId == 'comments'}">
            <a href="{{ tabUrl('comments') }}">
                <i class="fa fa-lg" ng-class="story.comments_count ? 'fa-comment' : 'fa-comment-o'"></i> ${message(code: 'todo.is.ui.comments')} {{ story.comments_count | parens }}
            </a>
        </li>
        <li role="presentation"
            class="hidden-sm hidden-md"
            ng-class="{'active':$state.params.storyTabId == 'tasks'}">
            <a href="{{ tabUrl('tasks') }}">
                <i class="fa fa-lg fa-tasks"></i> ${message(code: 'todo.is.ui.tasks')} {{ story.tasks_count | parens }}
            </a>
        </li>
        <li role="presentation" class="dropdown display-on-hover">
            <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                ${message(code: 'todo.is.ui.more')} <span class="fa fa-caret-down"></span>
            </a>
            <ul class="dropdown-menu dropdown-more dropdown-menu-right">
                <li role="presentation"
                    class="visible-sm-block"
                    ng-class="{'active':$state.params.storyTabId == 'comments'}">
                    <a href="{{ tabUrl('comments') }}">
                        <i class="fa fa-lg" ng-class="story.comments_count ? 'fa-comment' : 'fa-comment-o'"></i> ${message(code: 'todo.is.ui.comments')} {{ story.comments_count | parens }}
                    </a>
                </li>
                <li role="presentation"
                    class="visible-sm-block visible-md-block"
                    ng-class="{'active':$state.params.storyTabId == 'tasks'}">
                    <a href="{{ tabUrl('tasks') }}">
                        <i class="fa fa-lg fa-tasks"></i> ${message(code: 'todo.is.ui.tasks')} {{ story.tasks_count | parens }}
                    </a>
                </li>
                <li role="presentation" ng-class="{'active':$state.params.storyTabId == 'tests'}">
                    <a href="{{ tabUrl('tests') }}">
                        <i class="fa fa-lg" ng-class="story.acceptanceTests_count ? 'fa-check-square' : 'fa-check-square-o'"></i> ${message(code: 'todo.is.ui.acceptanceTests')} {{ story.acceptanceTests_count | parens }}
                    </a>
                </li>
                <entry:point id="story-details-tab-button"/>
            </ul>
        </li>
    </ul>
    <div ui-view="details-tab">
        <g:include view="story/templates/_story.properties.gsp"/>
    </div>
</div>
</script>