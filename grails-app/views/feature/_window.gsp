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
    <div class="panel panel-light">
        <div class="panel-heading">
            <div class="btn-toolbar">
                <div class="btn-group btn-view">
                    <button type="button"
                            ng-if="isSortableFeature()"
                            class="btn btn-default"
                            ng-click="enableSortable()"
                            uib-tooltip="{{ isSortingFeature() ? '${message(code: /todo.is.ui.sortable.enabled/)}' : '${message(code: /todo.is.ui.sortable.enable/)}' }}">
                        <i ng-class="isSortingFeature() ? 'text-success' : 'text-danger forbidden-stack'" class="fa fa-hand-pointer-o"></i>
                    </button>
                    <div class="btn-group"
                         uib-dropdown
                         uib-tooltip="${message(code:'todo.is.ui.sort')}">
                        <button class="btn btn-default"
                                uib-dropdown-toggle type="button">
                            <span>{{ orderBy.current.name }}</span>
                            <i class="fa fa-caret-down"></i>
                        </button>
                        <ul uib-dropdown-menu role="menu">
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
                <div class="btn-group btn-view"
                     uib-dropdown
                     uib-tooltip="${message(code:'todo.is.ui.export')}">
                    <button type="button"
                            class="btn btn-default"
                            uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                            ng-click="print($event)"
                            ng-href="feature/print"
                            hotkey="{'P': hotkeyClick }"><i class="fa fa-print"></i>
                    </button>
                    <button class="btn btn-default"
                            uib-dropdown-toggle
                            type="button">
                        <i class="fa fa-download"></i> <i class="fa fa-caret-down"></i>
                    </button>
                    <ul uib-dropdown-menu
                        role="menu">
                        <g:each in="${is.exportFormats(windowDefinition:windowDefinition)}" var="format">
                            <li role="menuitem">
                                <a href="${format.controller?:'feature'}/${format.action?:'print'}/${format.params.format}"
                                   ng-click="print($event)">${format.name}</a>
                            </li>
                        </g:each>
                    </ul>
                </div>
                <div class="pull-right">
                    <div class="btn-group btn-view">
                        <button type="button"
                            class="btn btn-default"
                            uib-tooltip="${message(code: 'todo.is.ui.postit.size')}"
                            ng-click="setPostitSize(viewName)"><i class="fa {{ iconCurrentPostitSize(viewName, 'grid-group') }}"></i>
                        </button>
                        <button type="button"
                                class="btn btn-default"
                                ng-click="fullScreen()"
                                uib-tooltip="${message(code:'is.ui.window.fullscreen')}"><i class="fa fa-arrows-alt"></i>
                        </button>
                    </div>
                    <div class="btn-group btn-view">
                        <button type="button"
                                class="btn btn-default"
                                ng-click="toggleSelectableMultiple()"
                                uib-tooltip="{{ app.selectableMultiple ? '${message(code: /todo.is.ui.selectable.bulk.disable/)}' : '${message(code: /todo.is.ui.selectable.bulk.enable/)}' }}">
                            <i class="fa fa-object-ungroup" ng-class="app.selectableMultiple ? 'text-success' : 'text-danger'"></i>
                        </button>
                    </div>
                    <a ng-if="authorizedFeature('create')"
                       href="#/{{ ::viewName }}/new"
                       class="btn btn-primary pull-right">${message(code: "todo.is.ui.feature.new")}</a>
                </div>
            </div>
        </div>
        <div class="panel-body"
             selectable="selectableOptions">
            <div ng-if="features.length == 0"
                 class="empty-view">
                <p class="help-block">${message(code: 'is.ui.feature.help')}<p>
                <a class="btn btn-primary"
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
                <a class="btn btn-primary"
                   ng-if="authorizedFeature('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.feature.new')}
                </a>
            </div>
            <div class="postits {{ currentPostitSize(viewName, 'grid-group size-sm') + ' ' + (isSortingFeature() ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '') }}"
                 postits-screen-size
                 ng-controller="featureCtrl"
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
</is:window>