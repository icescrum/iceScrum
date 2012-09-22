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
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>
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
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>

<g:if test="${request.inProduct}">
<li class="first">
    <a href="#sprintPlan/${sprint.id}">
        <g:message code="is.ui.releasePlan.menu.sprint.open"/>
    </a>
</li>
</g:if>
<g:if test="${poOrSm && ( template || sprint.state == Sprint.STATE_WAIT)}">
    <li id="menu-activate-sprint-${sprint.id}" class="activate-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.activable?'':'hidden'}">
        <a href="${createLink(action:'activate',controller:'sprint',id:sprint.id,params:[product:params.product])}"
           data-ajax-trigger='{"activate_sprint":"sprint","inProgress_story":"stories"}'
           data-ajax-notice="${message(code: 'is.sprint.activated').encodeAsJavaScript()}"
           data-ajax-confirm="${message(code:'is.ui.releasePlan.menu.sprint.activate.confirm').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.releasePlan.menu.sprint.activate'/>
        </a>
    </li>
</g:if>
<g:if test="${poOrSm && (template || sprint.state <= Sprint.STATE_INPROGRESS)}">
    <li id="menu-close-sprint-${sprint.id}" class="close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.state == Sprint.STATE_INPROGRESS?'':'hidden'}">
        <a href="${createLink(action:'close',controller:'releasePlan',id:sprint.id,params:[product:params.product])}"
           data-ajax-trigger='{"close_sprint":"sprint","done_story":"stories","update_story":"unDoneStories"}'
           data-ajax-notice="${message(code: 'is.sprint.closed').encodeAsJavaScript()}"
           data-ajax-confirm="${message(code:'is.ui.releasePlan.menu.sprint.close.confirm').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.releasePlan.menu.sprint.close'/>
        </a>
    </li>
</g:if>
<g:if test="${poOrSm && (sprint.state != Sprint.STATE_DONE || template)}">
    <li id="menu-edit-sprint-${sprint.id}">
        <a href="#${controllerName}/edit/${sprint.parentRelease.id}/?subid=${sprint.id}">
            <g:message code="is.ui.releasePlan.menu.sprint.update"/>
        </a>
    </li>
</g:if>
<g:if test="${poOrSm && (sprint.state == Sprint.STATE_WAIT || template)}">
    <li id="menu-delete-sprint-${sprint.id}">
        <a href="${createLink(action:'delete',controller:'releasePlan',id:sprint.id,params:[product:params.product])}"
           data-ajax-trigger='remove_sprint'
           data-ajax-notice="${message(code: 'is.sprint.deleted').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.releasePlan.menu.sprint.delete'/>
        </a>
    </li>
</g:if>
<g:if test="${poOrSm && (sprint.state != Sprint.STATE_DONE || template)}">
    <li id="menu-unplan-sprint-${sprint.id}">
        <a href="${createLink(action:'unPlan',controller:'sprint',id:sprint.id,params:[product:params.product])}"
           data-ajax-trigger='{"sprintMesure_sprint":"sprint", "unPlan_story":"stories"}'
           data-ajax-confirm="${message(code:'is.ui.releasePlan.menu.sprint.warning.dissociateAll').encodeAsJavaScript()}"
           data-ajax-notice="${message(code:'is.sprint.stories.dissociated').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.releasePlan.menu.sprint.dissociateAll'/>
        </a>
    </li>
</g:if>
<entry:point id="${controllerName}-${actionName}-sprintMenu" model="[sprint:sprint]"/>