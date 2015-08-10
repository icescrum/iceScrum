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
<nav id="header" class="navbar navbar-masthead navbar-default" role="navigation">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="pull-left navbar-toggle">
                <span class="sr-only">${message(code:'todo.is.main.menu')}</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="hidden-xs navbar-brand"
               hotkey="{'I': showAbout}"
               hotkey-description="${message(code: 'is.about')}"
               ng-click="showAbout()"
               href>
                <span id="is-logo" class="disconnected" title="${message(code: 'is.about')} (I)"><g:message code="is.shortname"/></span>
            </a>
            <is:errors/>
        </div>
        <div id="mainmenu" ng-controller="projectCtrl">
            <ul class="nav navbar-nav scroll menubar"
                html-sortable="menuSortableOptions"
                html-sortable-callback="menuSortableUpdate"
                ng-init='menus.visible = ${menus as JSON};'
                ng-model="menus.visible">
                <li class="dropdown contextual-menu" dropdown>
                    <a class="dropdown-toggle" dropdown-toggle>
                        ${pageScope.variables?.space ? pageScope.space.object.name.encodeAsJavaScript() : message(code:'is.projectmenu.title')}&nbsp;<i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu">
                        <li role="presentation" class="dropdown-header">
                            ${message(code: 'todo.is.projects')}
                        </li>
                        <g:if test="${creationProjectEnable}">
                            <li>
                                <a hotkey="{ 'shift+n': hotkeyClick}"
                                   href="#project/new">
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
                                ${message(code: 'todo.is.current.project')}
                            </li>
                            <li>
                                <a hotkey="{ 'shift+e': hotkeyClick}" href ng-click="showProjectEditModal()">
                                    <g:message code="is.projectmenu.submenu.project.edit"/> <small class="text-muted">(SHIFT+E)</small>
                                </a>
                            </li>$
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
                                <a href ng-click="showProjectListModal('byUser')">
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
                    ng-repeat="menu in menus.visible"
                    ng-include="'menuitem.item.html'"
                    ng-class="{'active':$state.includes(menu.id)}"
                    class="menuitem draggable-to-main">
                </li>
                <li class="dropdown menubar-more" dropdown ng-class="{ 'hidden': menus.hidden.length == 0 }">
                    <a class="dropdown-toggle" dropdown-toggle href>${message(code:'todo.is.more')} <i class="fa fa-caret-down"></i></a>
                    <ul class="dropdown-menu menubar"
                        html-sortable="menuSortableOptions"
                        html-sortable-callback="menuHiddenSortableUpdate"
                        ng-init='menus.hidden = ${menusHidden as JSON};'
                        ng-model="menus.hidden">
                            <li ng-repeat="menu in menus.hidden"
                                ng-include="'menuitem.item.html'"
                                ng-class="{'active':$state.includes(menu.id)}" class="menuitem draggable-to-main"></li>
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
                                <button class="btn btn-primary" type="button"><span class="fa fa-search"></span></button>
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
                <div ng-if="currentUser.username" dropdown class="pull-left" on-toggle="notificationToggle(open)">
                    <div ng-switch="getUnreadActivities()"
                         class="dropdown-toggle navbar-notif"
                         dropdown-toggle>
                        <span class="fa fa-bolt text-muted" ng-switch-when="0"></span>
                        <span class="fa fa-bolt" ng-switch-default></span>
                        <span class="badge alert-info" ng-show="getUnreadActivities()">{{ getUnreadActivities()}}</span>
                    </div>
                    <div class="dropdown-menu notifications" ng-include="'notifications.panel.html'"></div>
                </div>
                <div ng-if="currentUser.username" dropdown class="pull-left">
                    <div class="navbar-user pull-left dropdown-toggle" dropdown-toggle>
                        <img ng-src="{{ currentUser | userAvatar }}" height="32px" width="32px"/>
                    </div>
                    <div class="dropdown-menu" ng-include="'profile.panel.html'"></div>
                </div>
                <button id="login"
                        ng-show="!(currentUser.username)"
                        class="btn btn-primary"
                        ng-click="showAuthModal()"
                        tooltip="${message(code:'is.button.connect')} (SHIFT+L)"
                        tooltip-append-to-body="true"
                        tooltip-placement="bottom"><g:message code="is.button.connect"/></button>
            </div>
        </div>
    </div>
</nav>