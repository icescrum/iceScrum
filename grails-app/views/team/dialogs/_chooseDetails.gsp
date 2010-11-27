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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<ul>
  <li><a href="#tabs-description">
<g:message code="is.team.description"/></a></li>
  <li><a href="#tabs-members"><g:message code="is.team.members"/></a></li>
  <li><a href="#tabs-products"><g:message code="is.team.products"/></a></li>
</ul>
<div id="tabs-description">
  <div class="browse-informations clearfix">
    <img src="${resource(dir: is.currentThemeImage(), file: 'choose/default.png')}" class="ico">
    <h4>${team.name}</h4>
    <p class="description">${team.description}</p>
  </div>
  <table cellpadding="0" cellspacing="0" class="table-lines">
    <tr class="table-lines-head">
      <th class="first"><g:message code='is.dialog.wizard.project.option'/></th>
      <th class="last"><g:message code='is.dialog.wizard.project.value'/></th>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.team.preferences.allowNewMembers'/></td>
      <td class="last"><g:formatBoolean boolean="${team.preferences.allowNewMembers}"/></td>
    </tr>
    <tr class="table-lines-item table-lines-odd">
      <td class="first"><g:message code='is.team.preferences.allowRoleChange'/></td>
      <td class="last"><g:formatBoolean boolean="${team.preferences.allowRoleChange}"/></td>
    </tr>
  </table>
</div>

<g:hiddenField name="id" value="${team.id}" /> 

<div id="tabs-members">
  <g:include action="detailsMembers" params="[id:team.id,offset:0]"/>
</div>

<div id="tabs-products">
  <g:include action="detailsProducts" params="[id:team.id,offset:0]"/>
</div>

