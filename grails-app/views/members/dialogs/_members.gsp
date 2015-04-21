<%@ page import="org.icescrum.core.domain.security.Authority; grails.converters.JSON" %>
%{--
- Copyright (c) 2011 Kagilum.
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
<g:set var="ownerOrSm" value="${request.owner || request.scrumMaster}"/>
<is:dialog valid="${ownerOrSm ? [action:'update',
                                 controller:'members',
                                 onSuccess:' jQuery.icescrum.renderNotice(\''+message(code:'is.team.saved')+'\');'] : null}"
           buttons="'${message(code:'is.button.close')}': function() { jQuery(this).dialog('close'); }"
           title="is.dialog.project.title"
           width="650"
           resizable="false"
           draggable="false">
<form id="form-team" name="form-team" method="post" class='box-form box-form-250 box-form-200-legend'>
    <input type="hidden" name="product" value="${params.product}">
    <is:fieldset title="is.team"
                 id="team-member-autocomplete"
                 class="member-autocomplete">

        <g:if test="${!request.admin && (request.inProduct || (request.stakeHolder && product.preferences.hidden))}">
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

        <g:if test="${ownerOrSm}">
            <is:fieldSelect for="teamFinder"
                            label="is.team">
                <input id="teamFinder"
                       name="teamFinder"
                       type="hidden"
                       value="${team.id}"
                       data-width="242"
                       data-ajax-select="true"
                       data-url="${createLink(controller: 'members', action:'getTeamEntries')}"
                       data-placeholder="${message(code:'is.ui.team.choose')}"
                       data-create-choice="true"
                       data-create-choice-unique="true"
                       data-init-selection="var members = ${(memberEntries as JSON).toString().replaceAll('"', "'")};
                                            $.each(members, function(index, member) {
                                                member.editable = true;
                                                member.view = 'members';
                                            });
                                            attachOnDomUpdate(jQuery('#team-member-list').jqotesub('#user-tmpl',members));
                                            var data = {id: element.val(), text: '${team.name}'};
                                            callback(data);"
                       data-change="jQuery.icescrum.product.teamChange"/>
            </is:fieldSelect>
            <input type="hidden" id="teamId" name="team.id" value="${team.id}"/>
            <input type="hidden" id="teamName" name="team.name" value="${team.name}"/>
            <% def link = "<a><img height='40' width='40' src='\" + item.avatar + \"'/><span><b>\" + item.name + \"</b><br/>\" + item.activity + \"</span></a>"%>
            <is:fieldInput for="find-team-members" label="is.dialog.members.find" class="members">
                <is:autoCompleteSkin controller="user"
                                     action="findUsers"
                                     cache="true"
                                     filter="jQuery('#member'+object.id).length == 0 ? true : false"
                                     id="members"
                                     name="find-team-members"
                                     appendTo="#team-member-autocomplete"
                                     onSelect="ui.item.editable = true;
                                               ui.item.view = 'members';
                                               ui.item.role = ${Authority.MEMBER};
                                               attachOnDomUpdate(jQuery('#team-member-list').jqoteapp('#user-tmpl', ui.item));"
                                     renderItem="${link}"
                                     minLength="2"/>
            </is:fieldInput>
        </g:if>
        <div id="team-member-list" class="members-list"></div>
    </is:fieldset>
</form>
</is:dialog>