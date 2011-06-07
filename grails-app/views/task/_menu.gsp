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
<%@ page import="org.icescrum.core.domain.Task;org.icescrum.core.domain.Sprint;" %>
<g:set var="poOrSm" value="${sec.access(expression:'productOwner() or scrumMaster()',{true})}"/>
<g:set var="scrumMaster" value="${sec.access(expression:'scrumMaster()',{true})}"/>
<g:set var="creator" value="${task.creator.id == user.id}"/>
<g:set var="responsible" value="${task.responsible?.id == user.id}"/>

<is:postitMenuItem first="${!responsible}" rendered="${(!responsible && task.state != Task.STATE_DONE) || template}"
                   elementId="menu-take-${task.id}">
    <is:link id="${task.id}"
             action="take"
             controller="task"
             remote="true"
             onSuccess="jQuery.event.trigger('update_task',data); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.taken')}')"
             history="false"
             value="${message(code:'is.ui.sprintPlan.menu.task.take')}"/>
</is:postitMenuItem>
<is:postitMenuItem
        first="${responsible}"
        rendered="${(responsible && task.state != Task.STATE_DONE) || template}" elementId="menu-unassign-${task.id}">
    <is:link id="${task.id}"
             action="unassign"
             controller="task"
             history="false"
             onSuccess="jQuery.event.trigger('update_task',data); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.unassigned')}')"
             value="${message(code:'is.ui.sprintPlan.menu.task.unassign')}"
             remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem
        rendered="${((poOrSm || responsible || creator) && task.state != Task.STATE_DONE) || template}"
        elementId="menu-edit-${task.id}">
    <is:link id="${task.backlog?.id}"
             action="edit"
             subid="${task.id}"
             params="[subid:task.id]"
             controller="sprintPlan"
             update="window-content-${id}"
             value="${message(code:'is.ui.sprintPlan.menu.task.update')}"
             remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem first="${task.state == Task.STATE_DONE}" elementId="menu-copy-${task.id}">
    <is:link id="${task.id}"
             action="copy"
             controller="task"
             remote="true"
             history="false"
             onSuccess="jQuery.event.trigger('add_task',data); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.copied')}')"
             value="${message(code:'is.ui.sprintPlan.menu.task.copy')}"/>
</is:postitMenuItem>
<is:postitMenuItem
        rendered="${((poOrSm || creator || responsible) && task.state != Task.STATE_DONE) || (scrumMaster && task.state == Task.STATE_DONE) || template}"
        elementId="menu-delete-${task.id}">
    <is:link id="${task.id}"
             action="delete"
             controller="task"
             remote="true"
             history="false"
             onSuccess="jQuery.event.trigger('remove_task',data); jQuery.icescrum.renderNotice('${g.message(code: 'is.task.deleted')}')"
             value="${message(code:'is.ui.sprintPlan.menu.task.delete')}"/>
</is:postitMenuItem>
<is:postitMenuItem
        rendered="${((responsible || scrumMaster) && task.state != Task.STATE_DONE && task.backlog?.state == Sprint.STATE_INPROGRESS) || template}"
        elementId="menu-blocked-${task.id}">
    <is:link id="${task.id}"
             action="changeBlockState"
             controller="task"
             remote="true"
             history="false"
             onSuccess="jQuery.icescrum.task.toggleBlocked('${task.id}');"
             value="${task.blocked?message(code:'is.ui.sprintPlan.menu.task.unblock'):message(code:'is.ui.sprintPlan.menu.task.block')}"/>
</is:postitMenuItem>
<entry:point id="${id}-${actionName}-taskMenu" model="[task:task]"/>