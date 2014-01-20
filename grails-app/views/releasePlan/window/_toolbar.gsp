<%@ page import="org.icescrum.core.domain.Release" %>
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<g:if test="${release.id}">
    <g:if test="${release.state <= Release.STATE_INPROGRESS && (request.productOwner || request.scrumMaster)}">
    %{-- Add button --}%
        <li class="navigation-item button-ico button-add close-release-${release.id}">
            <a class="tool-button button-n"
               href="#${controllerName}/add/${release.id}"
               data-is-shortcut
               data-is-shortcut-key="ctrl+n"
               data-is-shortcut-on="#window-id-${controllerName}"
               alt="${message(code:'is.ui.releasePlan.toolbar.alt.new')}"
               title="${message(code:'is.ui.releasePlan.toolbar.alt.new')}">
                    <span class="start"></span>
                    <span class="content">
                        <span class="ico"></span>
                        ${message(code: 'is.ui.releasePlan.toolbar.new')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>

        %{-- Sprints generation --}%
        <li class="navigation-item close-release-${release.id}">
            <a class="tool-button button-n"
               href="${createLink(controller:'release', action:'generateSprints', params:[product:params.product], id:release.id)}"
               data-is-shortcut
               data-is-shortcut-key="ctrl+g"
               data-is-shortcut-on="#window-id-${controllerName}"
               data-ajax="true"
               data-ajax-trigger="add_sprint"
               data-ajax-notice="${message(code:'is.release.sprints.generated').encodeAsJavaScript()}"
               alt="${message(code:'is.ui.releasePlan.toolbar.alt.generateSprints')}"
               title="${message(code:'is.ui.releasePlan.toolbar.alt.generateSprints')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.releasePlan.toolbar.generateSprints')}
                </span>
                <span class="end"></span>
            </a>
        </li>

    %{-- Automatic planification --}%

        <li class="navigation-item close-release-${release.id}">
            <a class="tool-button button-n"
               href="${createLink(controller:'releasePlan', action:'autoPlan', params:[product:params.product], id:release.id)}"
               data-is-shortcut
               data-is-shortcut-key="ctrl+shift+a"
               data-is-shortcut-on="#window-id-${controllerName}"
               data-ajax="true"
               alt="${message(code:'is.ui.releasePlan.toolbar.alt.autoPlan')}"
               title="${message(code:'is.ui.releasePlan.toolbar.alt.autoPlan')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.releasePlan.toolbar.autoPlan')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>

    %{-- Dissociate All --}%
        <li class="navigation-item close-release-${release.id}">
            <a class="tool-button button-n"
               href="${createLink(controller:'release', action:'unPlan', params:[product:params.product], id:release.id)}"
               data-is-shortcut
               data-is-shortcut-key="ctrl+shift+d"
               data-is-shortcut-on="#window-id-${controllerName}"
               data-ajax="true"
               data-ajax-trigger='{"sprintMesure_sprint":"sprints", "unPlan_story":"stories"}'
               data-ajax-confirm="${message(code:'is.ui.releasePlan.toolbar.warning.dissociateAll').encodeAsJavaScript()}"
               data-ajax-notice="${message(code:'is.release.stories.dissociated').encodeAsJavaScript()}"
               alt="${message(code:'is.ui.releasePlan.toolbar.alt.dissociateAll')}"
               title="${message(code:'is.ui.releasePlan.toolbar.alt.dissociateAll')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.releasePlan.toolbar.dissociateAll')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>
    </g:if>

    <is:panelButton alt="documents" id="menu-documents" arrow="true" icon="create" text="${message(code:'is.ui.toolbar.documents')}">
        <ul class="dropmenu-scrollable" id="release-attachments-${release.id}">
            %{-- vision --}%
            <li class="first">
                <a href="#${controllerName}/vision/${release.id}"
                   data-is-shortcut
                   data-is-shortcut-key="ctrl+shift+v"
                   data-is-shortcut-on="#window-id-${controllerName}"
                   alt="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}"
                   title="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}">
                        <span class="start"></span>
                        <span class="content">
                            ${message(code: 'is.ui.releasePlan.toolbar.vision')}
                        </span>
                        <span class="end"></span>
                </a>
            </li>
            <li>
                <a href="#${controllerName}/notes/${release.id}"
                   data-is-shortcut
                   data-is-shortcut-key="ctrl+shift+o"
                   data-is-shortcut-on="#window-id-${controllerName}"
                   alt="${message(code:'is.ui.releasePlan.toolbar.alt.notes')}"
                   title="${message(code:'is.ui.releasePlan.toolbar.alt.notes')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.releasePlan.toolbar.notes')}
                    </span>
                    <span class="end"></span>
                </a>
            </li>
            <g:if test="${request.inProduct}">
                <li>
                    <a href="${g.createLink(action:"addDocument", id: release.id, params: [product:params.product])}"
                       title="${message(code:'is.dialog.documents.manage.release')}"
                       alt="${message(code:'is.dialog.documents.manage.release')}"
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
            <g:each var="attachment" in="${release.attachments}">
                <g:render template="/attachment/line" model="[attachment: attachment, controllerName: 'release']"/>
            </g:each>
        </ul>
    </is:panelButton>
    <is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph"
                    text="${message(code:'is.ui.toolbar.charts')}">
        <ul>
            <li class="first">
                <a href="#${controllerName}/releaseBurndownChart/${release.id}">${message(code:'is.ui.releaseplan.charts.burndown')}</a>
            </li>
            <li class="last">
                <a href="#${controllerName}/releaseParkingLotChart/${release.id}">${message(code:'is.ui.releaseplan.charts.parkingLot')}</a>
            </li>
        </ul>
    </is:panelButton>

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

    <entry:point id="${controllerName}-${actionName}" model="[release:release]"/>

    <is:onStream
            on="#release-attachments-${release.id}"
            events="[[object:'attachments', events:['replaceAll']]]"
            template="toolbar"/>
</g:if>