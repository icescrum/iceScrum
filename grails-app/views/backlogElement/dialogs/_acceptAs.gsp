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
<form class="box-form box-form-160 box-form-160-legend">
  <input type="hidden" value="${params.product}" name="product"/>
  <input type="hidden" value="${params.id}" name="id"/>
  <input type="hidden" value="${params.referrer.id}" name="referrer.id"/>
  <input type="hidden" value="${params.referrer.controller}" name="referrer.controller"/>
  <input type="hidden" value="${params.referrer.action}" name="referrer.action"/>
  <is:fieldset title="is.dialog.acceptAs.title">
      <is:fieldRadio for="acceptAs" label="is.dialog.acceptAs.acceptAs.title" noborder="true">
        <g:if test="${sprint}">
          <is:radio from="[(message(code: 'is.story')): '0', (message(code: 'is.feature')): '1', (message(code: 'is.task.type.urgent')): '2']" id="acceptAs" value="0" name="acceptAs"/>
        </g:if>
        <g:else>
          <is:radio from="[(message(code: 'is.story')): '0', (message(code: 'is.feature')): '1']" id="acceptAs" value="0" name="acceptAs"/>
        </g:else>
      </is:fieldRadio>
  </is:fieldset>
</form>