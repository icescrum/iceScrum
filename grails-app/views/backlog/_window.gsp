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
    <div class="card card-view"
         flow-init
         flow-drop
         flow-files-submitted="newFromFiles($flow, project)"
         flow-drop-enabled="authorizedStoryCreateFromFile()"
         flow-drag-enter="dropClass='card drop-enabled'"
         flow-drag-leave="dropClass='card'"
         ng-class="dropClass">
        <div ng-if="authorizedStoryCreateFromFile()"
             class="drop-split-zone-left d-flex align-items-center justify-content-center"
             flow-drag-hover>
            <div>
                <asset:image src="application/upload-new-many-stories.svg" width="70" height="70"/>
                <span class="drop-text">${message(code: 'todo.is.ui.drop.multiple.file.create.many', args: [message(code: 'is.story')])}</span>
            </div>
        </div>
        <div ng-if="authorizedStoryCreateFromFile()"
             class="drop-split-zone-right d-flex align-items-center justify-content-center"
             flow-drag-hover>
            <div>
                <asset:image src="application/upload-new-one-story.svg" width="70" height="70"/>
                <span class="drop-text">${message(code: 'todo.is.ui.drop.multiple.file.create.one', args: [message(code: 'is.story')])}</span>
            </div>
        </div>
        <div class="card-header row" ng-controller="elementsListMenuCtrl" ng-init="initialize(availableBacklogs, 'backlog', 'code')">
            <div class="card-nav order-0 col-auto flex-grow-1"
                 id="elementslist-list">
                <ul class="nav nav-pills"
                    as-sortable="elementsListSortableOptions"
                    ng-if="visibleElementsList.length"
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
            <div class="w-100 order-2 d-block d-sm-none col-auto"></div>
            <div class="btn-toolbar order-3 order-sm-1 col-12 col-sm-auto mt-2 mt-sm-0 pl-1 pr-0 justify-content-between"
                 id="elementslist-toolbar">
                <div class="btn-group ml-0" ng-if="backlogContainers.length == 1">
                    <div uib-dropdown>
                        <button class="btn btn-link"
                                uib-dropdown-toggle
                                type="button">${message(code: 'todo.is.ui.order.sort')}&nbsp;<strong>{{ backlogContainers[0].orderBy.current.name }}</strong><span class="sort" ng-class="{'reverse':backlogContainers[0].orderBy.reverse}"></span>
                        </button>
                        <div uib-dropdown-menu class="dropdown-menu-right" role="menu">
                            <div class="dropdown-header">${message(code: 'todo.is.ui.order')}</div>
                            <div role="menuitem"
                                 class="dropdown-item"
                                 ng-click="backlogContainers[0].orderBy.reverse = !backlogContainers[0].orderBy.reverse"
                                 ng-class="{'active': !backlogContainers[0].orderBy.reverse}">${message(code: 'todo.is.ui.order.sort.asc')}</div>
                            <div role="menuitem"
                                 class="dropdown-item"
                                 ng-click="backlogContainers[0].orderBy.reverse = !backlogContainers[0].orderBy.reverse"
                                 ng-class="{'active': backlogContainers[0].orderBy.reverse}">${message(code: 'todo.is.ui.order.sort.desc')}</div>
                            <div class="dropdown-divider"></div>
                            <div class="dropdown-header">${message(code: 'todo.is.ui.order.sort')}</div>
                            <div role="menuitem"
                                 class="dropdown-item"
                                 ng-repeat="order in backlogContainers[0].orderBy.values"
                                 ng-click="changeBacklogOrder(backlogContainers[0], order)"
                                 ng-class="{'active': backlogContainers[0].orderBy.current.id == order.id}">{{:: order.name }}</div>
                        </div>
                    </div>
                    <button type="button"
                            ng-if="backlogContainers[0].sortable && !isSortingBacklog(backlogContainers[0])"
                            class="btn btn-link"
                            ng-click="enableSortable(backlogContainers[0])"
                            uib-tooltip="${message(code: 'todo.is.ui.sortable.enable')}">
                        <i class="fa fa-hand-stop-o text-danger"></i>
                    </button>
                </div>
                <div>
                    <entry:point id="backlog-window-toolbar-right"/>
                    <div class="btn-group" uib-dropdown ng-if="authenticated() && backlogContainers.length == 1">
                        <button class="btn btn-link"
                                ng-disabled="!backlogContainers[0].backlog.stories.length"
                                uib-dropdown-toggle type="button"><i class="fa fa-download"></i>
                        </button>
                        <div uib-dropdown-menu class="dropdown-menu-right" role="menu">
                            <div class="dropdown-header">${message(code: 'todo.is.ui.export')}</div>
                            <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                                <a role="menuitem"
                                   class="dropdown-item"
                                   href="${format.onlyJsClick ? '' : (format.resource ?: 'story') + '/backlog/{{ backlogContainers[0].backlog.id }}/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                                   ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">
                                    ${format.name}
                                </a>
                            </g:each>
                        </div>
                    </div>
                    <div class="btn-group d-none d-lg-inline-block sticky-note-size dropdown" uib-dropdown>
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
                                 ng-click="setStickyNoteSize(viewName,'grid-group size-sm')"
                                 ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'grid-group-sm'}">${message(code: 'todo.is.ui.stickynote.display.grid.sm')}&nbsp;<span class="float-right icon icon-grid-group-sm icon-highlight"></span>
                            </div>
                            <div role="menuitem"
                                 class="dropdown-item clearfix"
                                 ng-click="setStickyNoteSize(viewName,'grid-group')"
                                 ng-class="{'active': iconCurrentStickyNoteSize(viewName) == 'grid-group'}">${message(code: 'todo.is.ui.stickynote.display.grid')}&nbsp;<span class="float-right icon icon-grid-group icon-highlight"></span></div>
                        </div>
                    </div>
                    <a class="btn btn-icon mr-1"
                       ng-if="backlogContainers.length == 1"
                       ng-href="{{ openBacklogUrl(backlogContainers[0].backlog) }}">
                        <span class="icon icon-details"></span>
                    </a>
                </div>
            </div>
            <div class="order-1 order-sm-3 col-auto">
                <a ui-sref="backlog.backlog.story.new" class="btn btn-primary">
                    <span>${message(code: "todo.is.ui.story.new")}</span>
                </a>
            </div>
        </div>
        <div class="window-alert bg-warning" ng-if="selectableOptions.selectingMultiple">
            <i class="fa fa-warning"></i> ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
        </div>
        <div class="card-body backlog-list scrollable-selectable-container" selectable="selectableOptions" ng-class="{'multiple-backlog': backlogContainers.length > 1}">
            <div ng-repeat="backlogContainer in backlogContainers" class="backlog col" ng-class="{'has-selected': hasSelected()}">
                <div ng-if="backlogContainers.length > 1" class="backlog-multiple-toolbar d-flex justify-content-between">
                    <span class="backlog-title">
                        {{ (backlogContainer.backlog | i18nName) + ' (' + backlogContainer.backlog.count + ')' }}
                    </span>
                    <a ng-href="{{ closeBacklogUrl(backlogContainer.backlog) }}"
                       class="btn btn-icon">
                        <span class="icon icon-close"></span>
                    </a>
                </div>
                <div>
                    <div class="sticky-notes grey-sticky-notes {{ currentStickyNoteSize(viewName, 'grid-group size-sm') }}"
                         ng-class="{'sortable-moving': application.sortableMoving, 'sortable-multiple': application.sortableMultiple}"
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