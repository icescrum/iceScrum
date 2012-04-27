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
--}%

<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>
<div class="box-blank clearfix" style="display:${sprints ? 'none' : 'block'};">
    <p>${message(code: 'is.ui.releasePlan.blankSprint.description')}</p>
    <table cellpadding="0" cellspacing="0" border="0" class="box-blank-button">
        <tr>
            <td class="empty">&nbsp;</td>
            <td>
                <is:button
                        type="link"
                        button="button-s button-s-light"
                        history="false"
                        remote="true"
                        id="${release.id}"
                        rendered="${poOrSm}"
                        controller="release"
                        action="generateSprints"
                        onSuccess="jQuery.event.trigger('add_sprint',[data]); jQuery.icescrum.renderNotice('${g.message(code:'is.release.sprints.generated')}')"
                        title="${message(code:'is.ui.releasePlan.blankSprint.generateSprints')}"
                        alt="${message(code:'is.ui.releasePlan.blankSprint.generateSprints')}"
                        icon="create">
                    <strong>${message(code: 'is.ui.releasePlan.blankSprint.generateSprints')}</strong>
                </is:button>
            </td>
            <td class="empty">&nbsp;</td>
            <td>
                <is:button
                        type="link"
                        button="button-s button-s-light"
                        rendered="${poOrSm}"
                        href="#${controllerName}/add/${release.id}"
                        title="${message(code:'is.ui.releasePlan.blankSprint.new')}"
                        alt="${message(code:'is.ui.releasePlan.blankSprint.new')}"
                        icon="create">
                    <strong>${message(code: 'is.ui.releasePlan.blankSprint.new')}</strong>
                </is:button>
            </td>
            <td class="empty">&nbsp;</td>
        </tr>
    </table>
    <entry:point id="${controllerName}-${actionName}-blankSprint" model="[release:release]"/>
</div>
