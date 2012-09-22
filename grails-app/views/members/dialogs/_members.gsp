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
<is:dialog
        valid="${ownerOrSm ? [action:'update',controller:'members',onSuccess:' jQuery.icescrum.renderNotice(\''+message(code:'is.team.saved')+'\');'] : null}"
          buttons="'${message(code:'is.button.close')}': function() { jQuery(this).dialog('close'); }"
          title="is.dialog.project.title"
          width="650"
          resizable="false"
          draggable="false">
<form id="form-project" name="form-project" method="post" class='box-form box-form-250 box-form-200-legend'>
    <input type="hidden" name="product" value="${params.product}">
    <is:fieldset title="is.team" id="member-autocomplete">
        <g:if test="${request.admin}">
            <is:fieldSelect for="creator" label="is.role.owner" class="productcreator">
                <is:select
                        container="#form-project"
                        width="240"
                        maxHeight="200"
                        styleSelect="dropdown"
                        from="${possibleOwners*.name}"
                        keys="${possibleOwners*.id}"
                        name="creator"
                        value="${ownerSelect.id}"/>
            </is:fieldSelect>
        </g:if>

        <g:if test="${!request.admin && (request.inProduct || (request.stakeHolder && product.preferences.hidden))}">
            <is:fieldInput for="leaveTeam" label="is.dialog.members.leave.team" class="productcreator">
                <button onClick="if (confirm('${message(code:'is.dialog.members.leave.team.confirm').encodeAsJavaScript()}')) {
                                      ${g.remoteFunction(action:'leaveTeam',
                                                         controller:'members',
                                                         params:[product:params.product],
                                                         onSuccess:'document.location=jQuery.icescrum.o.baseUrl;')
                                       };}return false;" class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
                    <g:message code="is.dialog.members.leave.team"/>
                </button>
            </is:fieldInput>
        </g:if>

        <g:if test="${ownerOrSm}">
            <is:fieldInput for="team.members" label="is.dialog.members.find" class="members">
                <% def link = "<a><img height='40' width='40' src='\" + item.avatar + \"'/><span><b>\" + item.name + \"</b><br/>\" + item.activity + \"</span></a>"%>
                    <is:autoCompleteSkin
                                controller="user"
                                action="findUsers"
                                cache="true"
                                filter="jQuery('#member'+object.id).length == 0 ? true : false"
                                id="members"
                                name="team.members"
                                appendTo="#member-autocomplete"
                                onSelect="jQuery('.members-list').jqoteapp('#user-tmpl', ui.item)"
                                renderItem="${link}"
                                minLength="2"/>
            </is:fieldInput>
        </g:if>
        <div class="members-list">
            <g:each in="${members}" var="member">
                <span class="member ui-corner-all" id='member${member.id}'>
                    <g:if test="${ownerOrSm}">
                        <span class="button-s">
                            <span style="display: block;" class="button-action button-delete" onclick="jQuery(this).closest('.member').remove();">del</span>
                        </span>
                    </g:if>
                    <img src="${member.avatar}" height="48" class="avatar" width="48"/>
                    <span class="fullname">${is.truncated(value:member.name,size:17)}</span>
                    <span class="activity">${member.activity}</span>
                    <input type="hidden" name="members.${member.id}" value="${member.id}"/>
                     <is:select container="#member${member.id}"
                                width="110"
                                maxHeight="200"
                                id="member-role-select-${member.id}"
                                styleSelect="dropdown"
                                disabled="${!ownerOrSm}"
                                from="${rolesNames}"
                                keys="${rolesKeys}"
                                name="role.${member.id}"
                                value="${member.role}"/>
                </span>
            </g:each>
        </div>
    </is:fieldset>
</form>
</is:dialog>