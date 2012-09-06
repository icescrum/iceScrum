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
<g:set var="poOrSm" value="${request.scrumMaster || request.productOwner}"/>

<is:iconButton
        rendered="${poOrSm}"
        action="add"
        shortcut="[key:'ctrl+n',scope:controllerName]"
        update="window-content-${controllerName}"
        icon="create"
        class="${(currentPanel == 'add') ? 'select' : ''}"
        title="${message(code:'is.ui.timeline.toolbar.alt.new')}"
        alt="${message(code:'is.ui.timeline.toolbar.alt.new')}">
  <g:message code="is.ui.timeline.toolbar.new"/>
</is:iconButton>

<is:separator rendered="${poOrSm}"/>

<is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
  <ul>
    <li class="first">
        <a href="#${controllerName}/productCumulativeFlowChart" title="${message(code:'is.ui.timeline.charts.productCumulativeFlow')}">
            ${message(code:'is.ui.timeline.charts.productCumulativeFlow')}
        </a>
    </li>
    <li>
        <a href="#${controllerName}/productBurnupChart" title="${message(code:'is.ui.timeline.charts.productBurnup')}">
            ${message(code:'is.ui.timeline.charts.productBurnup')}
        </a>
    </li>
    <li>
        <a href="#${controllerName}/productBurndownChart" title="${message(code:'is.ui.timeline.charts.productBurndown')}">
          ${message(code:'is.ui.timeline.charts.productBurndown')}
        </a>
    </li>
    <li><is:link action="productParkingLotChart"
            params="['referrer.action':'index','referrer.controller':controllerName]"
            controller="${controllerName}"
            update="window-content-${controllerName}"
            title="${message(code:'is.ui.timeline.charts.parkinglot')}"
            remote="true"
            value="${message(code:'is.ui.timeline.charts.productParkingLot')}"/>
    </li>
      <li>
          <a href="#${controllerName}/productVelocityChart" title="${message(code:'is.ui.timeline.charts.productVelocity')}">
            ${message(code:'is.ui.timeline.charts.productVelocity')}
          </a>
      </li>
      <li class="last">
        <a href="#${controllerName}/productVelocityCapacityChart" title="${message(code:'is.ui.timeline.charts.productVelocityCapacity')}">
          ${message(code:'is.ui.timeline.charts.productVelocityCapacity')}
        </a>
    </li>
  </ul>
</is:panelButton>

<is:separator elementId="menu-report-separator"/>

%{--Print button--}%
<is:reportPanel
        action="print"
        text="${message(code: 'is.ui.toolbar.print')}"
        formats="[
                  ['PDF', message(code:'is.report.format.pdf')],
                  ['RTF', message(code:'is.report.format.rtf')],
                  ['DOCX', message(code:'is.report.format.docx')],
                  ['ODT', message(code:'is.report.format.odt')]
                ]"
        params="locationHash='+encodeURIComponent(\$.icescrum.o.currentOpenedWindow.context.location.hash)+'"/>

<entry:point id="${controllerName}-${actionName}"/>