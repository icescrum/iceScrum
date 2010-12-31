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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<sec:access expression="scrumMaster() or productOwner()">

  <g:if test="${params.team}">
    <sec:access expression="scrumMaster()">
    %{--New--}%
      <is:iconButton
              dialog="true"
              action="addMember"
              controller="members"
              resizable="false"
              draggable="false"
              width="600"
              valid="[action:'updateMembers',params:'\'team='+params.team+'\'',controller:'members',
              update:'window-content-'+id ,button:'is.button.ok']"
              shortcut="[key:'ctrl+n',scope:id]"
              icon="add"
              alt="${message(code:'is.ui.members.toolbar.alt.new')}"
              title="${message(code:'is.ui.members.toolbar.alt.new')}">
        <g:message code="is.ui.members.toolbar.new"/>
      </is:iconButton>
      <is:separatorSmall/>

    %{--dek member--}%
      <is:iconButton
              disabled="true"
              onclick="\$.icescrum.selectableAction('deleteMembers');"
              icon="remove"
              shortcut="[key:'del',scope:id]"
              alt="${message(code:'is.ui.members.toolbar.alt.delete.member')}"
              title="${message(code:'is.ui.members.toolbar.alt.delete.member')}">
        <g:message code="is.ui.members.toolbar.delete.member"/>
      </is:iconButton>
      <is:separatorSmall/>
    </sec:access>
  </g:if>


  <g:if test="${params.product}">
  %{--Register Team--}%
    <sec:access expression="productOwner()">
      <is:iconButton
              dialog="true"
              action="addTeam"
              controller="members"
              resizable="false"
              draggable="false"
              width="600"
              valid="[action:'updateTeams',params:'\'product='+params.product+'\'',controller:'members',
              update:'window-content-'+id,button:'is.button.ok']"
              shortcut="[key:'ctrl+a',scope:id]"
              icon="add"
              alt="${message(code:'is.ui.members.toolbar.alt.register.team')}"
              title="${message(code:'is.ui.members.toolbar.alt.register.team')}">
        <g:message code="is.ui.members.toolbar.register.team"/>
      </is:iconButton>
      <is:separatorSmall/>
    </sec:access>

    <sec:access expression="productOwner() or scrumMaster()">
      <is:iconButton
              disabled="true"
              onclick="\$.icescrum.selectableAction('leaveProduct');"
              icon="remove"
              shortcut="[key:'del',scope:id]"
              alt="${message(code:'is.ui.members.toolbar.alt.leave.product')}"
              title="${message(code:'is.ui.members.toolbar.alt.leave.product')}">
        <g:message code="is.ui.members.toolbar.leave.product"/>
      </is:iconButton>
      <is:separatorSmall/>
    </sec:access>

  </g:if>

</sec:access>


%{--View--}%
<is:panelButton alt="Role" id="menu-role" arrow="true" icon="queen" text="${message(code:'is.ui.members.toolbar.role')}">
  <ul>

    <sec:access expression="hasRole('ROLE_ADMIN')">
      <li class="first">
        <is:link disabled="true"
                onclick="\$.icescrum.selectableAction('setOwner',true, 'uid');"
                alt="${message(code:'is.ui.members.toolbar.alt.set.owner')}"
                title="${message(code:'is.ui.members.toolbar.alt.set.owner')}"
                value="${message(code:'is.ui.members.toolbar.set.owner')}"/>
        <is:separatorSmall/>
      </li>
    </sec:access>

    <g:if test="${params.product}">

      <g:if test="${product && !product.preferences.lockPo}">
        <sec:access expression="not productOwner() and (scrumMaster() or teamMember())">
          <li class="first">
            <is:link
                    remote="true"
                    action="beProductOwner"
                    onSuccess='location.reload(true);'
                    shortcut="[key:'ctrl+p',scope:id]"
                    alt="${message(code:'is.ui.members.toolbar.alt.be.po')}"
                    title="${message(code:'is.ui.members.toolbar.alt.be.po')}"
                    value="${message(code:'is.ui.members.toolbar.be.po')}"/>
          </li>
          <is:separatorSmall/>
        </sec:access>
        <sec:access expression="productOwner() and (not owner())">
          <li class="first">
            <is:link
                    remote="true"
                    action="dontBeProductOwner"
                    onSuccess='location.reload(true);'
                    shortcut="[key:'ctrl+p',scope:id]"
                    alt="${message(code:'is.ui.members.toolbar.alt.dontbe.po')}"
                    title="${message(code:'is.ui.members.toolbar.alt.dontbe.po')}"
                    value="${message(code:'is.ui.members.toolbar.dontbe.po')}"/>
          </li>
          <is:separatorSmall/>
        </sec:access>
      </g:if>
      <sec:access expression="owner()">
        <li class="first">
          <is:link
                  disabled="true"
                  onclick="\$.icescrum.selectableAction('setProductOwner',true, 'uid');"
                  shortcut="[key:'ctrl+p',scope:id]"
                  alt="${message(code:'is.ui.members.toolbar.alt.set.po')}"
                  title="${message(code:'is.ui.members.toolbar.alt.set.po')}"
                  value="${message(code:'is.ui.members.toolbar.set.po')}"/>
        </li>
        <is:separatorSmall/>
        <li>
          <is:link
                  disabled="true"
                  onclick="\$.icescrum.selectableAction('unsetProductOwner',true, 'uid');"
                  alt="${message(code:'is.ui.members.toolbar.alt.unset.po')}"
                  title="${message(code:'is.ui.members.toolbar.alt.unset.po')}"
                  value="${message(code:'is.ui.members.toolbar.unset.po')}"/>
        </li>
      </sec:access>
    </g:if>
    <g:if test="${params.team}">
      <sec:access expression="owner()">
        <li>
          <is:link
                  disabled="true"
                  onclick="\$.icescrum.selectableAction('setScrumMaster',true, 'uid');"
                  shortcut="[key:'ctrl+m',scope:id]"
                  alt="${message(code:'is.ui.members.toolbar.alt.set.sm')}"
                  title="${message(code:'is.ui.members.toolbar.alt.set.sm')}"
                  value="${message(code:'is.ui.members.toolbar.set.sm')}"/>
        </li>
        <li>
          <is:link
                  disabled="true"
                  onclick="\$.icescrum.selectableAction('unsetScrumMaster',true, 'uid');"
                  alt="${message(code:'is.ui.members.toolbar.alt.unset.sm')}"
                  title="${message(code:'is.ui.members.toolbar.alt.unset.sm')}"
                  value="${message(code:'is.ui.members.toolbar.unset.sm')}"/>
        </li>
      </sec:access>

      <g:if test="${team && !team.preferences.allowRoleChange}">
        <sec:access expression="teamMember()">
          <li class="first">
            <is:link
                    history="false"
                    remote="true"
                    action="beScrumMaster"
                    onSuccess='location.reload(true);'
                    shortcut="[key:'ctrl+m',scope:id]"
                    alt="${message(code:'is.ui.members.toolbar.alt.be.sm')}"
                    title="${message(code:'is.ui.members.toolbar.alt.be.sm')}"
                    value="${message(code:'is.ui.members.toolbar.be.sm')}"/>
          </li>
        </sec:access>
        <sec:access expression="scrumMaster() and (not owner())">
          <li class="first">
            <is:link
                    history="false"
                    remote="true"
                    action="dontBeScrumMaster"
                    onSuccess='location.reload(true);'
                    shortcut="[key:'ctrl+m',scope:id]"
                    alt="${message(code:'is.ui.members.toolbar.alt.dontbe.sm')}"
                    title="${message(code:'is.ui.members.toolbar.alt.dontbe.sm')}"
                    value="${message(code:'is.ui.members.toolbar.dontbe.sm')}"/>
          </li>
        </sec:access>
      </g:if>
      <sec:access expression="teamMember()">
        <li>
          <is:link
                  history="false"
                  shortcut="[key:'ctrl+l',scope:id]"
                  remote="true"
                  action="leaveTeam"
                  onSuccess='document.location=data.url;'
                  alt="${message(code:'is.ui.members.toolbar.alt.leave.team')}"
                  title="${message(code:'is.ui.members.toolbar.alt.leave.team')}"
                  value="${message(code:'is.ui.members.toolbar.leave.team')}"/>
        </li>
      </sec:access>

    </g:if>
  </ul>
</is:panelButton>
