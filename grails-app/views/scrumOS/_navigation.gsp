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
<g:setProvider library="jquery"/>
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>
<g:set var="ownerOrSm" value="${request.scrumMaster || request.owner}"/>

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
                buttons="'${message(code:'is.button.close')}': function() { jQuery(this).dialog('close'); }"
                draggable="false">
            <span id="is-logo" class="disconnected" title="${message(code: 'is.about')}"><g:message
                    code="is.shortname"/></span>
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
                                width="800"
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
                                onOpen="if (jQuery('#import-validate').is(':hidden')){jQuery(\'.ui-dialog-buttonpane button:eq(1)\').hide()}"
                                valid="[button:'is.dialog.importProject.submit',
                                    action:'saveImport',
                                    update:'dialog',
                                    onSuccess:'$(\'#dialog\').dialog(\'close\'); jQuery.icescrum.renderNotice(\''+message(code:'is.dialog.importProject.success')+'\'); jQuery.event.trigger(\'redirect_product\',data);',
                                    controller:'project']"
                                cancel="[action:'importProject',controller:'project',params:'\'cancel=1\'']"
                                draggable="false">
                            <g:message code="is.projectmenu.submenu.project.import"/>
                        </is:remoteDialog>
                    </li>
                </g:if>
                <g:if test="${product}">
                    <li id="edit-members">
                        <is:remoteDialog
                                action="edit"
                                controller="members"
                                params="[product:product.id]"
                                valid="${ownerOrSm ? [action:'update',controller:'members',onSuccess:' jQuery.icescrum.renderNotice(\''+message(code:'is.team.saved')+'\');'] : null}"
                                buttons="'${message(code:'is.button.close')}': function() { jQuery(this).dialog('close'); }"
                                title="is.dialog.project.title"
                                width="650"
                                resizable="false"
                                draggable="false">
                            <g:message code='is.projectmenu.submenu.project.members'/>
                        </is:remoteDialog>
                    </li>
                </g:if>
                <g:if test="${ownerOrSm && product}">
                    <li>
                        <is:remoteDialog
                                action="edit"
                                controller="project"
                                params="[product:product.id]"
                                valid="[action:'update',controller:'project',onSuccess:'jQuery.event.trigger(\'update_product\',[data]); jQuery.icescrum.renderNotice(\''+message(code:'is.product.updated')+'\');']"
                                title="is.dialog.project.title"
                                width="600"
                                resizable="false"
                                draggable="false">
                            <g:message code='is.projectmenu.submenu.project.edit'/>
                        </is:remoteDialog>
                    </li>
                </g:if>
                <g:if test="${ownerOrSm && product}">
                    <li>
                        <is:remoteDialog
                                action="editPractices"
                                controller="project"
                                params="[product:product.id]"
                                valid="[action:'update',controller:'project',onSuccess:'jQuery.event.trigger(\'update_product\',[data]);  jQuery.icescrum.renderNotice(\''+message(code:'is.product.updated')+'\');']"
                                title="is.dialog.project.title"
                                width="600"
                                resizable="false"
                                draggable="false">
                            <g:message code='is.projectmenu.submenu.project.editPractices'/>
                        </is:remoteDialog>
                    </li>
                </g:if>
                <g:if test="${request.owner && product}">
                    <li>
                        <a href="#"
                           onClick="if (confirm('${message(code:'is.dialog.project.others.delete.button').encodeAsJavaScript()}')) {
                               ${g.remoteFunction(action:'delete',
                                             controller:'project',
                                             params:[product:params.product],
                                             onSuccess:'jQuery.event.trigger(\'remove_product\',[data]);')
                           };
                           }
                           return false;">
                            <g:message code="is.projectmenu.submenu.project.delete"/>
                        </a>
                    </li>
                </g:if>
                <g:if test="${exportEnable && product != null && (request.scrumMaster || request.productOwner)}">
                    <li>
                        <is:remoteDialog
                                action="export"
                                controller="project"
                                resizable="false"
                                withTitlebar="false"
                                onClose="jQuery.doTimeout('progressBar');"
                                buttons="'${message(code:'is.button.cancel')}': function() { jQuery(this).dialog('close'); }, '${message(code:'is.button.close')}': function() { jQuery(this).dialog('close'); }"
                                draggable="false">
                            <g:message code="is.projectmenu.submenu.project.export"/>
                        </is:remoteDialog>
                    </li>
                </g:if>
                <entry:point id="menu-project" model="[curProduct:curProduct]"/>
                <g:if test="${productFilteredsList}">
                    <li class="menu-label">
                        ${message(code: 'is.projectmenu.submenu.project.my.title')}
                    </li>
                    <g:each var="curProduct" in="${productFilteredsList}">
                        <li><g:link class="${(product?.id == curProduct.id) ? 'active' : ''}" controller="scrumOS"
                                    fragment="project" params="[product:curProduct.pkey]"
                                    onClick="${(product?.id == curProduct.id) ? is.notice(text:g.message(code:'is.ui.alreadyOpen', args:[g.message(code:'is.product')]))+'return false;' : ''}">
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
    <li class="navigation-line separator"></li>
    <entry:point id="menu-left" model="[product:product]"/>
    <is:cache cache="userMenuCache" cacheResolver="userProjectCacheResolver" key="user-${sec.username()}" disabled="${product ? false : true}" role="false" locale="false">
        <is:menuBar/>
    </is:cache>
</ul>
</div>

<div class="right">
    <ul class="navigation-content clearfix">
        <sec:ifLoggedIn>
            <li class="navigation-line"><is:buttonNavigation button="button-s button-s-black"
                                                             controller="logout"><g:message
                        code="is.logout"/></is:buttonNavigation></li>
            <li class="navigation-line separator"></li>
            <li class="navigation-line" id="profile-name">
                <is:remoteDialog
                        action="openProfile"
                        controller="user"
                        valid="[action:'update',controller:'user',onSuccess:'jQuery.icescrum.updateProfile(data)']"
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
        <entry:point id="menu-right" model="[curProduct:curProduct]"/>
    </ul>
</div>
</div>