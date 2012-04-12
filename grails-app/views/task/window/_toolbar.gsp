%{--
- Copyright (c) 2012 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<%@ page import="org.icescrum.core.domain.Task" %>

<g:set var="responsible" value="${task.responsible?.id == user.id}"/>
<g:set var="creator" value="${task.creator.id == user.id}"/>
<g:set var="taskDone" value="${task.state == Task.STATE_DONE}"/>
<g:set var="taskEditable" value="${(request.scrumMaster || responsible || creator) && !taskDone}"/>
<g:set var="taskDeletable" value="${(request.scrumMaster || responsible || creator)}"/>

<is:iconButton
        action="edit"
        controller="sprintPlan"
        rendered="${taskEditable}"
        id="${task.backlog.id}"
        subid="${task.id}"
        params="[product:params.product, referrerUrl:controllerName+'/'+task.id]"
        title="${message(code:'is.ui.backlogelement.toolbar.update')}"
        alt="${message(code:'is.ui.backlogelement.toolbar.update')}"
        update="window-content-${controllerName}">
    ${message(code: 'is.ui.backlogelement.toolbar.update')}
</is:iconButton>

<is:separatorSmall rendered="${taskEditable}"/>

<is:iconButton
        action="delete"
        controller="task"
        id="${task.id}"
        params="[product:params.product]"
        rendered="${taskDeletable}"
        title="${message(code:'is.ui.backlogelement.toolbar.delete')}"
        alt="${message(code:'is.ui.backlogelement.toolbar.delete')}"
        onSuccess="jQuery.icescrum.openWindow('sprintPlan');
          jQuery.icescrum.renderNotice('${message(code:'is.task.deleted').encodeAsJavaScript()}');"
        icon="delete">
    ${message(code: 'is.ui.backlogelement.toolbar.delete')}
</is:iconButton>

<is:separator rendered="${taskDeletable}"/>

<entry:point id="${controllerName}-${actionName}-toolbar"/>

<div class="navigation-right-toolbar">

    <g:if test="${previous}">
        <is:iconButton
                href="#${controllerName}/${previous.id}"
                title="${message(code:'is.ui.backlogelement.toolbar.previous')}"
                alt="${message(code:'is.ui.backlogelement.toolbar.previous')}">
            ${message(code: 'is.ui.backlogelement.toolbar.previous')}
        </is:iconButton>
    </g:if>

    <is:separatorSmall rendered="${previous != null && next != null}"/>

    <g:if test="${next}">
        <is:iconButton
                href="#${controllerName}/${next.id}"
                title="${message(code:'is.ui.backlogelement.toolbar.next')}"
                alt="${message(code:'is.ui.backlogelement.toolbar.next')}">
            ${message(code: 'is.ui.backlogelement.toolbar.next')}
        </is:iconButton>
    </g:if>

</div>