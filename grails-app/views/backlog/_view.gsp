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
<div class="backlogs-list">
    <div class="btn-toolbar">
        <div class="btn-group" ng-repeat="availableBacklog in availableBacklogs">
            <button class="btn btn-default btn-backlog"
                    ng-class="{'shown': availableBacklog.shown}"
                    ng-click="pinBacklog(availableBacklog)">
                <i class="fa" ng-class="availableBacklog.pinned ? 'fa-dot-circle-o' : 'fa-circle-o'"></i>

            </button>
            <button class="btn btn-default btn-backlog"
                    ng-class="{'shown': availableBacklog.shown}"
                    ng-click="toggleBacklog(availableBacklog)">
                {{ availableBacklog.isDefault ? message(availableBacklog.name) : availableBacklog.name }}
                <span class="badge">{{ availableBacklog.count }}</span>
            </button>
        </div>
        <div class="btn-group">
            <button class="btn btn-primary" unavailable-feature="true">
                <i class="fa fa-plus"></i>
            </button>
        </div>
        <div class="pull-right">
            <div class="btn-group btn-view visible-on-hover">
                <button type="button"
                        uib-tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
                        unavailable-feature="true"
                        class="btn btn-default">
                    <span class="fa fa-th" ng-class="{'fa-th-list': app.asList, 'fa-th': !app.asList}"></span>
                </button>
                <g:if test="${params?.fullScreen}">
                    <button type="button"
                            class="btn btn-default"
                            ng-show="!app.isFullScreen"
                            ng-click="fullScreen()"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                            hotkey="{'F': fullScreen }"><span class="fa fa-expand"></span>
                    </button>
                    <button type="button"
                            class="btn btn-default"
                            ng-show="app.isFullScreen"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')}"
                            ng-click="fullScreen()"><span class="fa fa-compress"></span>
                    </button>
                </g:if>
            </div>
            <div class="btn-group btn-view">
                <button type="button"
                        class="btn btn-default"
                        ng-click="toggleSelectableMultiple()"
                        uib-tooltip="{{ app.selectableMultiple ? '${message(code: /todo.is.ui.selectable.multiple.disable/)}' : '${message(code: /todo.is.ui.selectable.multiple.enable/)}' }}">
                    <span class="fa fa-object-ungroup" ng-class="app.selectableMultiple ? 'text-success' : 'text-danger'"></span>
                </button>
            </div>
            <a type="button"
               ng-if="authorizedStory('create')"
               href="#/{{ ::viewName }}/new"
               class="btn btn-primary">${message(code: "todo.is.ui.story.new")}</a>
        </div>
    </div>
    <hr>
</div>
<div class="backlogs-list-details"
     selectable="selectableOptions">
    <div class="panel panel-light" ng-repeat="backlog in backlogs">
        <div class="panel-heading">
            <div class="btn-group">
                <button type="button"
                        ng-if="backlog.sortable"
                        class="btn btn-default"
                        ng-click="enableSortable(backlog)"
                        uib-tooltip="{{ backlog.sorting ? '${message(code: /todo.is.ui.sortable.enabled/)}' : '${message(code: /todo.is.ui.sortable.enable/)}' }}">
                    <span ng-class="backlog.sorting ? 'text-success' : 'text-danger forbidden-stack'" class="fa fa-hand-pointer-o"></span>
                </button>
                <div class="btn-group"
                     uib-dropdown
                     uib-tooltip="${message(code:'todo.is.ui.sort')}">
                    <button class="btn btn-default" uib-dropdown-toggle type="button">
                        <span>{{ backlog.orderBy.current.name }}</span>
                        <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu" role="menu">
                        <li role="menuitem" ng-repeat="order in backlog.orderBy.values">
                            <a ng-click="changeBacklogOrder(backlog, order)" href>{{ order.name }}</a>
                        </li>
                    </ul>
                </div>
                <button type="button" class="btn btn-default"
                        ng-click="reverseBacklogOrder(backlog)"
                        uib-tooltip="${message(code:'todo.is.ui.order')}">
                    <span class="fa fa-sort-amount{{ backlog.orderBy.reverse ? '-desc' : '-asc'}}"></span>
                </button>
            </div>
            <div class="btn-group" uib-dropdown>
                <g:if test="${params?.printable}">
                    <button type="button"
                            class="btn btn-default"
                            uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                            ng-click="print($event)"
                            ng-href="backlog/{{ ::backlog.id }}/print"
                            hotkey="{'P': hotkeyClick }"><span class="fa fa-print"></span>
                    </button>
                </g:if>
                <button class="btn btn-default"
                        uib-tooltip="${message(code:'todo.is.ui.export')}"
                        uib-dropdown-toggle type="button">
                    <span class="fa fa-download"></span>&nbsp;<span class="caret"></span>
                </button>
                <ul class="uib-dropdown-menu"
                    role="menu">
                    <g:each in="${is.exportFormats()}" var="format">
                        <li role="menuitem">
                            <a href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}&id={{ ::backlog.id }}"
                               ng-click="print($event)">${format.name}</a>
                        </li>
                    </g:each>
                    <entry:point id="${controllerName}-toolbar-export" model="[product:params.product, origin:controllerName]"/>
                </ul>
            </div>
            <div class="btn-group pull-right visible-on-hover">
                <entry:point id="${controllerName}-${actionName}-toolbar-right"/>
                <button type="button"
                        class="btn btn-default"
                        ng-if="backlogs.length > 1"
                        ng-click="toggleBacklog(backlog)"
                        uib-tooltip="${message(code:'is.ui.window.closeable')}">
                    <span class="fa fa-times"></span>
                </button>
            </div>
        </div>
        <div class="panel-body" ng-class="{'loading': !backlog.storiesLoaded}">
            <div class="panel-loading" ng-include="'loading.html'"></div>
            <div class="postits {{ (backlog.sorting ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '')  + ' ' + (app.sortableMoving ? 'sortable-moving' : '')}} "
                 ng-controller="storyCtrl"
                 as-sortable="backlogSortableOptions | merge: sortableScrollOptions()"
                 is-disabled="!backlog.sorting"
                 ng-model="backlog.stories"
                 ng-class="app.asList ? 'list-group' : 'grid-group'"
                 ng-include="'story.backlog.html'">
            </div>
        </div>
    </div>
</div>