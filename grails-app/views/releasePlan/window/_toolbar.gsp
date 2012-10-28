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
--}%
<g:if test="${release.id}">
    <g:if test="${release.state <= Release.STATE_INPROGRESS && (request.productOwner || request.scrumMaster)}">
    %{-- Add button --}%
        <li class="navigation-item button-ico button-create close-release-${release.id}">
            <a class="tool-button button-n"
               href="#${controllerName}/add/${release.id}"
               data-shortcut="ctrl+n"
               data-shortcut-on="#window-id-${controllerName}"
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
        <li class="navigation-item separator close-release-${release.id}">
            <a class="tool-button button-n"
               href="${createLink(controller:'release', action:'generateSprints', params:[product:params.product], id:release.id)}"
               data-shortcut="ctrl+g"
               data-ajax="true"
               data-ajax-trigger="add_sprint"
               data-ajax-notice="${message(code:'is.release.sprints.generated').encodeAsJavaScript()}"
               data-shortcut-on="#window-id-${controllerName}"
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

        <li class="navigation-item separator close-release-${release.id}">
            <a class="tool-button button-n"
               href="${createLink(controller:'releasePlan', action:'autoPlan', params:[product:params.product], id:release.id)}"
               data-shortcut="ctrl+shift+a"
               data-ajax="true"
               data-shortcut-on="#window-id-${controllerName}"
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
        <li class="navigation-item separator close-release-${release.id}">
            <a class="tool-button button-n"
               href="${createLink(controller:'release', action:'unPlan', params:[product:params.product], id:release.id)}"
               data-shortcut="ctrl+shift+d"
               data-ajax="true"
               data-ajax-trigger='{"sprintMesure_sprint":"sprints", "unPlan_story":"stories"}'
               data-ajax-confirm="${message(code:'is.ui.releasePlan.toolbar.warning.dissociateAll').encodeAsJavaScript()}"
               data-ajax-notice="${message(code:'is.release.stories.dissociated').encodeAsJavaScript()}"
               data-shortcut-on="#window-id-${controllerName}"
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

%{-- Vision --}%
    <li class="navigation-item ${release.state <= Release.STATE_INPROGRESS && (request.productOwner || request.scrumMaster) ? 'separator' : ''}">
        <a class="tool-button button-n"
           href="#${controllerName}/vision/${release.id}"
           data-shortcut="ctrl+shift+v"
           data-shortcut-on="#window-id-${controllerName}"
           alt="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}"
           title="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.releasePlan.toolbar.vision')}
                </span>
                <span class="end"></span>
        </a>
    </li>

    <is:panelButton alt="Charts" id="menu-chart" arrow="true" separator="true" icon="graph"
                    text="${message(code:'is.ui.toolbar.charts')}">
        <ul>
            <li class="first">
                <a href="${createLink(action:'releaseBurndownChart', params: [product:params.product], id:release.id)}"
                         data-ajax="true"
                         data-ajax-update="#window-content-${controllerName}">${message(code:'is.ui.releaseplan.charts.burndown')}</a>
            </li>
            <li class="last">
                <a href="${createLink(action:'releaseParkingLotChart', params: [product:params.product], id:release.id)}"
                         data-ajax="true"
                         data-ajax-update="#window-content-${controllerName}">${message(code:'is.ui.releaseplan.charts.parkingLot')}</a>
            </li>
        </ul>
    </is:panelButton>
    <entry:point id="${controllerName}-${actionName}" model="[release:release]"/>
</g:if>
