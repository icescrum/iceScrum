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
<g:set var="poOrsm" value="${sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>

<is:iconButton
        rendered="${poOrsm}"
        action="add"
        shortcut="[key:'ctrl+n',scope:id]"
        update="window-content-${id}"
        icon="create"
        class="${(currentPanel == 'add') ? 'select' : ''}"
        title="${message(code:'is.ui.timeline.toolbar.alt.new')}"
        alt="${message(code:'is.ui.timeline.toolbar.alt.new')}">
  <g:message code="is.ui.timeline.toolbar.new"/>
</is:iconButton>

<is:separator rendered="${poOrsm}"/>

<is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
  <ul>
    <li class="first"><is:link action="productCumulativeFlowChart" controller="${id}" update="window-content-${id}" title="${message(code:'is.ui.timeline.charts.productCumulativeflow')}" remote="true" value="${message(code:'is.ui.timeline.charts.productCumulativeFlow')}"/></li>
    <li><is:link action="productBurnupChart" controller="${id}" update="window-content-${id}" title="${message(code:'is.ui.timeline.charts.burnup')}" remote="true" value="${message(code:'is.ui.timeline.charts.productBurnup')}"/></li>
    <li><is:link action="productBurndownChart" controller="${id}" update="window-content-${id}" title="${message(code:'is.ui.timeline.charts.burndown')}" remote="true" value="${message(code:'is.ui.timeline.charts.productBurndown')}"/></li>
    <li><is:link action="productParkingLotChart"
            params="['referrer.action':'index','referrer.controller':id]"
            controller="${id}"
            update="window-content-${id}"
            title="${message(code:'is.ui.timeline.charts.parkinglot')}"
            remote="true"
            value="${message(code:'is.ui.timeline.charts.productParkingLot')}"/>
    </li>
    <li><is:link action="productVelocityChart" controller="${id}" update="window-content-${id}" title="${message(code:'is.ui.timeline.charts.velocityType')}" remote="true" value="${message(code:'is.ui.timeline.charts.productVelocity')}"/></li>
    <li class="last"><is:link action="productVelocityCapacityChart" controller="${id}" update="window-content-${id}" title="${message(code:'is.ui.timeline.charts.productVelocityCapacity')}" remote="true" value="${message(code:'is.ui.timeline.charts.productVelocityCapacity')}"/></li>
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

<entry:point id="${id}-${actionName}"/>