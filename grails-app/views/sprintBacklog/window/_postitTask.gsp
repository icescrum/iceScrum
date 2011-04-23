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

<%@ page import="org.icescrum.core.domain.Task" %>
%{-- Task postit --}%
<is:postit title="${task.name.encodeAsHTML()}"
        id="${task.id}" miniId="${task.id}" styleClass="story task${task.state == Task.STATE_DONE ? ' ui-selectable-disabled':''}"
        type="task"
        stateText="${task.responsible?.firstName?.encodeAsHTML() ?: ''} ${task.responsible?.lastName?.encodeAsHTML() ?: ''}"
        miniValue="${task.estimation ?: task.estimation == 0?'0':'?'}"
        color="yellow"
        rect="true"
        maximizable="true">
  <sec:access expression="productOwner() or scrumMaster() or teamMember()">
    <g:if test="${task.state != Task.STATE_DONE}">
      <is:postitMenu id="urgent-task-${task.id}" contentView="window/taskMenu" params="[id:id, task:task, story:story, user:user]" />
    </g:if>
  </sec:access>
</is:postit>