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
<div id="blank-release" class="box-blank clearfix">
    <p>${message(code: 'is.ui.releasePlan.blank.description')}</p>
    <table cellpadding="0" cellspacing="0" border="0" class="box-blank-button">
        <tr>
            <td class="empty">&nbsp;</td>
            <td>
                <is:button
                        type="link"
                        rendered="${request.productOwner || request.scrumMaster}"
                        button="button-s button-s-light"
                        update="window-content-${controllerName}"
                        href="#timeline/add"
                        title="${message(code:'is.ui.releasePlan.blank.new')}"
                        alt="${message(code:'is.ui.releasePlan.blank.new')}"
                        icon="create">
                    <strong>${message(code: 'is.ui.releasePlan.blank.new')}</strong>
                </is:button>
            </td>
            <td class="empty">&nbsp;</td>
        </tr>
    </table>
    <entry:point id="${controllerName}-${actionName}-blank"/>
</div>
<is:onStream
        on="#blank-release"
        events="[[object:'release',events:['add']]]"
        callback="jQuery.icescrum.navigateTo('${controllerName}/'+release.id);"/>