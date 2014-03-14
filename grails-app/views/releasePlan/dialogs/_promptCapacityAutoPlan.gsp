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
<is:dialog width="400" focusable="${false}" valid="[action:'autoPlan',
                  controller:controllerName,
                  id:params.id,
                  onSuccess:'jQuery.event.trigger(\'plan_story\',[data]); jQuery.icescrum.renderNotice(\''+g.message(code:'is.release.autoplan')+'\')',
                  button:'is.dialog.promptCapacityAutoPlan.button']">
    <form method="post" class="box-form box-form-160 box-form-160-legend"
          onsubmit="if (jQuery('#capacity').val() != '') {
              jQuery('.ui-dialog-buttonpane button:eq(1)').click();
          }
          return false;">
        <input type="hidden" id="product" name="product" value="${params.product}"/>
        <input type="hidden" id="id" name="id" value="${params.id}"/>
        <is:fieldset title="is.dialog.promptCapacityAutoPlan.title">
            <is:fieldInformation noborder="true">
                <g:message code="is.dialog.promptCapacityAutoPlan.description"/>
            </is:fieldInformation>
            <is:fieldInput for="capacity" label="is.dialog.promptCapacityAutoPlan.capacity" noborder="true">
                <is:input id="capacity" name="capacity" value="" typed="[type:'numeric',allow:'.,']"/>
            </is:fieldInput>
        </is:fieldset>
    </form>
</is:dialog>