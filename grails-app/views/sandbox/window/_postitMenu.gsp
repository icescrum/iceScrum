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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%

<g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>

<is:postitMenuItem first="true">
  <is:scrumLink
        id="${story.id}"
        controller="backlogElement"
        update="window-content-${id}">
    <g:message code='is.ui.sandbox.menu.details'/>
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
        action="accept"
        params="[story:true]"
        remote="true"
        update="window-content-${id}"
        value="${message(code:'is.ui.sandbox.menu.acceptAsStory')}"
        history='false'/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner}">
  <is:link id="${story.id}"
        action="accept"
        params="[feature:true]"
        remote="true"
        update="window-content-${id}"
        value="${message(code:'is.ui.sandbox.menu.acceptAsFeature')}"
        history='false'/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner && sprint}">
  <is:link id="${story.id}"
        action="accept"
        params="[task:true]"
        remote="true"
        update="window-content-${id}"
        value="${message(code:'is.ui.sandbox.menu.acceptAsUrgentTask')}"
        history='false'/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner || story.creator.id == user?.id}">
  <is:link id="${story.id}"
          action="edit"
          controller="sandbox"
          update="window-content-${id}"
          value="${message(code:'is.ui.sandbox.menu.update')}"
          remote="true"/>
</is:postitMenuItem>
<is:postitMenuItem rendered="${productOwner || story.creator.id == user?.id}">
  <is:link id="${story.id}"
          action="delete"
          remote="true"
          update="window-content-${id}"
          value="${message(code:'is.ui.sandbox.menu.delete')}"
          history='false'/>
</is:postitMenuItem>