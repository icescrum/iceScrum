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
    <div class="backlogs-list elements-list" ng-controller="elementsListMenuCtrl" ng-init="initialize(availableBacklogs, 'backlog', 'code')">
        <ul id="elementslist-list" ng-class="['nav nav-tabs nav-tabs-is clearfix pull-left', { 'hasElements': visibleElementsList.length > 0 }]" as-sortable="elementsListSortableOptions" ng-model="visibleElementsList">
            <li as-sortable-item role="presentation" ng-repeat="elem in visibleElementsList" ng-class="{'active': isShown(elem)}">
                <a href="{{ toggleElementUrl(elem) }}" ng-click="clickOnElementHref($event)">
                    <i as-sortable-item-handle
                       class="fa fa-lg fa-border fa-inbox"
                       tooltip-placement="right"
                       uib-tooltip="{{ isPinned(elem) ? '${message(code: /todo.is.ui.backlog.pinned/)}' : '${message(code: /todo.is.ui.backlog.pin/)}' }}"
                       style="margin-right:3px;" href="{{ togglePinElementUrl(elem) }}"
                       ng-class="{'fa-pinned':isPinned(elem), 'fa-pin':!isPinned(elem)}"></i>
                    <span as-sortable-item-handle>{{ (elem | i18nName) + ' (' + elem.count + ')' }}</span>
                </a>
            </li>
            <li id="elementslist-more" class="nav-more" uib-dropdown is-open="more.isopen || menuDragging" ng-show="menuDragging || hiddenElementsList.length > 0" ng-class="{'active': isShownInMore()}">
                <a uib-dropdown-toggle href style="padding: 15px">${message(code: 'todo.is.ui.more')} <i class="fa fa-caret-down"></i></a>
                <ul uib-dropdown-menu
                    as-sortable="elementsListSortableOptions"
                    ng-model="hiddenElementsList"
                    class="nav-tabs nav-tabs-is">
                    <li as-sortable-item role="presentation" ng-repeat="elem in hiddenElementsList" ng-class="{'active': isShown(elem)}">
                        <a href="{{ toggleElementUrl(elem) }}" ng-click="clickOnElementHref($event)">
                            <i as-sortable-item-handle
                               class="fa fa-lg fa-border fa-inbox"
                               tooltip-placement="right"
                               uib-tooltip="{{ isPinned(elem) ? '${message(code: /todo.is.ui.backlog.pinned/)}' : '${message(code: /todo.is.ui.backlog.pin/)}' }}"
                               style="margin-right:3px;" href="{{ togglePinElementUrl(elem) }}"
                               ng-class="{'fa-pinned':isPinned(elem), 'fa-pin':!isPinned(elem)}"></i>
                            <span as-sortable-item-handle title="{{ (elem | i18nName) + ' (' + elem.count + ')' }}">{{ (elem | i18nName) + ' (' + elem.count + ')' }}</span>
                        </a>
                    </li>
                </ul>
            </li>
            <entry:point id="backlog-window-toolbar"/>
        </ul>
        <div id="elementslist-toolbar" class="btn-toolbar pull-right">
            <div class="btn-group">
                <button type="button"
                        class="btn btn-default hidden-xs hidden-sm"
                        uib-tooltip="${message(code: 'todo.is.ui.postit.size')}"
                        ng-click="setPostitSize(viewName)"><i class="fa {{ iconCurrentPostitSize(viewName) }}"></i>
                </button>
                <button type="button"
                        class="btn btn-default hidden-xs"
                        uib-tooltip="${message(code: 'is.ui.window.fullscreen')}"
                        ng-click="fullScreen()"><i class="fa fa-arrows-alt"></i>
                </button>
            </div>
            <div class="btn-group hidden-xs">
                <button type="button"
                        class="btn btn-default"
                        ng-click="toggleSelectableMultiple()"
                        uib-tooltip="{{ selectableOptions.selectingMultiple ? '${message(code: /todo.is.ui.selectable.bulk.disable/)}' : '${message(code: /todo.is.ui.selectable.bulk.enable/)}' }}">
                    <i class="fa fa-object-ungroup" ng-class="selectableOptions.selectingMultiple ? 'text-success' : 'text-danger'"></i>
                </button>
            </div>
            <a ng-if="authorizedStory('create')"
               ui-sref="backlog.backlog.story.new"
               ng-class="{ 'pull-right': backlogContainers.length == 1 }"
               class="btn btn-primary"><span>${message(code: "todo.is.ui.story.new")}</span></a>
            <entry:point id="backlog-window-toolbar-right"/>
        </div>
    </div>
    <div class="window-alert bg-warning" ng-if="selectableOptions.selectingMultiple">
        ${message(code: 'todo.is.ui.selectable.bulk.enabled')} (<strong><a href class="link" ng-click="toggleSelectableMultiple()">${message(code: 'todo.is.ui.disable')}</a></strong>)
    </div>
    <div class="backlogs-list-details" selectable="selectableOptions">
        <div class="panel panel-light" ng-repeat="backlogContainer in backlogContainers">
            <div class="panel-heading">
                <h3 class="panel-title small-title clearfix">
                    <span class="title pull-left">
                        <a href="{{ openBacklogUrl(backlogContainer.backlog) }}"
                           class="link">
                            <i class="fa fa-inbox"></i> {{ (backlogContainer.backlog | i18nName) + ' (' + backlogContainer.backlog.count + ')' }}
                        </a>
                    </span>
                    <div class="btn-toolbar pull-left">
                        <entry:point id="backlog-list-toolbar-left"/>
                        <div class="btn-group">
                            <entry:point id="backlog-list-toolbar-group-left"/>
                            <button type="button"
                                    ng-if="backlogContainer.sortable"
                                    class="btn btn-default hidden-xs"
                                    ng-click="enableSortable(backlogContainer)"
                                    tooltip-placement="right"
                                    uib-tooltip="{{ isSortingBacklog(backlogContainer) ? '${message(code: /todo.is.ui.sortable.enabled/)}' : '${message(code: /todo.is.ui.sortable.enable/)}' }}">
                                <i ng-class="isSortingBacklog(backlogContainer) ? 'text-success' : 'text-danger forbidden-stack'" class="fa fa-hand-pointer-o"></i>
                            </button>
                            <div class="btn-group"
                                 uib-dropdown
                                 uib-tooltip="${message(code: 'todo.is.ui.sort')}">
                                <button class="btn btn-default" uib-dropdown-toggle type="button">
                                    <span>{{ backlogContainer.orderBy.current.name }}</span>
                                    <i class="fa fa-caret-down"></i>
                                </button>
                                <ul uib-dropdown-menu role="menu">
                                    <li role="menuitem" ng-repeat="order in backlogContainer.orderBy.values">
                                        <a ng-click="changeBacklogOrder(backlogContainer, order)" href>{{ order.name }}</a>
                                    </li>
                                </ul>
                            </div>
                            <button type="button" class="btn btn-default"
                                    ng-click="reverseBacklogOrder(backlogContainer)"
                                    uib-tooltip="${message(code: 'todo.is.ui.order')}">
                                <i class="fa fa-sort-amount{{ backlogContainer.orderBy.reverse ? '-desc' : '-asc'}}"></i>
                            </button>
                            <entry:point id="backlog-list-toolbar-group-right"/>
                        </div>
                        <div class="btn-group hidden-xs" uib-dropdown>
                            <button type="button"
                                    class="btn btn-default"
                                    uib-tooltip="${message(code: 'is.ui.window.print')} (P)"
                                    ng-click="print($event)"
                                    ng-disabled="!backlogContainer.backlog.stories.length"
                                    ng-href="story/backlog/{{ ::backlogContainer.backlog.id }}/print"
                                    hotkey="{'P': hotkeyClick }"
                                    hotkey-description="${message(code: 'is.ui.window.print')}">
                                <i class="fa fa-print"></i>
                            </button>
                            <button class="btn btn-default"
                                    uib-tooltip="${message(code: 'todo.is.ui.export')}"
                                    ng-disabled="!backlogContainer.backlog.stories.length"
                                    uib-dropdown-toggle type="button">
                                <i class="fa fa-download"></i>&nbsp;<i class="fa fa-caret-down"></i>
                            </button>
                            <ul uib-dropdown-menu
                                class="pull-right"
                                role="menu">
                                <g:each in="${is.exportFormats(windowDefinition: windowDefinition)}" var="format">
                                    <li role="menuitem">
                                        <a href="${format.resource ?: 'story'}/backlog/{{ ::backlogContainer.backlog.id }}/${format.action ?: 'print'}/${format.params.format}"
                                           ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                                    </li>
                                </g:each>
                            </ul>
                            <entry:point id="backlog-list-toolbar-right-hidden-xs"/>
                        </div>
                    </div>
                    <div class="btn-toolbar pull-right">
                        <a class="btn btn-default" href="{{ openBacklogUrl(backlogContainer.backlog) }}"
                           uib-tooltip="${message(code: 'todo.is.ui.details')}">
                            <i class="fa fa-pencil"></i>
                        </a>
                        <entry:point id="backlog-list-toolbar-right"/>
                        <a href="{{ closeBacklogUrl(backlogContainer.backlog) }}"
                           class="btn btn-default"
                           ng-if="backlogContainers.length > 1"
                           uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                            <i class="fa fa-times"></i>
                        </a>
                    </div>
                </h3>
            </div>
            <div class="panel-body" ng-class="{'loading': !backlogContainer.storiesLoaded}">
                <div class="loading-logo" ng-include="'loading.html'"></div>
                <div class="postits {{ postitClass }}"
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
</is:window>