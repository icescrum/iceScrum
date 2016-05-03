<%@ page import="org.icescrum.core.domain.Story; grails.converters.JSON" %>
%{--
- Copyright (c) 2014 Kagilum SAS.
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
<is:window windowDefinition="${windowDefinition}">
    <div class="backlogs-list">
        <div class="btn-toolbar">
            <div class="btn-group" ng-repeat="availableBacklog in availableBacklogs">
                <a class="btn btn-default btn-backlog pin"
                   href="{{ togglePinBacklogUrl(availableBacklog) }}"
                   ng-class="{'shown': isShown(availableBacklog)}"
                   tooltip-placement="right"
                   uib-tooltip="{{ isPinned(availableBacklog) ? '${message(code: /todo.is.ui.backlog.pinned/)}' : '${message(code: /todo.is.ui.backlog.pin/)}' }}">
                    <i class="fa" ng-class="{'pinned': isPinned(availableBacklog)}"></i>
                </a>
                <a class="btn btn-default btn-backlog"
                   href="{{ toggleBacklogUrl(availableBacklog) }}"
                   ng-class="{'shown': isShown(availableBacklog)}">
                    {{ availableBacklog | backlogName }}
                    <span class="badge">{{ availableBacklog.count }}</span>
                </a>
            </div>
            <entry:point id="backlog-window-toolbar"/>
            <div class="pull-right">
                <div class="btn-group btn-view visible-on-hover">
                    <button type="button"
                            uib-tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
                            ng-click="app.asList = !app.asList"
                            class="btn btn-default">
                        <i class="fa fa-th" ng-class="{'fa-th-list': app.asList, 'fa-th': !app.asList}"></i>
                    </button>
                    <g:if test="${params?.fullScreen}">
                        <button type="button"
                                class="btn btn-default"
                                ng-show="!app.isFullScreen"
                                ng-click="fullScreen()"
                                uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                                hotkey="{'F': fullScreen }"><i class="fa fa-expand"></i>
                        </button>
                        <button type="button"
                                class="btn btn-default"
                                ng-show="app.isFullScreen"
                                uib-tooltip="${message(code:'is.ui.window.fullscreen')}"
                                ng-click="fullScreen()"><i class="fa fa-compress"></i>
                        </button>
                    </g:if>
                </div>
                <div class="btn-group btn-view">
                    <button type="button"
                            class="btn btn-default"
                            ng-click="toggleSelectableMultiple()"
                            uib-tooltip="{{ app.selectableMultiple ? '${message(code: /todo.is.ui.selectable.multiple.disable/)}' : '${message(code: /todo.is.ui.selectable.multiple.enable/)}' }}">
                        <i class="fa fa-object-ungroup" ng-class="app.selectableMultiple ? 'text-success' : 'text-danger'"></i>
                    </button>
                </div>
                <a ng-if="authorizedStory('create')"
                   href="#/{{ ::viewName }}/sandbox/story/new"
                   class="btn btn-primary">${message(code: "todo.is.ui.story.new")}</a>
            </div>
        </div>
        <hr>
    </div>
    <div class="backlogs-list-details"
         selectable="selectableOptions">
        <div class="panel panel-light" ng-repeat="backlogContainer in backlogContainers">
            <div class="panel-heading">
                <div class="btn-group">
                    <button type="button"
                            ng-if="backlogContainer.sortable"
                            class="btn btn-default"
                            ng-click="enableSortable(backlogContainer)"
                            tooltip-placement="right"
                            uib-tooltip="{{ backlogContainer.sorting ? '${message(code: /todo.is.ui.sortable.enabled/)}' : '${message(code: /todo.is.ui.sortable.enable/)}' }}">
                        <i ng-class="backlogContainer.sorting ? 'text-success' : 'text-danger forbidden-stack'" class="fa fa-hand-pointer-o"></i>
                    </button>
                    <div class="btn-group"
                         uib-dropdown
                         uib-tooltip="${message(code:'todo.is.ui.sort')}">
                        <button class="btn btn-default" uib-dropdown-toggle type="button">
                            <span>{{ backlogContainer.orderBy.current.name }}</span>
                            <span class="caret"></span>
                        </button>
                        <ul uib-dropdown-menu role="menu">
                            <li role="menuitem" ng-repeat="order in backlogContainer.orderBy.values">
                                <a ng-click="changeBacklogOrder(backlogContainer, order)" href>{{ order.name }}</a>
                            </li>
                        </ul>
                    </div>
                    <button type="button" class="btn btn-default"
                            ng-click="reverseBacklogOrder(backlogContainer)"
                            uib-tooltip="${message(code:'todo.is.ui.order')}">
                        <i class="fa fa-sort-amount{{ backlogContainer.orderBy.reverse ? '-desc' : '-asc'}}"></i>
                    </button>
                </div>
                <a class="btn btn-default"
                   ui-sref="backlog.backlog.details({backlogCode: backlogContainer.backlog.code})"
                   uib-tooltip="${message(code: 'todo.is.ui.details')}">
                    <i class="fa fa-pencil-square-o "></i>
                </a>
                <div class="btn-group" uib-dropdown>
                    <g:if test="${params?.printable}">
                        <button type="button"
                                class="btn btn-default"
                                uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                                ng-click="print($event)"
                                ng-href="backlog/{{ ::backlogContainer.backlog.id }}/print"
                                hotkey="{'P': hotkeyClick }"><i class="fa fa-print"></i>
                        </button>
                    </g:if>
                    <button class="btn btn-default"
                            uib-tooltip="${message(code:'todo.is.ui.export')}"
                            uib-dropdown-toggle type="button">
                        <i class="fa fa-download"></i>&nbsp;<span class="caret"></span>
                    </button>
                    <ul uib-dropdown-menu
                        role="menu">
                        <g:each in="${is.exportFormats(windowDefinition:windowDefinition)}" var="format">
                            <li role="menuitem">
                                <a href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}&id={{ ::backlogContainer.backlog.id }}"
                                   ng-click="print($event)">${format.name}</a>
                            </li>
                        </g:each>
                    </ul>
                </div>
                <div class="btn-group pull-right visible-on-hover">
                    <a href="{{ closeBacklogUrl(backlogContainer.backlog) }}"
                       class="btn btn-default"
                       ng-if="backlogContainers.length > 1"
                       uib-tooltip="${message(code:'is.ui.window.closeable')}">
                        <i class="fa fa-times"></i>
                    </a>
                </div>
            </div>
            <div class="panel-body" ng-class="{'loading': !backlogContainer.storiesLoaded}">
                <div class="panel-loading" ng-include="'loading.html'"></div>
                <div class="postits {{ (backlogContainer.sorting ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '')  + ' ' + (app.sortableMoving ? 'sortable-moving' : '')}} "
                     ng-controller="storyCtrl"
                     as-sortable="backlogSortableOptions | merge: sortableScrollOptions()"
                     is-disabled="!backlogContainer.sorting"
                     ng-model="backlogContainer.backlog.stories"
                     ng-class="app.asList ? 'list-group' : 'grid-group'"
                     ng-init="backlog = backlogContainer.backlog"
                     ng-include="'story.backlog.html'">
                </div>
            </div>
        </div>
    </div>
</is:window>