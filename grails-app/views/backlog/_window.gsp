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
    <div class="card card-view" ng-controller="elementsListMenuCtrl" ng-init="initialize(availableBacklogs, 'backlog', 'code')">
        <div class="card-header">
            <ul class="nav nav-pills card-header-pills"
                ng-class="{ 'hasElements': visibleElementsList.length > 0 }"
                as-sortable="elementsListSortableOptions"
                ng-model="visibleElementsList">
                <li class="nav-item"
                    as-sortable-item
                    ng-repeat="elem in visibleElementsList">
                    <a href="{{ toggleElementUrl(elem) }}"
                       class="nav-link"
                       ng-class="{'active': isShown(elem)}"
                       ng-click="clickOnElementHref($event)">
                        <span as-sortable-item-handle>{{ (elem | i18nName) + ' (' + elem.count + ')' }}</span>
                    </a>
                </li>
                <li class="nav-item"
                    uib-dropdown
                    is-open="more.isopen || menuDragging"
                    ng-show="menuDragging || hiddenElementsList.length > 0">
                    <a uib-dropdown-toggle
                       href
                       ng-class="{'active': isShownInMore()}"
                       style="padding: 15px">
                        ${message(code: 'todo.is.ui.more')}
                    </a>
                    <div uib-dropdown-menu
                         as-sortable="elementsListSortableOptions"
                         ng-model="hiddenElementsList">
                        <a href="{{ toggleElementUrl(elem) }}"
                           class="dropdown-item"
                           ng-class="{'active': isShown(elem)}"
                           as-sortable-item
                           role="presentation"
                           ng-repeat="elem in hiddenElementsList"
                           ng-click="clickOnElementHref($event)">
                            <span as-sortable-item-handle>{{ (elem | i18nName) + ' (' + elem.count + ')' }}</span>
                        </a>
                    </div>
                </li>
                <entry:point id="backlog-window-toolbar"/>
            </ul>
            <div class="btn-toolbar">
                <entry:point id="backlog-window-toolbar-right"/>
                <div class="btn-group">
                    <button type="button"
                            class="btn btn-secondary btn-sm hidden-xs hidden-sm"
                            defer-tooltip="${message(code: 'todo.is.ui.stickynote.size')}"
                            ng-click="setStickyNoteSize(viewName)"><i class="fa {{ iconCurrentStickyNoteSize(viewName) }}"></i>
                    </button>
                    <button type="button"
                            class="btn btn-secondary btn-sm hidden-xs"
                            defer-tooltip="${message(code: 'is.ui.window.fullscreen')}"
                            ng-click="fullScreen()"><i class="fa fa-arrows-alt"></i>
                    </button>
                </div>
                <a ui-sref="backlog.backlog.story.new"
                   class="btn btn-primary btn-intermediate"><span>${message(code: "todo.is.ui.story.new")}</span></a>
            </div>
        </div>
        <div class="card-body backlog-list row" selectable="selectableOptions" ng-class="{'multiple-backlog': backlogContainers.length > 1}">
            <div class="window-alert bg-warning" ng-if="selectableOptions.selectingMultiple">
                ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
            </div>
            <div ng-repeat="backlogContainer in backlogContainers"
                 class="backlog col">
                <div>
                    <span class="backlog-title">
                        {{ (backlogContainer.backlog | i18nName) + ' (' + backlogContainer.backlog.count + ')' }}
                    </span>
                    <div class="btn-toolbar">
                        <entry:point id="backlog-list-toolbar-left"/>
                        <div class="btn-group">
                            <entry:point id="backlog-list-toolbar-group-left"/>
                            <div class="btn-group"
                                 uib-dropdown
                                 defer-tooltip="${message(code: 'todo.is.ui.sort')}">
                                <button class="btn btn-secondary btn-sm" uib-dropdown-toggle type="button">
                                    <span>{{ backlogContainer.orderBy.current.name }}</span>
                                </button>
                                <div uib-dropdown-menu role="menu">
                                    <a role="menuitem"
                                       class="dropdown-item"
                                       ng-repeat="order in backlogContainer.orderBy.values"
                                       ng-click="changeBacklogOrder(backlogContainer, order)"
                                       href>
                                        {{ order.name }}</a>
                                </div>
                            </div>
                            <button type="button" class="btn btn-secondary btn-sm"
                                    ng-click="reverseBacklogOrder(backlogContainer)"
                                    defer-tooltip="${message(code: 'todo.is.ui.sort.order')}">
                                <i class="fa fa-sort-amount{{ backlogContainer.orderBy.reverse ? '-desc' : '-asc'}}"></i>
                            </button>
                            <button type="button"
                                    ng-if="backlogContainer.sortable && !isSortingBacklog(backlogContainer)"
                                    class="btn btn-secondary btn-sm hidden-sm hidden-xs"
                                    ng-click="enableSortable(backlogContainer)"
                                    uib-tooltip="${message(code: 'todo.is.ui.sortable.enable')}">
                                <i class="fa fa-hand-stop-o text-danger"></i>
                            </button>
                            <entry:point id="backlog-list-toolbar-group-right"/>
                        </div>
                        <div class="btn-group hidden-xs" uib-dropdown ng-if="authenticated()">
                            <button class="btn btn-secondary btn-sm"
                                    ng-disabled="!backlogContainer.backlog.stories.length"
                                    uib-dropdown-toggle type="button">
                                <span defer-tooltip="${message(code: 'todo.is.ui.export')}"><i class="fa fa-download"></i></span>
                            </button>
                            <div uib-dropdown-menu
                                 role="menu">
                                <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                                    <a role="menuitem"
                                       class="dropdown-item"
                                       href="${format.onlyJsClick ? '' : (format.resource ?: 'story') + '/backlog/{{ ::backlogContainer.backlog.id }}/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                                       ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">
                                        ${format.name}
                                    </a>
                                </g:each>
                            </div>
                            <entry:point id="backlog-list-toolbar-right-hidden-xs"/>
                        </div>
                        <a class="btn btn-secondary btn-sm"
                           ng-href="{{ openBacklogUrl(backlogContainer.backlog) }}">
                            <i class="fa fa-pencil"
                               defer-tooltip="${message(code: 'todo.is.ui.details')}"></i>
                        </a>
                        <entry:point id="backlog-list-toolbar-right"/>
                        <a ng-href="{{ closeBacklogUrl(backlogContainer.backlog) }}"
                           class="btn btn-icon btn-icon-close"
                           ng-if="backlogContainers.length > 1">
                        </a>
                    </div>
                </div>
                <div ng-class="{'loading': !backlogContainer.storiesLoaded}">
                    <div class="loading-logo" ng-include="'loading.html'"></div>
                    <div class="sticky-notes {{ stickyNoteClass }}"
                         ng-class="{'has-selected': hasSelected(), 'sortable-moving': application.sortableMoving}"
                         ng-controller="storyBacklogCtrl"
                         as-sortable="backlogSortableOptions | merge: sortableScrollOptions()"
                         is-disabled="!isSortingBacklog(backlogContainer)"
                         ng-model="backlogContainer.backlog.stories"
                         ng-init="(backlog = backlogContainer.backlog) && (emptyBacklogTemplate = 'story.backlog.backlogs.empty.html') && (orderBy = backlogContainer.orderBy)"
                         ng-include="'story.backlog.html'">
                    </div>
                </div>
            </div>
            <entry:point id="backlog-list-details"/>
        </div>
    </div>
</is:window>