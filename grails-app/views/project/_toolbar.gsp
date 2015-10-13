%{--
- Copyright (c) 2014 Kagilum SAS
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<nav class="navbar navbar-toolbar navbar-default" role="navigation">
    <div class="container-fluid">
        <div class="btn-toolbar" role="toolbar">
            <div class="btn-group">
                <div uib-dropdown class="btn-group" tooltip-append-to-body="true" uib-tooltip="${message(code:'todo.is.ui.export')}">
                    <button class="btn btn-default btn-sm" type="button" uib-dropdown-toggle>
                        <span class="fa fa-download"></span>&nbsp;<span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu">
                        <g:each in="${is.exportFormats()}" var="format">
                            <li>
                                <a data-ajax="true" href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}">${format.name}</a>
                            </li>
                        </g:each>
                        <entry:point id="${controllerName}-toolbar-export" model="[product:params.product, origin:controllerName]"/>
                    </ul>
                </div>
                <div uib-dropdown class="btn-group" tooltip-append-to-body="true" uib-tooltip="${message(code:'todo.is.ui.charts')}">
                    <button class="btn btn-default btn-sm" type="button" uib-dropdown-toggle>
                        <span class="fa fa-bar-chart"></span>&nbsp;<span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu">
                        <li><a data-ui-chart data-ui-chart-container="modal" href="${controllerName}/productCumulativeFlowChart">${message(code:'is.ui.project.charts.productCumulativeFlow')}</a></li>
                        <li><a data-ui-chart data-ui-chart-container="modal" href="${controllerName}/productBurnupChart">${message(code:'is.ui.project.charts.productBurnup')}</a></li>
                        <li><a data-ui-chart data-ui-chart-container="modal" href="${controllerName}/productBurndownChart">${message(code:'is.ui.project.charts.productBurndown')}</a></li>
                        <li><a data-ui-chart data-ui-chart-container="modal" href="${controllerName}/productParkingLotChart">${message(code:'is.ui.project.charts.productParkingLot')}</a></li>
                        <li><a data-ui-chart data-ui-chart-container="modal" href="${controllerName}/productVelocityChart">${message(code:'is.ui.project.charts.productVelocity')}</a></li>
                        <li><a data-ui-chart data-ui-chart-container="modal" href="${controllerName}/productVelocityCapacityChart">${message(code:'is.ui.project.charts.productVelocityCapacity')}</a></li>
                        <entry:point id="${controllerName}-toolbar-chart" model="[product:params.product, origin:controllerName]"/>
                    </ul>
                </div>
                <entry:point id="${controllerName}-toolbar" model="[product:params.product, origin:controllerName]"/>
            </div>
            <div class="btn-group pull-right">
                <entry:point id="${controllerName}-${actionName}-toolbar-right"/>
                <g:if test="${params?.printable}">
                    <button type="button"
                            class="btn btn-default"
                            tooltip-append-to-body="true"
                            uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                            data-is-shortcut
                            data-is-shortcut-on="#window-id-${controllerName}"
                            data-is-shortcut-key="P"
                            title="${message(code:'is.ui.window.print')}"
                            href="${createLink(controller:controllerName,action:'print', params:[product:params.product?:null, format:'PDF'])}"
                            data-ajax="true"><span class="fa fa-print"></span>
                    </button>
                </g:if>
                <g:if test="${params?.fullScreen}">
                    <button type="button"
                            class="btn btn-default btn-fullscreen"
                            tooltip-append-to-body="true"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                            data-is-shortcut
                            data-is-shortcut-on="#window-id-${controllerName}"
                            data-is-shortcut-key="F"><span class="fa fa-expand"></span>
                    </button>
                </g:if>
            </div>
        </div>
    </div>
</nav>


<g:if test="${product?.id}">
    <is:panelButton alt="documents" id="menu-documents" arrow="true" icon="create" text="${message(code:'is.ui.toolbar.documents')}">
        <ul class="dropmenu-scrollable" id="product-attachments-${product.id}">
            <g:if test="${request.inProduct}">
                <li>
                    <a href="${g.createLink(action:"addDocument", id: product.id, params: [product:params.product])}"
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
                <g:render template="/attachment/line" model="[attachment: attachment]"/>
            </g:each>
        </ul>
    </is:panelButton>

    <is:onStream
            on="#product-attachments-${product.id}"
            events="[[object:'attachments', events:['replaceAll']]]"
            template="toolbar"/>
</g:if>