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

<%@ page import="org.icescrum.core.domain.Story;org.icescrum.core.domain.Sprint;" %>
<g:set var="productOwner" value="${sec.access(expression:'productOwner()',{true})}"/>
<g:set var="scrumMaster" value="${sec.access(expression:'scrumMaster()',{true})}"/>

<is:postitMenuItem first="true">
 <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        update="window-content-${id}">
   <g:message code='is.ui.releasePlan.menu.story.details'/>
 </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem>
  <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        params="[tab:'comments']"
        update="window-content-${id}">
    <g:message code='is.ui.releasePlan.menu.story.commentable'/>
  </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem rendered="${productOwner && story.state != org.icescrum.core.domain.Story.STATE_DONE}">
  <is:link
          action="edit"
          controller="productBacklog"
          id="${story.id}"
          params="['referrer.controller':id, 'referrer.action':'index', 'referrer.id':params.id]"
          update="window-content-${id}"
          value="${message(code:'is.ui.releasePlan.menu.story.update')}"
          history="false"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem renderedOnAccess="inProduct()">
  <is:link id="${story.id}"
          action="cloneStory"
          controller="sandbox"
          remote="true"
          history="false"
          onSuccess="jQuery.icescrum.renderNotice(data.notice.text)"
          value="${message(code:'is.ui.releasePlan.menu.story.clone')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${(productOwner || scrumMaster) && story.state != org.icescrum.core.domain.Story.STATE_DONE}">
  <is:link
          history="false"
          id="${params.id}"
          action="dissociate"
          update="window-content-${id}"
          params="['story.id':story.id]"
          remote="true"
          value="${message(code:'is.ui.releasePlan.menu.story.dissociate')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner && story.state == org.icescrum.core.domain.Story.STATE_INPROGRESS}">
  <is:link
          history="false"
          id="${params.id}"
          action="declareAsDone"
          params="['story.id':story.id]"
          update="window-content-${id}"
          remote="true"
          value="${message(code:'is.ui.releasePlan.menu.story.done')}"/>
</is:postitMenuItem>

<is:postitMenuItem rendered="${productOwner && story.state == org.icescrum.core.domain.Story.STATE_DONE && story.parentSprint.state == org.icescrum.core.domain.Sprint.STATE_INPROGRESS}">
  <is:link
          history="false"
          id="${params.id}"
          action="declareAsUnDone"
          params="['story.id':story.id]"
          update="window-content-${id}"
          remote="true"
          value="${message(code:'is.ui.releasePlan.menu.story.undone')}"/>
</is:postitMenuItem>
