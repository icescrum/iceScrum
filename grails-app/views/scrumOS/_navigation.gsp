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
<g:set var="poOrSm" value="${sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>
<g:set var="scrumMaster" value="${sec.access([expression:'scrumMaster()'], {true})}"/>

<div id="navigation">
  <div class="left">
    <ul class="navigation-content clearfix">
      <li class="navigation-line is-logo">
        <is:remoteDialog
                action="about"
                controller="scrumOS"
                resizable="false"
                withTitlebar="false"
                noprefix="true"
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
            <g:if test="${creationProjectEnable}">
              <li>
                <is:remoteDialog
                        action="openWizard"
                        rendered="${creationEnable}"
                        controller="project"
                        resizable="false"
                        noprefix="true"
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
                        noprefix="true"
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
            <g:if test="${poOrSm && product}">
              <li>
                <is:remoteDialog
                        action="edit"
                        controller="project"
                        params="[product:product.id]"
                        valid="[action:'update',controller:'project',onSuccess:'\$(\'#project-details ul li:first strong\').text(data.name); \$.icescrum.renderNotice(data.notice);']"
                        title="is.dialog.project.title"
                        width="600"
                        resizable="false"
                        draggable="false">
                  <g:message code='is.projectmenu.submenu.project.edit'/>
                </is:remoteDialog>
              </li>
            </g:if>
            <g:if test="${poOrSm && product}">
              <li>
                <is:remoteDialog
                        action="editPractices"
                        controller="project"
                        params="[product:product.id]"
                        valid="[action:'update',controller:'project',onSuccess:'\$.icescrum.renderNotice(data.notice);']"
                        title="is.dialog.project.title"
                        width="600"
                        resizable="false"
                        draggable="false">
                  <g:message code='is.projectmenu.submenu.project.editPractices'/>
                </is:remoteDialog>
              </li>
            </g:if>
            <g:if test="${sec.access(expression:'owner()',{true}) && product}">
              <li>
                 <a href="#" onClick="if (confirm('${message(code:'is.dialog.project.others.delete.button').encodeAsJavaScript()}')) {
                      ${g.remoteFunction(action:'delete',
                                         controller:'project',
                                         params:[product:params.product],
                                         onSuccess:'document.location=data.url;')
                       };
                    }
                    return false;">
                   <g:message code="is.projectmenu.submenu.project.delete"/>
                 </a>
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
            <g:if test="${productFilteredsList}">
              <li class="menu-label">
                ${message(code:'is.projectmenu.submenu.project.my.title')}
              </li>
              <g:each var="curProduct" in="${productFilteredsList}">
                <li><g:link class="${(product?.id == curProduct.id) ? 'active' : ''}" controller="scrumOS" fragment="project" params="[product:curProduct.pkey]" onClick="${(product?.id == curProduct.id) ? is.notice(text:g.message(code:'is.ui.alreadyOpen', args:[g.message(code:'is.product')]))+'return false;' : ''}">
                      <is:truncated encodedHTML="true" size="25">${curProduct.name.encodeAsHTML()}</is:truncated>
                    </g:link>
                </li>
              </g:each>
            </g:if>
            <g:if test="${publicProductsExists}">
              <li>
                <is:remoteDialog
                        action="browse"
                        controller="project"
                        resizable="false"
                        draggable="false"
                        noprefix="true"
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
          </ul>
        </is:dropMenu>
      </li>
      <sec:ifLoggedIn>
        <li class="navigation-line">
          <is:dropMenu id="menu-project-2" title="${message(code: 'is.team')}">
            <ul>
              <g:if test="${creationTeamEnable}">
                <li>
                  <is:remoteDialog
                          action="create"
                          controller="team"
                          resizable="false"
                          draggable="false"
                          noprefix="true"
                          width="610"
                          title="is.projectmenu.submenu.team.create"
                          valid="[action:'save',controller:'team',update:'dialog',button:'is.dialog.createTeam.button']">
                    <g:message code="is.projectmenu.submenu.team.create"/>
                  </is:remoteDialog>
                </li>
              </g:if>
              <g:if test="${scrumMaster && team}">
                <li>
                  <is:remoteDialog
                        action="edit"
                        controller="team"
                        params="[team:team.id]"
                        valid="[action:'update',controller:'team',onSuccess:'\$(\'#team-details ul li:first strong\').text(data.name); \$.icescrum.renderNotice(data.notice);']"
                        title="is.dialog.team.title"
                        width="600"
                        resizable="false"
                        draggable="false">
                      <g:message code='is.projectmenu.submenu.team.edit' />
                  </is:remoteDialog>
                </li>
              </g:if>
              <g:if test="${sec.access(expression:'owner()',{true}) && team}">
                <li>
                   <a href="#" onClick="if (confirm('${message(code:'is.dialog.team.others.delete.button').encodeAsJavaScript()}')) {
                              ${g.remoteFunction(action:'delete',
                                                 controller:'team',
                                                 params:[team:params.team],
                                                 onSuccess:'document.location=data.url;')
                               };
                            }
                            return false;">
                     <g:message code="is.projectmenu.submenu.project.delete"/>
                   </a>
                </li>
              </g:if>
              <g:if test="${teamsList}">
                <li class="menu-label">
                  <g:message code="is.projectmenu.submenu.team.my.title"/>
                </li>
                <g:each var="curTeam" in="${teamsList}">
                  <li>
                      <g:link class="${(team?.id == curTeam.id) ? 'active' : ''}" controller="team" params="[team:curTeam.id]" fragment="team" onClick="${(team?.id == curTeam.id) ? is.notice(text:g.message(code:'is.ui.alreadyOpen', args:[g.message(code:'is.team')]))+'return false;' : ''}">
                        <is:truncated encodedHTML="true" size="25">${curTeam.name.encodeAsHTML()}</is:truncated>
                      </g:link>
                  </li>
                </g:each>
              </g:if>
              <li>
                <is:remoteDialog
                        action="join"
                        controller="team"
                        resizable="false"
                        draggable="false"
                        noprefix="true"
                        width="940"
                        valid="[action:'requestMembership',controller:'team',update:'dialog',button:'is.dialog.joinTeam.button']">
                  <g:message code="is.projectmenu.submenu.team.join"/>
                </is:remoteDialog>
              </li>
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
                  noprefix="true"
                  resizable="false"
                  draggable="false">
            ${user?.firstName?.encodeAsHTML()} ${user?.lastName?.encodeAsHTML()}
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
                  action="auth"
                  onClick="this.href=this.href+'?ref='+decodeURI('${params.product?'p/'+product.pkey:params.team?'t/'+params.team:''}')+decodeURI(document.location.hash.replace('#','@'));">
            <g:message code="is.button.connect"/>
          </is:buttonNavigation>
        </li>
      </sec:ifNotLoggedIn>
    </ul>
  </div>
</div>