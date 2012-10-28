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
- Manuarii Stein (manuarii.stein@icescrum.com)
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%

<is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
  <ul>
    <li class="first">
        <a href="#${controllerName}/productCumulativeFlowChart">
            ${message(code:'is.ui.project.charts.productCumulativeFlow')}
        </a>
    </li>
    <li>
        <a href="#${controllerName}/productBurnupChart">
            ${message(code:'is.ui.project.charts.productBurnup')}
        </a>
    </li>
    <li>
        <a href="#${controllerName}/productBurndownChart">
            ${message(code:'is.ui.project.charts.productBurndown')}
        </a>
    </li>
    <li>
        <a href="#${controllerName}/productParkingLotChart">
            ${message(code:'is.ui.project.charts.productParkingLot')}
        </a>
    </li>
    <li>
        <a href="#${controllerName}/productVelocityChart">
            ${message(code:'is.ui.project.charts.productVelocity')}
        </a>
    </li>
    <li class="last">
        <a href="#${controllerName}/productVelocityCapacityChart">
            ${message(code:'is.ui.project.charts.productVelocityCapacity')}
        </a>
    </li>
  </ul>
</is:panelButton>

<entry:point id="${controllerName}-${actionName}"/>

%{--Print button--}%
<is:reportPanel
        action="print"
        separator="true"
        text="${message(code: 'is.ui.toolbar.print')}"
        formats="[
                  ['PDF', message(code:'is.report.format.pdf')],
                  ['RTF', message(code:'is.report.format.rtf')],
                  ['DOCX', message(code:'is.report.format.docx')],
                  ['ODT', message(code:'is.report.format.odt')]
                ]"
        params="locationHash=${params.actionWindow?:''}"/>

%{--Print button--}%
<is:reportPanel
        action="printPostits"
        id="all"
        separator="true"
        formats="[
                    ['PDF', message(code:'is.report.format.pdf')]
                ]"
        text="${message(code: 'is.ui.project.toolbar.print.allStories')}"/>