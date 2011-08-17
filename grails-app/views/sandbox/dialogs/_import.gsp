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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<g:if test="${columns && mapping}">
  <is:dialog width="400" valid="[
  action:'dropImport',
  controller:id,
  onSuccess:'jQuery.event.trigger(\'add_story\',[data]); jQuery.icescrum.renderNotice(\''+g.message(code:'is.story.imported')+'\');',
  button:'is.dialog.drop.import.button']">
    <form method="post" class="box-form box-form-250 box-form-200-legend" onsubmit="return false;">
      <input type="hidden" value="true" name="confirm"/>
      <input type="hidden" value="${data}" name="data"/>
      <input type="hidden" value="${params.product}" name="product"/>
      <is:fieldset title="is.dialog.drop.import.sandbox.title">
        <is:fieldInformation noborder="true">
          <g:message code="is.dialog.drop.import.sandbox.information"/>
        </is:fieldInformation>
        <g:each in="${mapping}" var="mapValue" status="index">
          <is:fieldSelect for="mapping.${mapValue.key}" label="${message(code:mapValue.value)}" noborder="${index == mapping.size()-1 ? 'true' : ''}">
            <is:select width="100" maxHeight="100" styleSelect="dropdown" from="${columns}" name="mapping.${mapValue.key}" value="${matchValues ? matchValues[mapValue.key] : ''}" noSelection="['':message(code:'is.dialog.drop.import.select.ignore')]"/>
          </is:fieldSelect>
        </g:each>
      </is:fieldset>
    </form>
  </is:dialog>
</g:if>
<g:else>
  <is:dialog width="400" valid="[action:'add',controller:id,update:'window-content-'+id,button:'is.yes']">
    <form method="post" class="box-form box-form-250 box-form-200-legend" onsubmit="return false;">
      <input type="hidden" value="${data}" name="story.description"/>
      <input type="hidden" value="${params.product}" name="product"/>
      <is:fieldset title="is.dialog.drop.import.sandbox.title">
        <is:fieldInformation noborder="true">
          <g:message code="is.dialog.drop.import.sandbox.invalid.format" args="[message(code:'is.backlogelement.description')]"/>
        </is:fieldInformation>
      </is:fieldset>
    </form>
  </is:dialog>
</g:else>