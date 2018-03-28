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
<header ng-style="application.context | contextStyle">
    <button type="button" class="navbar-toggle offcanvas-toggle navbar-inverse" data-target="#menu-header" data-toggle="offcanvas">
        <span class="sr-only">${message(code: 'todo.is.ui.main.menu')}</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
    </button>
    <entry:point id="header-before-menu"/>
    <nav id="menu-header"
         class="navbar navbar-masthead navbar-offcanvas navbar-icescrum navbar-default navbar-inverse {{ application.context.color | contrastColor:true }}"
         role="navigation">
        <div class="container-fluid">
            <div class="nav-header">
                <div class="hidden-xs pull-left">
                </div>
                <a ng-if="warning"
                   class="show-warning link"
                   ng-click="showAbout()"
                   href
                   tooltip-placement="right"
                   uib-tooltip="{{:: warning.title }}"><i class="fa fa-{{:: warning.icon }}"></i>
                </a>
                <ul ng-controller="mainMenuCtrl"
                    class="nav navbar-nav menubar"
                    is-disabled="!currentUser.id || workspaceType != 'project'"
                    as-sortable="menuSortableOptions"
                    ng-model="application.menus.visible">
                    <li class="workspace-menu {{:: workspaceType }}" uib-dropdown>
                        <a uib-dropdown-toggle>
                            <svg class="logo" ng-class="getPushState()" viewBox="0 0 150 150">
                                <g:render template="/scrumOS/logo"/>
                            </svg>&nbsp;<g:if test="${workspace}"><i tooltip-placement="bottom" uib-tooltip="{{ message('is.ui.${workspace.name}.public') }}"
                                                                     ng-if="workspace.preferences && !workspace.preferences.hidden && authorized${workspace.name.capitalize()}('edit')"
                                                                     ng-click="show${workspace.name.capitalize()}EditModal(); $event.stopPropagation();" class="fa fa-eye">&nbsp;</i></g:if><g:if test="${workspace?.icon}"><i
                                class="fa fa-${workspace.icon}"></i> <span class="text-ellipsis" title="{{ workspace.name }}">{{ workspace.name }}</span></g:if> <i class="fa fa-caret-down"></i>
                        </a>
                        <ul uib-dropdown-menu class="main-dropdown-menu">
                            <li role="presentation" class="dropdown-header">
                                ${message(code: 'is.ui.workspaces')}
                            </li>
                            <g:if test="${creationEnable}">
                                <li>
                                    <a hotkey="{ 'shift+n': hotkeyClick}"
                                       hotkey-description="${message(code: 'todo.is.ui.project.createNew')}"
                                       ui-sref="new">
                                        <g:message code="is.ui.workspace.create"/> <small class="text-muted">(SHIFT+N)</small>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${importEnable}">
                                <li>
                                    <a hotkey="{ 'shift+m': import}"
                                       hotkey-description="${message(code: 'is.dialog.importProject.choose.title')}"
                                       href=""
                                       ng-click="import()">
                                        <g:message code="is.projectmenu.submenu.project.import"/> <small class="text-muted">(SHIFT+M)</small>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${browsableWorkspacesExist}">
                                <g:if test="${request.admin}">
                                    <li>
                                        <a hotkey="{ 'shift+a': hotkeyClick}"
                                           href
                                           ng-click="showWorkspaceListModal('all', 'project')"
                                           hotkey-description="${message(code: 'todo.is.ui.project.list.all')}">
                                            <g:message code="todo.is.ui.project.list.all"/>
                                            <small class="text-muted">(SHIFT+A)</small>
                                        </a>
                                    </li>
                                    <g:if test="${portfolioEnabled}">
                                        <li>
                                            <a hotkey="{ 'shift+z': hotkeyClick}"
                                               href
                                               ng-click="showWorkspaceListModal('all','portfolio')"
                                               hotkey-description="${message(code: 'is.ui.portfolio.list.all')}">
                                                <g:message code="is.ui.portfolio.list.all"/>
                                                <small class="text-muted">(SHIFT+Z)</small>
                                            </a>
                                        </li>
                                    </g:if>
                                </g:if>
                                <g:else>
                                    <li>
                                        <a hotkey="{ 'shift+a': hotkeyClick}"
                                           href
                                           ng-click="showWorkspaceListModal('public', 'project')"
                                           hotkey-description="${message(code: 'todo.is.ui.project.list.public')}">
                                            <g:message code="todo.is.ui.project.list.public"/>
                                            <small class="text-muted">(SHIFT+A)</small>
                                        </a>
                                    </li>
                                </g:else>
                            </g:if>
                            <g:if test="${workspace?.object}">
                                <li ng-if=":: authorized${workspace.name.capitalize()}('edit')" role="presentation" class="divider"></li>
                                <li ng-if=":: authorized${workspace.name.capitalize()}('edit')" role="presentation" class="dropdown-header">
                                    ${message(code: 'is.ui.workspace.' + workspace.name + '.current')} <span class="current-workspace-name text-ellipsis" title="{{ workspace.name }}"
                                                                                                             style="display:inline-block; max-width:70px"><b>{{ workspace.name }}</b></span>
                                </li>
                                <li ng-if=":: authorized${workspace.name.capitalize()}('edit')">
                                    <a hotkey="{ 'shift+e': hotkeyClick}"
                                       hotkey-description="${message(code: 'is.ui.apps.configure')}"
                                       href
                                       ng-click="show${workspace.name.capitalize()}EditModal()">
                                        <g:message code="is.ui.workspace.submenu.edit"/> <small class="text-muted">(SHIFT+E)</small>
                                    </a>
                                </li>
                                <g:if test="${exportEnable}">
                                    <li ng-if=":: authorized${workspace.name.capitalize()}('export')">
                                        <a hotkey="{ 'shift+d': export}"
                                           hotkey-description="${message(code: 'is.dialog.exportProject.title')}"
                                           href
                                           ng-click="export(${workspace.name})">
                                            <g:message code="is.ui.workspace.submenu.export"/> <small class="text-muted">(SHIFT+X)</small>
                                        </a>
                                    </li>
                                </g:if>
                                <li ng-if=":: authorizedApp('show')">
                                    <a href ng-click="showAppsModal()">
                                        <b class="text-important">${message(code: 'is.ui.apps')}</b>
                                    </a>
                                </li>
                                <entry:point id="header-menu-current-workspace"/>
                            </g:if>
                            <g:if test="${workspacesFilteredsList}">
                                <li role="presentation" class="divider" style='display:${workspacesFilteredsList ? 'block' : 'none'}'></li>
                                <li role="presentation" class="dropdown-header" style='display:${workspacesFilteredsList ? 'block' : 'none'}'>
                                    ${message(code: 'is.ui.workspace.my.title')}
                                </li>
                                <g:each var="workspaceFiltered" in="${workspacesFilteredsList}">
                                    <is:workspaceListItem workspace="${workspaceFiltered}" currentWorkspace="${workspace?.object}"/>
                                </g:each>
                            </g:if>
                            <g:if test="${moreWorkspacesExist}">
                                <li>
                                    <a href ng-click="showWorkspaceListModal('user')">
                                        <g:message code="is.projectmenu.submenu.project.more"/>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${request.authenticated}">
                                <li role="presentation" class="divider"></li>
                                <li role="presentation" class="dropdown-header">${message(code: 'is.ui.team.menu')}</li>
                                <li><a href ng-click="showManageTeamsModal()">${message(code: 'is.ui.team.manage')}</a></li>
                            </g:if>
                            <li role="presentation" class="divider"></li>
                            <li role="presentation" class="dropdown-header">iceScrum</li>
                            <entry:point id="header-menu-icescrum-first"/>
                            <li>
                                <a href
                                   hotkey="{'shift+i': showAbout}"
                                   hotkey-description="${message(code: 'is.ui.about')}"
                                   uib-tooltip="(shift+i)"
                                   ng-click="showAbout()">
                                    ${message(code: 'is.ui.about')}
                                </a>
                            </li>
                            <entry:point id="header-menu-icescrum"/>
                        </ul>
                    </li>
                    <li id="{{:: menu.id }}"
                        as-sortable-item
                        ng-repeat="menu in application.menus.visible"
                        ng-include="'menuitem.item.html'"
                        ng-class="{'active':$state.includes(menu.id)}"
                        class="menuitem">
                    </li>
                    <li class="menubar-more" uib-dropdown is-open="more.isopen || menuDragging" ng-class="{ 'hidden': !menuDragging && application.menus.hidden.length == 0 }">
                        <a uib-dropdown-toggle href>${message(code: 'todo.is.ui.more')} <i class="fa fa-caret-down"></i></a>
                        <ul uib-dropdown-menu class="menubar"
                            is-disabled="!currentUser.id || workspaceType != 'project'"
                            as-sortable="menuSortableOptions"
                            ng-model="application.menus.hidden">
                            <li ng-repeat="menu in application.menus.hidden"
                                ng-include="'menuitem.item.html'"
                                as-sortable-item
                                ng-class="{'active':$state.includes(menu.id)}" class="menuitem"></li>
                        </ul>
                    </li>
                </ul>
                <div class="navbar-right">
                    <g:if test="${project}">
                        <form class="navbar-form pull-left" role="search">
                            <div class="input-group search">
                                <span class="input-group-btn" ng-if="application.context">
                                    <button class="btn btn-default"
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
                                <span class="input-group-btn">
                                    <button class="btn btn-default" type="button" ng-click="application.search = null">
                                        <i class="fa search-status" ng-class="application.search ? 'fa-times' : 'fa-search'"></i>
                                    </button>
                                </span>
                            </div>
                        </form>
                    </g:if>
                    <g:else>
                        <form class="navbar-form pull-left" role="search">
                            <div class="input-group search">
                                <input autocomplete="off"
                                       type="text"
                                       name="application.search"
                                       class="form-control"
                                       ng-model="application.search"
                                       placeholder="${message(code: 'todo.is.ui.search.action')}"
                                       ng-model-options="{ debounce: 300 }">
                                <span class="input-group-btn">
                                    <button class="btn btn-default" type="button" ng-click="application.search = null">
                                        <i class="fa search-status" ng-class="application.search ? 'fa-times' : 'fa-search'"></i>
                                    </button>
                                </span>
                            </div>
                        </form>
                    </g:else>
                    <g:if test="${g.meta(name: 'app.displayReleaseNotes')}">
                        <div class="navbar-fa navbar-whatsNew pull-left" ng-if="currentUser.preferences ? currentUser.preferences.displayReleaseNotes : true">
                            <a href ng-click="showReleaseNotesModal()">
                                <i class="fa fa-gift fa-2x" id="ga-show-whats-new-event"></i>
                            </a>
                        </div>
                    </g:if>
                    <div ng-if=":: currentUser.username" uib-dropdown class="pull-left" on-toggle="notificationToggle(open)">
                        <div class="navbar-fa navbar-notif"
                             uib-dropdown-toggle>
                            <i class="fa fa-bolt" ng-class="{'empty':getUnreadActivities() == 0}"></i>
                            <span class="badge" ng-show="getUnreadActivities()">{{ getUnreadActivities()}}</span>
                        </div>
                        <div uib-dropdown-menu class="notifications selection-disable" ng-include="'notifications.panel.html'"></div>
                    </div>
                    <div class="navbar-fa navbar-home pull-left">
                        <a hotkey="{ 'shift+h': goToHome}"
                           hotkey-description="${message(code: 'todo.is.ui.open.view')} <g:message code="is.ui.home"/>"
                           uib-tooltip="${message(code: 'is.ui.home')} (shift+h)"
                           tooltip-placement="bottom"
                           ng-href="{{:: serverUrl }}">
                            <i class="fa fa-home"></i>
                        </a>
                    </div>
                    <div ng-if=":: currentUser.username" uib-dropdown class="pull-left">
                        <div class="navbar-user pull-left" uib-dropdown-toggle>
                            <img ng-src="{{ currentUser | userAvatar }}" class="{{ currentUser | userColorRoles }}" height="32px" width="32px"/>
                        </div>
                        <div uib-dropdown-menu class="profile-panel" ng-include="'profile.panel.html'"></div>
                    </div>
                    <button id="login"
                            ng-show="!(currentUser.username)"
                            class="btn btn-default"
                            ng-click="showAuthModal()"
                            uib-tooltip="${message(code: 'is.button.connect')} (SHIFT+L)"
                            tooltip-placement="bottom"><g:message code="is.button.connect"/></button>
                </div>
            </div>
        </div>
    </nav>
</header>