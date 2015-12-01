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
                    ng-class="{'shown':availableBacklog.shown}"
                    uib-tooltip="{{ availableBacklog.name }}"
                    tooltip-append-to-body="true"
                    ng-click="manageShownBacklog(availableBacklog)"
                    tooltip-placement="top">
                <i class="fa" ng-class="{'fa-circle-o':!availableBacklog.shown, 'fa-dot-circle-o':availableBacklog.shown}"></i>
                {{ availableBacklog.name }}
                <span class="badge">{{ availableBacklog.count }}</span>
            </button>
        </div>
        <div class="pull-right">
            <div class="btn-group btn-view visible-on-hover">
                <button type="button"
                        uib-tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
                        tooltip-append-to-body="true"
                        tooltip-placement="right"
                        ng-click="app.asList = !app.asList"
                        class="btn btn-default">
                    <span class="fa fa-th" ng-class="{'fa-th-list': app.asList, 'fa-th': !app.asList}"></span>
                </button>
                <g:if test="${params?.fullScreen}">
                    <button type="button"
                            class="btn btn-default"
                            ng-show="!app.isFullScreen"
                            ng-click="fullScreen()"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                            tooltip-append-to-body="true"
                            tooltip-placement="bottom"
                            hotkey="{'F': fullScreen }"><span class="fa fa-expand"></span>
                    </button>
                    <button type="button"
                            class="btn btn-default"
                            ng-show="app.isFullScreen"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')}"
                            tooltip-append-to-body="true"
                            tooltip-placement="bottom"
                            ng-click="fullScreen()"><span class="fa fa-compress"></span>
                    </button>
                </g:if>
            </div>
            <a type="button"
               ng-if="authorizedStory('create')"
               uib-tooltip="${message(code:'default.button.create.label')}"
               tooltip-append-to-body="true"
               tooltip-placement="right"
               href="#/{{ ::viewName }}/new"
               class="btn btn-primary">${message(code: "todo.is.ui.story.new")}</a>
        </div>
    </div>
    <hr>
</div>
<div class="backlogs-list-details">
    <div class="panel panel-light" ng-repeat="backlog in backlogs">
        <div class="panel-heading">
            <div class="btn-group">
                <button type="button"
                        class="btn"
                        ng-class="backlog.sortable ? 'btn-success' : 'btn-danger'"
                        ng-click="orderBacklogByRank(backlog)"
                        uib-tooltip="${message(code:'todo.is.ui.changeRank')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-hand-pointer-o"></span>
                </button>
                <div class="btn-group"
                     uib-dropdown
                     is-open="backlog.orderBy.status"
                     tooltip-append-to-body="true"
                     uib-tooltip="${message(code:'todo.is.ui.sort')}">
                    <button class="btn btn-default" uib-dropdown-toggle type="button">
                        <span id="sort">{{ backlog.orderBy.current.name }}</span>
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
                        uib-tooltip="${message(code:'todo.is.ui.order')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-sort-amount{{ backlog.orderBy.reverse ? '-desc' : '-asc'}}"></span>
                </button>
            </div>
            <div class="btn-group" tooltip-append-to-body="true" uib-dropdown uib-tooltip="${message(code:'todo.is.ui.export')}">
                <g:if test="${params?.printable}">
                    <button type="button"
                            class="btn btn-default"
                            uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                            tooltip-append-to-body="true"
                            tooltip-placement="bottom"
                            ng-click="print($event)"
                            ng-href="backlog/{{ ::backlog.id }}/print"
                            hotkey="{'P': hotkeyClick }"><span class="fa fa-print"></span>
                    </button>
                </g:if>
                <button class="btn btn-default" uib-dropdown-toggle type="button">
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
                        tooltip-placement="bottom"
                        ng-if="backlogs.length > 1"
                        tooltip-append-to-body="true"
                        ng-click="manageShownBacklog(backlog)"
                        uib-tooltip="${message(code:'is.ui.window.closeable')}">
                    <span class="fa fa-times"></span>
                </button>
            </div>
        </div>
        <div class="panel-body" ng-class="{'loading': !backlog.storiesRendered}">
            <div class="panel-loading" ng-include="'loading.html'"></div>
            <div class="postits {{ backlog.sortable ? '' : 'sortable-disabled' }}"
                 as-sortable="backlogSortable"
                 is-disabled="!backlog.sortable"
                 ng-model="backlog.stories"
                 ng-class="app.asList ? 'list-group' : 'grid-group'"
                 ng-include="'story.html'">
            </div>
        </div>
    </div>
</div>