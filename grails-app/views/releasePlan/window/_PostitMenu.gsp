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

<%@ page import="org.icescrum.core.domain.Story;org.icescrum.core.domain.Sprint;" %>
<is:postitMenuItem first="true">
 <is:scrumLink
        id="${story.id}"
        controller="story"
        update="window-content-${controllerName}">
   <g:message code='is.ui.releasePlan.menu.story.details'/>
 </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem>
  <is:scrumLink
        id="${story.id}"
        controller="story"
        params="[tab:'comments']"
        update="window-content-${controllerName}">
    <g:message code='is.ui.releasePlan.menu.story.commentable'/>
  </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem rendered="${request.productOwner && story.state != Story.STATE_DONE}">
  <is:link
          action="edit"
          controller="productBacklog"
          id="${story.id}"
          params="['referrer.controller':controllerName, 'referrer.action':'index', 'referrer.id':params.id]"
          update="window-content-${controllerName}"
          value="${message(code:'is.ui.releasePlan.menu.story.update')}"
          history="false"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${request.inProduct}">
  <is:link id="${story.id}"
          action="cloneStory"
          controller="sandbox"
          remote="true"
          history="false"
          onSuccess="jQuery.icescrum.renderNotice('${g.message(code:'is.story.cloned')}')"
          value="${message(code:'is.ui.releasePlan.menu.story.clone')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${(request.productOwner || request.scrumMaster) && story.state != Story.STATE_DONE}">
  <is:link
          history="false"
          id="${story.id}"
          action="dissociate"
          controller="productBacklog"
          remote="true"
          onSuccess="jQuery.icescrum.renderNotice('${g.message(code:'is.sprint.stories.dissociated')}')"
          value="${message(code:'is.ui.releasePlan.menu.story.dissociate')}"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${request.productOwner && story.state == Story.STATE_INPROGRESS}">
  <is:link
          history="false"
          id="${story.id}"
          controller="productBacklog"
          action="declareAsDone"
          remote="true"
          onSuccess="jQuery.icescrum.renderNotice('${g.message(code:'is.story.declaredAsDone')}')"
          value="${message(code:'is.ui.releasePlan.menu.story.done')}"/>
</is:postitMenuItem>

<is:postitMenuItem rendered="${request.productOwner && story.state == Story.STATE_DONE && story.parentSprint.state == Sprint.STATE_INPROGRESS}">
  <is:link
          history="false"
          id="${story.id}"
          action="declareAsUnDone"
          controller="productBacklog"
          remote="true"
          onSuccess="jQuery.icescrum.renderNotice('${g.message(code:'is.story.declaredAsUnDone')}')"
          value="${message(code:'is.ui.releasePlan.menu.story.undone')}"/>
</is:postitMenuItem>
<entry:point id="${controllerName}-${actionName}-postitMenu" model="[story:story]"/>
