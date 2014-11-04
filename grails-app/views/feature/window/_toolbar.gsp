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
<div class="btn-group">
    <a type="button"
       ng-if="authorizedFeature('create')"
       tooltip="${message(code:'todo.is.ui.new')}"
       tooltip-append-to-body="true"
       href="#feature/new"
       class="btn btn-primary">
        <span class="fa fa-plus"></span>
    </a>
    <button type="button"
            tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
            tooltip-append-to-body="true"
            ng-click="view.asList = !view.asList"
            class="btn btn-default">
        <span class="glyphicon glyphicon-th" ng-class="{'glyphicon-th-list': view.asList, 'glyphicon-th': !view.asList}"></span>
    </button>
    <div class="btn-group"
         dropdown
         is-open="orderBy.status"
         tooltip-append-to-body="true"
         tooltip="${message(code:'todo.is.ui.sort')}">
        <button class="btn btn-default dropdown-toggle" type="button">
            <span id="sort">{{ orderBy.current.name }}</span>
            <span class="caret"></span>
        </button>
        <ul class="dropdown-menu" role="menu">
            <li role="menuitem" ng-repeat="order in orderBy.values">
                <a ng-click="orderBy.current = order; orderBy.status = false;" href>{{ order.name }}</a>
            </li>
        </ul>
    </div>
    <button type="button" class="btn btn-default"
            ng-click="orderBy.reverse = !orderBy.reverse"
            tooltip="${message(code:'todo.is.ui.order')}"
            tooltip-append-to-body="true">
        <span class="glyphicon glyphicon-sort-by-attributes{{ orderBy.reverse ? '-alt' : ''}}"></span>
    </button>
</div>
<div class="btn-group" tooltip-append-to-body="true" dropdown tooltip="${message(code:'todo.is.ui.export')}">
    <button class="btn btn-default dropdown-toggle" type="button">
        <span class="glyphicon glyphicon-export"></span>&nbsp;<span class="caret"></span>
    </button>
    <ul class="dropdown-menu"
        role="menu">
        <g:each in="${is.exportFormats()}" var="format">
            <li role="menuitem">
                <a data-ajax="true" href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}">${format.name}</a>
            </li>
        </g:each>
        <entry:point id="${controllerName}-toolbar-export" model="[product:params.product, origin:controllerName]"/>
    </ul>
</div>
<div class="btn-group pull-right">
    <entry:point id="${controllerName}-${actionName}-toolbar-right"/>
    <g:if test="${params?.printable}">
        <button type="button"
                class="btn btn-default"
                tooltip="${message(code:'is.ui.window.print')} (P)"
                tooltip-append-to-body="true"
                hotkey="{'P': hotkeyClick }"
                href="${createLink(controller:controllerName,action:'print', params:[product:params.product?:null, format:'PDF'])}"
                data-ajax="true"><span class="glyphicon glyphicon-print"></span>
        </button>
    </g:if>
    <g:if test="${params?.widgetable}">
        <button type="button"
                class="btn btn-default btn-widget"
                tooltip="${message(code:'is.ui.window.widgetable')} (W)"
                tooltip-append-to-body="true"
                hotkey="{'W': hotkeyClick }"><span class="glyphicon glyphicon-retweet"></span>
        </button>
    </g:if>
    <g:if test="${params?.fullScreen}">
        <button type="button"
                class="btn btn-default btn-fullscreen"
                tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                tooltip-append-to-body="true"
                hotkey="{'F': hotkeyClick }"><span class="glyphicon glyphicon-fullscreen"></span>
        </button>
    </g:if>
</div>