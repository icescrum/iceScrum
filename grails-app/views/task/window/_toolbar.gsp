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

<g:if test="${taskEditable}">
    <li class="navigation-item">
        <a class="tool-button button-n"
           href="#sprintPlan/${task.backlog.id}/edit/${task.id}"
           title="${message(code:'is.ui.backlogelement.toolbar.update')}"
           alt="${message(code:'is.ui.backlogelement.toolbar.update')}">
                <span class="start"></span>
                <span class="content">
                ${message(code: 'is.ui.backlogelement.toolbar.update')}
                </span>
                <span class="end"></span>
        </a>
    </li>
    <li class="navigation-item separator-s"></li>
</g:if>
<g:if test="${taskDeletable}">
    <li class="navigation-item">
        <a class="tool-button button-n"
           href="${createLink(controller:'task', action:'delete',id:task.id,params:[product:params.product])}"
           data-ajax-notice="${message(code:'is.task.deleted').encodeAsJavaScript()}"
           data-ajax-trigger="remove_task"
           data-ajax-success="#sprintPlan"
           data-ajax="true"
           title="${message(code:'is.ui.backlogelement.toolbar.delete')}"
           alt="${message(code:'is.ui.backlogelement.toolbar.delete')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.backlogelement.toolbar.delete')}
                </span>
                <span class="end"></span>
        </a>
    </li>
</g:if>

<entry:point id="${controllerName}-${actionName}-toolbar"/>

<div class="navigation-right-toolbar">

    <g:if test="${previous}">
        <li class="navigation-item">
            <a class="tool-button button-n"
               href="#${controllerName}/${previous.id}"
               title="${message(code:'is.ui.backlogelement.toolbar.previous')}"
               alt="${message(code:'is.ui.backlogelement.toolbar.previous')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.backlogelement.toolbar.previous')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>
    </g:if>

    <g:if test="${next && previous}">
        <li class="navigation-item separator-s"></li>
    </g:if>

    <g:if test="${next}">
        <li class="navigation-item">
            <a class="tool-button button-n"
               href="#${controllerName}/${next.id}"
               title="${message(code:'is.ui.backlogelement.toolbar.next')}"
               alt="${message(code:'is.ui.backlogelement.toolbar.next')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.backlogelement.toolbar.next')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>
    </g:if>

</div>