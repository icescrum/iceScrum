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
<is:dialog valid="[
                action:'activate',
                controller:controllerName,
                id:sprint.id,
                onSuccess:'jQuery.event.trigger(\'activate_sprint\',data.sprint); jQuery.event.trigger(\'inProgress_story\',[data.stories]); jQuery.icescrum.renderNotice(\''+g.message(code:'is.sprint.activated')+'\');',button:'is.dialog.confirmActivateSprintAndRelease.button']">
    <form method="post" class="box-form box-form-250 box-form-200-legend" onsubmit="return false;">
        <input type="hidden" value="${params.product}" name="product"/>
        <input type="hidden" value="true" name="confirm"/>
        <is:fieldset title="is.dialog.confirmActivateSprintAndRelease.title">
            <is:fieldInformation noborder="true">
                <g:message code="is.dialog.confirmActivateSprintAndRelease.description"/>
            </is:fieldInformation>
        </is:fieldset>
    </form>
</is:dialog>