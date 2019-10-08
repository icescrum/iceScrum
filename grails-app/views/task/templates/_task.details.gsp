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
<script type="text/ng-template" id="task.details.html">
<div class="card"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, task)"
     flow-drop-enabled="authorizedTask('upload', task)"
     flow-drag-enter="dropClass='card drop-enabled'"
     flow-drag-leave="dropClass='card'"
     ng-class="authorizedTask('upload', task) && dropClass">
    <div class="details-header">
        <entry:point id="task-details-right-title"/>
        <a ng-if="previousTask"
           class="btn btn-icon"
           role="button"
           tabindex="0"
           hotkey="{'left': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
           href="{{:: currentStateUrl(previousTask.id) }}">
            <span class="icon icon-caret-left"></span>
        </a>
        <a class="btn btn-icon"
           ng-class="nextTask ? 'visible' : 'invisible'"
           role="button"
           tabindex="0"
           hotkey="{'right': hotkeyClick}"
           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
           uib-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
           href="{{:: currentStateUrl(nextTask ? nextTask.id : task.id) }}">
            <span class="icon icon-caret-right"></span>
        </a>
        <details-layout-buttons remove-ancestor="true"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-id">{{ ::task.uid }}</span>
                <span class="item-name" title="{{ task.name }}">{{ task.name }}</span>
                <div>
                    <entry:point id="task-details-left-title"/>
                </div>
            </div>
            <div class="btn-menu" uib-dropdown>
                <shortcut-menu ng-model="task" model-menus="menus" view-type="'details'" btn-sm="true"></shortcut-menu>
                <div uib-dropdown-toggle></div>
                <div uib-dropdown-menu ng-init="itemType = 'task'" template-url="item.menu.html"></div>
            </div>
        </div>
        <a href="{{ tabUrl('activities') }}"><visual-states ng-model="task" model-states="taskStatesByName"/></a>
    </div>
    <ul class="nav nav-tabs nav-justified disable-active-link">
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl() }}"
               class="nav-link"
               ng-class="{'active':!$state.params.taskTabId}">
                ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl('comments') }}"
               class="nav-link"
               ng-class="{'active':$state.params.taskTabId == 'comments'}">
                ${message(code: 'todo.is.ui.comments')} {{ task.comments_count | parens }}
            </a>
        </li>
        <li role="presentation"
            class="nav-item">
            <a href="{{ tabUrl('activities') }}"
               class="nav-link"
               ng-class="{'active':$state.params.taskTabId == 'activities'}">
                ${message(code: 'todo.is.ui.history')}
            </a>
        </li>
        <entry:point id="task-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <g:include view="task/templates/_task.properties.gsp"/>
    </div>
</div>
</script>
