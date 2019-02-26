<%@ page import="grails.converters.JSON" %>
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
<g:if test="${workspace && workspace.name == 'project' && workspace.object.preferences.archived}">
    <div class="bg-danger text-center text-danger archived-message"><i class="fa fa-archive"></i> <g:message code="is.ui.${workspace.name}.archived"/></div>
</g:if>
<entry:point id="header-before-menu"/>
<nav class="navbar navbar-light navbar-expand-lg {{ application.context.color | contrastColor:true }}"
     ng-style="application.context | contextStyle"
     role="navigation">
    <a ng-if="warning"
       ng-click="showAbout()"
       href
       tooltip-placement="right"
       defer-tooltip="{{:: warning.title }}"><i class="fa fa-{{:: warning.icon }}"></i>
    </a>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul ng-controller="mainMenuCtrl"
            class="nav navbar-nav"
            is-disabled="!currentUser.id || workspaceType != 'project'"
            as-sortable="menuSortableOptions"
            ng-model="application.menus.visible">
            <li class="nav-item"
                ng-class="workspaceType ? workspaceType : ''"
                uib-dropdown>
                <a uib-dropdown-toggle
                   href
                   class="nav-link">
                    <svg class="logo" ng-class="getPushState()" viewBox="0 0 150 150">
                        <g:render template="/scrumOS/logo"/>
                    </svg>
                    <g:if test="${workspace}"><i tooltip-placement="bottom"
                                                 defer-tooltip="{{ message('is.ui.${workspace.name}.public') }}"
                                                 ng-if="workspace.preferences && !workspace.preferences.hidden && authorized${workspace.name.capitalize()}('edit')"
                                                 ng-click="show${workspace.name.capitalize()}EditModal(); $event.stopPropagation();" class="fa fa-eye">&nbsp;</i></g:if><g:if test="${workspace?.icon}"><i class="fa fa-${workspace.icon}"></i>
                    <span class="text-ellipsis" title="{{ workspace.name }}"><strong>{{ workspace.name }}</strong></span></g:if>
                </a>
                <div uib-dropdown-menu>
                    <span role="presentation" class="dropdown-header">
                        ${message(code: 'is.ui.workspaces')}
                    </span>
                    <g:if test="${creationEnable}">
                        <a class="dropdown-item"
                           hotkey="{ 'shift+n': hotkeyClick}"
                           hotkey-description="${message(code: 'todo.is.ui.project.createNew')}"
                           ui-sref="new">
                            <g:message code="is.ui.workspace.create"/> <small class="text-muted">(SHIFT+N)</small>
                        </a>
                    </g:if>
                    <g:if test="${importEnable}">
                        <a class="dropdown-item"
                           hotkey="{ 'shift+m': import}"
                           hotkey-description="${message(code: 'is.dialog.importProject.choose.title')}"
                           href=""
                           ng-click="import()">
                            <g:message code="is.projectmenu.submenu.project.import"/> <small class="text-muted">(SHIFT+M)</small>
                        </a>
                    </g:if>
                    <g:if test="${browsableWorkspacesExist}">
                        <g:if test="${request.admin}">
                            <a class="dropdown-item"
                               hotkey="{ 'shift+a': hotkeyClick}"
                               href
                               ng-click="showWorkspaceListModal('all', 'project')"
                               hotkey-description="${message(code: 'todo.is.ui.project.list.all')}">
                                <g:message code="todo.is.ui.project.list.all"/>
                                <small class="text-muted">(SHIFT+A)</small>
                            </a>
                            <g:if test="${portfolioEnabled}">
                                <a class="dropdown-item"
                                   hotkey="{ 'shift+z': hotkeyClick}"
                                   href
                                   ng-click="showWorkspaceListModal('all','portfolio')"
                                   hotkey-description="${message(code: 'is.ui.portfolio.list.all')}">
                                    <g:message code="is.ui.portfolio.list.all"/>
                                    <small class="text-muted">(SHIFT+Z)</small>
                                </a>
                            </g:if>
                        </g:if>
                        <g:else>
                            <a class="dropdown-item"
                               hotkey="{ 'shift+a': hotkeyClick}"
                               href
                               ng-click="showWorkspaceListModal('public', 'project')"
                               hotkey-description="${message(code: 'todo.is.ui.project.list.public')}">
                                <g:message code="todo.is.ui.project.list.public"/>
                                <small class="text-muted">(SHIFT+A)</small>
                            </a>
                        </g:else>
                    </g:if>
                    <g:if test="${workspace?.object}">
                        <span ng-if=":: authorized${workspace.name.capitalize()}('edit')" role="presentation" class="dropdown-divider"></span>
                        <span ng-if=":: authorized${workspace.name.capitalize()}('edit')" role="presentation" class="dropdown-header">
                            ${message(code: 'is.ui.workspace.' + workspace.name + '.current')} <span class="current-workspace-name text-ellipsis" title="{{ workspace.name }}"
                                                                                                     style="display:inline-block; max-width:70px"><b>{{ workspace.name }}</b></span>
                        </span>
                        <a class="dropdown-item"
                           ng-if=":: authorized${workspace.name.capitalize()}('edit')"
                           hotkey="{ 'shift+e': hotkeyClick}"
                           hotkey-description="${message(code: 'is.ui.apps.configure')}"
                           href
                           ng-click="show${workspace.name.capitalize()}EditModal()">
                            <g:message code="is.ui.workspace.submenu.edit"/> <small class="text-muted">(SHIFT+E)</small>
                        </a>
                        <a class="dropdown-item"
                           ng-if=":: authorizedApp('show')"
                           href
                           ng-click="showAppsModal()">
                            <b class="text-important">${message(code: 'is.ui.apps')}</b>
                        </a>
                        <g:if test="${exportEnable}">
                            <a class="dropdown-item"
                               ng-if=":: authorized${workspace.name.capitalize()}('export')"
                               href
                               ng-click="confirm({buttonTitle: 'is.ui.workspace.submenu.export', message: message('is.ui.project.export.confirm'), callback: export, args: [${workspace.name}]})">
                                ${message(code: 'is.ui.workspace.submenu.export')}
                            </a>
                        </g:if>
                        <entry:point id="header-menu-current-workspace"/>
                    </g:if>
                    <g:if test="${workspacesFilteredsList}">
                        <span role="presentation" class="dropdown-divider" style='display:${workspacesFilteredsList ? 'block' : 'none'}'></span>
                        <span role="presentation" class="dropdown-header" style='display:${workspacesFilteredsList ? 'block' : 'none'}'>
                            ${message(code: 'is.ui.workspace.my.title')}
                        </span>
                        <g:each var="workspaceFiltered" in="${workspacesFilteredsList}">
                            <is:workspaceListItem workspace="${workspaceFiltered}" currentWorkspace="${workspace?.object}"/>
                        </g:each>
                    </g:if>
                    <g:if test="${moreWorkspacesExist}">
                        <a class="dropdown-item"
                           href
                           ng-click="showWorkspaceListModal('user')">
                            <g:message code="is.projectmenu.submenu.project.more"/>
                        </a>
                    </g:if>
                    <g:if test="${request.authenticated}">
                        <span role="presentation" class="dropdown-divider"></span>
                        <span role="presentation" class="dropdown-header">${message(code: 'is.ui.team.menu')}</span>
                        <a class="dropdown-item"
                           href
                           ng-click="showManageTeamsModal()">
                            ${message(code: 'is.ui.manage')}
                        </a>
                    </g:if>
                    <span role="presentation" class="dropdown-divider"></span>
                    <span role="presentation" class="dropdown-header">iceScrum</span>
                    <entry:point id="header-menu-icescrum-first"/>
                    <a class="dropdown-item"
                       href
                       hotkey="{'shift+i': showAbout}"
                       hotkey-description="${message(code: 'is.ui.about')}"
                       defer-tooltip="(shift+i)"
                       ng-click="showAbout()">
                        ${message(code: 'is.ui.about')}
                    </a>
                    <entry:point id="header-menu-icescrum"/>
                </div>
            </li>
            <li id="{{:: menu.id }}"
                as-sortable-item
                ng-repeat="menu in application.menus.visible"
                ng-include="'menuitem.item.html'"
                ng-class="{'active':$state.includes(menu.id)}"
                class="nav-item">
            </li>
            <li class="nav-item"
                uib-dropdown is-open="more.isopen || menuDragging" ng-class="{ 'hidden': !menuDragging && application.menus.hidden.length == 0 }">
                <a uib-dropdown-toggle href class="nav-link">${message(code: 'todo.is.ui.more')}</a>
                <ul uib-dropdown-menu
                    is-disabled="!currentUser.id || workspaceType != 'project'"
                    as-sortable="menuSortableOptions"
                    ng-model="application.menus.hidden">
                    <li ng-repeat="menu in application.menus.hidden"
                        ng-include="'menuitem.item.html'"
                        as-sortable-item
                        ng-class="{'active':$state.includes(menu.id)}"></li>
                </ul>
            </li>
        </ul>
    </div>
    <g:if test="${project}">
        <form class="form-inline pull-left" role="search">
            <div class="input-group search">
                <span class="input-group-prepend" ng-if="application.context">
                    <button class="btn btn-secondary btn-sm"
                            type="button"
                            ng-click="setContext(null)">
                        <i class="fa" ng-class="application.context.type | contextIcon"></i>
                        <span class="context">{{ application.context.term }}</span>
                        <i class="fa fa-times"></i>
                    </button>
                </span>
                <input autocomplete="off"
                       type="text"
                       name="application.search"
                       class="form-control"
                       ng-model="application.search"
                       placeholder="${message(code: 'todo.is.ui.search.action')}"
                       ng-model-options="{ debounce: 300 }"
                       uib-typeahead="context.term for context in searchContext($viewValue)"
                       typeahead-on-select="setContext($item)"
                       typeahead-template-url="search.context.html">
                <span class="input-group-append">
                    <button class="btn btn-secondary btn-sm" type="button" ng-click="application.search = null">
                        <i class="fa search-status" ng-class="application.search ? 'fa-times' : 'fa-search'"></i>
                    </button>
                </span>
            </div>
        </form>
    </g:if>
    <g:else>
        <form class="form-inline pull-left" role="search">
            <div class="input-group search">
                <input autocomplete="off"
                       type="text"
                       name="application.search"
                       class="form-control"
                       ng-model="application.search"
                       placeholder="${message(code: 'todo.is.ui.search.action')}"
                       ng-model-options="{ debounce: 300 }">
                <span class="input-group-append">
                    <button class="btn btn-secondary btn-sm" type="button" ng-click="application.search = null">
                        <i class="fa search-status" ng-class="application.search ? 'fa-times' : 'fa-search'"></i>
                    </button>
                </span>
            </div>
        </form>
    </g:else>
    <g:if test="${g.meta(name: 'app.displayReleaseNotes')}">
        <div class="pull-left" ng-if="currentUser.preferences ? currentUser.preferences.displayReleaseNotes : true">
            <a href ng-click="showReleaseNotesModal()">
                <i class="fa fa-gift fa-2x" id="ga-show-whats-new-event"></i>
            </a>
        </div>
    </g:if>
    <div ng-if=":: currentUser.username" uib-dropdown class="pull-left" on-toggle="notificationToggle(open)">
        <div uib-dropdown-toggle>
            <i class="fa fa-bolt" ng-class="{'empty':getUnreadActivities() == 0}"></i>
            <span class="badge" ng-show="getUnreadActivities()">{{ getUnreadActivities()}}</span>
        </div>
        <div uib-dropdown-menu class="notifications selection-disable" ng-include="'notifications.panel.html'"></div>
    </div>
    <div class="pull-left">
        <a hotkey="{ 'shift+h': goToHome}"
           hotkey-description="${message(code: 'todo.is.ui.open.view')} <g:message code="is.ui.home"/>"
           defer-tooltip="${message(code: 'is.ui.home')} (shift+h)"
           tooltip-placement="bottom"
           ng-href="{{:: serverUrl }}">
            <i class="fa fa-home"></i>
        </a>
    </div>
    <div ng-if=":: currentUser.username" uib-dropdown class="pull-left">
        <div class="pull-left" uib-dropdown-toggle>
            <img ng-src="{{ currentUser | userAvatar }}" class="{{ currentUser | userColorRoles }}" height="32px" width="32px"/>
        </div>
        <div uib-dropdown-menu class="profile-panel" ng-include="'profile.panel.html'"></div>
    </div>
    <button id="login"
            ng-show="!(currentUser.username)"
            class="btn btn-secondary"
            ng-click="showAuthModal()"
            defer-tooltip="${message(code: 'is.button.connect')} (SHIFT+L)"
            tooltip-placement="bottom"><g:message code="is.button.connect"/></button>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
</nav>