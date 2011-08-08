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
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>
<g:if test="${release.id}">
    <g:if test="${release.state <= Release.STATE_INPROGRESS && poOrSm}">
    %{-- Add button --}%
        <is:iconButton
                controller="${id}"
                action="add"
                shortcut="[key:'ctrl+n',scope:id]"
                update="window-content-${id}"
                icon="create"
                id="${release.id}"
                class="select close-release-${release.id}"
                alt="${message(code:'is.ui.releasePlan.toolbar.alt.new')}"
                title="${message(code:'is.ui.releasePlan.toolbar.alt.new')}">
            ${message(code: 'is.ui.releasePlan.toolbar.new')}
        </is:iconButton>

        <is:separator class="close-release-${release.id}"/>

    %{-- Sprints generation --}%
        <is:iconButton
                alt="${message(code:'is.ui.releasePlan.toolbar.alt.generateSprints')}"
                title="${message(code:'is.ui.releasePlan.toolbar.alt.generateSprints')}"
                action="generateSprints"
                history='false'
                shortcut="[key:'ctrl+g',scope:id]"
                id="${release.id}"
                controller="release"
                class="close-release-${release.id}"
                onSuccess="jQuery.event.trigger('add_sprint',[data]); jQuery.icescrum.renderNotice('${g.message(code:'is.release.sprints.generated')}')">
            ${message(code: 'is.ui.releasePlan.toolbar.generateSprints')}
        </is:iconButton>

        <is:separatorSmall class="close-release-${release.id}"/>

    %{-- Automatic planification --}%
        <is:iconButton
                alt="${message(code:'is.ui.releasePlan.toolbar.alt.autoPlan')}"
                title="${message(code:'is.ui.releasePlan.toolbar.alt.autoPlan')}"
                action="autoPlan"
                controller="releasePlan"
                shortcut="[key:'ctrl+shift+a',scope:id]"
                history='false'
                id="${params.id}"
                class="close-release-${release.id}"
                onSuccess="jQuery(document.body).append(data.dialog);">
            ${message(code: 'is.ui.releasePlan.toolbar.autoPlan')}
        </is:iconButton>

        <is:separatorSmall class="close-release-${release.id}"/>

    %{-- Dissociate All --}%
        <is:iconButton
                alt="${message(code:'is.ui.releasePlan.toolbar.alt.dissociateAll')}"
                title="${message(code:'is.ui.releasePlan.toolbar.alt.dissociateAll')}"
                action="unPlan"
                history='false'
                shortcut="[key:'ctrl+shift+d',scope:id]"
                id="${params.id}"
                controller="release"
                class="close-release-${release.id}"
                onSuccess="jQuery.event.trigger('sprintMesure_sprint',[data.sprints]); jQuery.event.trigger('unPlan_story',[data.stories]); jQuery.icescrum.renderNotice('${g.message(code:'is.release.stories.dissociated')}')">
            ${message(code: 'is.ui.releasePlan.toolbar.dissociateAll')}
        </is:iconButton>

        <is:separator class="close-release-${release.id}"/>
    </g:if>

%{-- Vision --}%
    <is:iconButton
            alt="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}"
            title="${message(code:'is.ui.releasePlan.toolbar.alt.vision')}"
            action="vision"
            shortcut="[key:'ctrl+shift+v',scope:id]"
            id="${release.id}"
            controller="${id}"
            update="window-content-${id}">
        ${message(code: 'is.ui.releasePlan.toolbar.vision')}
    </is:iconButton>

    <is:separator/>

    <is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph"
                    text="${message(code:'is.ui.toolbar.charts')}">
        <ul>
            <li class="first">
                <is:link id="${release.id}"
                         action="releaseBurndownChart"
                         controller="${id}"
                         update="window-content-${id}"
                         title="${message(code:'is.ui.releaseplan.charts.burndown')}"
                         remote="true"
                         value="${message(code:'is.ui.releaseplan.charts.burndown')}"/>
            </li>
            <li class="last">
                <is:link id="${release.id}"
                         action="releaseParkingLotChart"
                         controller="${id}"
                         update="window-content-${id}"
                         title="${message(code:'is.ui.releaseplan.charts.parkingLot')}"
                         remote="true"
                         value="${message(code:'is.ui.releaseplan.charts.parkingLot')}"/>
            </li>
        </ul>
    </is:panelButton>
    <entry:point id="${id}-${actionName}" model="[release:release]"/>
</g:if>
