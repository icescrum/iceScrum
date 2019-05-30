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
<nav class="navbar navbar-light navbar-expand-lg"
     role="navigation">
    <div class="nav-item">
        <div id="menu-loader"></div>
    </div>
    <a ng-if="warning"
       class="nav-warning"
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
            <li class="nav-item nav-item-main"
                ng-class="workspaceType ? ('workspace-menu ' + workspaceType) : ''"
                uib-dropdown>
                <a uib-dropdown-toggle
                   href
                   class="nav-link">
                    <g:if test="${workspace}">
                        <div class="is-icon"
                             ng-class="'icon-' + (workspace.preferences.hidden ? 'private' : 'public')"
                             ng-if="workspace.preferences"
                             tooltip-placement="bottom"
                             uib-tooltip="{{ message('is.ui.${workspace.name}.' + (workspace.preferences.hidden ? 'private' : 'public')) }}"
                             ng-click="authorized${workspace.name.capitalize()}('edit') && show${workspace.name.capitalize()}EditModal();">
                        </div>
                        <g:if test="${workspace.name}">
                            <div class="is-icon icon-${workspace.name}"></div>
                            <span class="workspace-title text-ellipsis">{{ workspace.name }}</span>
                        </g:if>
                    </g:if>
                </a>
                <div uib-dropdown-menu>
                    <g:if test="${workspace?.object}">
                        <span ng-if=":: authorized${workspace.name.capitalize()}('edit')" role="presentation" class="dropdown-header">
                            ${message(code: 'is.ui.workspace.' + workspace.name + '.current')}
                        </span>
                        <a class="dropdown-item"
                           ng-if=":: authorized${workspace.name.capitalize()}('edit')"
                           hotkey="{ 'shift+s': hotkeyClick}"
                           hotkey-description="${message(code: 'is.ui.apps.configure')}"
                           href
                           ng-click="show${workspace.name.capitalize()}EditModal()">
                            <g:message code="is.ui.workspace.submenu.edit"/> <small class="text-muted">Shift S</small>
                        </a>
                        <g:if test="${exportEnable}">
                            <a class="dropdown-item"
                               ng-if=":: authorized${workspace.name.capitalize()}('export')"
                               href
                               ng-click="confirm({buttonTitle: 'is.ui.workspace.submenu.export', message: message('is.ui.project.export.confirm'), callback: export, args: [${workspace.name}]})">
                                ${message(code: 'is.ui.workspace.submenu.export')}
                            </a>
                        </g:if>
                        <a class="dropdown-item"
                           ng-if=":: authorizedApp('show')"
                           href
                           hotkey="{'shift+a': showAppsModal}"
                           hotkey-description="${message(code: 'is.ui.apps')}"
                           ng-click="showAppsModal()">
                            <b class="text-primary">${message(code: 'is.ui.apps')}</b> <small class="text-muted">Shift A</small>
                        </a>
                        <entry:point id="header-menu-current-workspace"/>
                        <div ng-if=":: authorized${workspace.name.capitalize()}('edit')" role="presentation" class="dropdown-divider"></div>
                    </g:if>
                    <span role="presentation" class="dropdown-header">
                        ${message(code: 'is.ui.workspaces')}
                    </span>
                    <g:if test="${creationEnable}">
                        <a class="dropdown-item"
                           hotkey="{ 'shift+n': hotkeyClick}"
                           hotkey-description="${message(code: 'todo.is.ui.project.createNew')}"
                           ui-sref="new">
                            <g:message code="is.ui.workspace.create"/> <small class="text-muted">Shift N</small>
                        </a>
                    </g:if>
                    <g:if test="${importEnable}">
                        <a class="dropdown-item"
                           hotkey="{ 'shift+m': import}"
                           hotkey-description="${message(code: 'is.dialog.importProject.choose.title')}"
                           href=""
                           ng-click="import()">
                            <g:message code="is.projectmenu.submenu.project.import"/> <small class="text-muted">Shift M</small>
                        </a>
                    </g:if>
                    <g:if test="${browsableWorkspacesExist}">
                        <g:if test="${request.admin}">
                            <a class="dropdown-item"
                               href
                               ng-click="showWorkspaceListModal('all', 'project')">
                                <g:message code="todo.is.ui.project.list.all"/>
                            </a>
                            <g:if test="${portfolioEnabled}">
                                <a class="dropdown-item"
                                   href
                                   ng-click="showWorkspaceListModal('all','portfolio')">
                                    <g:message code="is.ui.portfolio.list.all"/>
                                </a>
                            </g:if>
                        </g:if>
                        <g:else>
                            <a class="dropdown-item"
                               hotkey="{ 'shift+p': hotkeyClick}"
                               href
                               ng-click="showWorkspaceListModal('public', 'project')"
                               hotkey-description="${message(code: 'todo.is.ui.project.list.public')}">
                                <g:message code="todo.is.ui.project.list.public"/> <small class="text-muted">Shift P</small>
                            </a>
                        </g:else>
                    </g:if>
                    <g:if test="${workspacesFilteredsList}">
                        <div role="presentation" class="dropdown-divider"></div>
                        <span role="presentation" class="dropdown-header">
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
                        <div role="presentation" class="dropdown-divider"></div>
                        <span role="presentation" class="dropdown-header">${message(code: 'is.ui.team.menu')}</span>
                        <a class="dropdown-item"
                           href
                           ng-click="showManageTeamsModal()">
                            ${message(code: 'is.ui.manage')}
                        </a>
                    </g:if>
                    <div role="presentation" class="dropdown-divider"></div>
                    <span role="presentation" class="dropdown-header">iceScrum</span>
                    <entry:point id="header-menu-icescrum-first"/>
                    <a class="dropdown-item"
                       href
                       hotkey="{'shift+i': showAbout}"
                       hotkey-description="${message(code: 'is.ui.about')}"
                       ng-click="showAbout()">
                        ${message(code: 'is.ui.about')} <small class="text-muted">Shift I</small>
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
    <div class="navbar-right {{ application.context.color | contrastColor:true }}"
         ng-style="application.context | contextStyle">
        <g:if test="${project}">
            <form class="form-inline" role="search">
                <div ng-class="application.context ? 'input-group' : ''">
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
                           class="form-control search-input"
                           ng-model="application.search"
                           placeholder="${message(code: 'todo.is.ui.search.action')}"
                           ng-model-options="{ debounce: 300 }"
                           uib-typeahead="context.term for context in searchContext($viewValue)"
                           typeahead-on-select="setContext($item)"
                           typeahead-template-url="search.context.html">
                </div>
            </form>
        </g:if>
        <g:else>
            <form class="form-inline" role="search">
                <input autocomplete="off"
                       type="text"
                       name="application.search"
                       class="form-control search-input"
                       ng-model="application.search"
                       placeholder="${message(code: 'todo.is.ui.search.action')}"
                       ng-model-options="{ debounce: 300 }">
            </form>
        </g:else>
        <g:if test="${g.meta(name: 'app.displayReleaseNotes')}">
            <div ng-if="currentUser.preferences ? currentUser.preferences.displayReleaseNotes : true">
                <a href ng-click="showReleaseNotesModal()">
                    <i class="fa fa-gift fa-2x" id="ga-show-whats-new-event"></i>
                </a>
            </div>
        </g:if>
        <div ng-if=":: currentUser.username" uib-dropdown on-toggle="notificationToggle(open)">
            <div uib-dropdown-toggle class="no-caret">
                <div class="main-notifications" ng-class="{'has-notifications': getUnreadActivities() != 0}">
                    <div class="fi-bell"></div>
                    <span class="notification-count" ng-show="getUnreadActivities()">{{ getUnreadActivities()}}</span>
                </div>
            </div>
            <div uib-dropdown-menu class="dropdown-menu-right" ng-include="'notifications.panel.html'"></div>
        </div>
        <div ng-if=":: currentUser.username" uib-dropdown>
            <a hotkey="{ 'shift+h': goToHome}"
               hotkey-description="${message(code: 'todo.is.ui.open.view')} <g:message code="is.ui.home"/>"
               ng-href="{{:: serverUrl }}/#/">
                <img ng-src="{{ currentUser | userAvatar }}"
                     class="{{ currentUser | userColorRoles }}"
                     tooltip-placement="left"
                     defer-tooltip="{{ currentUser.email }} {{:: getCurrentUserRoles() }}"
                     height="37px"
                     width="37px"/>
            </a>
        </div>
        <button id="login"
                ng-show="!(currentUser.username)"
                class="btn btn-secondary"
                ng-click="logIn()"
                defer-tooltip="${message(code: 'is.button.connect')} (SHIFT+L)"
                tooltip-placement="bottom"><g:message code="is.button.connect"/></button>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
    </div>
</nav>