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
<is:tableView>
  <is:table id="members-table">

    <is:tableHeader width="3%" class="table-cell-checkbox" name=""/>
    <is:tableHeader width="17%" name="${message(code:'is.team')}"/>
    <is:tableHeader width="70%" name="${message(code:'is.team.members')}"/>

    <is:tableRows in="${teams}" var="team" elemID="id">
      <is:tableColumn class="table-cell-checkbox">
        <sec:access expression="productOwner() or scrumMaster(${team.id})">
          <g:checkBox name="check-${team.id}"/>
        </sec:access>
      </is:tableColumn>
      <is:tableColumn class="cell-center"><strong>${team.name.encodeAsHTML()}</strong></is:tableColumn>
      <is:tableColumn><div class="panel-box-content members-medium">
        <g:set var="selectable" value="${sec.access(expression:'owner() or productOwner() or scrumMaster('+team.id+')',{'identifiable ui-selectable'})}" />
        <g:each in="${team.members}" var="m">
          <div class="member-medium ui-corner-all ${m.id != principalId ? selectable : ''}" elemId="${m.id}">
            <is:avatar userid="${m.id}" class="ico"/>
            <p><is:scrumLink controller="user" action='profile' id="${m.username}"><strong>${m.firstName.encodeAsHTML()} ${m.lastName.encodeAsHTML()} (${m.username.encodeAsHTML()})</strong></is:scrumLink></p>
            <p>${m.preferences?.activity?.encodeAsHTML() ?: ''}</p>
            <p><strong><is:displayRole product="${params.product}" team="${team.id}" user="${m}"/></strong></p>
          </div>
        </g:each>
        <div class="clearfix"></div>
      </div></is:tableColumn>
    </is:tableRows>
  </is:table>
</is:tableView>
<sec:access expression="productOwner() or scrumMaster()">
  <jq:jquery>
    $('#members-table').selectable({filter:'.ui-selectable',cancel:'a,.table-cell-checkbox'});
  </jq:jquery>
</sec:access>
<jq:jquery>
  <is:renderNotice />
</jq:jquery>
