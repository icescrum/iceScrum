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
--}%
<%@ page import="org.icescrum.core.domain.Release" %>
<g:set var="poOrsm" value="${sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>

<is:menuItem first="true">
    <is:link id="${release.id}"
             action="open"
             update="window-content-${id}"
             value="${message(code:'is.ui.timeline.menu.open')}"
             onclick="jQuery.icescrum.stopEvent(event).openWindow('releasePlan/${release.id}');"
             disabled="true"/>
</is:menuItem>

<is:menuItem rendered="${poOrsm && (release.state == Release.STATE_WAIT && !activeRelease)}">
    <is:link id="${release.id}"
             action="activate"
             controller="release"
             onclick="jQuery.icescrum.stopEvent(event)"
             before="if (!confirm('${g.message(code:'is.ui.timeline.menu.activate.confirm')}')){ return false; }"
             onSuccess="jQuery.event.trigger('activate_release',data)"
             value="${message(code:'is.ui.timeline.menu.activate')}"
             history='false'
             remote="true"/>
</is:menuItem>

<is:menuItem rendered="${poOrsm && (release.state == Release.STATE_INPROGRESS && isClosable)}">
    <is:link id="${release.id}"
             action="close"
             controller="release"
             onClick="jQuery.icescrum.stopEvent(event)"
             before="if (!confirm('${g.message(code:'is.ui.timeline.menu.close.confirm')}')){ return false; }"
             onSuccess="jQuery.event.trigger('close_release',data)"
             history='false'
             value="${message(code:'is.ui.timeline.menu.close')}"
             remote="true"/>
</is:menuItem>

<is:menuItem rendered="${poOrsm && release.state != org.icescrum.core.domain.Release.STATE_DONE}">
    <is:link id="${release.id}"
             action="edit"
             update="window-content-${id}"
             onclick="jQuery.icescrum.stopEvent(event);"
             value="${message(code:'is.ui.timeline.menu.update')}"
             remote="true"/>
</is:menuItem>
<is:menuItem rendered="${poOrsm && release.state == Release.STATE_WAIT}">
    <is:link id="${release.id}"
             action="delete"
             controller="release"
             remote="true"
             history='false'
             onclick="jQuery.icescrum.stopEvent(event);"
             onSuccess="jQuery.event.trigger('remove_release',data)"
             value="${message(code:'is.ui.timeline.menu.delete')}"/>
</is:menuItem>
<entry:point id="${id}-${actionName}-menu" model="[release:release]"/>