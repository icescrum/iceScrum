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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%

<g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>

<is:postitMenuItem first="true">
 <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        update="window-content-${id}">
   <g:message code='is.ui.productBacklog.menu.details'/>
 </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem>
  <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        params="[tab:'comments']"
        update="window-content-${id}">
    <g:message code='is.ui.sandbox.menu.commentable'/>
  </is:scrumLink>
</is:postitMenuItem>

<is:postitMenuItem rendered="${productOwner}">
  <is:link id="${story.id}" 
        action="edit"
        controller="productBacklog"
        update="window-content-${id}"
        value="${message(code:'is.ui.productBacklog.menu.update')}"
        remote="true"/>
</is:postitMenuItem>

<is:postitMenuItem renderedOnAccess="inProduct()">
  <is:link id="${story.id}"
          action="cloneStory"
          controller="sandbox"
          remote="true"
          history="false"
          onSuccess="jQuery.icescrum.renderNotice(data.notice.text)"
          value="${message(code:'is.ui.productBacklog.menu.clone')}"/>
</is:postitMenuItem>

<is:postitMenuItem renderedOnAccess="scrumMaster() or teamMember()" rendered="${story.state >= 2 && session.currentView == 'postitsView'}">
  <is:link
        disabled="true"
        history="false"
        value="${message(code:'is.ui.productBacklog.menu.estimate')}"
        onclick="jQuery('#postit-story-${story.id}').find('.mini-value').click();"
        />
</is:postitMenuItem>

<is:postitMenuItem rendered="${productOwner}">
  <is:link id="${story.id}"
        action="delete"
        history='false'
        remote="true"
        update="window-content-${id}"
        value="${message(code:'is.ui.productBacklog.menu.delete')}"/>
</is:postitMenuItem>
<entry:point id="${id}-${actionName}-postitMenu" model="[story:story]"/>