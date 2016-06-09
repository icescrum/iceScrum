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
<header>
    <button type="button" class="navbar-toggle offcanvas-toggle navbar-inverse" data-target="#menu-header" data-toggle="offcanvas">
        <span class="sr-only">${message(code:'todo.is.ui.main.menu')}</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
    </button>
    <entry:point id="before-menu-header"/>
    <nav id="menu-header" class="navbar navbar-masthead navbar-offcanvas navbar-icescrum navbar-default navbar-inverse" role="navigation">
        <div class="container-fluid">
            <div class="nav-header">
                <div class="hidden-xs pull-left">

                </div>
                <is:errors/>
                <ul ng-controller="projectCtrl"
                    class="nav navbar-nav menubar"
                    ng-class="{'sortable':currentUser.id}"
                    is-disabled="!currentUser.id"
                    as-sortable="menuSortableOptions"
                    ng-model="app.menus.visible">
                    <li class="contextual-menu" uib-dropdown>
                        <a uib-dropdown-toggle>
                            <svg class="logo" ng-class="getPushState()" width="100%" height="100%" x="0px" y="0px" viewBox="0 0 150 150" style="enable-background:new 0 0 150 150;" xml:space="preserve">
                                <path class="logois logois1" fill="#42A9E0" d="M77.345,118.476c0,0-44.015-24.76-47.161-26.527c-3.146-1.771-0.028-3.523-0.028-3.523  l49.521-27.854c0,0,46.335,26.058,49.486,27.833c3.154,1.771,0.008,3.545,0.008,3.545S83.921,117.4,81.978,118.492  C79.676,119.787,77.345,118.476,77.345,118.476z"/>
                                <path class="logois logois2" fill="1C3660" d="M77.349,107.287c0,0-44.019-24.758-47.165-26.527s0-3.539,0-3.539L79.68,49.38  c0,0,46.332,26.062,49.482,27.834c3.154,1.775,0.008,3.547,0.008,3.547s-45.193,25.422-47.16,26.525  C79.676,108.599,77.349,107.287,77.349,107.287z"/>
                                <path class="logois logois3" fill="#FFCC04" d="M77.345,95.244c0,0-44.015-24.76-47.161-26.529s0-3.541,0-3.541  s44.814-25.207,47.153-26.522c2.339-1.313,4.602-0.041,4.602-0.041l36.191,20.396c0,0,4.141,1.336,8.162-0.852  c0.33-0.178,0.924-0.553,0.922,0.732c-0.014,12.328-15.943,19.957-15.943,19.957S84.345,93.939,82.009,95.248  C79.676,96.556,77.345,95.244,77.345,95.244z"/>
                            </svg> <i class="fa fa-caret-down"></i>
                        </a>
                        <ul uib-dropdown-menu class="main-dropdown-menu">
                            <li>
                                <a hotkey="{ 'shift+h': goToHome}" href ng-click="goToHome()">
                                    <g:message code="is.projectmenu.submenu.user.home"/> <small class="text-muted">(SHIFT+H)</small>
                                </a>
                            </li>
                            <li role="presentation" class="divider"></li>
                            <li role="presentation" class="dropdown-header">
                                ${message(code: 'todo.is.ui.projects')}
                            </li>
                            <g:if test="${creationProjectEnable}">
                                <li>
                                    <a hotkey="{ 'shift+n': hotkeyClick}"
                                       href
                                       ng-click="goToNewProject()">
                                        <g:message code="is.projectmenu.submenu.project.create"/> <small class="text-muted">(SHIFT+N)</small>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${importEnable}">
                                <li>
                                    <a hotkey="{ 'shift+m': import}" href="" ng-click="import()">
                                        <g:message code="is.projectmenu.submenu.project.import"/> <small class="text-muted">(SHIFT+M)</small>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${browsableProductsExist}">
                                <li>
                                    <a hotkey="{ 'shift+a': hotkeyClick}" href ng-click="showProjectListModal('public')">
                                        <g:message code="is.projectmenu.submenu.project.browse"/> <small class="text-muted">(SHIFT+A)</small>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${product}">
                                <li ng-if="authorizedProject('edit')" role="presentation" class="divider"></li>
                                <li ng-if="authorizedProject('edit')" role="presentation" class="dropdown-header">
                                    ${message(code: 'todo.is.ui.projects.current')} <span class="current-project-name"><b>${product.name}</b></span>
                                </li>
                                <li ng-if="authorizedProject('edit')">
                                    <a hotkey="{ 'shift+e': hotkeyClick}" href ng-click="showProjectEditModal()">
                                        <g:message code="is.projectmenu.submenu.project.edit"/> <small class="text-muted">(SHIFT+E)</small>
                                    </a>
                                </li>
                                <g:if test="${exportEnable && (request.scrumMaster || request.productOwner)}">
                                    <li ng-if="authorizedProject('edit')">
                                        <a hotkey="{ 'shift+d': export}" href ng-click="export(currentProject)">
                                            <g:message code="is.projectmenu.submenu.project.export"/> <small class="text-muted">(SHIFT+X)</small>
                                        </a>
                                    </li>
                                </g:if>
                            </g:if>
                            <g:if test="${productFilteredsList}">
                                <li role="presentation" class="divider" style='display:${productFilteredsList ?'block':'none'}'></li>
                                <li role="presentation" class="dropdown-header" id="my-projects" style='display:${productFilteredsList ?'block':'none'}'>
                                    ${message(code: 'is.projectmenu.submenu.project.my.title')}
                                </li>
                                <g:each var="curProduct" in="${productFilteredsList}">
                                    <li class="project">
                                        <a class="${product?.id == curProduct.id ? 'active' : ''}"
                                           href="${product?.id == curProduct.id ? '' : createLink(controller: "scrumOS", params: [product:curProduct.pkey])+'/'}"
                                           title="${curProduct.name.encodeAsHTML()}">
                                            ${curProduct.name.encodeAsHTML()}
                                        </a>
                                    </li>
                                </g:each>
                            </g:if>
                            <g:if test="${moreProductsExist}">
                                <li>
                                    <a href ng-click="showProjectListModal('user')">
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
                            <li role="presentation" class="dropdown-header">${message(code: 'is.ui.app')}</li>
                            <li><a href hotkey="{'I': showAbout}" hotkey-description="${message(code: 'is.ui.app.extensions')}" ng-click="showManageExtensionsModal()">${message(code: 'is.ui.app.extensions')}</a></li>
                            <li><a href hotkey="{'I': showAbout}" hotkey-description="${message(code: 'is.ui.app.about')}" ng-click="showAbout()">${message(code: 'is.ui.app.about')}</a></li>
                        </ul>
                    </li>
                    <li id="{{ menu.id }}"
                        as-sortable-item
                        ng-repeat="menu in app.menus.visible"
                        ng-include="'menuitem.item.html'"
                        ng-class="{'active':$state.includes(menu.id)}"
                        class="menuitem">
                    </li>
                    <li class="menubar-more" uib-dropdown is-open="more.isopen || menuDragging" ng-class="{ 'hidden': !menuDragging && app.menus.hidden.length == 0 }">
                        <a uib-dropdown-toggle href>${message(code:'todo.is.ui.more')} <i class="fa fa-caret-down"></i></a>
                        <ul uib-dropdown-menu class="menubar"
                            ng-class="{'sortable':currentUser.id}"
                            is-disabled="!currentUser.id"
                            as-sortable="menuSortableOptions"
                            ng-model="app.menus.hidden">
                            <li ng-repeat="menu in app.menus.hidden"
                                ng-include="'menuitem.item.html'"
                                as-sortable-item
                                ng-class="{'active':$state.includes(menu.id)}" class="menuitem"></li>
                        </ul>
                    </li>
                </ul>
                <div class="navbar-right">
                        <g:if test="${product}">
                            <form class="navbar-form pull-left" role="search">
                                <div class="input-group search">
                                    <span class="input-group-btn" ng-if="app.context">
                                        <button class="btn btn-default"
                                                type="button"
                                                ng-click="setContext(null)">
                                            <i class="fa" ng-class="app.context.type == 'feature' ? 'fa-sticky-note' : 'fa-tag'"></i>
                                            <span class="context">{{ app.context.term }}</span>
                                            <i class="fa fa-times"></i>
                                        </button>
                                    </span>
                                    <input autocomplete="off"
                                           type="text"
                                           name="app.search"
                                           class="form-control"
                                           ng-model="app.search"
                                           placeholder="${message(code:'todo.is.ui.search.action')}"
                                           ng-model-options="{ debounce: 300 }"
                                           uib-typeahead="context.term for context in searchContext($viewValue)"
                                           typeahead-on-select="setContext($item)"
                                           typeahead-template-url="search.context.html">
                                    <span class="input-group-btn">
                                        <button class="btn btn-default" type="button" ng-click="app.search = null">
                                            <i class="fa search-status" ng-class="app.search ? 'fa-times' : 'fa-search'"></i>
                                        </button>
                                    </span>
                                </div>
                            </form>
                        </g:if>
                        <div ng-if="currentUser.username" uib-dropdown class="pull-left" on-toggle="notificationToggle(open)">
                            <div class="navbar-notif"
                                 uib-dropdown-toggle>
                                <i class="fa fa-bolt" ng-class="{'empty':getUnreadActivities() == 0}"></i>
                                <span class="badge" ng-show="getUnreadActivities()">{{ getUnreadActivities()}}</span>
                            </div>
                            <div uib-dropdown-menu class="notifications selection-disable" ng-include="'notifications.panel.html'"></div>
                        </div>
                        <div ng-if="currentUser.username" uib-dropdown class="pull-left">
                            <div class="navbar-user pull-left" uib-dropdown-toggle>
                                <img ng-src="{{ currentUser | userAvatar }}" class="{{ currentUser | userColorRoles }}" height="32px" width="32px"/>
                            </div>
                            <div uib-dropdown-menu class="profile-panel" ng-include="'profile.panel.html'"></div>
                        </div>
                        <button id="login"
                                ng-show="!(currentUser.username)"
                                class="btn btn-default"
                                ng-click="showAuthModal()"
                                uib-tooltip="${message(code:'is.button.connect')} (SHIFT+L)"
                                tooltip-placement="bottom"><g:message code="is.button.connect"/></button>
                    </div>
            </div>
        </div>
    </nav>
</header>