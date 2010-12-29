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
- Vincent Barrier (vincent.barrier@icescrum.com)
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:set var="inTeam" value="${sec.access([expression:'teamMember() or productOwner() or scrumMaster()'], {true})}"/>
<g:set var="poOrSm" value="${sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>

<g:if test="${sprint?.id}">
%{--Add button--}%
  <is:iconButton
          action="add"
          icon="create"
          rendered="${inTeam && sprint.state != Sprint.STATE_DONE}"
          id="${sprint.id}"
          controller="${id}"
          shortcut="[key:'ctrl+n',scope:id]"
          title="${message(code:'is.ui.sprintBacklog.toolbar.alt.new')}"
          alt="${message(code:'is.ui.sprintBacklog.toolbar.alt.new')}"
          update="window-content-${id}">
    ${message(code: 'is.ui.sprintBacklog.toolbar.new')}
  </is:iconButton>

  <is:separatorSmall rendered="${inTeam && sprint.state != Sprint.STATE_DONE}"/>

%{--Delete button--}%
  <is:iconButton
          icon="delete"
          rendered="${inTeam && sprint.state != Sprint.STATE_DONE}"
          onclick="\$.icescrum.selectableAction();"
          history='false'
          shortcut="[key:'del',scope:id]"
          disabled="true"
          disablable="true"
          title="${message(code:'is.ui.sprintBacklog.toolbar.alt.delete')}"
          alt="${message(code:'is.ui.sprintBacklog.toolbar.alt.delete')}">
    ${message(code: 'is.ui.sprintBacklog.toolbar.delete')}
  </is:iconButton>

  <is:separator rendered="${inTeam && sprint.state != Sprint.STATE_DONE}"/>

    %{--View--}%
  <is:panelButton alt="View" id="menu-display" arrow="true" icon="view" text="${message(code:'is.view.'+currentView)}">
    <ul>
      <li class="first">
        <is:link
                controller="scrumOS"
                action="changeView"
                params="'product=${params.product}&view=postitsView&window=${id}&id=${sprint.id}&actionWindow=index&term='+\$(\'#autoCmpTxt\').val()"
                history="false"
                update="window-content-${id}"
                remote="true"
                onSuccess="\$.icescrum.displayView('${message(code:'is.view.postitsView')}')"
                value="${message(code:'is.view.postitsView')}"/>
      </li>
      <li class="last">
        <is:link controller="scrumOS"
                action="changeView"
                params="'product=${params.product}&view=tableView&window=${id}&id=${sprint.id}&actionWindow=index&term='+\$(\'#autoCmpTxt\').val()"
                update="window-content-${id}"
                history="false"
                onSuccess="\$.icescrum.displayView('${message(code:'is.view.tableView')}')"
                remote="true"
                value="${message(code:'is.view.tableView')}"/>
      </li>
    </ul>
  </is:panelButton>

  <is:separatorSmall/>

%{--Filter--}%
  <is:panelButton alt="Filter" id="menu-filter-task" arrow="true" icon="filter" text="${message(code:'is.ui.sprintBacklog.toolbar.filter.'+currentFilter)}">
    <ul>
      <li class="first">
        <is:link
                controller="${id}"
                action="changeFilterTasks"
                params="[filter:'allTasks']"
                history="false"
                onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
                id="${params.id}"
                update="window-content-${id}"
                remote="true"
                value="${message(code:'is.ui.sprintBacklog.toolbar.filter.allTasks')}"/>
      </li>
      <li>
        <is:link controller="${id}"
                action="changeFilterTasks"
                params="[filter:'myTasks']"
                update="window-content-${id}"
                onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
                history="false"
                id="${params.id}"
                remote="true"
                value="${message(code:'is.ui.sprintBacklog.toolbar.filter.myTasks')}"/>
      </li>
      <g:if test="${sprint.state == Sprint.STATE_INPROGRESS}">
        <li>
      </g:if>
      <g:else>
        <li class="last">
      </g:else>
        <is:link controller="${id}"
                action="changeFilterTasks"
                params="[filter:'freeTasks']"
                onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
                update="window-content-${id}"
                history="false"
                id="${params.id}"
                remote="true"
                value="${message(code:'is.ui.sprintBacklog.toolbar.filter.freeTasks')}"/>
      </li>
      <g:if test="${sprint.state == Sprint.STATE_INPROGRESS}">
        <li class="last">
          <is:link
            action="changeHideDoneState"
            controller="${id}"
            onSuccess="\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
            history="false"
            remote="true"
            id="${params.id}"
            update="window-content-${id}">
              ${hideDoneState?message(code: 'is.ui.sprintBacklog.toolbar.showDoneState'):message(code: 'is.ui.sprintBacklog.toolbar.hideDoneState')}
          </is:link>
        </li>
      </g:if>
    </ul>
  </is:panelButton>

  <is:separator/>

%{--Activate button--}%
  <is:iconButton
          rendered="${poOrSm && sprint.state == Sprint.STATE_WAIT && activable}"
          action="activate"
          shortcut="[key:'ctrl+shift+a',scope:id]"
          controller="${id}"
          history="false"
          id="${sprint.id}"
          update="window-content-${id}"
          alt="${message(code:'is.ui.sprintBacklog.toolbar.alt.activate')}"
          title="${message(code:'is.ui.sprintBacklog.toolbar.alt.activate')}">
    ${message(code: 'is.ui.sprintBacklog.toolbar.activate')}
  </is:iconButton>

  <is:separator rendered="${poOrSm && sprint.state == Sprint.STATE_WAIT && activable}"/>

%{--Close button--}%
  <is:iconButton
          rendered="${poOrSm && sprint.state == Sprint.STATE_INPROGRESS}"
          action="close"
          shortcut="[key:'ctrl+shift+c',scope:id]"
          controller="${id}"
          history="false"
          success="\$('#window-toolbar').icescrum('toolbar').reload('${id}');"
          id="${sprint.id}"
          update="window-content-${id}"
          alt="${message(code:'is.ui.sprintBacklog.toolbar.alt.close')}"
          title="${message(code:'is.ui.sprintBacklog.toolbar.alt.close')}">
    ${message(code: 'is.ui.sprintBacklog.toolbar.close')}
  </is:iconButton>

  <is:separator rendered="${poOrSm && sprint.state == Sprint.STATE_INPROGRESS}"/>

%{-- doneDefinition --}%
  <is:iconButton
          alt="${message(code:'is.ui.sprintBacklog.toolbar.alt.doneDefinition')}"
          title="${message(code:'is.ui.sprintBacklog.toolbar.alt.doneDefinition')}"
          action="doneDefinition"
          shortcut="[key:'ctrl+shift+d',scope:id]"
          id="${params.id}"
          controller="${id}"
          update="window-content-${id}">
    ${message(code: 'is.ui.sprintBacklog.toolbar.doneDefinition')}
  </is:iconButton>

  <is:separatorSmall/>

%{-- retrospective --}%
  <is:iconButton
          alt="${message(code:'is.ui.sprintBacklog.toolbar.alt.retrospective')}"
          title="${message(code:'is.ui.sprintBacklog.toolbar.alt.retrospective')}"
          action="retrospective"
          shortcut="[key:'ctrl+shift+r',scope:id]"
          id="${params.id}"
          controller="${id}"
          update="window-content-${id}">
    ${message(code: 'is.ui.sprintBacklog.toolbar.retrospective')}
  </is:iconButton>

  <is:separator/>

  <is:panelButton alt="Charts" id="menu-chart" arrow="true" icon="graph" text="${message(code:'is.ui.toolbar.charts')}">
    <ul>
      <li class="first">
        <is:link
                action="sprintBurndownHoursChart"
                controller="${id}"
                id="${sprint.id}"
                update="window-content-${id}"
                title="${message(code:'is.ui.sprintBacklog.charts.sprintBurndownHoursChart')}"
                remote="true"
                value="${message(code:'is.ui.sprintBacklog.charts.sprintBurndownHoursChart')}"/>
      </li>
      <li>
        <is:link
                action="sprintBurnupTasksChart"
                controller="${id}"
                id="${sprint.id}"
                update="window-content-${id}"
                title="${message(code:'is.ui.sprintBacklog.charts.sprintBurnupTasksChart')}"
                remote="true"
                value="${message(code:'is.ui.sprintBacklog.charts.sprintBurnupTasksChart')}"/>
      </li>
      <li class="last">
        <is:link
                action="sprintBurnupStoriesChart"
                controller="${id}"
                id="${sprint.id}"
                update="window-content-${id}"
                title="${message(code:'is.ui.sprintBacklog.charts.sprintBurnupStoriesChart')}"
                remote="true"
                value="${message(code:'is.ui.sprintBacklog.charts.sprintBurnupStoriesChart')}"/>
      </li>
    </ul>
  </is:panelButton>

%{--Print button
  <is:separatorSmall/>
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
--}%
</g:if>

<g:if test="${sprint?.id}">
%{--Search--}%
  <is:panelSearch id="search-ui">
    <is:autoCompleteSearch elementId="autoCmpTxt" controller="${id}" action="index" id="${sprint.id}" update="window-content-${id}"/>
  </is:panelSearch>
</g:if>
