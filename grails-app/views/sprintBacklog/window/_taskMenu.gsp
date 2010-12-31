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
<%@ page import="org.icescrum.core.domain.Task;org.icescrum.core.domain.Sprint;" %>

<g:set var="poOrSm" value="${sec.access(expression:'productOwner() or scrumMaster()',{true})}"/>
<g:set var="scrumMaster" value="${sec.access(expression:'scrumMaster()',{true})}"/>

<is:postitMenuItem
        first="${task.state != Task.STATE_DONE}"
        rendered="${task.responsible?.id != user.id && task.state != Task.STATE_DONE}">
  <is:link id="${task.id}"
          action="take"
          controller="${id}"
          remote="true"
          update="window-content-${id}"
          history="false"
          value="${message(code:'is.ui.sprintBacklog.menu.task.take')}"/>
</is:postitMenuItem>
<is:postitMenuItem
        first="${task.responsible?.id == user.id}"
        rendered="${task.responsible?.id == user.id && task.state != Task.STATE_DONE}">
  <is:link id="${task.id}"
          action="unassign"
          controller="${id}"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.task.unassign')}"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem
        rendered="${(poOrSm || task.responsible?.id == user.id || task.creator?.id == user.id) && task.state != Task.STATE_DONE}">
  <is:link id="${task.id}"
          action="edit"
          controller="${id}"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.task.update')}"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem
        first="${scrumMaster && task.state == Task.STATE_DONE}"
        rendered="${((poOrSm || task.responsible?.id == user.id || task.creator?.id == user.id) && task.state != Task.STATE_DONE) || (scrumMaster && task.state == Task.STATE_DONE)}">
  <is:link id="${task.id}"
          action="delete"
          controller="${id}"
          remote="true"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.task.delete')}"/>
</is:postitMenuItem>
<is:postitMenuItem
        first="${!scrumMaster}" rendered="${task.state == Task.STATE_DONE}">
  <is:link id="${task.id}"
          action="cloneTask"
          controller="${id}"
          remote="true"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.task.recreate')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${(task.responsible?.id == user.id || scrumMaster) && task.state != Task.STATE_DONE && task.backlog.state == Sprint.STATE_INPROGRESS}">
  <is:link id="${task.id}"
          action="changeBlockedTask"
          controller="${id}"
          remote="true"
          history="false"
          onSuccess="if(jQuery('#postit-task-${task.id} .postit-ico').toggleClass('ico-task-1').hasClass('ico-task-1')){
                       jQuery('#dropmenu-postit-story-task-${task.id} ul li:last a, #dropmenu-story-task-${task.id} ul li:last a').text('${message(code:'is.ui.sprintBacklog.menu.task.unblock')}');
                       jQuery('#postit-task-${task.id} .postit-ico').attr('title','${message(code:'is.task.blocked')}');
                     }else{
                       jQuery('#dropmenu-postit-story-task-${task.id} ul li:last a, #dropmenu-story-task-${task.id} ul li:last a').text('${message(code:'is.ui.sprintBacklog.menu.task.block')}');
                       jQuery('#postit-task-${task.id} .postit-ico').attr('title','');
                     };"
          value="${task.blocked?message(code:'is.ui.sprintBacklog.menu.task.unblock'):message(code:'is.ui.sprintBacklog.menu.task.block')}"/>
</is:postitMenuItem>