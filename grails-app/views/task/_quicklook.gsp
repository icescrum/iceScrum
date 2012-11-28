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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="org.icescrum.core.domain.Task" %>
<is:dialog width="600"
           resizable="false"
           draggable="false"
           withTitlebar="false"
           buttons="'${message(code: 'is.button.close')}': function() { \$(this).dialog('close'); }"
           focusable="${false}">
<div class="postit-details postit-details-task quicklook" data-elemid="${task.id}" type="task">
    <div class="colset-2 clearfix">
        <div class="col1 postit-details-information">
            <p>
                <strong><g:message code="is.backlogelement.id"/></strong>
                <is:scrumLink onclick="jQuery('#dialog').dialog('close');" controller="task"
                              id="${task.id}">${task.uid}</is:scrumLink>
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
                              timeZone="${task.backlog.parentRelease.parentProduct.preferences.timezone}"/>
            </p>
            <g:if test="${task.state >= Task.STATE_BUSY}">
                <p>
                    <strong><g:message code="is.task.date.inprogress"/> :</strong>
                    <g:formatDate date="${task.inProgressDate}" formatName="is.date.format.short.time"
                                  timeZone="${task.backlog.parentRelease.parentProduct.preferences.timezone}"/>
                </p>
            </g:if>
            <g:if test="${task.state == Task.STATE_DONE}">
                <p>
                    <strong><g:message code="is.task.date.done"/> :</strong>
                    <g:formatDate date="${task.doneDate}" formatName="is.date.format.short.time"
                                  timeZone="${task.backlog.parentRelease.parentProduct.preferences.timezone}"/>
                </p>
            </g:if>
            <p>
                <strong><g:message code="is.task.creator"/> :</strong> <is:scrumLink controller="user" action='profile'
                                                                                     onclick="\$('#dialog').dialog('close');"
                                                                                     id="${task.creator.username}">${task.creator.firstName.encodeAsHTML()} ${task.creator.lastName.encodeAsHTML()}</is:scrumLink>
            </p>
            <g:if test="${task.responsible}">
                <p>
                    <strong><g:message code="is.task.responsible"/> :</strong> <is:scrumLink controller="user"
                                                                                             action='profile'
                                                                                             onclick="\$('#dialog').dialog('close');"
                                                                                             id="${task.responsible.username}">${task.responsible.firstName.encodeAsHTML()} ${task.responsible.lastName.encodeAsHTML()}</is:scrumLink>
                </p>
            </g:if>
            <g:if test="${task.tags}">
                <div class="line last">
                    <strong><g:message code="is.backlogelement.tags"/> :</strong>&nbsp;<g:each var="tag" status="i"
                                                                                               in="${task.tags}"> <a href="#finder?tag=${tag}">${tag}</a>${i < task.tags.size() - 1 ? ', ' : ''}</g:each>
                </div>
            </g:if>
            <entry:point id="quicklook-task-left" model="[task: task]"/>
        </div>

        <div class="col2">
            <is:postit title="${task.name}"
                       id="${task.id}"
                       miniId="${task.uid}"
                       rect="true"
                       styleClass="story task ui-selectable-disabled"
                       type="task"
                       typeNumber="${task.blocked ? 1 : 0}"
                       typeTitle="${task.blocked ? message(code: 'is.task.blocked') : ''}"
                       color="${task.color}"
                       stateText="${task.responsible?.firstName?.encodeAsHTML() ?: ''} ${task.responsible?.lastName?.encodeAsHTML() ?: ''}"
                       miniValue="${task.estimation ?: task.estimation == 0? '0' : '?'}">
            </is:postit>
            <g:if test="${task.totalAttachments}">
                <div>
                    <strong>${message(code: 'is.postit.attachment', args: [task.totalAttachments, task.totalAttachments > 1 ? 's' : ''])} :</strong>
                    <is:attachedFiles bean="${task}" width="120" deletable="${false}" action="download"
                                      params="[product: params.product]" controller="task" size="20"/>
                </div>
            </g:if>
            <entry:point id="quicklook-task-right" model="[task: task]"/>
        </div>
    </div>
</div>
</is:dialog>
<is:onStream
        on=".postit-details-task[data-elemid=${task.id}]"
        events="[[object: 'task', events: ['update']]]"
        constraint="task.id == ${task.id}"
        callback="\$.icescrum.displayQuicklook(\$('#dialog .postit-task'));"/>
<is:onStream
        on=".postit-details-task[data-elemid=${task.id}]"
        events="[[object: 'task', events: ['remove']]]"
        constraint="task.id == ${task.id}"
        callback="alert('${message(code: 'is.task.deleted')}'); jQuery('#dialog').dialog('close');"/>