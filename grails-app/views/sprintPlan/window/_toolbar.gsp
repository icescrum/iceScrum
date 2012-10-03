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
--}%
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:if test="${sprint?.id}">

    <g:if test="${(request.teamMember || request.scrumMaster || request.productOwner) && sprint.state != Sprint.STATE_DONE}">

        %{--Add button--}%
        <li class="navigation-item button-ico button-create close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber}">
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

        <li class="navigation-item separator close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber}"></li>

        %{--Delete button--}%
        <li class="navigation-item button-ico button-delete close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber}">
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

        <li class="navigation-item separator close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber}"></li>

    </g:if>

    %{--View--}%
    <is:panelButton alt="View" id="menu-display" arrow="true" icon="view">
        <ul>
            <li class="first">
                <a href="${createLink(action:'index',controller:controllerName,params:[product:params.product])}"
                   data-default-view="postitsView"
                   data-ajax-begin="$.icescrum.setDefaultView"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax="true">${message(code:'is.view.postitsView')}</a>
            </li>
            <li class="last">
                <a href="${createLink(action:'index',controller:controllerName,params:[product:params.product, viewType:'tableView'])}"
                   data-default-view="tableView"
                   data-ajax-begin="$.icescrum.setDefaultView"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax="true">${message(code:'is.view.tableView')}</a>
            </li>
        </ul>
    </is:panelButton>

    <li class="navigation-item separator-s"></li>

    %{--Filter--}%
    <is:panelButton alt="Filter"
                    id="menu-filter-task"
                    arrow="true"
                    icon="filter"
                    classDropmenu="${currentFilter == 'allTasks' ? '' : 'filter-active'}"
                    text="${message(code:'is.ui.sprintPlan.toolbar.filter.'+currentFilter)}">
        <ul>
            <li class="first">
                <a href="${createLink(action:'changeFilterTasks', params:[filter:'allTasks', product:params.product], id:sprint.id)}"
                   data-ajax="true"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax-success="$.icescrum.updateFilterTask"
                   data-active="false">
                    ${message(code:'is.ui.sprintPlan.toolbar.filter.allTasks')}
                </a>
            </li>
            <li>
                <a href="${createLink(action:'changeFilterTasks', params:[filter:'myTasks', product:params.product], id:sprint.id)}"
                   data-ajax="true"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax-success="$.icescrum.updateFilterTask"
                   data-active="true">
                    ${message(code:'is.ui.sprintPlan.toolbar.filter.myTasks')}
                </a>
            </li>
            <entry:point id="${controllerName}-${actionName}-filters" model="[sprint:sprint]"/>
            <g:if test="${sprint.state == Sprint.STATE_INPROGRESS}">
                <li>
            </g:if>
            <g:else>
                <li class="last">
            </g:else>
                <a href="${createLink(action:'changeFilterTasks', params:[filter:'freeTasks', product:params.product], id:sprint.id)}"
                   data-ajax="true"
                   data-ajax-update="#window-content-${controllerName}"
                   data-ajax-success="$.icescrum.updateFilterTask"
                   data-active="true">
                    ${message(code:'is.ui.sprintPlan.toolbar.filter.freeTasks')}
                </a>
        </ul>
    </is:panelButton>

    <li class="navigation-item separator"></li>

    <g:if test="${request.scrumMaster || request.productOwner}">

        %{--Activate button--}%
        <li class="navigation-item activate-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${(sprint.activable) ?'':'hidden'}">
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

        <g:if test="${sprint.state == Sprint.STATE_WAIT}">
            <li class="navigation-item separator activate-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${(sprint.activable) ?'':'hidden'}"></li>
        </g:if>

        %{--Close button--}%
        <li class="navigation-item close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.state == Sprint.STATE_INPROGRESS ?'':'hidden'}">
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

        <li class="navigation-item separator close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.state == Sprint.STATE_INPROGRESS ?'':'hidden'}"></li>

    </g:if>

    %{-- doneDefinition --}%
    <li class="navigation-item">
        <a class="tool-button button-n"
           href="#${controllerName}/doneDefinition/${sprint.id}"
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

    <li class="navigation-item separator-s"></li>

    %{-- retrospective --}%
    <li class="navigation-item">
        <a class="tool-button button-n"
           href="#${controllerName}/retrospective/${sprint.id}"
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

    <li class="navigation-item separator"></li>

    <is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
        <ul>
            <li class="first">
                <a href="${createLink(action:'sprintBurndownHoursChart', params: [product:params.product], id:sprint.id)}"
                         data-ajax="true"
                         data-ajax-update="#window-content-${controllerName}">${message(code:'is.ui.sprintPlan.charts.sprintBurndownHoursChart')}</a>
            </li>
            <li>
                <a href="${createLink(action:'sprintBurnupTasksChart', params: [product:params.product], id:sprint.id)}"
                         data-ajax="true"
                         data-ajax-update="#window-content-${controllerName}">${message(code:'is.ui.sprintPlan.charts.sprintBurnupTasksChart')}</a>
            </li>
            <li>
                <a href="${createLink(action:'sprintBurnupStoriesChart', params: [product:params.product], id:sprint.id)}"
                         data-ajax="true"
                         data-ajax-update="#window-content-${controllerName}">${message(code:'is.ui.sprintPlan.charts.sprintBurnupStoriesChart')}</a>
            </li>
            <li class="last">
                <a href="${createLink(action:'sprintBurnupPointsChart', params: [product:params.product], id:sprint.id)}"
                         data-ajax="true"
                         data-ajax-update="#window-content-${controllerName}">${message(code:'is.ui.sprintPlan.charts.sprintBurnupPointsChart')}</a>
            </li>
        </ul>
    </is:panelButton>

    <li class="navigation-item separator-s"></li>

    <is:reportPanel
            action="print"
            text="${message(code: 'is.ui.toolbar.print')}"
            formats="[
                      ['PDF', message(code:'is.report.format.pdf')],
                      ['RTF', message(code:'is.report.format.rtf')],
                      ['DOCX', message(code:'is.report.format.docx')],
                      ['ODT', message(code:'is.report.format.odt')]
                    ]"
            params="id=${sprint.id}&locationHash='+encodeURIComponent(\$.icescrum.o.currentOpenedWindow.context.location.hash)+'"/>

    <li class="navigation-item separator-s"></li>

    <is:reportPanel
            action="printPostits"
            id="all"
            formats="[
                        ['PDF', message(code:'is.report.format.pdf')]
                    ]"
            text="${message(code: 'is.ui.sprintPlan.toolbar.print.stories')}"
            params="id=${sprint.id}"/>

</g:if>
<entry:point id="${controllerName}-${actionName}" model="[sprint:sprint]"/>  %{-- attention le sprint peut etre null --}%

<g:if test="${sprint?.id}">
%{--Search--}%
    <is:panelSearch id="search-ui">
        <is:autoCompleteSearch elementId="autoCmpTxt" controller="${controllerName}" action="index" id="${sprint.id}"
                               update="window-content-${controllerName}"/>
    </is:panelSearch>
</g:if>
