%{--
- Copyright (c) 2011 Kagilum.
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

<%@ page import="org.icescrum.core.domain.Sprint; org.icescrum.core.domain.Task" %>
<g:set var="scrumMaster" value="${sec.access([expression:'scrumMaster()'], {true})}"/>
<g:set var="inProduct" value="${sec.access(expression:'inProduct()',{true})}"/>
<g:set var="responsible" value="${task.responsible?.id == user.id}"/>
<g:set var="creator" value="${task.creator.id == user.id}"/>

%{-- Task postit --}%
<is:postit title="${task.name}"
           id="${task.id}"
           miniId="${task.id}"
           styleClass="task"
           type="task"
           sortable='[rendered:(scrumMaster || responsible),disabled:task.state == Task.STATE_DONE]'
           typeNumber="${task.blocked ? 1 : 0}"
           typeTitle="${task.blocked ? message(code:'is.task.blocked') : ''}"
           attachment="${task.totalAttachments}"
           stateText="${task.responsible?.firstName?.encodeAsHTML() ?: ''} ${task.responsible?.lastName?.encodeAsHTML() ?: ''}"
           miniValue="${task.estimation >= 0 ? task.estimation :'?'}"
           editableEstimation="${(responsible || (!responsible && creator) || scrumMaster) && task.state != Task.STATE_DONE}"
           color="yellow"
           cacheKey="${task.lastUpdated}${responsible}${creator}"
           rect="true">
    <g:if test="${inProduct}">
        <is:postitMenu id="task-${task.id}"
                       contentView="/task/menu"
                       model="[id:id, task:task, user:user]"
                       rendered="${task.backlog.state != Sprint.STATE_DONE}"/>
    </g:if>
</is:postit>
<g:if test="${task.name?.length() > 17 || task.description?.length() > 0}">
    <is:tooltipPostit
            type="task"
            id="${task.id}"
            title="${task.name?.encodeAsHTML()}"
            text="${task.description?.encodeAsHTML()}"
            apiBeforeShow="if(jQuery('#dropmenu').is(':visible')){return false;}"
            container="jQuery('#window-content-${id}')"/>
</g:if>