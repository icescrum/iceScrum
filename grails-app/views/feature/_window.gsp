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
    <div class="backlogs-list-details">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title small-title clearfix">
                    <span class="title pull-left"><i class="fa fa-puzzle-piece"></i> ${message(code: 'is.ui.feature')} ({{ features.length}})</span>
                    <div class="btn-toolbar pull-left">
                        <div class="btn-group">
                            <div class="btn-group"
                                 uib-dropdown
                                 defer-tooltip="${message(code: 'todo.is.ui.sort')}">
                                <button class="btn btn-secondary"
                                        uib-dropdown-toggle type="button">
                                    <span>{{ orderBy.current.name }}</span>
                                </button>
                                <ul uib-dropdown-menu role="menu">
                                    <li role="menuitem" ng-repeat="order in orderBy.values">
                                        <a ng-click="orderBy.current = order" href>{{ order.name }}</a>
                                    </li>
                                </ul>
                            </div>
                            <button type="button"
                                    class="btn btn-secondary"
                                    ng-click="orderBy.reverse = !orderBy.reverse"
                                    defer-tooltip="${message(code: 'todo.is.ui.sort.order')}">
                                <i class="fa fa-sort-amount{{ orderBy.reverse ? '-desc' : '-asc'}}"></i>
                            </button>
                            <button type="button"
                                    ng-if="isSortableFeature() && !isSortingFeature()"
                                    class="btn btn-secondary hidden-sm hidden-xs"
                                    ng-click="enableSortable()"
                                    uib-tooltip="${message(code: 'todo.is.ui.sortable.enable')}">
                                <i class="fa fa-hand-pointer-o text-danger forbidden-stack"></i>
                            </button>
                        </div>
                        <div class="btn-group hidden-sm hidden-xs"
                             uib-dropdown
                             ng-if="authenticated()"
                             defer-tooltip="${message(code: 'todo.is.ui.export')}">
                            <button class="btn btn-secondary"
                                    uib-dropdown-toggle
                                    ng-disabled="!features.length"
                                    type="button">
                                <i class="fa fa-download"></i>
                            </button>
                            <ul uib-dropdown-menu
                                role="menu">
                                <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                                    <li role="menuitem">
                                        <a href="${format.onlyJsClick ? '' : (format.resource ?: 'feature') + '/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                                           ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                                    </li>
                                </g:each>
                            </ul>
                        </div>
                    </div>
                    <div class="btn-toolbar pull-right">
                        <div class="btn-group">
                            <button type="button"
                                    class="btn btn-secondary hidden-xs hidden-sm"
                                    defer-tooltip="${message(code: 'todo.is.ui.postit.size')}"
                                    ng-click="setPostitSize(viewName)"><i class="fa {{ iconCurrentPostitSize(viewName) }}"></i>
                            </button>
                            <button type="button"
                                    class="btn btn-secondary hidden-xs"
                                    ng-click="fullScreen()"
                                    defer-tooltip="${message(code: 'is.ui.window.fullscreen')}"><i class="fa fa-arrows-alt"></i>
                            </button>
                        </div>
                        <a ng-if="authorizedFeature('create')"
                           href="#/{{ ::viewName }}/new"
                           class="btn btn-primary pull-right">${message(code: "todo.is.ui.feature.new")}</a>
                    </div>
                </h3>
                <div class="clearfix"></div>
                <div class="window-alert window-alert-margin-top bg-warning"
                     ng-if="selectableOptions.selectingMultiple">
                    ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
                </div>
                <div class="window-alert window-alert-margin-top bg-info"
                     ng-if="authorizedFeature('update') && !isSortableFeature()">
                    ${message(code: 'is.ui.feature.rank.disabled')}
                </div>
            </div>
            <div class="card-body"
                 selectable="selectableOptions">
                <div ng-if="features.length == 0"
                     class="empty-view">
                    <p class="form-text">${message(code: 'is.ui.feature.help')}<p>
                    <a class="btn btn-primary"
                       ng-if="authorizedFeature('create')"
                       href="#{{ ::viewName }}/new">
                        ${message(code: 'todo.is.ui.feature.new')}
                    </a>
                </div>
                <div ng-if="application.search && features.length != 0 && (features | search).length == 0"
                     class="empty-view">
                    <p class="form-text">${message(code: 'is.ui.feature.search.empty')} <strong>{{ application.search }}</strong></p>
                    <button class="btn btn-secondary"
                            ng-click="application.search = null">
                        ${message(code: 'todo.is.ui.search.clear')}
                    </button>
                    <a class="btn btn-primary"
                       ng-if="authorizedFeature('create')"
                       href="#{{ ::viewName }}/new">
                        ${message(code: 'todo.is.ui.feature.new')}
                    </a>
                </div>
                <div class="postits {{ postitClass }}"
                     ng-class="{'has-selected': hasSelected() }"
                     ng-controller="featureCtrl"
                     as-sortable="featureSortableOptions | merge: sortableScrollOptions()"
                     is-disabled="!isSortingFeature()"
                     ng-model="features">
                    <div is-watch="feature"
                         ng-class="{ 'is-selected': isSelected(feature) }"
                         selectable-id="{{ ::feature.id }}"
                         as-sortable-item
                         ng-repeat="feature in features | search | orderBy:orderBy.current.id:orderBy.reverse"
                         class="postit-container">
                        <div ng-include="'feature.html'"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</is:window>