<%@ page import="org.icescrum.core.domain.Sprint" %>
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

<li class="first">
    <a href="#sprintPlan/add/${sprint.id}/?story.id=${type}"
       alt="${message(code:'is.ui.sprintPlan.kanban.recurrentTasks.add')}">
        ${message(code: 'is.ui.sprintPlan.kanban.recurrentTasks.add')}
    </a>
</li>
<g:if test="${previousSprintExist && type == 'recurrent'}">
<li>
    <a href="${createLink(controller:controllerName,action:'copyRecurrentTasksFromPreviousSprint', id:sprint.id, params:[product:params.product])}"
       data-ajax="true"
       data-ajax-trigger="add_task"
       data-ajax-notice="${message(code: 'is.sprint.copyRecurrentTasks.copied').encodeAsJavaScript()}">
        ${message(code: 'is.ui.sprintPlan.kanban.copyRecurrentTasks')}
    </a>
</li>
</g:if>
<entry:point id="${controllerName}-${actionName}-recurrentOrUrgentTask" model="[sprint:sprint,type:type]"/>