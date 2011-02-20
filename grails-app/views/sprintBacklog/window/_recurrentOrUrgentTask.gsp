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
- Vincent Barrier (vincent.barrier@icescrum.com)
--}%

<is:postitMenuItem first="true">
  <is:link
      action="add"
      id="${sprint.id}"
      controller="${id}"
      params="['story.id':type]"
      remote="true"
      alt="${message(code:'is.ui.sprintBacklog.kanban.recurrentTasks.add')}"
      update="window-content-${id}">
    ${message(code: 'is.ui.sprintBacklog.kanban.recurrentTasks.add')}
  </is:link>
</is:postitMenuItem>
<is:postitMenuItem rendered="${previousSprintExist && type == 'recurrent'}">
  <is:link
      action="copyRecurrentTasksFromPreviousSprint"
      id="${sprint.id}"
      controller="${id}"
      remote="true"
      history="false"
      alt="${message(code:'is.ui.sprintBacklog.kanban.copyRecurrentTasks')}"
      update="window-content-${id}">
    ${message(code: 'is.ui.sprintBacklog.kanban.copyRecurrentTasks')}
  </is:link>
</is:postitMenuItem>
<entry:point id="${id}-${actionName}-recurrentOrUrgentTask" model="[sprint:sprint,type:type]"/>