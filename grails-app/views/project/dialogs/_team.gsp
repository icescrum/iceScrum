<%@ page import="org.icescrum.core.domain.security.Authority; grails.converters.JSON" %>
%{--
- Copyright (c) 2015 Kagilum.
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
<g:set var="ownerOrSm" value="${request.owner || request.scrumMaster}"/>
<is:dialog valid="${ownerOrSm ? [action:'changeTeam', controller:'project', onSuccess:' jQuery.icescrum.renderNotice(\''+message(code:'is.team.saved')+'\');'] : null}"
           buttons="'${message(code:'is.button.close')}': function() { jQuery(this).dialog('close'); }"
           title="is.dialog.project.title"
           width="650"
           resizable="false"
           draggable="false">
<form id="form-team" name="form-team" method="post" class='box-form box-form-250 box-form-200-legend'>
    <input type="hidden" name="product" value="${params.product}">
    <is:fieldset title="is.ui.project.team"
                 id="team-member-autocomplete"
                 class="member-autocomplete">
        <g:if test="${!request.admin && (request.teamMember || request.scrumMaster)}">
            <is:fieldInput for="leaveTeam" label="is.dialog.members.leave.team" class="productcreator">
                <button type="button" onClick="if (confirm('${message(code:'is.dialog.members.leave.team.confirm').encodeAsJavaScript()}')) {
                                      ${g.remoteFunction(action:'leaveTeam',
                                                         controller:'members',
                                                         params:[product: params.product],
                                                         onSuccess:'document.location=jQuery.icescrum.o.baseUrl;')
                                       };}return false;" class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
                    <g:message code="is.dialog.members.leave.team"/>
                </button>
            </is:fieldInput>
        </g:if>
        <p class="field-input clearfix">
            <label>${ message(code: 'is.ui.project.members')}</label>
            <span style="padding-left: 10px; display: inline-block; padding-top:5px">
                <g:if test="${poNames}"><strong>${message(code: 'is.role.pos')}</strong> ${poNames.join(', ')}</g:if>
                <g:if test="${poNames && shNames}"><br/></g:if>
                <g:if test="${shNames}"><strong>${message(code: 'is.role.shs')}</strong> ${shNames.join(', ')}</g:if>
                <g:if test="${ownerOrSm}">
                    <g:if test="${poNames || shNames}"><br/></g:if>
                    <a href="${createLink(controller:'project', action:'edit',params:[openPanelIndex: 2, product:params.product])}"
                       data-ajax-begin="jQuery('#dialog').dialog('close');"
                       data-ajax="true">
                        ${message(code: 'is.ui.project.members.edit')}
                    </a>
                </g:if>
            </span>
        </p>
        <g:if test="${ownerOrSm}">
            <is:fieldSelect for="teamFinder"
                            label="is.ui.project.team">
                <input id="teamFinder"
                       name="teamFinder"
                       type="hidden"
                       value="${team.id}"
                       data-width="242"
                       data-ajax-select="true"
                       data-url="${createLink(controller: 'members', action:'getTeamEntries')}"
                       data-init-selection="var data = {id: element.val(), text: '${team.name}'};
                                            callback(data);"
                       data-change="jQuery.icescrum.product.teamChange"/>
            </is:fieldSelect>
            <input type="hidden" id="teamId" name="team.id" value="${team.id}"/>
        </g:if><g:else>
            <is:fieldInput label="is.ui.project.team">
                <span style="display: inline-block; padding-left: 10px; padding-top: 5px">${team.name}</span>
            </is:fieldInput>
        </g:else>
        <div id="team-member-list" class="members-list"></div>
    </is:fieldset>
    <jq:jquery>
        var members = ${memberEntries as JSON};
        $.each(members, function(index, member) {
            member.editable = false;
            member.view = 'members';
        });
        attachOnDomUpdate(jQuery('#team-member-list').jqotesub('#user-tmpl', members));
    </jq:jquery>
</form>
</is:dialog>