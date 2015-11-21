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
<nav class="navbar navbar-masthead navbar-icescrum navbar-default" role="navigation">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="pull-left navbar-toggle">
                <span class="sr-only">${message(code:'todo.is.ui.main.menu')}</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <div class="hidden-xs"
               hotkey="{'I': showAbout}"
               hotkey-description="${message(code: 'is.about')}"
               ng-click="showAbout()">
                <svg class="logo" ng-class="getPushState()" width="100%" height="100%" x="0px" y="0px" viewBox="0 0 150 150" style="enable-background:new 0 0 150 150;" xml:space="preserve">
                    <path class="logois logois1" d="M77.345,118.476c0,0-44.015-24.76-47.161-26.527c-3.146-1.771-0.028-3.523-0.028-3.523  l49.521-27.854c0,0,46.335,26.058,49.486,27.833c3.154,1.771,0.008,3.545,0.008,3.545S83.921,117.4,81.978,118.492  C79.676,119.787,77.345,118.476,77.345,118.476z"/>
                    <path class="logois logois2" d="M77.349,107.287c0,0-44.019-24.758-47.165-26.527s0-3.539,0-3.539L79.68,49.38  c0,0,46.332,26.062,49.482,27.834c3.154,1.775,0.008,3.547,0.008,3.547s-45.193,25.422-47.16,26.525  C79.676,108.599,77.349,107.287,77.349,107.287z"/>
                    <path class="logois logois3" d="M77.345,95.244c0,0-44.015-24.76-47.161-26.529s0-3.541,0-3.541  s44.814-25.207,47.153-26.522c2.339-1.313,4.602-0.041,4.602-0.041l36.191,20.396c0,0,4.141,1.336,8.162-0.852  c0.33-0.178,0.924-0.553,0.922,0.732c-0.014,12.328-15.943,19.957-15.943,19.957S84.345,93.939,82.009,95.248  C79.676,96.556,77.345,95.244,77.345,95.244z"/>
                </svg>
            </div>
            <is:errors/>
        </div>
        <div id="mainmenu" ng-controller="projectCtrl">
            <ul class="nav navbar-nav scroll menubar"
                ng-class="{'sortable':currentUser.id}"
                is-disabled="!currentUser.id"
                as-sortable="menuSortableListeners"
                ng-model="menus.visible">
                <li class="contextual-menu" uib-dropdown>
                    <a uib-dropdown-toggle>
                        ${pageScope.variables?.space ? pageScope.space.object.name.encodeAsJavaScript() : message(code:'is.projectmenu.title')}&nbsp;<i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="uib-dropdown-menu">
                        <li>
                            <a hotkey="{ 'shift+h': goToHome}" href ng-click="goToHome()">
                                <g:message code="is.projectmenu.submenu.user.home"/> <small class="text-muted">(SHIFT+H)</small>
                            </a>
                        </li>
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
                            <li role="presentation" class="divider"></li>
                            <li role="presentation" class="dropdown-header">
                                ${message(code: 'todo.is.ui.projects.current')}
                            </li>
                            <li>
                                <a hotkey="{ 'shift+e': hotkeyClick}" href ng-click="showProjectEditModal()">
                                    <g:message code="is.projectmenu.submenu.project.edit"/> <small class="text-muted">(SHIFT+E)</small>
                                </a>
                            </li>
                            <g:if test="${exportEnable && (request.scrumMaster || request.productOwner)}">
                                <li>
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
                        <entry:point id="menu-project" model="[curProduct:product,user:user]"/>
                    </ul>
                </li>
                <entry:point id="menu-left" model="[product:product]"/>
                <li id="{{ menu.id }}"
                    as-sortable-item
                    ng-repeat="menu in menus.visible"
                    ng-include="'menuitem.item.html'"
                    ng-class="{'active':$state.includes(menu.id)}"
                    class="menuitem">
                </li>
                <li class="menubar-more" uib-dropdown is-open="more.isopen || menuDragging" ng-class="{ 'hidden': !menuDragging && menus.hidden.length == 0 }">
                    <a uib-dropdown-toggle href>${message(code:'todo.is.ui.more')} <i class="fa fa-caret-down"></i></a>
                    <ul class="uib-dropdown-menu menubar"
                        ng-class="{'sortable':currentUser.id}"
                        is-disabled="!currentUser.id"
                        as-sortable="menuSortableListeners"
                        ng-model="menus.hidden">
                            <li ng-repeat="menu in menus.hidden"
                                ng-include="'menuitem.item.html'"
                                as-sortable-item
                                ng-class="{'active':$state.includes(menu.id)}" class="menuitem"></li>
                    </ul>
                </li>
            </ul>
            <entry:point id="menu-right" model="[curProduct:curProduct]"/>
            <div class="navbar-right">
                <g:if test="${product}">
                    <form class="navbar-form pull-left" role="search">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="${message(code:'todo.is.ui.search')}">
                            <span class="input-group-btn">
                                <button class="btn btn-default" type="button"><span class="fa fa-search"></span></button>
                            </span>
                        </div>
                    </form>
                    <!-- Todo remove, user role change for dev only -->
                    <div style="padding: 13px" class="pull-left" ng-if="false">
                        <a ng-class="{ 'text-warning': roles.productOwner && roles.scrumMaster }" ng-click="changeRole('PO_SM')">PO_SM</a>
                        <a ng-class="{ 'text-warning': roles.productOwner && (!roles.scrumMaster) }" ng-click="changeRole('PO')">PO</a>
                        <a ng-class="{ 'text-warning': roles.scrumMaster && (!roles.productOwner) }" ng-click="changeRole('SM')">SM</a>
                        <a ng-class="{ 'text-warning': roles.teamMember }" ng-click="changeRole('TM')">TM</a>
                        <a ng-class="{ 'text-warning': roles.stakeHolder }" ng-click="changeRole('SH')">SH</a>
                    </div>
                </g:if>
                <div ng-if="currentUser.username" uib-dropdown class="pull-left" on-toggle="notificationToggle(open)">
                    <div ng-switch="getUnreadActivities()"
                         class="navbar-notif"
                         uib-dropdown-toggle>
                        <span class="fa fa-bolt text-muted" ng-switch-when="0"></span>
                        <span class="fa fa-bolt" ng-switch-default></span>
                        <span class="badge alert-info" ng-show="getUnreadActivities()">{{ getUnreadActivities()}}</span>
                    </div>
                    <div class="uib-dropdown-menu notifications selection-disable" ng-include="'notifications.panel.html'"></div>
                </div>
                <div ng-if="currentUser.username" uib-dropdown class="pull-left">
                    <div class="navbar-user pull-left" uib-dropdown-toggle>
                        <img ng-src="{{ currentUser | userAvatar }}" height="32px" width="32px"/>
                    </div>
                    <div class="uib-dropdown-menu profile-panel" ng-include="'profile.panel.html'"></div>
                </div>
                <button id="login"
                        ng-show="!(currentUser.username)"
                        class="btn btn-default"
                        ng-click="showAuthModal()"
                        uib-tooltip="${message(code:'is.button.connect')} (SHIFT+L)"
                        tooltip-append-to-body="true"
                        tooltip-placement="bottom"><g:message code="is.button.connect"/></button>
            </div>
        </div>
    </div>
</nav>