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
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:if test="${sprint?.id}">

    <g:if test="${(request.teamMember || request.scrumMaster || request.productOwner) && sprint.state != Sprint.STATE_DONE}">

        %{--Add button--}%
        <li class="navigation-item button-ico button-add close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber}">
            <a class="tool-button button-n"
               href="#sprintPlan/add/${sprint.id}"
               data-shortcut="ctrl+n"
               data-shortcut-on="#window-id-${controllerName}"
               title="${message(code:'is.ui.sprintPlan.toolbar.alt.new')}"
               alt="${message(code:'is.ui.sprintPlan.toolbar.alt.new')}">
                    <span class="start"></span>
                    <span class="content">
                        <span class="ico"></span>
                        ${message(code: 'is.ui.sprintPlan.toolbar.new')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>

        %{--Delete button--}%
        <li class="navigation-item button-ico button-delete separator close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber}">
            <a class="tool-button button-n"
               onclick="jQuery.icescrum.selectableAction('task/delete',null,null,function(data){ jQuery.event.trigger('remove_task',[data]); jQuery.icescrum.renderNotice('${message(code:'is.task.deleted')}'); });"
               data-shortcut="del"
               data-shortcut-on="#window-id-${controllerName}"
               alt="${message(code:'is.ui.sprintPlan.toolbar.alt.delete')}"
               title="${message(code:'is.ui.sprintPlan.toolbar.alt.delete')}">
                <span class="start"></span>
                <span class="content">
                    <span class="ico"></span>
                    ${message(code: 'is.ui.sprintPlan.toolbar.delete')}
                </span>
                <span class="end"></span>
            </a>
        </li>

    </g:if>

    %{--View--}%
    <is:panelButton alt="View" id="menu-display" arrow="true" separator="${(request.teamMember || request.scrumMaster || request.productOwner) && sprint.state != Sprint.STATE_DONE}" icon="view">
        <ul>
            <li class="first">
                <a href="${createLink(action:'index',controller:controllerName,params:[product:params.product],id: sprint.id)}"
                   data-default-view="postitsView"
                   data-ajax-begin="$.icescrum.setDefaultView"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax="true">${message(code:'is.view.postitsView')}</a>
            </li>
            <li class="last">
                <a href="${createLink(action:'index',controller:controllerName,params:[product:params.product, viewType:'tableView'],id: sprint.id)}"
                   data-default-view="tableView"
                   data-ajax-begin="$.icescrum.setDefaultView"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax="true">${message(code:'is.view.tableView')}</a>
            </li>
        </ul>
    </is:panelButton>

    %{--Filter--}%
    <is:panelButton alt="Filter"
                    id="menu-filter-task"
                    arrow="true"
                    icon="filter"
                    separator="true"
                    classDropmenu="${currentFilter == 'allTasks' ? '' : 'filter-active'}"
                    text="${message(code:'is.ui.sprintPlan.toolbar.filter.'+currentFilter)}">
        <ul class="dropmenu-scrollable">
            <li class="first">
                <a href="${createLink(action:'changeFilterTasks', params:[filter:'allTasks', product:params.product], id:sprint.id)}"
                   data-ajax="true"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax-success="$.icescrum.updateFilterTask"
                   data-active="false"
                   data-filter="allTasks">
                    ${message(code:'is.ui.sprintPlan.toolbar.filter.allTasks')}
                </a>
            </li>
            <g:if test="${request.inProduct}">
                <li>
                    <a href="${createLink(action:'changeFilterTasks', params:[filter:'myTasks', product:params.product], id:sprint.id)}"
                       data-ajax="true"
                       data-ajax-update="#window-content-${controllerName}"
                       data-ajax-success="$.icescrum.updateFilterTask"
                       data-active="true"
                       data-filter="myTasks">
                        ${message(code:'is.ui.sprintPlan.toolbar.filter.myTasks')}
                    </a>
                </li>
            </g:if>
            <entry:point id="${controllerName}-${actionName}-filters" model="[sprint:sprint]"/>
            <li>
                <a href="${createLink(action:'changeFilterTasks', params:[filter:'freeTasks', product:params.product], id:sprint.id)}"
                   data-ajax="true"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax-success="$.icescrum.updateFilterTask"
                   data-active="true"
                   data-filter="freeTasks">
                    ${message(code:'is.ui.sprintPlan.toolbar.filter.freeTasks')}
                </a>
            </li>
            <li class="last">
                <a href="${createLink(action:'changeFilterTasks', params:[filter:'blockedTasks', product:params.product], id:sprint.id)}"
                   data-ajax="true"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax-success="$.icescrum.updateFilterTask"
                   data-active="true"
                   data-filter="blockedTasks">
                    ${message(code:'is.ui.sprintPlan.toolbar.filter.blockedTasks')}
                </a>
            </li>
        </ul>
    </is:panelButton>

    <g:if test="${request.scrumMaster || request.productOwner}">

        %{--Activate button--}%
        <li class="navigation-item separator  button-activate activate-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${(sprint.activable) ?'separator':'hidden'}">
            <a class="tool-button button-n"
               data-ajax="true"
               href="${createLink(action:'activate',controller:'releasePlan',params:[product:params.product],id:sprint.id)}"
               data-ajax-trigger='{"activate_sprint":"sprint","inProgress_story":"stories"}'
               data-ajax-notice="${message(code:'is.sprint.activated').encodeAsJavaScript()}"
               data-ajax-confirm="${message(code:'is.ui.sprintPlan.toolbar.activate.confirm').encodeAsJavaScript()}"
               data-shortcut="ctrl+shift+a"
               data-shortcut-on="#window-id-${controllerName}"
               alt="${message(code:'is.ui.sprintPlan.toolbar.alt.activate')}"
               title="${message(code:'is.ui.sprintPlan.toolbar.alt.activate')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.sprintPlan.toolbar.activate')}
                </span>
                <span class="end"></span>
            </a>
        </li>

        %{--Close button--}%
        <li class="navigation-item  button-close close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.state == Sprint.STATE_INPROGRESS ?'separator':'hidden'}">
            <a class="tool-button button-n"
               data-ajax="true"
               href="${createLink(action:'close',controller:'releasePlan',params:[product:params.product],id:sprint.id)}"
               data-ajax-trigger='{"close_sprint":"sprint","update_story":"stories"}'
               data-ajax-notice="${message(code:'is.sprint.closed').encodeAsJavaScript()}"
               data-ajax-confirm="${message(code:'is.ui.sprintPlan.toolbar.close.confirm').encodeAsJavaScript()}"
               data-shortcut="ctrl+shift+c"
               data-shortcut-on="#window-id-${controllerName}"
               alt="${message(code:'is.ui.sprintPlan.toolbar.alt.close')}"
               title="${message(code:'is.ui.sprintPlan.toolbar.alt.close')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.sprintPlan.toolbar.close')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>

    </g:if>

    <is:panelButton alt="documents" separator="true" id="menu-documents" arrow="true" icon="create" text="${message(code:'is.ui.toolbar.documents')}">
        <ul class="dropmenu-scrollable" id="sprint-attachments-${sprint.id}">
        %{-- doneDefinition --}%
            <li class="first">
                <a href="#${controllerName}/doneDefinition/${sprint.id}"
                   data-shortcut="ctrl+shift+d"
                   data-shortcut-on="#window-id-${controllerName}"
                   alt="${message(code:'is.ui.sprintPlan.toolbar.alt.doneDefinition')}"
                   title="${message(code:'is.ui.sprintPlan.toolbar.alt.doneDefinition')}">
                        <span class="start"></span>
                        <span class="content">
                            ${message(code: 'is.ui.sprintPlan.toolbar.doneDefinition')}
                        </span>
                        <span class="end"></span>
                </a>
            </li>

            %{-- retrospective --}%
            <li>
                <a href="#${controllerName}/retrospective/${sprint.id}"
                   data-shortcut="ctrl+shift+r"
                   data-shortcut-on="#window-id-${controllerName}"
                   alt="${message(code:'is.ui.sprintPlan.toolbar.alt.retrospective')}"
                   title="${message(code:'is.ui.sprintPlan.toolbar.alt.retrospective')}">
                        <span class="start"></span>
                        <span class="content">
                            ${message(code: 'is.ui.sprintPlan.toolbar.retrospective')}
                        </span>
                        <span class="end"></span>
                </a>
            </li>

            %{-- sprint notes --}%
            <li class="last">
                <a href="#${controllerName}/notes/${sprint.id}"
                   data-shortcut="ctrl+shift+o"
                   data-shortcut-on="#window-id-${controllerName}"
                   alt="${message(code:'is.ui.sprintPlan.toolbar.alt.notes')}"
                   title="${message(code:'is.ui.sprintPlan.toolbar.alt.notes')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.sprintPlan.toolbar.notes')}
                    </span>
                    <span class="end"></span>
                </a>
            </li>

            <g:if test="${request.inProduct}">
                <li>
                    <a href="${g.createLink(action:"addDocument", id: sprint.id, params: [product:params.product])}"
                       title="${message(code:'is.dialog.documents.manage.sprint')}"
                       alt="${message(code:'is.dialog.documents.manage.sprint')}"
                       data-ajax="true">
                        <span class="start"></span>
                        <span class="content">
                            <span class="ico"></span>
                            ${message(code: 'is.ui.toolbar.documents.add')}
                        </span>
                        <span class="end"></span>
                    </a>
                </li>
            </g:if>
            <g:each var="attachment" in="${sprint.attachments}">
                <g:render template="/attachment/line" model="[attachment: attachment, controllerName:'sprint']"/>
            </g:each>
        </ul>
    </is:panelButton>

    <is:panelButton alt="Charts" separator="true" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
        <ul>
            <li class="first">
                <a href="#${controllerName}/sprintBurndownRemainingChart/${sprint.id}">${message(code:'is.ui.sprintPlan.charts.sprintBurndownRemainingChart')}</a>
            </li>
            <li>
                <a href="#${controllerName}/sprintBurnupTasksChart/${sprint.id}">${message(code:'is.ui.sprintPlan.charts.sprintBurnupTasksChart')}</a>
            </li>
            <li>
                <a href="#${controllerName}/sprintBurnupStoriesChart/${sprint.id}">${message(code:'is.ui.sprintPlan.charts.sprintBurnupStoriesChart')}</a>
            </li>
            <entry:point id="${controllerName}-${actionName}-charts" model="[sprint:sprint]"/>
            <li class="last">
                <a href="#${controllerName}/sprintBurnupPointsChart/${sprint.id}">${message(code:'is.ui.sprintPlan.charts.sprintBurnupPointsChart')}</a>
            </li>
        </ul>
    </is:panelButton>

    <is:reportPanel
            separator="true"
            action="print"
            text="${message(code: 'is.ui.toolbar.print')}"
            formats="[
                      ['PDF', message(code:'is.report.format.pdf')],
                      ['RTF', message(code:'is.report.format.rtf')],
                      ['DOCX', message(code:'is.report.format.docx')],
                      ['ODT', message(code:'is.report.format.odt')]
                    ]"
            params="id=${sprint.id}&locationHash=${params.actionWindow?:''}"/>

    <is:reportPanel
            separator="true"
            action="printPostits"
            id="all"
            formats="[
                        ['PDF', message(code:'is.report.format.pdf')]
                    ]"
            text="${message(code: 'is.ui.sprintPlan.toolbar.print.stories')}"
            params="id=${sprint.id}"/>

</g:if>

<jq:jquery>
    jQuery.icescrum.sprint.currentTaskFilter = '${currentFilter}';
</jq:jquery>

<entry:point id="${controllerName}-${actionName}" model="[sprint:sprint]"/>  %{-- attention le sprint peut etre null --}%

<g:if test="${sprint?.id}">
%{--Search--}%
    <is:panelSearch id="search-ui">
        <is:autoCompleteSearch elementId="autoCmpTxt" controller="${controllerName}" action="index" id="${sprint.id}"
                               update="window-content-${controllerName}" withTags="true"/>
    </is:panelSearch>

    <is:onStream
            on="#sprint-attachments-${sprint?.id}"
            events="[[object:'attachments', events:['replaceAll']]]"
            template="toolbar"/>
</g:if>