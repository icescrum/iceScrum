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
        <div>
            <entry:point id="feature-details-right-title"/>
            <div class="btn-group">
                <a ng-if="previousFeature && !isModal"
                   class="btn btn-secondary"
                   role="button"
                   tabindex="0"
                   hotkey="{'left': hotkeyClick}"
                   hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
                   defer-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
                   ui-sref=".({featureId: previousFeature.id})">
                    <i class="fa fa-caret-left"></i>
                </a>
                <a ng-if="nextFeature && !isModal"
                   class="btn btn-secondary"
                   role="button"
                   tabindex="0"
                   hotkey="{'right': hotkeyClick}"
                   hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
                   defer-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
                   ui-sref=".({featureId: nextFeature.id})">
                    <i class="fa fa-caret-right"></i>
                </a>
            </div>
            <details-layout-buttons ng-if="!isModal" remove-ancestor="!$state.includes('feature.**')"/>
        </div>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="left-title">
                <strong>{{ ::feature.uid }}</strong>&nbsp;<span class="item-name" title="{{ feature.name }}">{{ feature.name }}</span>
                <entry:point id="feature-details-left-title"/>
            </div>
            <div class="btn-menu" uib-dropdown>
                <shortcut-menu ng-model="feature" model-menus="menus" view-type="'details'" btn-sm="true"></shortcut-menu>
                <div uib-dropdown-toggle></div>
                <div uib-dropdown-menu class="float-right" ng-init="itemType = 'feature'" template-url="item.menu.html"></div>
            </div>
        </div>
        <a href="{{ tabUrl('activities') }}"><visual-states ng-model="feature" model-states="featureStatesByName"/></a>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified disable-active-link">
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl() }}"
               class="nav-link"
               ng-class="{'active':!$state.params.featureTabId}">
                ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl('stories') }}"
               class="nav-link"
               ng-class="{'active':$state.params.featureTabId == 'stories'}">
                ${message(code: 'todo.is.ui.stories')} {{ feature.stories_ids.length | parens }}
            </a>
        </li>
        <li role="presentation"
            class="nav-item">
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
</script>
