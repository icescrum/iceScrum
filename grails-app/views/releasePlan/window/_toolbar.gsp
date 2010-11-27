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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%

<g:set var="poOrSm" value="${sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>

<g:if test="${params.id}">
%{-- Add button --}%
  <is:iconButton
          rendered='${poOrSm}'
          controller="${id}"
          action="add"
          shortcut="[key:'ctrl+n',scope:id]"
          update="window-content-${id}"
          icon="create"
          id="${params.id}"
          class="${(currentPanel == 'add') ? 'select' : ''}"
          alt="${message(code:'is.ui.releasePlan.toolbar.alt.new')}"
          title="${message(code:'is.ui.releasePlan.toolbar.alt.new')}">
    ${message(code: 'is.ui.releasePlan.toolbar.new')}
  </is:iconButton>

  <is:separator rendered="${poOrSm}"/>

%{-- Sprints generation --}%
  <is:iconButton
          rendered='${poOrSm}'
          alt="${message(code:'is.ui.releasePlan.toolbar.alt.generateSprints')}"
          title="${message(code:'is.ui.releasePlan.toolbar.alt.generateSprints')}"
          action="generateSprints"
          history='false'
          shortcut="[key:'ctrl+g',scope:id]"
          id="${params.id}"
          controller="${id}"
          update="window-content-${id}"
          onFailure="${is.notice(xhr:'XMLHttpRequest')}">
    ${message(code: 'is.ui.releasePlan.toolbar.generateSprints')}
  </is:iconButton>

  <is:separatorSmall rendered='${poOrSm}'/>

%{-- Automatic planification --}%
  <is:iconButton
          rendered='${poOrSm}'
          alt="${message(code:'is.ui.releasePlan.toolbar.alt.autoPlan')}"
          title="${message(code:'is.ui.releasePlan.toolbar.alt.autoPlan')}"
          action="autoPlan"
          controller="${id}"
          shortcut="[key:'ctrl+shift+a',scope:id]"
          history='false'
          id="${params.id}"
          update="window-content-${id}">
    ${message(code: 'is.ui.releasePlan.toolbar.autoPlan')}
  </is:iconButton>

  <is:separatorSmall rendered='${poOrSm}'/>

%{-- Dissociate All --}%
  <is:iconButton rendered='${poOrSm}'
          alt="${message(code:'is.ui.releasePlan.toolbar.alt.dissociateAll')}"
          title="${message(code:'is.ui.releasePlan.toolbar.alt.dissociateAll')}"
          action="dissociateAll"
          history='false'
          shortcut="[key:'ctrl+shift+d',scope:id]"
          id="${params.id}"
          controller="${id}"
          update="window-content-${id}">
    ${message(code: 'is.ui.releasePlan.toolbar.dissociateAll')}
  </is:iconButton>

  <is:separator rendered='${poOrSm}'/>

%{-- Vision --}%
  <is:iconButton
          alt="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}"
          title="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}"
          action="vision"
          shortcut="[key:'ctrl+shift+v',scope:id]"
          id="${params.id}"
          controller="${id}"
          update="window-content-${id}">
    ${message(code: 'is.ui.releasePlan.toolbar.vision')}
  </is:iconButton>

  <is:separator/>

  <is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
    <ul>
      <li class="first">
        <is:link id="${params.id}"
                action="releaseBurndownChart"
                controller="${id}"
                update="window-content-${id}"
                title="${message(code:'is.ui.releaseplan.charts.burndown')}"
                remote="true"
                value="${message(code:'is.ui.releaseplan.charts.burndown')}"/>
      </li>
      <li class="last">
        <is:link id="${params.id}"
                action="releaseParkingLotChart"
                controller="${id}"
                update="window-content-${id}"
                title="${message(code:'is.ui.releaseplan.charts.parkingLot')}"
                remote="true"
                value="${message(code:'is.ui.releaseplan.charts.parkingLot')}"/>
      </li>
    </ul>
  </is:panelButton>

  %{--Print button

  <is:separator/>

  <is:iconButton
          onClick="window.print();return false;"
          disabled="true"
          shortcut="[key:'ctrl+p',scope:id]"
          icon="print"
          alt="${message(code:'is.ui.toolbar.alt.print')}">
    <g:message code="is.ui.toolbar.print"/> 
  </is:iconButton>--}%

</g:if>
