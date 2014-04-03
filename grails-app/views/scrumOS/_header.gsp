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
--}%
<g:set var="ownerOrSm" value="${request.scrumMaster || request.owner}"/>
<nav id="header" class="navbar navbar-masthead navbar-default" role="navigation">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="pull-left navbar-toggle" onclick="return $.icescrum.toggleSidebar();">
                <span class="sr-only">${message(code:'todo.is.main.menu')}</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="hidden-xs navbar-brand"
               data-ajax="true"
               data-is-shortcut
               data-is-shortcut-key="I"
               href="${createLink(controller:'scrumOS',action:'about')}">
                <span id="is-logo" class="disconnected" title="${message(code: 'is.about')}"><g:message code="is.shortname"/></span>
            </a>
            <is:errors/>
        </div>
        <div id="mainmenu">
            <ul class="nav navbar-nav scroll"
                ${sec.ifLoggedIn(null,'data-ui-sortable-handle=".drag"')}
                data-ui-sortable-revert="true"
                data-ui-sortable-helper="clone"
                data-ui-sortable-delay="100"
                data-ui-sortable-items=".menubar"
                data-ui-sortable-cancel="span.title"
                data-ui-sortable-stop="$.icescrum.menuBar.stop"
                data-ui-sortable-start="$.icescrum.menuBar.start"
                data-ui-sortable-update="$.icescrum.menuBar.update"
                data-ui-sortable-connect-with="#menubar-list-content">
                <li class="dropdown contextual-menu">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        ${pageScope.variables?.space ? pageScope.space.object.name.encodeAsJavaScript() : message(code:'is.projectmenu.title')}&nbsp;<i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu">
                        <li role="presentation" class="dropdown-header">
                            ${message(code: 'todo.is.projects')}
                        </li>
                        <g:if test="${creationProjectEnable}">
                            <li>
                                <a data-is-shortcut
                                   data-is-shortcut-key="SHIFT+N"
                                   href="${createLink(controller:'project', action:'openWizard')}"
                                   data-ajax="true">
                                    <g:message code="is.projectmenu.submenu.project.create"/> <small class="text-muted">(SHIFT+N)</small>
                                </a>
                            </li>
                        </g:if>
                        <g:if test="${importEnable}">
                            <li>
                                <a href="${createLink(controller:'project', action:'importProject')}" data-ajax="true">
                                    <g:message code="is.projectmenu.submenu.project.import"/>
                                </a>
                            </li>
                        </g:if>
                        <g:if test="${browsableProductsExist}">
                            <li>
                                <a href="${createLink(controller:'project', action:'browse')}" data-ajax="true">
                                    <g:message code="is.projectmenu.submenu.project.browse"/>
                                </a>
                            </li>
                        </g:if>
                        <g:if test="${product}">
                            <li role="presentation" class="divider"></li>
                            <li role="presentation" class="dropdown-header">
                                ${message(code: 'todo.is.current.project')}
                            </li>
                            <li>
                                <a href="${createLink(controller:'members', action:'edit',params:[product:product.id])}" data-ajax="true">
                                    <g:message code="is.projectmenu.submenu.project.team"/>
                                </a>
                            </li>
                            <g:if test="${ownerOrSm}">
                                <li>
                                    <a href="${createLink(controller:'project', action:'edit',params:[product:product.id])}" data-ajax="true">
                                        <g:message code="is.projectmenu.submenu.project.edit"/>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${ownerOrSm}">
                                <li>
                                    <a href="${createLink(controller:'project', action:'editPractices',params:[product:product.id])}" data-ajax="true">
                                        <g:message code="is.projectmenu.submenu.project.editPractices"/>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${request.owner}">
                                <li>
                                    <a href="${createLink(action:'delete',controller:'project',params:[product:params.product])}"
                                       data-ajax="true"
                                       data-ajax-trigger="remove_product"
                                       data-ajax-confirm="${message(code:'is.projectmenu.submenu.project.delete').encodeAsJavaScript()}">
                                        <g:message code="is.projectmenu.submenu.project.delete"/>
                                    </a>
                                </li>
                            </g:if>
                            <g:if test="${exportEnable && (request.scrumMaster || request.productOwner)}">
                                <li>
                                    <a href="${createLink(controller:'project', action:'export',params:[product:product.id])}" data-ajax="true">
                                        <g:message code="is.projectmenu.submenu.project.export"/>
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
                                <li id='product-${curProduct.id}' class="projects ${(curProduct.owner.id == user?.id) ? 'owner' : ''}">
                                    <g:link class="${(product?.id == curProduct.id) ? 'active' : ''}" controller="scrumOS"
                                            params="[product:curProduct.pkey]"
                                            onClick="${(product?.id == curProduct.id) ? ' jQuery.icescrum.renderNotice(\''+g.message(code:'is.ui.alreadyOpen', args:[g.message(code:'is.product')])+'\'); return false;' : ''}">
                                        <is:truncated encodedHTML="true" size="25">${curProduct.name.encodeAsHTML()}</is:truncated>
                                    </g:link>
                                </li>
                            </g:each>
                        </g:if>
                        <g:if test="${moreProductsExist}">
                            <li>
                                <a href="${createLink(controller:'project', action:'browse')}" data-ajax="true">
                                    <g:message code="is.projectmenu.submenu.project.more"/>
                                </a>
                            </li>
                        </g:if>
                        <entry:point id="menu-project" model="[curProduct:product,user:user]"/>
                    </ul>
                </li>
                <entry:point id="menu-left" model="[product:product]"/>
                <is:cache cache="userCache" key="user-${user?.username?:'anonymous'}-${user?.lastUpdated}-${product?.lastUpdated}" disabled="${product ? true : true}" role="false" locale="false">
                    <li class="menubar hidden">&nbsp;</li>
                    <g:each in="${menus}" var="menu" status="index">
                        <li class="menubar draggable-to-main ${menu.widgetable ? 'draggable-to-widgets' : ''}" id="elem_${menu.id}">
                            <a  data-is-shortcut
                                data-is-shortcut-key="ctrl+${index + 1}"
                                data-toggle="tooltip"
                                data-placement="bottom"
                                title="${message(code: menu.title)} (CTRL+${index + 1})"
                                href='#${menu.id}'>
                                <span class="drag text-muted">
                                    <span class="glyphicon glyphicon-th"></span>
                                    <span class="glyphicon glyphicon-th"></span>
                                </span>
                                <i class="visible-xs ${menu.icon}"></i> ${message(code: menu.title)}</a>
                        </li>
                    </g:each>
                    <li class="dropdown menubar-hidden">
                        <a class="dropdown-toggle" data-toggle="dropdown" href="#">${message(code:'todo.is.more')} <i class="fa fa-caret-down"></i></a>
                        <ul class="dropdown-menu">
                            <li class="menubar hidden" data-hidden="true">&nbsp;</li>
                            <g:each in="${menusHidden}" var="menu" status="index">
                                <li data-hidden="true" class="menubar draggable-to-main ${menu.widgetable ? 'draggable-to-widgets' : ''}" id="elem_${menu.id}">
                                    <a  data-is-shortcut
                                        data-is-shortcut-key="ctrl+${index + menus.size() + 1}"
                                        data-toggle="tooltip"
                                        data-placement="left"
                                        title="${message(code: menu.title)} (CTRL+${index + menus.size() + 1})"
                                        href='#${menu.id}'>
                                        <span class="drag text-muted">
                                            <span class="glyphicon glyphicon-th"></span>
                                            <span class="glyphicon glyphicon-th"></span>
                                        </span>
                                        <i class="visible-xs ${menu.icon}"></i> ${message(code: menu.title)}</a>
                                </li>
                            </g:each>
                        </ul>
                    </li>
                </is:cache>
            </ul>
            <entry:point id="menu-right" model="[curProduct:curProduct]"/>
            <div class="navbar-right">
                <g:if test="${product}">
                    <form class="navbar-form pull-left" role="search">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="${message(code:'todo.is.ui.search')}">
                            <span class="input-group-btn">
                                <button class="btn btn-primary" type="button"><span class="glyphicon glyphicon-search"></span></button>
                            </span>
                        </div>
                    </form>
                </g:if>
                <sec:ifLoggedIn>
                    <div class="navbar-user pull-left"
                       data-ui-popover
                       data-ui-popover-placement="bottom"
                       data-ui-popover-id="popover-user"
                       data-ui-popover-html-content="#user-details">
                        <img src="${is.avatar()}" height="32px" width="32px"/>
                    </div>
                    <div id="user-details" class="hidden">
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <img src="${is.avatar()}" height="60px" width="60px" class="pull-left"/>
                                ${user.username}
                                <g:if test="${product}">
                                    <br/>
                                    <a href="javascript:;" onclick="$('#edit-members').find('a').click();"><strong> <is:displayRole product="${product.id}"/> </strong></a>
                                </g:if>
                            </div>
                            <div class="panel-footer">
                                <div class="row">
                                    <div class="col-xs-6">
                                        <a class="btn btn-info"
                                           data-is-shortcut
                                           data-is-shortcut-key="U"
                                           data-toggle="tooltip"
                                           title="${message(code:'is.dialog.profile')} (U)"
                                           href="${createLink(controller:'user', action:'openProfile')}"
                                           data-ajax="true">${message(code:'is.dialog.profile')}</a>
                                    </div>
                                    <div class="col-xs-6">
                                        <a class="btn btn-danger" href="${createLink(controller:'logout')}">${message(code:'is.logout')}</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </sec:ifLoggedIn>
                <sec:ifNotLoggedIn>
                    <button id="login"
                            class="btn btn-primary"
                            data-ajax="true"
                            data-is-shortcut
                            data-is-shortcut-key="L"
                            data-toggle="tooltip"
                            data-placement="bottom"
                            title="${message(code:'is.button.connect')} (L)"
                            href="${createLink(controller:'login',action:'auth')}"><g:message code="is.button.connect"/></button>
                </sec:ifNotLoggedIn>
            </div>
        </div>
    </div>
</nav>