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
- Vincent Barrier (vincent.barrier@icescrum.com)
--}%
<is:dialog width="400" valid="[action:'close',controller:id,id:sprint.id,update:'window-content-'+id,button:'is.dialog.closeSprint.button']">
  <form method="post" class="box-form box-form-250 box-form-200-legend" onsubmit="return false;">
    <input type="hidden" value="true" name="confirm"/>
    <input type="hidden" value="${params.product}" name="product"/>
    <is:fieldset title="is.dialog.closeSprint.title">
      <is:fieldInformation noborder="true">
        <g:message code="is.dialog.closeSprint.description"/>
      </is:fieldInformation>
      <g:each in="${stories}" var="story" status="u">
        <is:fieldRadio noborder="${(u + 1) == stories.size()?'true':'false'}" for="undonestory-${story.id}" label="${story.id} - ${story.name.encodeAsHTML()} (${story.effort} ${story.effort > 1 ? 'pts' : 'pt'})">
         <is:radio from="[(message(code: 'is.dialog.closeSprint.done')): '1', (message(code: 'is.dialog.closeSprint.notDone')): '0']" id="undonestory-${story.id}" value="0" name="story.id.${story.id}"/>
        </is:fieldRadio>
      </g:each>
    </is:fieldset>
  </form>
</is:dialog>