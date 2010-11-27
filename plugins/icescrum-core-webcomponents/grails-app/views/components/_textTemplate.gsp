%{--
  - Copyright (c) 2010 iceScrum Technologies.
  -
  - This file is part of iceScrum.
  -
  - iceScrum is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Lesser General Public License as published by
  - the Free Software Foundation, either version 3 of the License.
  -
  - iceScrum is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU General Public License for more details.
  -
  - You should have received a copy of the GNU Lesser General Public License
  - along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
  --}%

<is:fieldset id="${id}" title="${title}">

  <g:if test="${!disabled}">
    <is:fieldCheckbox for="displayTemplate" label="${label}" noborder="true">
      <input type="checkbox" id="displayTemplate" name="displayTemplate" ${!checked ? 'value="1"' : 'value="0"'} ${!checked ? 'checked="checked"' : ''}/>
      <jq:jquery>
        $("#displayTemplate").checkBox();
        $("#displayTemplate").click(function(event){
          jQuery.icescrum.displayTemplate('#story-template', this.checked);
        });
      </jq:jquery>
    </is:fieldCheckbox>
  </g:if>

  %{-- Template --}%
  <div class="text-template" style="${checked ? 'display:none;' :''}">
      <g:each in="${rows}" var="row" status="i">
        <g:if test="${i==(rows.size-1)}">
          <is:fieldInput label="${row.title}" noborder="true">${row.content}</is:fieldInput>
        </g:if>
        <g:else>
          <is:fieldInput label="${row.title}">${row.content}</is:fieldInput>
        </g:else>
      </g:each>
  </div>
  
</is:fieldset>