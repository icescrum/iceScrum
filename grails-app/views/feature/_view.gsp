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
<div class="panel panel-light">
    <div class="panel-heading">
        <div class="btn-toolbar">
            <div class="btn-group">
                <button type="button"
                        ng-if="isSortableFeature()"
                        class="btn btn-default"
                        ng-click="enableSortable()"
                        uib-tooltip="{{ isSortingFeature() ? '${message(code: /todo.is.ui.sortable.enabled/)}' : '${message(code: /todo.is.ui.sortable.enable/)}' }}">
                    <span ng-class="isSortingFeature() ? 'text-success' : 'text-danger forbidden-stack'" class="fa fa-hand-pointer-o"></span>
                </button>
                <div class="btn-group"
                     uib-dropdown
                     uib-tooltip="${message(code:'todo.is.ui.sort')}">
                    <button class="btn btn-default"
                            uib-dropdown-toggle type="button">
                        <span>{{ orderBy.current.name }}</span>
                        <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu" role="menu">
                        <li role="menuitem" ng-repeat="order in orderBy.values">
                            <a ng-click="orderBy.current = order" href>{{ order.name }}</a>
                        </li>
                    </ul>
                </div>
                <button type="button"
                        class="btn btn-default"
                        ng-click="orderBy.reverse = !orderBy.reverse"
                        uib-tooltip="${message(code:'todo.is.ui.order')}">
                    <i class="fa fa-sort-amount{{ orderBy.reverse ? '-desc' : '-asc'}}"></i>
                </button>
            </div>
            <div class="btn-group"
                 uib-dropdown
                 uib-tooltip="${message(code:'todo.is.ui.export')}">
                <button class="btn btn-default"
                        uib-dropdown-toggle
                        type="button">
                    <i class="fa fa-download"></i>&nbsp;<span class="caret"></span>
                </button>
                <ul class="uib-dropdown-menu"
                    role="menu">
                    <g:each in="${is.exportFormats()}" var="format">
                        <li role="menuitem">
                            <a unavailable-feature="true">${format.name}</a>
                        </li>
                    </g:each>
                    <entry:point id="${controllerName}-toolbar-export" model="[product:params.product, origin:controllerName]"/>
                </ul>
            </div>
            <button type="button"
                    class="btn btn-default"
                    ng-click="toggleSelectableMultiple()"
                    uib-tooltip="{{ app.selectableMultiple ? '${message(code: /todo.is.ui.selectable.multiple.disable/)}' : '${message(code: /todo.is.ui.selectable.multiple.enable/)}' }}">
                <i class="fa fa-object-ungroup" ng-class="app.selectableMultiple ? 'text-success' : 'text-danger'"></i>
            </button>
            <a type="button"
               ng-if="authorizedFeature('create')"
               href="#/{{ ::viewName }}/new"
               class="btn btn-primary pull-right">${message(code: "todo.is.ui.feature.new")}</a>
            <div class="btn-group pull-right visible-on-hover">
                <entry:point id="${controllerName}-${actionName}-toolbar-right"/>
                <g:if test="${params?.printable}">
                    <button type="button"
                            class="btn btn-default"
                            uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                            unavailable-feature="true"
                            ng-href="{{ ::viewName }}/print"
                            hotkey="{'P': hotkeyClick }"><i class="fa fa-print"></i>
                    </button>
                </g:if>
                <button type="button"
                        uib-tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
                        unavailable-feature="true"
                        class="btn btn-default">
                    <i class="fa" ng-class="app.asList ? 'fa-th-list' : 'fa-th'"></i>
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
        </div>
    </div>
    <div class="panel-body"
         selectable="selectableOptions">
        <div ng-if="features.length == 0"
             class="empty-view">
            <p class="help-block">${message(code: 'is.ui.feature.help')}<p>
            <a type="button"
               class="btn btn-primary"
               ng-if="authorizedFeature('create')"
               href="#{{ ::viewName }}/new">
                ${message(code: 'todo.is.ui.feature.new')}
            </a>
        </div>
        <div ng-if="app.search && features.length != 0 && (features | search).length == 0"
             class="empty-view">
            <p class="help-block">${message(code: 'is.ui.feature.search.empty')} <strong>{{ app.search }}</strong><p>
            <button class="btn btn-default"
                    ng-click="app.search = null">
                ${message(code: 'todo.is.ui.search.clear')}
            </button>
            <a type="button"
               class="btn btn-primary"
               ng-if="authorizedFeature('create')"
               href="#{{ ::viewName }}/new">
                ${message(code: 'todo.is.ui.feature.new')}
            </a>
        </div>
        <div class="postits {{ (isSortingFeature() ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '') }}"
             ng-controller="featureCtrl"
             ng-class="app.asList ? 'list-group' : 'grid-group'"
             as-sortable="featureSortableOptions | merge: sortableScrollOptions()"
             is-disabled="!isSortingFeature()"
             ng-model="features">
            <div ng-class="{ 'is-selected': isSelected(feature) }"
                 selectable-id="{{ ::feature.id }}"
                 as-sortable-item
                 ng-repeat="feature in features | search | orderBy:orderBy.current.id:orderBy.reverse"
                 class="postit-container">
                <div ng-include="'feature.html'"></div>
            </div>
        </div>
    </div>
</div>