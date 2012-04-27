<%@ page import="grails.converters.JSON; org.icescrum.core.domain.Sprint; org.icescrum.core.domain.Task" %>
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
<is:tableView>

    <g:set var="timezone" value="${sprint.parentRelease.parentProduct.preferences.timezone}"/>

    <is:table id="tasks-table">

        <is:tableHeader width="5%" class="table-cell-checkbox">
            <g:checkBox name="checkbox-header"/>
        </is:tableHeader>
        <is:tableHeader width="14%" name="${message(code:'is.task.name')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.task.state')}"/>
        <is:tableHeader width="8%" name="${message(code:'is.task.estimation')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.backlogelement.description')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.backlogelement.notes')}"/>
        <is:tableHeader width="8%" name="${message(code:'is.task.responsible')}"/>
        <is:tableHeader width="7%" name="${message(code:'is.task.date.inprogress')}"/>
        <is:tableHeader width="7%" name="${message(code:'is.task.date.done')}"/>

    %{-- Table group for recurrent tasks --}%
        <is:tableGroup
                elementId="recurrent"
                rendered="${displayRecurrentTasks}"
                editable="[controller:controllerName,action:'updateTable',params:[product:params.product],onExitCell:'submit']">
            <is:tableGroupHeader>
                <is:menu rendered="${request.inProduct && sprint.state != Sprint.STATE_DONE}" yoffset="4"
                         class="dropmenu-action" id="menu-recurrent" contentView="window/recurrentOrUrgentTask"
                         params="[sprint:sprint,previousSprintExist:previousSprintExist,type:'recurrent']"/>
                <strong>${message(code: 'is.ui.sprintPlan.kanban.recurrentTasks')}</strong>
            </is:tableGroupHeader>
            <is:tableRows in="${recurrentTasks?.sort{it.rank}}" rowClass="${{task -> task.blocked?'ico-task-1':''}}"
                          var="task" elemid="id">

                <g:set var="responsible" value="${task.responsible?.id == user.id}"/>
                <g:set var="creator" value="${task.creator?.id == user.id}"/>
                <g:set var="taskDone" value="${task.state == Task.STATE_DONE}"/>
                <g:set var="sprintDone" value="${sprint?.state == Sprint.STATE_DONE}"/>
                <g:set var="sprintInProgress" value="${sprint?.state == Sprint.STATE_DONE}"/>

                <g:set var="taskEditable" value="${(request.scrumMaster || responsible || creator) && !sprintDone && !taskDone}"/>
                <g:set var="taskSortable" value="${(request.scrumMaster || responsible) && sprintInProgress && !taskDone}"/>

                <is:tableColumn class="table-cell-checkbox">
                    <g:checkBox name="check-${task.id}"/>
                    <is:menu rendered="${request.inProduct && sprint.state != Sprint.STATE_DONE}" yoffset="4"
                             class="dropmenu-action" id="story-task-${task.id}" contentView="/task/menu" params="[task:task, story:story, user:user]"/>
                    <g:set var="attachment" value="${task.totalAttachments}"/>
                    <g:if test="${attachment}">
                        <span class="table-attachment"
                              title="${message(code: 'is.postit.attachment', args: [attachment, attachment > 1 ? 's' : ''])}"></span>
                    </g:if>
                </is:tableColumn>

                <is:tableColumn
                        editable="[type:'text', disabled:!taskEditable,name:'name']">${task.name.encodeAsHTML()}</is:tableColumn>
                <is:tableColumn
                        editable="[type:'selectui',id:'state',disabled:!taskSortable,name:'state',values:stateSelect]"><is:bundle
                        bundle="taskStates" value="${task.state}"/></is:tableColumn>
                <is:tableColumn
                        editable="[type:'text',disabled:!taskEditable,name:'estimation']">${task.estimation >= 0 ? task.estimation : '?'}</is:tableColumn>
                <is:tableColumn
                        editable="[type:'textarea',disabled:!taskEditable,name:'description']">${task.description?.encodeAsHTML()?.encodeAsNL2BR()}</is:tableColumn>
                <is:tableColumn
                        editable="[type:'richarea',disabled:!taskEditable,name:'notes']">${task.notes}</is:tableColumn>

                <is:tableColumn>${task.responsible?.firstName?.encodeAsHTML()} ${task.responsible?.lastName?.encodeAsHTML()}</is:tableColumn>
                <is:tableColumn>${task.inProgressDate ? g.formatDate(formatName: 'is.date.format.short', date: task.inProgressDate, timezone: timezone) : ''}</is:tableColumn>
                <is:tableColumn>${task.doneDate ? g.formatDate(formatName: 'is.date.format.short', date: task.doneDate, timezone: timezone) : ''}</is:tableColumn>
            </is:tableRows>
        </is:tableGroup>

    %{-- Table group for urgent tasks --}%
        <is:tableGroup
                elementId="urgent"
                rendered="${displayUrgentTasks}"
                editable="[controller:controllerName,action:'updateTable',params:[product:params.product],onExitCell:'submit']">
            <is:tableGroupHeader>
                <is:menu rendered="${request.inProduct && sprint.state != Sprint.STATE_DONE}" yoffset="4"
                         class="dropmenu-action" id="menu-urgent" contentView="window/recurrentOrUrgentTask"
                         params="[sprint:sprint,type:'urgent']"/>
                <strong>${message(code: 'is.ui.sprintPlan.kanban.urgentTasks')}</strong>
            </is:tableGroupHeader>
            <is:tableRows in="${urgentTasks?.sort{it.rank}}" rowClass="${{task -> task.blocked?'ico-task-1':''}}"
                          var="task" elemid="id">

                <g:set var="responsible" value="${task.responsible?.id == user.id}"/>
                <g:set var="creator" value="${task.creator?.id == user.id}"/>
                <g:set var="taskDone" value="${task.state == Task.STATE_DONE}"/>
                <g:set var="sprintDone" value="${sprint?.state == Sprint.STATE_DONE}"/>
                <g:set var="sprintInProgress" value="${sprint?.state == Sprint.STATE_DONE}"/>

                <g:set var="taskEditable" value="${(request.scrumMaster || responsible || creator) && !sprintDone && !taskDone}"/>
                <g:set var="taskSortable" value="${(request.scrumMaster || responsible) && sprintInProgress && !taskDone}"/>

                <is:tableColumn class="table-cell-checkbox">
                    <g:checkBox name="check-${task.id}"/>
                    <is:menu rendered="${request.inProduct && sprint.state != Sprint.STATE_DONE}" yoffset="4"
                             class="dropmenu-action" id="story-task-${task.id}" contentView="/task/menu"
                             params="[task:task, story:story, user:user]"/>
                    <g:set var="attachment" value="${task.totalAttachments}"/>
                    <g:if test="${attachment}">
                        <span class="table-attachment"
                              title="${message(code: 'is.postit.attachment', args: [attachment, attachment > 1 ? 's' : ''])}"></span>
                    </g:if>
                </is:tableColumn>

                <is:tableColumn
                        editable="[type:'text', disabled:!taskEditable,name:'name']">${task.name.encodeAsHTML()}</is:tableColumn>
                <is:tableColumn
                        editable="[type:'selectui',id:'state',disabled:!taskSortable,name:'state',values:stateSelect]"><is:bundle
                        bundle="taskStates" value="${task.state}"/></is:tableColumn>
                <is:tableColumn
                        editable="[type:'text',disabled:!taskEditable,name:'estimation']">${task.estimation >= 0 ? task.estimation : '?'}</is:tableColumn>
                <is:tableColumn
                        editable="[type:'textarea',disabled:!taskEditable,name:'description']">${task.description?.encodeAsHTML()?.encodeAsNL2BR()}</is:tableColumn>
                <is:tableColumn
                        editable="[type:'richarea',disabled:!taskEditable,name:'notes']">${task.notes}</is:tableColumn>

                <is:tableColumn>${task.responsible?.firstName?.encodeAsHTML()} ${task.responsible?.lastName?.encodeAsHTML()}</is:tableColumn>
                <is:tableColumn>${task.inProgressDate ? g.formatDate(formatName: 'is.date.format.short', date: task.inProgressDate) : ''}</is:tableColumn>
                <is:tableColumn>${task.doneDate ? g.formatDate(formatName: 'is.date.format.short', date: task.doneDate) : ''}</is:tableColumn>
            </is:tableRows>
        </is:tableGroup>

    %{-- Table group for stories --}%
        <g:each in="${stories.sort{it.rank}}" var="story">
            <is:tableGroup
                    elementId="${story.id}"
                    editable="[controller:controllerName,action:'updateTable',params:[product:params.product],onExitCell:'submit']">
                <is:tableGroupHeader>
                    <is:menu rendered="${request.inProduct}" yoffset="4" class="dropmenu-action" id="${story.id}"
                             contentView="/story/menu" params="[story:story,nextSprintExist:nextSprintExist]"/>
                    <is:scrumLink id="${story.id}" controller="story">
                        ${story.uid}
                    </is:scrumLink> -
                    <is:postitIcon name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}"/>
                    <strong>${story.name.encodeAsHTML()} - ${story.effort} - ${is.bundle(bundle: 'storyStates', value: story.state)}</strong>
                </is:tableGroupHeader>
                <is:tableRows in="${story.tasks.sort{it.rank}}" rowClass="${{task -> task.blocked?'ico-task-1':''}}"
                              var="task" elemid="id">

                    <g:set var="responsible" value="${task.responsible?.id == user.id}"/>
                    <g:set var="creator" value="${task.creator?.id == user.id}"/>
                    <g:set var="taskDone" value="${task.state == Task.STATE_DONE}"/>
                    <g:set var="sprintDone" value="${sprint?.state == Sprint.STATE_DONE}"/>
                    <g:set var="sprintInProgress" value="${sprint?.state == Sprint.STATE_DONE}"/>

                    <g:set var="taskEditable" value="${(request.scrumMaster || responsible || creator) && !sprintDone && !taskDone}"/>
                    <g:set var="taskSortable" value="${(request.scrumMaster || responsible) && sprintInProgress && !taskDone}"/>

                    <is:tableColumn class="table-cell-checkbox">
                        <g:checkBox name="check-${task.id}"/>
                        <is:menu rendered="${request.inProduct && sprint.state != Sprint.STATE_DONE}" yoffset="4"
                                 class="dropmenu-action" id="story-task-${task.id}" contentView="/task/menu"
                                 params="[task:task, story:story, user:user]"/>
                        <g:set var="attachment" value="${task.totalAttachments}"/>
                        <g:if test="${attachment}">
                            <span class="table-attachment"
                                  title="${message(code: 'is.postit.attachment', args: [attachment, attachment > 1 ? 's' : ''])}"></span>
                        </g:if>
                    </is:tableColumn>

                    <is:tableColumn
                            editable="[type:'text', disabled:!taskEditable,name:'name']">${task.name.encodeAsHTML()}</is:tableColumn>
                    <is:tableColumn
                            editable="[type:'selectui',id:'state',disabled:!taskSortable,name:'state',values:stateSelect]"><is:bundle
                            bundle="taskStates" value="${task.state}"/></is:tableColumn>
                    <is:tableColumn
                            editable="[type:'text',disabled:!taskEditable,name:'estimation']">${task.estimation >= 0 ? task.estimation : '?'}</is:tableColumn>
                    <is:tableColumn
                            editable="[type:'textarea',disabled:!taskEditable,name:'description']">${task.description?.encodeAsHTML()?.encodeAsNL2BR()}</is:tableColumn>
                    <is:tableColumn
                            editable="[type:'richarea',disabled:!taskEditable,name:'notes']">${task.notes}</is:tableColumn>

                    <is:tableColumn>${task.responsible?.firstName?.encodeAsHTML()} ${task.responsible?.lastName?.encodeAsHTML()}</is:tableColumn>
                    <is:tableColumn>${task.inProgressDate ? g.formatDate(formatName: 'is.date.format.short', date: task.inProgressDate) : ''}</is:tableColumn>
                    <is:tableColumn>${task.doneDate ? g.formatDate(formatName: 'is.date.format.short', date: task.doneDate) : ''}</is:tableColumn>
                </is:tableRows>
            </is:tableGroup>

        </g:each>

    </is:table>
</is:tableView>
<jq:jquery>
    jQuery.icescrum.sprint.updateWindowTitle(${[id:sprint.id,orderNumber:sprint.orderNumber,totalRemainingHours:sprint.totalRemainingHours,state:sprint.state,startDate:sprint.startDate,endDate:sprint.endDate] as JSON});
</jq:jquery>