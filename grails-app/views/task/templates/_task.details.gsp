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
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, task)"
     flow-drop-enabled="authorizedTask('upload', task)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedTask('upload', task) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-file" ng-style="{color: task.color }"></i> <strong>{{:: task.uid }}</strong>&nbsp;<span class="item-name" title="{{ task.name }}">{{ task.name }}</span>
                <div style="margin-top:10px">
                    <entry:point id="task-details-left-title"/>
                </div>
            </div>
            <div class="right-title">
                <div style="margin-bottom:10px">
                    <entry:point id="task-details-right-title"/>
                    <span ng-if="task.responsible"
                          defer-tooltip="${message(code: 'is.task.responsible')} {{ task.responsible | userFullName }}">
                        <img ng-src="{{ task.responsible | userAvatar }}"
                             class="{{ task.responsible | userColorRoles }}"
                             alt="{{ task.responsible | userFullName }}"
                             height="30px"/>
                    </span>
                    <div class="btn-group">
                        <a ng-if="previousTask"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           hotkey="{'left': hotkeyClick}"
                           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.previous')}"
                           defer-tooltip="${message(code: 'is.ui.backlogelement.toolbar.previous')} (&#xf060;)"
                           href="{{:: currentStateUrl(previousTask.id) }}">
                            <i class="fa fa-caret-left"></i>
                        </a>
                        <a ng-if="nextTask"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           hotkey="{'right': hotkeyClick}"
                           hotkey-description="${message(code: 'is.ui.backlogelement.toolbar.next')}"
                           defer-tooltip="${message(code: 'is.ui.backlogelement.toolbar.next')} (&#xf061;)"
                           href="{{:: currentStateUrl(nextTask.id) }}">
                            <i class="fa fa-caret-right"></i>
                        </a>
                    </div>
                    <details-layout-buttons ng-if="!isModal" remove-ancestor="true"/>
                </div>
                <div class="btn-group shortcut-menu" role="group">
                    <shortcut-menu ng-model="task" model-menus="menus" view-type="'details'"></shortcut-menu>
                    <div ng-class="['btn-group dropdown', {'dropup': application.minimizedDetailsView}]" uib-dropdown>
                        <button type="button" class="btn btn-default" uib-dropdown-toggle>
                            <i ng-class="['fa', application.minimizedDetailsView ? 'fa-caret-up' : 'fa-caret-down']"></i>
                        </button>
                        <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'task'" template-url="item.menu.html"></ul>
                    </div>
                </div>
            </div>
        </h3>
        <a href="{{ tabUrl('activities') }}"><visual-states ng-model="task" model-states="taskStatesByName"/></a>
    </div>
    <ul class="nav nav-tabs nav-tabs-is nav-justified disable-active-link">
        <li role="presentation" ng-class="{'active':!$state.params.taskTabId}">
            <a href="{{ tabUrl() }}">
                <i class="fa fa-lg fa-edit"></i> ${message(code: 'todo.is.ui.details')}
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.taskTabId == 'comments'}">
            <a href="{{ tabUrl('comments') }}">
                <i class="fa fa-lg" ng-class="task.comments_count ? 'fa-comment' : 'fa-comment-o'"></i> ${message(code: 'todo.is.ui.comments')} {{ task.comments_count | parens }}
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.taskTabId == 'activities'}">
            <a href="{{ tabUrl('activities') }}">
                <i class="fa fa-lg fa-clock-o"></i> ${message(code: 'todo.is.ui.history')}
            </a>
        </li>
        <entry:point id="task-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <g:include view="task/templates/_task.properties.gsp"/>
    </div>
</div>
</script>
