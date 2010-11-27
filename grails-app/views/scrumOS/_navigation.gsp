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
- Vincent Barrier (vincent.barrier@icescrum.com)
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<g:setProvider library="jquery"/>
<div id="navigation">
  <div class="left">
    <ul class="navigation-content clearfix">
      <li class="navigation-line is-logo">
        <is:remoteDialog
                action="about"
                controller="scrumOS"
                resizable="false"
                withTitlebar="false"
                width="600"
                height="430"
                buttons="'${message(code:'is.button.close')}': function() { \$(this).dialog('close'); }"
                draggable="false">
          <span id="is-logo" title="${message(code:'is.about')}"><g:message code="is.shortname"/></span>
        </is:remoteDialog>
      </li>
      <li class="navigation-line separator"></li>
      <li class="navigation-line">
        <is:dropMenu id="menu-project" title="${message(code:'is.projectmenu.title')}">
          <ul>
            <li class="first menu-label"><g:message code="is.projectmenu.submenu.project.title"/></li>
            <g:if test="${creationProjectEnable}">
              <li>
                <is:remoteDialog
                        action="openWizard"
                        rendered="${creationEnable}"
                        controller="project"
                        resizable="false"
                        withTitlebar="false"
                        width="770"
                        height="620"
                        draggable="false">
                  <g:message code="is.projectmenu.submenu.project.create"/>
                </is:remoteDialog>
              </li>
            </g:if>
            <g:if test="${importEnable}">
              <li>
                <is:remoteDialog
                        action="importProject"
                        rendered="${importEnable}"
                        controller="project"
                        resizable="false"
                        withTitlebar="false"
                        width="520"
                        onOpen="if (jQuery('#import-validate').is(':hidden')){jQuery(\'.ui-dialog-buttonpane button:eq(1)\').hide()};"
                        valid="[button:'is.dialog.importProject.submit',
                                action:'saveImport',
                                update:'dialog',
                                controller:'project']"
                        cancel="[action:'importProject',controller:'project',params:'\'cancel=1\'']"
                        draggable="false">
                    <g:message code="is.projectmenu.submenu.project.import"/>
                </is:remoteDialog>
              </li>
            </g:if>
            <g:if test="${exportEnable && product != null && sec.access(expression:'scrumMaster() or productOwner()',{true})}">
              <li>
                <is:remoteDialog
                      action="exportProject"
                      controller="project"
                      resizable="false"
                      withTitlebar="false"
                      onClose="\$.doTimeout('progressBar');"
                      buttons="'${message(code:'is.button.cancel')}': function() { \$(this).dialog('close'); }, '${message(code:'is.button.close')}': function() { \$(this).dialog('close'); }"
                      draggable="false">
                  <g:message code="is.projectmenu.submenu.project.export"/>
              </is:remoteDialog>
              </li>
            </g:if>
            <g:if test="${publicProductsExists}">
              <li>
                <is:remoteDialog
                        action="browse"
                        controller="project"
                        resizable="false"
                        draggable="false"
                        width="940"
                        height="540"
                        valid="[action:'index',
                                controller:'scrumOS',
                                before:'document.location=jQuery.icescrum.o.baseUrl+\'p/\'+jQuery(\'#product\').val()+\'#project\';jQuery(\'#dialog\').dialog(\'close\'); return false;',
                                button:'is.dialog.browseProject.button']">
                  <g:message code="is.projectmenu.submenu.project.browse"/>
                </is:remoteDialog>
              </li>
            </g:if>

            <g:if test="${product?.id}">
              <li>
                <is:link disabled="true" onClick="document.location=\$.icescrum.o.baseUrl;">
                  <g:message code="is.closeProduct" args="${[is.truncated([encodeHTML:false,size:25],{product.name})]}"/>
                </is:link>
              </li>
            </g:if>

            <g:if test="${productFilteredsList}">
              <li class="menu-label">
                <g:message code="is.projectmenu.submenu.choose.title"/>
              </li>
              <g:each var="curProduct" in="${productFilteredsList}">
                <li><g:link class="${(product?.id == curProduct.id) ? 'active' : ''}" controller="scrumOS" fragment="project" params="[product:curProduct.pkey]" onClick="${(product?.id == curProduct.id) ? is.notice(text:g.message(code:'is.ui.alreadyOpen', args:[g.message(code:'is.product')]))+'return false;' : ''}">
                      <is:truncated encodeHTML="false" size="25">${curProduct.name}</is:truncated>
                    </g:link>
                </li>
              </g:each>
            </g:if>
          </ul>
        </is:dropMenu>
      </li>
      <sec:ifLoggedIn>
        <li class="navigation-line">
          <is:dropMenu id="menu-project-2" title="${message(code: 'is.team')}">
            <ul>
              <li class="menu-label"><g:message code="is.projectmenu.submenu.team.title"/></li>
              <g:if test="${creationTeamEnable}">
                <li>
                  <is:remoteDialog
                          action="create"
                          controller="team"
                          resizable="false"
                          draggable="false"
                          width="610"
                          title="is.projectmenu.submenu.team.create"
                          valid="[action:'save',controller:'team',update:'dialog',button:'is.dialog.createTeam.button']">
                    <g:message code="is.projectmenu.submenu.team.create"/>
                  </is:remoteDialog>
                </li>
              </g:if>
              <li>
                <is:remoteDialog action="join" controller="team" resizable="false" draggable="false" width="940"
                        valid="[action:'requestMembership',controller:'team',update:'dialog',button:'is.dialog.joinTeam.button']">
                  <g:message code="is.projectmenu.submenu.team.join"/>
                </is:remoteDialog>
              </li>

              <g:if test="${teamsList}">
                <li class="menu-label">
                  <g:message code="is.projectmenu.submenu.team.choose.title"/>
                </li>
                <g:each var="curTeam" in="${teamsList}">
                  <li>
                      <g:link class="${(team?.id == curTeam.id) ? 'active' : ''}" controller="team" params="[team:curTeam.id]" fragment="team" onClick="${(team?.id == curTeam.id) ? is.notice(text:g.message(code:'is.ui.alreadyOpen', args:[g.message(code:'is.team')]))+'return false;' : ''}">
                        <is:truncated encodeHTML="false" size="25">${curTeam.name}</is:truncated>
                      </g:link>
                  </li>
                </g:each>
              </g:if>
            </ul>
          </is:dropMenu>
        </li>
      </sec:ifLoggedIn>
      <li class="navigation-line separator"></li>
      <is:menuBar/>
    </ul>
  </div>
  <div class="right">
    <ul class="navigation-content clearfix">
      <sec:ifLoggedIn>
        <li class="navigation-line"><is:buttonNavigation button="button-s button-s-black" controller="logout"><g:message code="is.logout"/></is:buttonNavigation></li>
        <li class="navigation-line separator"></li>
        <li class="navigation-line" id="profile-name">
          <is:remoteDialog
                  action="openProfile"
                  controller="user"
                  valid="[action:'update',controller:'user',onSuccess:'\$.icescrum.updateProfile(data)']"
                  title="is.dialog.profile"
                  width="600"
                  resizable="false"
                  draggable="false">
            ${user?.firstName} ${user?.lastName}
          </is:remoteDialog>
        </li>
      </sec:ifLoggedIn>
      <sec:ifNotLoggedIn>
        <li class="navigation-line">
          <is:buttonNavigation
                  elementId="login"
                  noprefix='true'
                  button="button-s button-s-black"
                  controller="login"
                  onClick="this.href=this.href+'?ref='+decodeURI('${params.product?'p/'+product.pkey:params.team?'t/'+params.team:''}')+decodeURI(document.location.hash.replace('#','@'));">
            <g:message code="is.button.connect"/>
          </is:buttonNavigation>
        </li>
      </sec:ifNotLoggedIn>
    </ul>
  </div>
</div>