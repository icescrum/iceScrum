%{--
- Copyright (c) 2010 iceScrum Technologies.
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
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<g:set var="ownerOrSm" value="${request.scrumMaster || request.owner}"/>

<div id="navigation">
<div class="left">
<ul class="navigation-content clearfix">
    <li class="navigation-line is-logo">
        <a data-ajax="true" href="${createLink(controller:'scrumOS',action:'about')}">
            <span id="is-logo" class="disconnected" title="${message(code: 'is.about')}"><g:message
                    code="is.shortname"/></span>
        </a>
    </li>
    <is:errors/>
    <li class="navigation-line separator">
        <div class="dropmenu" id="menu-project" data-dropmenu="true">

          <a class="button-n clearfix dropmenu-button" onclick="return false;">
            <span class="start"></span>
            <span class="content">${pageScope.variables?.space ? pageScope.space.object.name.encodeAsJavaScript() : message(code:'is.projectmenu.title')}</span>
            <span class="end"><span class="arrow"></span></span>
          </a>

          <div class="dropmenu-content ui-corner-all">
              <ul>
                  <g:if test="${creationProjectEnable}">
                      <li>
                          <a data-shortcut="ctrl+shift+n"
                             href="${createLink(controller:'project', action:'openWizard')}"
                             data-ajax="true">
                              <g:message code="is.projectmenu.submenu.project.create"/>
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
                  <g:if test="${product}">
                      <li id="edit-members">
                          <a href="${createLink(controller:'project', action:'editTeam',params:[product:product.id])}" data-ajax="true">
                              <g:message code="is.ui.project.team"/>...
                          </a>
                      </li>
                  </g:if>
                  <g:if test="${ownerOrSm && product}">
                      <li>
                          <a href="${createLink(controller:'project', action:'edit',params:[product:product.id])}" data-ajax="true">
                                <g:message code="is.projectmenu.submenu.project.edit"/>
                          </a>
                      </li>
                  </g:if>
                  <g:if test="${ownerOrSm && product}">
                      <li>
                          <a href="${createLink(controller:'project', action:'editPractices',params:[product:product.id])}" data-ajax="true">
                                  <g:message code="is.projectmenu.submenu.project.editPractices"/>
                            </a>
                      </li>
                  </g:if>
                  <g:if test="${request.owner && product}">
                      <li>
                          <a href="${createLink(action:'delete',controller:'project',params:[product:params.product])}"
                             data-ajax="true"
                             data-ajax-trigger="remove_product"
                             data-ajax-confirm="${message(code:'is.projectmenu.submenu.project.delete').encodeAsJavaScript()}">
                              <g:message code="is.projectmenu.submenu.project.delete"/>
                          </a>
                      </li>
                  </g:if>
                  <g:if test="${exportEnable && product != null && (request.scrumMaster || request.productOwner)}">
                      <li>
                          <a href="${createLink(controller:'project', action:'export',params:[product:product.id])}" data-ajax="true">
                                <g:message code="is.projectmenu.submenu.project.export"/>
                          </a>
                      </li>
                  </g:if>
                  <entry:point id="menu-project" model="[curProduct:product,user:user]"/>
                  <li class="menu-label" id="my-projects" style='display:${productFilteredsList ?'block':'none'}'>
                      ${message(code: 'is.projectmenu.submenu.project.my.title')}
                  </li>
                  <g:if test="${productFilteredsList}">
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
                  <g:if test="${browsableProductsExist || moreProductsExist}">
                      <li>
                          <a href="${createLink(controller:'project', action:'browse')}" data-ajax="true">
                              <g:if test="${moreProductsExist}">
                                  <g:message code="is.projectmenu.submenu.project.more"/>
                              </g:if><g:else>
                                  <g:message code="is.projectmenu.submenu.project.browse"/>
                              </g:else>
                          </a>
                      </li>
                  </g:if>
              </ul>
          </div>
        </div>
    </li>
    <entry:point id="menu-left" model="[product:product]"/>
    <is:cache cache="userCache" key="user-${user?.username?:'anonymous'}-${user?.lastUpdated}-${product?.lastUpdated}" disabled="${product ? false : true}" role="false" locale="false">
        <is:menuBar/>
    </is:cache>
</ul>
</div>

<div class="right">
    <ul class="navigation-content clearfix">
        <sec:ifLoggedIn>
            <g:set var="username" value="${user?.firstName?.encodeAsHTML() + ' ' + user?.lastName?.encodeAsHTML()}"/>
            <li class="navigation-line" id="profile-name">
                <is:link class="with-arrow" disabled="true" onClick="jQuery.icescrum.showAndHideOnClickAnywhere('.user-tooltip')">
                    ${username}
                </is:link>
            </li>
            <li class="navigation-line" id="navigation-avatar">
                <is:avatar user="${user}" class="navigation-avatar"/>
            </li>
            <div class="user-tooltip">
                <div id="user-tooltip-avatar">
                    <is:avatar user="${user}" id="user-tooltip-avatar"/>
                </div>
                <div id="user-tooltip-username">
                    ${username}
                </div>
                <g:if test="${product}">
                    <div id="user-tooltip-role">
                        ${message(code:"is.ui.details.role.name")}
                        <a href="javascript:;" onclick="jQuery('#edit-members a').click();"><strong> <is:displayRole /> </strong></a>
                    </div>
                </g:if>
                <div id="user-tooltip-buttons">
                    <div id="user-tooltip-logout">
                        <is:buttonNavigation button="button-s" controller="logout">
                            <g:message code="is.logout"/>
                        </is:buttonNavigation>
                    </div>
                    <div id="user-tooltip-profile">
                        <a href="${createLink(controller:'user', action:'openProfile')}" data-ajax="true">
                            <g:message code="is.dialog.profile"/>
                        </a>
                    </div>
                </div>
            </div>
        </sec:ifLoggedIn>
        <sec:ifNotLoggedIn>
            <li class="navigation-line">
                <is:buttonNavigation
                        elementId="login"
                        noprefix='true'
                        button="button-s button-s-black"
                        controller="login"
                        action="auth"
                        onClick="this.href=this.href+'?ref=${params.product?'p/'+product.pkey:''}'+location.hash;">
                    <g:message code="is.button.connect"/>
                </is:buttonNavigation>
            </li>
        </sec:ifNotLoggedIn>
        <entry:point id="menu-right" model="[curProduct:curProduct]"/>
    </ul>
</div>
</div>