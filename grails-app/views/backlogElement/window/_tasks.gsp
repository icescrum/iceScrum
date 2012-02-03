<%@ page import="org.icescrum.core.domain.Task" %>
%{--
- Copyright (c) 2011 Kagilum SAS.
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

<is:panelTab id="tasks" selected="${params.tab && 'tasks' in params.tab ? 'true' : ''}">
    <g:if test="${story.tasks}">
        <is:tableView>
            <is:cache cache="storyCache" key="story-tasks-${story.id}-${Task.findLastUpdated(story.id).list()[0]}">
                <is:table id="task-table">
                    <is:tableHeader name="${message(code:'is.task.name')}"/>
                    <is:tableHeader name="${message(code:'is.task.estimation')}"/>
                    <is:tableHeader name="${message(code:'is.task.creator')}"/>
                    <is:tableHeader name="${message(code:'is.task.responsible')}"/>
                    <is:tableHeader name="${message(code:'is.task.state')}"/>
                        <is:tableRows in="${story.tasks}" rowClass="${{task -> task.blocked?'ico-task-1':''}}" var="task">
                            <is:tableColumn>${task.name.encodeAsHTML()}</is:tableColumn>
                            <is:tableColumn>${task.estimation >= 0 ? task.estimation.round(2) : '?'}</is:tableColumn>
                            <is:tableColumn>${task.creator.firstName.encodeAsHTML()} ${task.creator.lastName.encodeAsHTML()}</is:tableColumn>
                            <is:tableColumn>${task.responsible?.firstName?.encodeAsHTML()} ${task.responsible?.lastName?.encodeAsHTML()}</is:tableColumn>
                            <is:tableColumn>${is.bundle(bundle: 'taskStates', value: task.state)}</is:tableColumn>
                        </is:tableRows>
                </is:table>
            </is:cache>
        </is:tableView>
    </g:if>
    <g:else><div
            class="panel-box-empty">${message(code: 'is.ui.backlogelement.activity.task.no')}</div></g:else>
</is:panelTab>