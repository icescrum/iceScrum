%{--
- Copyright (c) 2013 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<is:dialog width="500"
           valid="[action:'done',
                   controller:'story',
                   id: params.id, button:'is.ui.releasePlan.menu.story.done',
                   onSuccess:'jQuery.event.trigger(\'done_story\',[data]); jQuery.icescrum.renderNotice(\''+message(code:'is.story.declaredAsDone')+'\');',
           ]">
    <form method="post" class="box-form box-form-250 box-form-200-legend" onsubmit="return false;">
        <input type="hidden" value="${params.product}" name="product"/>
        <input type="hidden" value="true" name="confirm"/>
    </form>
    <g:message code="is.ui.story.done.confirm.acceptanceTests"/>
    <g:each in="${testsNotSuccess}" var="test">
        <div style="padding-left: 10px">${test.uid} - <strong>${test.name}:</strong> <g:message code="${test.stateEnum.toString()}"/></div>
    </g:each>
</is:dialog>