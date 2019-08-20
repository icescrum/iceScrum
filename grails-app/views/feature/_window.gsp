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
        <div class="card-header row">
            <div class="card-header-left order-0 col-auto flex-grow-1">
                <span class="card-title">${message(code: 'is.ui.feature')} ({{ features.length}})</span>
            </div>
            <div class="mt-2 mt-sm-0 order-3 order-sm-1 col-auto pr-0" uib-dropdown>
                <button class="btn btn-link"
                        uib-dropdown-toggle
                        ng-disabled="!features.length"
                        type="button"><strong>${message(code: 'todo.is.ui.order.sort')}&nbsp;</strong>{{ orderBy.current.name }}<span class="sort" ng-class="{'reverse':orderBy.reverse}"></span>
                </button>
                <div uib-dropdown-menu role="menu">
                    <div class="dropdown-header">${message(code: 'todo.is.ui.order')}</div>
                    <div role="menuitem"
                         class="dropdown-item"
                         ng-click="orderBy.reverse = !orderBy.reverse"
                         ng-class="{'active': !orderBy.reverse}">${message(code: 'todo.is.ui.order.sort.asc')}</div>
                    <div role="menuitem"
                         class="dropdown-item"
                         ng-click="orderBy.reverse = !orderBy.reverse"
                         ng-class="{'active': orderBy.reverse}">${message(code: 'todo.is.ui.order.sort.desc')}</div>
                    <div class="dropdown-divider"></div>
                    <div class="dropdown-header">${message(code: 'todo.is.ui.order.sort')}</div>
                    <div role="menuitem"
                         class="dropdown-item"
                         ng-repeat="order in orderBy.values"
                         ng-click="orderBy.current = order"
                         ng-class="{'active': orderBy.current == order}">{{:: order.name }}</div>
                </div>
            </div>
            <div class="w-100 order-2 d-block d-sm-none"></div>
            <div class="btn-toolbar pl-1 mt-2 mt-sm-0 order-4 order-sm-3 col-auto">
                <div class="btn-group"
                     uib-dropdown
                     ng-if="authenticated()">
                    <button class="btn btn-link"
                            uib-dropdown-toggle
                            ng-disabled="!features.length"
                            type="button">
                        <i class="fa fa-download"></i>
                    </button>
                    <div uib-dropdown-menu class="dropdown-menu-right" role="menu">
                        <div class="dropdown-header">${message(code: 'todo.is.ui.export')}</div>
                        <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                            <a role="menuitem"
                               class="dropdown-item"
                               href="${format.onlyJsClick ? '' : (format.resource ?: 'feature') + '/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                               ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                        </g:each>
                    </div>
                </div>
                <div class="btn-group d-none d-lg-block sticky-note-size" uib-dropdown>
                    <button class="btn btn-dropdown-icon"
                            uib-dropdown-toggle
                            type="button">
                        <span class="icon icon-{{ iconCurrentStickyNoteSize(viewName) }}"></span>
                    </button>
                    <div uib-dropdown-menu class="dropdown-menu-right" role="menu">
                        <div class="dropdown-header">${message(code: 'todo.is.ui.stickynote.display')}</div>
                        <div role="menuitem"
                             class="dropdown-item clearfix"
                             ng-click="setStickyNoteSize(viewName,'list-group')"
                             ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'list-group'}">${message(code: 'todo.is.ui.stickynote.display.list')}&nbsp;<span class="float-right icon icon-list-group icon-highlight"></span></div>
                        <div role="menuitem"
                             class="dropdown-item clearfix"
                             ng-click="setStickyNoteSize(viewName,'grid-group')"
                             ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'grid-group'}">${message(code: 'todo.is.ui.stickynote.display.grid')}&nbsp;<span class="float-right icon icon-grid-group icon-highlight"></span></div>
                    </div>
                </div>
            </div>
            <div class="order-1 order-sm-4 col-auto">
                <a class="btn btn-primary"
                   ng-if="authorizedFeature('create')"
                   href="#/{{ ::viewName }}/new">${message(code: "todo.is.ui.feature.new")}</a>
            </div>
        </div>
        <div class="window-alert bg-warning"
             ng-if="selectableOptions.selectingMultiple">
            <i class="fa fa-warning"></i> ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
        </div>
        <div class="window-alert bg-warning"
             ng-if="authorizedFeature('update') && !isSortableFeature()">
            <i class="fa fa-warning"></i> ${message(code: 'is.ui.feature.rank.disabled')}
        </div>
        <div class="card-body scrollable-selectable-container"
             selectable="selectableOptions" ng-class="{'has-selected': hasSelected()}">
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
                <button class="btn btn-link"
                        ng-click="application.search = null">
                    ${message(code: 'todo.is.ui.search.clear')}
                </button>
                <a class="btn btn-primary"
                   ng-if="authorizedFeature('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.feature.new')}
                </a>
            </div>
            <div class="sticky-notes {{ currentStickyNoteSize(viewName, 'grid-group') }}"
                 ng-class="{'sortable-multiple': application.sortableMultiple }"
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