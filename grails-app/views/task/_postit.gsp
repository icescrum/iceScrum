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
- Nicolas Noullet (nnoullet@kagilum.com)
- Jeroen Broekhuizen (Jeroen.Broekhuizen@quintiq.com)
--}%

<%@ page import="org.icescrum.core.domain.Sprint; org.icescrum.core.domain.Task" %>

<g:set var="responsible" value="${task.responsible?.id == user.id}"/>
<g:set var="creator" value="${task.creator.id == user.id}"/>
<g:set var="taskDone" value="${task.state == Task.STATE_DONE}"/>
<g:set var="sprintDone" value="${task.backlog?.state == Sprint.STATE_DONE}"/>

<g:set var="taskEditable" value="${(request.scrumMaster || responsible || creator) && !sprintDone && !taskDone}"/>
<g:set var="taskSortable" value="${request.scrumMaster || responsible || (assignOnBeginTask && task.state == Task.STATE_WAIT)}"/>

%{-- Task postit --}%
<is:postit title="${task.name}"
           id="${task.id}"
           miniId="${task.uid}"
           styleClass="task ${responsible ? 'hasResponsible' : ''}"
           type="task"
           sortable='[rendered:taskSortable, disabled:(sprintDone || taskDone)]'
           typeNumber="${task.blocked ? 1 : 0}"
           typeTitle="${task.blocked ? message(code:'is.task.blocked') : ''}"
           attachment="${task.totalAttachments}"
           menu="[id:'task-'+task.id,template:'/task/menu',params:[id:id, task:task, user:user], rendered:request.inProduct && !sprintDone]"
           stateText="${task.responsible?.firstName?.encodeAsHTML() ?: ''} ${task.responsible?.lastName?.encodeAsHTML() ?: ''}"
           miniValue="${task.estimation >= 0 ? task.estimation :'?'}"
           editableEstimation="${taskEditable}"
           color="${task.color}"
           rect="${rect ? rect : true}">
</is:postit>
<g:if test="${task.name?.length() > 17 || task.description?.length() > 0}">
    <div class="tooltip">
        <span class="tooltip-title">${task.name}</span>
        ${task.description?.encodeAsHTML() ?: ''}
    </div>
</g:if>