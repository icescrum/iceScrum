%{--
- Copyright (c) 2014 Kagilum SAS.
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
        <div class="btn-toolbar" id="${controllerName}-toolbar" role="toolbar">
            <div class="btn-group">
                <button type="button"
                        data-toggle="tooltip"
                        data-ui-tooltip-container="body"
                        title="${message(code:'todo.is.ui.toggle.grid.list')}"
                        onclick="$.icescrum.toggleGridList('#backlog-layout-window-${controllerName}',this)"
                        class="btn btn-default btn-sm">
                    <span class="glyphicon glyphicon-th"></span>
                </button>
            </div>
            <div class="btn-group" data-toggle="tooltip" data-ui-tooltip-container="body" title="${message(code:'todo.is.ui.export')}">
                <button class="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown">
                    <span class="glyphicon glyphicon-export"></span>&nbsp;<span class="caret"></span>
                </button>
                <ul class="dropdown-menu"
                    role="menu">
                    <g:each in="${is.exportFormats()}" var="format">
                        <li role="menuitem">
                            <a data-ajax="true" href="${createLink(action:format.action?:'print',controller:format.controller?:controllerName,params:format.params)}">${format.name}</a>
                        </li>
                    </g:each>
                    <entry:point id="${controllerName}-toolbar-export" model="[product:params.product, origin:controllerName]"/>
                </ul>
            </div>
            <div class="btn-group pull-right">
                <entry:point id="${controllerName}-${actionName}-toolbar-right"/>
                <g:if test="${params?.printable}">
                    <button type="button"
                            class="btn btn-default"
                            data-toggle="tooltip"
                            data-ui-tooltip-container="body"
                            title="${message(code:'is.ui.window.print')} (P)"
                            data-is-shortcut
                            data-is-shortcut-on="#window-id-${controllerName}"
                            data-is-shortcut-key="P"
                            title="${message(code:'is.ui.window.print')}"
                            href="${createLink(controller:controllerName,action:'print', params:[product:params.product?:null, format:'PDF'])}"
                            data-ajax="true"><span class="glyphicon glyphicon-print"></span>
                    </button>
                </g:if>
                <g:if test="${params?.widgetable}">
                    <button type="button"
                            class="btn btn-default btn-widget"
                            data-toggle="tooltip"
                            data-ui-tooltip-container="body"
                            title="${message(code:'is.ui.window.widgetable')} (W)"
                            data-is-shortcut
                            data-is-shortcut-on="#window-id-${controllerName}"
                            data-is-shortcut-key="W"><span class="glyphicon glyphicon-retweet"></span>
                    </button>
                </g:if>
                <g:if test="${params?.fullScreen}">
                    <button type="button"
                            class="btn btn-default btn-fullscreen"
                            data-toggle="tooltip"
                            data-ui-tooltip-container="body"
                            title="${message(code:'is.ui.window.fullscreen')} (F)"
                            data-is-shortcut
                            data-is-shortcut-on="#window-id-${controllerName}"
                            data-is-shortcut-key="F"><span class="glyphicon glyphicon-fullscreen"></span>
                    </button>
                </g:if>
            </div>
        </div>
    </div>
</nav>