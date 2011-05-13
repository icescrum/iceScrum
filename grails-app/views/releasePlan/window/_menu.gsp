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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<%@ page import="org.icescrum.core.domain.Sprint;" %>
<g:set var="poOrSm" value="${sec.access(expression:'productOwner() or scrumMaster()',{true})}"/>

<is:menuItem first="true" renderedOnAccess="inProduct()">
  <is:link id="${sprint.id}"
          action="open"
          controller="sprintBacklog"
          update="window-content-${id}"
          value="${message(code:'is.ui.releasePlan.menu.sprint.open')}"
          onclick="\$.icescrum.stopEvent(event).openWindow('sprintBacklog/${sprint.id}');"
          disabled="true"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && sprint.state == org.icescrum.core.domain.Sprint.STATE_WAIT  && nextSprint == sprint.orderNumber}">
  <is:link
          action="activate"
          id="${sprint.id}"
          update="window-content-${id}"
          before="if (!confirm('${g.message(code:'is.ui.releasePlan.menu.sprint.activate.confirm')}')){ return false; };"
          value="${message(code:'is.ui.releasePlan.menu.sprint.activate')}"
          remote="true"
          history="false"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && sprint.state == org.icescrum.core.domain.Sprint.STATE_INPROGRESS}">
  <is:link
          action="close"
          id="${sprint.id}"
          update="window-content-${id}"
          before="if (!confirm('${g.message(code:'is.ui.releasePlan.menu.sprint.close.confirm')}')){ return false; };"
          value="${message(code:'is.ui.releasePlan.menu.sprint.close')}"
          remote="true"
          history="false"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && sprint.state != org.icescrum.core.domain.Sprint.STATE_DONE}">
  <is:link 
          action="edit"
          id="${sprint.id}"
          update="window-content-${id}"
          value="${message(code:'is.ui.releasePlan.menu.sprint.update')}"
          remote="true"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && sprint.state == Sprint.STATE_WAIT}">
  <is:link
          action="delete"
          remote="true"
          id="${sprint.id}"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.releasePlan.menu.sprint.delete')}"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && sprint.state != org.icescrum.core.domain.Sprint.STATE_DONE}">
  <is:link
          action="dissociateAllSprint"
          id="${sprint.id}"
          update="window-content-${id}"
          value="${message(code:'is.ui.releasePlan.menu.sprint.dissociateAll')}"
          remote="true"
          history="false"/>
</is:menuItem>
<entry:point id="${id}-${actionName}-sprintMenu" model="[sprint:sprint]"/>