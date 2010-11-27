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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%

<%@ page import="org.icescrum.core.domain.Sprint;org.icescrum.core.domain.Story" %>

<g:set var="productOwner" value="${sec.access(expression:'productOwner()',{true})}"/>
<g:set var="scrumMaster" value="${sec.access(expression:'scrumMaster()',{true})}"/>

<is:postitMenuItem first="true">
  <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        update="window-content-${id}">
    <g:message code='is.ui.sprintBacklog.menu.postit.details'/>
  </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem>
  <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        params="[tab:'comments']"
        update="window-content-${id}">
    <g:message code='is.ui.sprintBacklog.menu.postit.commentable'/>
  </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem rendered="${story.state <= Story.STATE_INPROGRESS}">
  <is:link id="${params.id}"
          action="add"
          controller="${id}"
          update="window-content-${id}"
          params="['story.id':story.id]"
          value="${message(code:'is.ui.sprintBacklog.menu.postit.new')}"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner && story.state <= Story.STATE_INPROGRESS}">
  <is:link id="${story.id}"
          action="edit"
          controller="productBacklog"
          params="['referrer.controller':id, 'referrer.action':'index', 'referrer.id':params.id]"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.postit.update')}"
          history="false"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${(productOwner || scrumMaster) && story.state <= Story.STATE_INPROGRESS}">
  <is:link id="${story.id}"
          action="dissociate"
          remote="true"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.postit.dissociate')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${(productOwner || scrumMaster) && nextSprintExist && story.state <= Story.STATE_INPROGRESS}">
  <is:link id="${story.id}"
          action="dissociate"
          remote="true"
          history="false"
          params="[shiftToNext:true]"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.postit.shiftToNext')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner && story.state == Story.STATE_INPROGRESS}">
  <is:link id="${story.id}"
          action="declareAsDone"
          remote="true"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.postit.declareAsDone')}"/>
</is:postitMenuItem>
<is:postitMenuItem  rendered="${productOwner && story.state == Story.STATE_DONE && story.parentSprint.state == org.icescrum.core.domain.Sprint.STATE_INPROGRESS}">
  <is:link id="${story.id}"
          action="declareAsUnDone"
          remote="true"
          history="false"
          update="window-content-${id}"
          value="${message(code:'is.ui.sprintBacklog.menu.postit.declareAsUnDone')}"/>
</is:postitMenuItem>