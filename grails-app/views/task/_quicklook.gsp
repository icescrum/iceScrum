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
<div class="postit-details quicklook" elemid="${task.id}" type="task">
    <div class="colset-2 clearfix">
        <div class="col1 postit-details-information">
            <p>
                <strong><g:message code="is.backlogelement.id"/></strong> ${task.id}
            </p>

            <p>
                <strong><g:message
                        code="is.backlogelement.description"/> :</strong> ${task.description?.encodeAsHTML()?.encodeAsNL2BR()}
            </p>

            <div class="line">
                <strong><g:message code="is.backlogelement.notes"/> :</strong>

                <div class="content rich-content">
                    <wikitext:renderHtml markup="Textile">${task.notes}</wikitext:renderHtml>
                </div>
            </div>

            <p>
                <strong><g:message
                        code="is.task.state"/> :</strong> ${is.bundle(bundle: 'taskStates', value: task.state)}
            </p>

            <p>
                <strong><g:message code="is.backlogelement.creationDate"/> :</strong>
                <g:formatDate date="${task.creationDate}" formatName="is.date.format.short.time"
                              timeZone="${user?.preferences?.timezone?:null}"/>
            </p>
            <g:if test="${task.state >= Task.STATE_BUSY}">
                <p>
                    <strong><g:message code="is.task.date.inprogress"/> :</strong>
                    <g:formatDate date="${task.inProgressDate}" formatName="is.date.format.short.time"
                                  timeZone="${user?.preferences?.timezone?:null}"/>
                </p>
            </g:if>
            <g:if test="${task.state == Task.STATE_DONE}">
                <p>
                    <strong><g:message code="is.task.date.done"/> :</strong>
                    <g:formatDate date="${task.doneDate}" formatName="is.date.format.short.time"
                                  timeZone="${user?.preferences?.timezone?:null}"/>
                </p>
            </g:if>
            <p class="${task.responsible ?: 'last'}">
                <strong><g:message code="is.task.creator"/> :</strong> <is:scrumLink controller="user" action='profile'
                                                                                     onclick="\$('#dialog').dialog('close');"
                                                                                     id="${task.creator.username}">${task.creator.firstName.encodeAsHTML()} ${task.creator.lastName.encodeAsHTML()}</is:scrumLink>
            </p>
            <g:if test="${task.responsible}">
                <p class="last">
                    <strong><g:message code="is.task.responsible"/> :</strong> <is:scrumLink controller="user"
                                                                                             action='profile'
                                                                                             onclick="\$('#dialog').dialog('close');"
                                                                                             id="${task.responsible.username}">${task.responsible.firstName.encodeAsHTML()} ${task.responsible.lastName.encodeAsHTML()}</is:scrumLink>
                </p>
            </g:if>
            <entry:point id="quicklook-task-left" model="[task:task]"/>
        </div>

        <div class="col2">
            <is:postit title="${task.name}"
                       id="${task.id}"
                       miniId="${task.id}"
                       rect="true"
                       styleClass="story task ui-selectable-disabled"
                       type="task"
                       typeNumber="${task.blocked ? 1 : 0}"
                       typeTitle="${task.blocked ? message(code:'is.task.blocked') : ''}"
                       color="yellow"
                       stateText="${task.responsible?.firstName?.encodeAsHTML() ?: ''} ${task.responsible?.lastName?.encodeAsHTML() ?: ''}"
                       miniValue="${task.estimation ?: task.estimation == 0?'0':'?'}">
            </is:postit>
            <g:if test="${task.totalAttachments}">
                <div>
                    <strong>${message(code: 'is.postit.attachment', args: [task.totalAttachments, task.totalAttachments > 1 ? 's' : ''])} :</strong>
                    <is:attachedFiles bean="${task}" width="120" deletable="${false}" action="download"
                                      params="[product:params.product]" controller="sprintPlan" size="20"/>
                </div>
            </g:if>
            <entry:point id="quicklook-task-right" model="[task:task]"/>
        </div>
    </div>
</div>