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
<g:if test="${request.scrumMaster || request.productOwner}">

    <li class="navigation-item button-ico button-add">
        <a class="tool-button button-n"
           href="#${controllerName}/add"
           data-is-shortcut
           data-is-shortcut-key="ctrl+n"
           data-is-shortcut-on="#window-id-${controllerName}"
           title="${message(code:'is.ui.timeline.toolbar.alt.new')}"
           alt="${message(code:'is.ui.timeline.toolbar.alt.new')}">
                <span class="start"></span>
                <span class="content">
                    <span class="ico"></span>
                    ${message(code: 'is.ui.timeline.toolbar.new')}
                </span>
                <span class="end"></span>
        </a>
    </li>
</g:if>

<is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}"">
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
    <li>
        <a href="#${controllerName}/productParkingLotChart" title="${message(code:'is.ui.timeline.charts.productParkingLot')}">
          ${message(code:'is.ui.timeline.charts.productParkingLot')}
        </a>
    </li>
      <li>
          <a href="#${controllerName}/productVelocityChart" title="${message(code:'is.ui.timeline.charts.productVelocity')}">
            ${message(code:'is.ui.timeline.charts.productVelocity')}
          </a>
      </li>
      <entry:point id="${controllerName}-${actionName}-charts" model="[product:params.product, origin:controllerName]"/>
      <li class="last">
        <a href="#${controllerName}/productVelocityCapacityChart" title="${message(code:'is.ui.timeline.charts.productVelocityCapacity')}">
          ${message(code:'is.ui.timeline.charts.productVelocityCapacity')}
        </a>
    </li>
  </ul>
</is:panelButton>

<g:if test="${product?.id}">
    <is:panelButton alt="documents" id="menu-documents" arrow="true" icon="create" text="${message(code:'is.ui.toolbar.documents')}">
        <ul class="dropmenu-scrollable" id="product-attachments-${product.id}">
            <g:if test="${request.inProduct}">
                <li>
                    <a href="${g.createLink(controller:"project", action:"addDocument", id: product.id, params: [product:params.product])}"
                       title="${message(code:'is.dialog.documents.manage.project')}"
                       alt="${message(code:'is.dialog.documents.manage.project')}"
                       data-ajax="true">
                        <span class="start"></span>
                        <span class="content">
                            <span class="ico"></span>
                            ${message(code: 'is.ui.toolbar.documents.add')}
                        </span>
                        <span class="end"></span>
                    </a>
                </li>
            </g:if>
            <g:each var="attachment" in="${product.attachments}">
                <g:render template="/attachment/line" model="[attachment: attachment, controller: 'project']"/>
            </g:each>
        </ul>
    </is:panelButton>

    <is:onStream
            on="#product-attachments-${product.id}"
            events="[[object:'attachments', events:['replaceAll']]]"
            template="toolbar"/>
</g:if>

%{--Export--}%
<is:panelButton alt="Export" id="menu-export" arrow="true" text="${message(code: 'is.ui.toolbar.export')}">
    <ul>
        <g:each in="${exportFormats}" var="format">
            <li>
                <div class="file-icon ${format.code.toLowerCase()}-format" style="display:inline-block">
                    <a data-ajax="true" href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}">${format.name}</a>
                </div>
            </li>
        </g:each>
    </ul>
</is:panelButton>

<entry:point id="${controllerName}-${actionName}"/>