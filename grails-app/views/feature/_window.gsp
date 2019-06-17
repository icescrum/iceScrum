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
    <div class="card card-view">
        <div class="card-header">
            <div class="card-header-left">
                <span class="card-title">${message(code: 'is.ui.feature')} ({{ features.length}})</span>
            </div>
            <div class="btn-toolbar">
                <div class="btn-group">
                    <div class="btn-group"
                         uib-dropdown>
                        <button class="btn btn-secondary btn-sm"
                                uib-dropdown-toggle type="button">
                            <span>{{ orderBy.current.name }}</span>
                        </button>
                        <div uib-dropdown-menu role="menu">
                            <a role="menuitem"
                               class="dropdown-item"
                               ng-repeat="order in orderBy.values"
                               ng-click="orderBy.current = order"
                               href>
                                {{ order.name }}
                            </a>
                        </div>
                    </div>
                    <button type="button"
                            class="btn btn-secondary btn-sm"
                            ng-click="orderBy.reverse = !orderBy.reverse"
                            defer-tooltip="${message(code: 'todo.is.ui.sort.order')}">
                        <i class="fa fa-sort-amount{{ orderBy.reverse ? '-desc' : '-asc'}}"></i>
                    </button>
                    <button type="button"
                            ng-if="isSortableFeature() && !isSortingFeature()"
                            class="btn btn-secondary btn-sm hidden-sm hidden-xs"
                            ng-click="enableSortable()"
                            uib-tooltip="${message(code: 'todo.is.ui.sortable.enable')}">
                        <i class="fa fa-hand-pointer-o text-danger forbidden-stack"></i>
                    </button>
                </div>
                <div class="btn-group hidden-sm hidden-xs"
                     uib-dropdown
                     ng-if="authenticated()"
                     defer-tooltip="${message(code: 'todo.is.ui.export')}">
                    <button class="btn btn-secondary btn-sm"
                            uib-dropdown-toggle
                            ng-disabled="!features.length"
                            type="button">
                        <i class="fa fa-download"></i>
                    </button>
                    <div uib-dropdown-menu
                         role="menu">
                        <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                            <a role="menuitem"
                               class="dropdown-item"
                               href="${format.onlyJsClick ? '' : (format.resource ?: 'feature') + '/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                               ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                        </g:each>
                    </div>
                </div>
                <button type="button"
                        class="btn btn-secondary btn-sm hidden-xs hidden-sm"
                        defer-tooltip="${message(code: 'todo.is.ui.stickynote.size')}"
                        ng-click="setStickyNoteSize(viewName)"><i class="fa {{ iconCurrentStickyNoteSize(viewName) }}"></i>
                </button>
                <a ng-if="authorizedFeature('create')"
                   href="#/{{ ::viewName }}/new"
                   class="btn btn-primary">${message(code: "todo.is.ui.feature.new")}</a>
            </div>
        </div>
        <div class="window-alert window-alert-margin-top bg-warning"
             ng-if="selectableOptions.selectingMultiple">
            ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
        </div>
        <div class="window-alert window-alert-margin-top bg-info"
             ng-if="authorizedFeature('update') && !isSortableFeature()">
            ${message(code: 'is.ui.feature.rank.disabled')}
        </div>
        <div class="card-body scrollable-selectable-container"
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
                <button class="btn btn-secondary btn-sm"
                        ng-click="application.search = null">
                    ${message(code: 'todo.is.ui.search.clear')}
                </button>
                <a class="btn btn-primary"
                   ng-if="authorizedFeature('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.feature.new')}
                </a>
            </div>
            <div class="sticky-notes {{ stickyNoteClass }}"
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
                     class="sticky-note-container sticky-note-feature">
                    <div ng-include="'feature.html'"></div>
                </div>
            </div>
        </div>
    </div>
</is:window>