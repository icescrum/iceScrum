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
        <div class="card-header" ng-controller="elementsListMenuCtrl" ng-init="initialize(availableBacklogs, 'backlog', 'code')">
            <div class="card-nav">
                <ul class="nav nav-pills"
                    as-sortable="elementsListSortableOptions"
                    ng-model="visibleElementsList">
                    <li class="nav-item mr-2"
                        as-sortable-item
                        ng-repeat="elem in visibleElementsList">
                        <a href="{{ toggleElementUrl(elem) }}"
                           class="nav-link"
                           ng-class="{'active': isShown(elem)}"
                           ng-click="clickOnElementHref($event)">
                            <span as-sortable-item-handle>{{ (elem | i18nName) + ' (' + elem.count + ')' }}</span>
                        </a>
                    </li>
                </ul>
                <ul class="nav nav-pills">
                    <li class="nav-item more-item"
                        uib-dropdown
                        is-open="more.isopen || menuDragging"
                        ng-show="menuDragging || hiddenElementsList.length > 0">
                        <a uib-dropdown-toggle
                           href
                           ng-class="{'active': isShownInMore()}">
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
            </div>
            <div class="btn-toolbar">
                <entry:point id="backlog-window-toolbar-right"/>
                <div class="btn-group" ng-if="backlogContainers.length == 1">
                    <div class="btn-group"
                         uib-dropdown>
                        <button class="btn btn-secondary btn-sm" uib-dropdown-toggle type="button">
                            <span>{{ backlogContainers[0].orderBy.current.name }}</span>
                        </button>
                        <div uib-dropdown-menu role="menu">
                            <a role="menuitem"
                               class="dropdown-item"
                               ng-repeat="order in backlogContainers[0].orderBy.values"
                               ng-click="changeBacklogOrder(backlogContainers[0], order)"
                               href>
                                {{ order.name }}</a>
                        </div>
                    </div>
                    <button type="button" class="btn btn-secondary btn-sm"
                            ng-click="reverseBacklogOrder(backlogContainers[0])"
                            defer-tooltip="${message(code: 'todo.is.ui.sort.order')}">
                        <i class="fa fa-sort-amount{{ backlogContainers[0].orderBy.reverse ? '-desc' : '-asc'}}"></i>
                    </button>
                    <button type="button"
                            ng-if="backlogContainers[0].sortable && !isSortingBacklog(backlogContainers[0])"
                            class="btn btn-secondary btn-sm hidden-sm hidden-xs"
                            ng-click="enableSortable(backlogContainers[0])"
                            uib-tooltip="${message(code: 'todo.is.ui.sortable.enable')}">
                        <i class="fa fa-hand-stop-o text-danger"></i>
                    </button>
                </div>
                <div class="btn-group hidden-xs" uib-dropdown ng-if="authenticated() && backlogContainers.length == 1">
                    <button class="btn btn-secondary btn-sm"
                            ng-disabled="!backlogContainers[0].backlog.stories.length"
                            uib-dropdown-toggle type="button">
                        <span defer-tooltip="${message(code: 'todo.is.ui.export')}"><i class="fa fa-download"></i></span>
                    </button>
                    <div uib-dropdown-menu
                         role="menu">
                        <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                            <a role="menuitem"
                               class="dropdown-item"
                               href="${format.onlyJsClick ? '' : (format.resource ?: 'story') + '/backlog/{{ ::backlogContainers[0].backlog.id }}/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                               ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">
                                ${format.name}
                            </a>
                        </g:each>
                    </div>
                </div>
                <a class="btn btn-secondary btn-sm"
                   ng-if="backlogContainers.length == 1"
                   ng-href="{{ openBacklogUrl(backlogContainers[0].backlog) }}">
                    <i class="fa fa-pencil"></i>
                </a>
                <button type="button"
                        class="btn btn-secondary btn-sm hidden-xs hidden-sm"
                        defer-tooltip="${message(code: 'todo.is.ui.stickynote.size')}"
                        ng-click="setStickyNoteSize(viewName)"><i class="fa {{ iconCurrentStickyNoteSize(viewName) }}"></i>
                </button>
                <a ui-sref="backlog.backlog.story.new"
                   class="btn btn-primary"><span>${message(code: "todo.is.ui.story.new")}</span></a>
            </div>
        </div>
        <div class="window-alert bg-warning" ng-if="selectableOptions.selectingMultiple">
            <i class="fa fa-warning"></i> ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
        </div>
        <div class="card-body backlog-list scrollable-selectable-container" selectable="selectableOptions" ng-class="{'multiple-backlog': backlogContainers.length > 1}">
            <div ng-repeat="backlogContainer in backlogContainers"
                 class="backlog col">
                <div ng-if="backlogContainers.length > 1" class="backlog-multiple-toolbar d-flex justify-content-between">
                    <span class="backlog-title">
                        {{ (backlogContainer.backlog | i18nName) + ' (' + backlogContainer.backlog.count + ')' }}
                    </span>
                    <a ng-href="{{ closeBacklogUrl(backlogContainer.backlog) }}"
                       class="btn btn-icon btn-icon-close">
                    </a>
                </div>
                <div ng-class="{'loading': !backlogContainer.storiesLoaded}">
                    <div class="loading-logo" ng-include="'loading.html'"></div>
                    <div class="sticky-notes grey-sticky-notes {{ currentStickyNoteSize(viewName, 'grid-group size-sm') }}"
                         ng-class="{'has-selected': hasSelected(), 'sortable-moving': application.sortableMoving, 'sortable-multiple': application.sortableMultiple}"
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