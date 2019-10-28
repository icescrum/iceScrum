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
<script type="text/ng-template" id="feature.details.html">
<div class="card"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, feature)"
     flow-drop-enabled="authorizedFeature('upload', feature)"
     flow-drag-enter="dropClass='card drop-enabled'"
     flow-drag-leave="dropClass='card'"
     ng-class="authorizedFeature('upload', feature) && dropClass">
    <div class="details-header">
        <entry:point id="feature-details-right-title"/>
        <a ng-if="previousFeature && !isModal"
           class="btn btn-icon"
           role="button"
           tabindex="0"
           hotkey="{'left': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
           tooltip-placement="bottom"
           href="{{ currentStateUrl(previousFeature.id) }}">
            <span class="icon icon-caret-left"></span>
        </a>
        <a ng-if="!isModal"
           class="btn btn-icon"
           ng-class="nextFeature ? 'visible' : 'invisible'"
           role="button"
           tabindex="0"
           hotkey="{'right': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
           tooltip-placement="bottom"
           href="{{ currentStateUrl(nextFeature ? nextFeature.id : feature.id) }}">
            <span class="icon icon-caret-right"></span>
        </a>
        <a class="btn btn-icon expandable"
           ng-if="!isModal && !application.focusedDetailsView"
           href="{{ toggleFocusUrl() }}"
           tabindex="0"
           uib-tooltip="${message(code: 'is.ui.window.focus')} (SHIFT+↑)"
           tooltip-placement="bottom"
           hotkey="{'space': hotkeyClick, 'shift+up': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.window.focus')}">
            <span class="icon icon-expand"></span>
        </a>
        <a class="btn btn-icon expandable"
           ng-if="!isModal && application.focusedDetailsView"
           href="{{ toggleFocusUrl() }}"
           tabindex="0"
           uib-tooltip="${message(code: 'is.ui.window.unfocus')} (SHIFT+↓)"
           tooltip-placement="bottom"
           hotkey="{'escape': hotkeyClick, 'shift+down': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.window.unfocus')}">
            <span class="icon icon-compress"></span>
        </a>
        <details-layout-buttons remove-ancestor="!$state.includes('feature.**')"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-id">{{ ::feature.uid }}</span>
                <span class="item-name" title="{{ feature.name }}">{{ feature.name }}</span>
                <entry:point id="feature-details-left-title"/>
            </div>
            <div class="btn-menu" uib-dropdown>
                <shortcut-menu ng-model="feature" model-menus="menus" view-type="'details'" btn-sm="true"></shortcut-menu>
                <div uib-dropdown-toggle></div>
                <div uib-dropdown-menu ng-init="itemType = 'feature'" template-url="item.menu.html"></div>
            </div>
        </div>
        <a href="{{ tabUrl('activities') }}"><visual-states ng-model="feature" model-states="featureStatesByName"/></a>
    </div>
    <div class="details-content-container">
        <div class="details-content details-content-left">
            <ul class="nav nav-tabs nav-justified disable-active-link">
                <li role="presentation"
                    class="nav-item text-nowrap">
                    <a href="{{ tabUrl() }}"
                       class="nav-link"
                       ng-class="{'active':!$state.params.featureTabId}">
                        ${message(code: 'todo.is.ui.details')}
                    </a>
                </li>
                <li role="presentation"
                    class="nav-item text-nowrap"
                    ng-if="!application.focusedDetailsView">
                    <a href="{{ tabUrl('comments') }}"
                       class="nav-link"
                       ng-class="{'active':$state.params.featureTabId == 'comments'}">
                        ${message(code: 'todo.is.ui.comments')} {{ feature.comments_count | parens }}
                    </a>
                </li>
                <li role="presentation"
                    class="nav-item text-nowrap"
                    ng-if="!application.focusedDetailsView">
                    <a href="{{ tabUrl('stories') }}"
                       class="nav-link"
                       ng-class="{'active':$state.params.featureTabId == 'stories'}">
                        ${message(code: 'todo.is.ui.stories')} {{ feature.stories_ids.length | parens }}
                    </a>
                </li>
                <li role="presentation"
                    class="nav-item text-nowrap">
                    <a href="{{ tabUrl('activities') }}"
                       class="nav-link"
                       ng-class="{'active':$state.params.featureTabId == 'activities'}">
                        ${message(code: 'todo.is.ui.history')}
                    </a>
                </li>
                <entry:point id="feature-details-tab-button"/>
            </ul>
            <div ui-view="details-tab">
                <g:include view="feature/templates/_feature.properties.gsp"/>
            </div>
        </div>
        <div ng-if="application.focusedDetailsView" class="details-content details-content-center">
            <ul class="nav nav-tabs nav-justified disable-active-link">
                <li role="presentation"
                    class="nav-item">
                    <a href
                       class="nav-link active">
                        ${message(code: 'todo.is.ui.comments')} {{ feature.comments_count | parens }}
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
                        ${message(code: 'todo.is.ui.stories')} {{ feature.stories_ids.length | parens }}
                    </a>
                </li>
            </ul>
            <div ui-view="details-tab-right"></div>
        </div>
    </div>
</div>
</script>
