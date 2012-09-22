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
<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Task;org.icescrum.core.domain.Sprint;" %>

<g:set var="responsible" value="${task.responsible?.id == user.id}"/>
<g:set var="creator" value="${task.creator.id == user.id}"/>
<g:set var="taskDone" value="${task.state == Task.STATE_DONE}"/>

<g:set var="taskEditable" value="${(request.scrumMaster || responsible || creator) && !taskDone}"/>
<g:set var="taskDeletable" value="${(request.scrumMaster || responsible || creator)}"/>
<g:set var="taskBlockable" value="${(request.scrumMaster || responsible) && !taskDone && task.backlog?.state == Sprint.STATE_INPROGRESS}"/>
<g:set var="taskTakable" value="${!responsible && !taskDone}"/>
<g:set var="taskReleasable" value="${responsible && !taskDone}"/>
<g:set var="taskCopyable" value="${!task.parentStory || task.parentStory.state != Story.STATE_DONE}"/>

<li class="first">
    <a class="scrum-link" href="#task/${task.id}">
        <g:message code='is.ui.sprintPlan.menu.task.details'/>
    </a>
</li>
<g:if test="${taskTakable || template}">
<li id="menu-take-${task.id}">
    <a href="${createLink(action:'take',controller:'task',params:[product:params.product],id:task.id)}"
       data-ajax-trigger="update_task"
       data-ajax-notice="${message(code: 'is.task.taken').encodeAsJavaScript()}"
       data-ajax="true">
       <g:message code='is.ui.sprintPlan.menu.task.take'/>
    </a>
</li>
</g:if>
<g:if test="${taskReleasable || template}">
<li id="menu-unassign-${task.id}">
    <a href="${createLink(action:'unassign',controller:'task',params:[product:params.product],id:task.id)}"
       data-ajax-trigger="update_task"
       data-ajax-notice="${message(code: 'is.task.unassigned').encodeAsJavaScript()}"
       data-ajax="true">
       <g:message code='is.ui.sprintPlan.menu.task.unassign'/>
    </a>
</li>
</g:if>
<g:if test="${taskEditable || template}">
<li id="menu-edit-${task.id}">
    <a href="#sprintPlan/edit/${task.backlog.id}/?subid=${task.id}">
       <g:message code='is.ui.sprintPlan.menu.task.update'/>
    </a>
</li>
</g:if>
<g:if test="${taskCopyable || template}">
<li id="menu-copy-${task.id}">
    <a href="${createLink(action:'copy',controller:'task',params:[product:params.product],id:task.id)}"
       data-ajax-trigger="add_task"
       data-ajax-notice="${message(code: 'is.task.copied').encodeAsJavaScript()}"
       data-ajax="true">
       <g:message code='is.ui.sprintPlan.menu.task.copy'/>
    </a>
</li>
</g:if>
<g:if test="${taskDeletable || template}">
<li id="menu-delete-${task.id}">
    <a href="${createLink(action:'delete',controller:'task',params:[product:params.product],id:task.id)}"
       data-ajax-trigger="remove_task"
       data-ajax-notice="${message(code: 'is.task.deleted').encodeAsJavaScript()}"
       data-ajax="true">
       <g:message code='is.ui.sprintPlan.menu.task.delete'/>
    </a>
</li>
</g:if>
<g:if test="${taskBlockable || template}">
<li id="menu-blocked-${task.id}">
    <a href="${createLink(action:'block',controller:'task',params:[product:params.product],id:task.id)}"
       data-ajax-success="jQuery.icescrum.task.toggleBlocked"
       data-ajax="true">
       <g:message code="${task.blocked?message(code:'is.ui.sprintPlan.menu.task.unblock'):message(code:'is.ui.sprintPlan.menu.task.block')}"/>
    </a>
</li>
</g:if>
<entry:point id="${controllerName}-${actionName}-taskMenu" model="[task:task]"/>