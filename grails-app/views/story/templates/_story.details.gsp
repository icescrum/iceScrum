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
<div class="card"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, story)"
     flow-drop-enabled="authorizedStory('upload', story)"
     flow-drag-enter="dropClass='card drop-enabled'"
     flow-drag-leave="dropClass='card'"
     ng-class="authorizedStory('upload', story) && dropClass">
    <div class="details-header">
        <entry:point id="story-details-right-title"/>
        <a ng-if="previousStory()"
           class="btn btn-icon"
           role="button"
           tabindex="0"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
           tooltip-placement="bottom"
           hotkey="{'left': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
           href="{{ currentStateUrl(previousStory().id) }}">
            <span class="icon icon-caret-left"></span>
        </a>
        <a class="btn btn-icon"
           ng-class="nextStory() ? 'visible' : 'invisible'"
           role="button"
           tabindex="0"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
           tooltip-placement="bottom"
           hotkey="{'right': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
           href="{{ currentStateUrl(nextStory() ? nextStory().id : story.id) }}">
            <span class="icon icon-caret-right"></span>
        </a>
        <a class="btn btn-icon expandable"
           ng-if="!isModal && !application.focusedDetailsView"
           href="{{ toggleFocusUrl() }}"
           tabindex="0"
           uib-tooltip="${message(code: 'is.ui.window.focus')} (↑)"
           tooltip-placement="bottom"
           hotkey="{'space': hotkeyClick, 'up': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.window.focus')}">
            <span class="icon icon-expand"></span>
        </a>
        <a class="btn btn-icon expandable"
           ng-if="!isModal && application.focusedDetailsView"
           href="{{ toggleFocusUrl() }}"
           tabindex="0"
           uib-tooltip="${message(code: 'is.ui.window.unfocus')} (↓)"
           tooltip-placement="bottom"
           hotkey="{'escape': hotkeyClick, 'down': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.window.unfocus')}">
            <span class="icon icon-compress"></span>
        </a>
        <details-layout-buttons remove-ancestor="true"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-id">{{:: story.uid }}</span>
                <span class="item-name" title="{{ story.name }}">{{ story.name }}</span>
                <span defer-tooltip="{{ story.followers_ids.length }} ${message(code: 'todo.is.ui.followers')}"
                      ng-click="follow(story)">
                    <i class="fa" ng-class="story | followedByUser:'fa-star':'fa-star-o'"></i>
                </span>
                <div class="text-muted">
                    <small ng-show="story.origin">${message(code: 'is.story.origin')}: {{ story.origin }}</small>
                </div>
                <div>
                    <entry:point id="story-details-left-title"/>
                </div>
            </div>
            <div class="btn-menu" uib-dropdown>
                <shortcut-menu ng-model="story" model-menus="menus" view-type="'details'" btn-sm="true"></shortcut-menu>
                <div uib-dropdown-toggle></div>
                <div uib-dropdown-menu ng-init="itemType = 'story'" template-url="item.menu.html"></div>
            </div>
        </div>
        <entry:point id="story-details-before-states"/>
        <a href="{{ tabUrl('activities') }}"><visual-states ng-model="story" model-states="storyStatesByName"/></a>
        <entry:point id="story-details-before-tabs"/>
    </div>
    <div class="details-content-container">
        <div class="details-content details-content-left">
            <ul class="nav nav-tabs nav-justified disable-active-link">
                <li role="presentation"
                    class="nav-item text-nowrap">
                    <a href="{{ tabUrl() }}"
                       class="nav-link"
                       ng-class="{'active':!$state.params.storyTabId}">
                        ${message(code: 'todo.is.ui.details')}
                    </a>
                </li>
                <li role="presentation"
                    class="nav-item text-nowrap">
                    <a href="{{ tabUrl('comments') }}"
                       class="nav-link"
                       ng-class="{'active':$state.params.storyTabId == 'comments'}">
                        ${message(code: 'todo.is.ui.comments')} {{ story.comments_count | parens }}
                    </a>
                </li>
                <li role="presentation"
                    class="nav-item text-nowrap d-none d-md-block"
                    ng-if="!application.focusedDetailsView"
                    uib-tooltip="${message(code: 'todo.is.ui.acceptanceTests')}">
                    <a href="{{ tabUrl('tests') }}"
                       class="nav-link"
                       ng-class="getAcceptanceTestClass(story)">
                        <i class="{{ (story.testState | acceptanceTestIcon) }}"></i>
                        ${message(code: 'todo.is.ui.acceptanceTests.short')} {{ story.acceptanceTests_count | parens }}
                    </a>
                </li>
                <li role="presentation"
                    class="nav-item text-nowrap d-none d-lg-block"
                    ng-if="!application.focusedDetailsView">
                    <a href="{{ tabUrl('tasks') }}"
                       class="nav-link"
                       ng-class="{'active':$state.params.storyTabId == 'tasks'}">
                        ${message(code: 'todo.is.ui.tasks')} <span ng-bind-html="story | countAndRemaining"></span>
                    </a>
                </li>
                <li uib-dropdown
                    role="presentation"
                    class="nav-item display-on-hover">
                    <a class="nav-link"
                       ng-class="{'active': $state.params.storyTabId == 'activities'}"
                       uib-dropdown-toggle
                       role="button"
                       aria-haspopup="true"
                       aria-expanded="false"></a>
                    <div uib-dropdown-menu
                         class="dropdown-menu-right">
                        <a class="dropdown-item d-md-none"
                           uib-tooltip="${message(code: 'todo.is.ui.acceptanceTests')}"
                           ng-class="getAcceptanceTestClass(story)"
                           href="{{ tabUrl('tests') }}">
                            ${message(code: 'todo.is.ui.acceptanceTests.short')} {{ story.acceptanceTests_count | parens }}
                        </a>
                        <a class="dropdown-item d-lg-none"
                           ng-class="{'active':$state.params.storyTabId == 'tasks'}"
                           href="{{ tabUrl('tasks') }}">
                            ${message(code: 'todo.is.ui.tasks')} {{ story.tasks_count | parens }}
                        </a>
                        <a class="dropdown-item"
                           ng-class="{'active':$state.params.storyTabId == 'activities'}"
                           href="{{ tabUrl('activities') }}">
                            ${message(code: 'todo.is.ui.history')}
                        </a>
                        <entry:point id="story-details-tab-button"/>
                    </div>
                </li>
            </ul>
            <div ui-view="details-tab-left">
                <g:include view="story/templates/_story.properties.gsp"/>
            </div>
        </div>
        <div ng-if="application.focusedDetailsView" class="details-content details-content-center">
            <ul class="nav nav-tabs nav-justified disable-active-link">
                <li role="presentation"
                    class="nav-item">
                    <a href
                       class="nav-link"
                       ng-class="getAcceptanceTestClass(story)">
                        ${message(code: 'todo.is.ui.acceptanceTests')} {{ story.acceptanceTests_count | parens }}
                    </a>
                </li>
            </ul>
            <div ui-view="details-tab-center"></div>
        </div>
        <div ng-if="application.focusedDetailsView" class="details-content details-content-right">
            <ul class="nav nav-tabs nav-justified disable-active-link">
                <li role="presentation"
                    class="nav-item">
                    <a href
                       class="nav-link active">
                        ${message(code: 'todo.is.ui.tasks')} <span ng-bind-html="story | countAndRemaining"></span>
                    </a>
                </li>
            </ul>
            <div ui-view="details-tab-right"></div>
        </div>
    </div>
</div>
</script>