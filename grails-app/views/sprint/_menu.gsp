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
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>

<is:menuItem first="true" rendered="${request.inProduct}">
    <is:link id="${sprint.id}"
             action="open"
             controller="sprintPlan"
             value="${message(code:'is.ui.releasePlan.menu.sprint.open')}"
             onclick="\$.icescrum.stopEvent(event).openWindow('sprintPlan/${sprint.id}');"
             disabled="true"/>
</is:menuItem>
<is:menuItem class="activate-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.activable?'':'hidden'}"
             rendered="${poOrSm && ( template || sprint.state == Sprint.STATE_WAIT)}"
             elementId="menu-activate-sprint-${sprint.id}">
    <is:link
            action="activate"
            controller="releasePlan"
            id="${sprint.id}"
            onSuccess="if(data.dialog){ jQuery(document.body).append(data.dialog); }else{ jQuery.event.trigger('activate_sprint',data.sprint); jQuery.event.trigger('inProgress_story',[data.stories]); jQuery.icescrum.renderNotice('${g.message(code:'is.sprint.activated')}');}"
            before="if (!confirm('${g.message(code:'is.ui.releasePlan.menu.sprint.activate.confirm')}')){ return false; };"
            value="${message(code:'is.ui.releasePlan.menu.sprint.activate')}"
            remote="true"
            history="false"/>
</is:menuItem>
<is:menuItem
        class="close-sprint-${sprint.parentRelease.id}-${sprint.orderNumber} ${sprint.state == Sprint.STATE_INPROGRESS?'':'hidden'}"
        rendered="${poOrSm && (template || sprint.state <= Sprint.STATE_INPROGRESS)}"
        elementId="menu-close-sprint-${sprint.id}">
    <is:link
            action="close"
            controller="releasePlan"
            id="${sprint.id}"
            onSuccess="if(data.dialog){ jQuery(document.body).append(data.dialog); }else{ jQuery.event.trigger('close_sprint',data.sprint); jQuery.event.trigger('done_story',[data.stories]); jQuery.event.trigger('update_story',[data.unDoneStories]); jQuery.icescrum.renderNotice('${g.message(code:'is.sprint.closed')}');}"
            before="if (!confirm('${g.message(code:'is.ui.releasePlan.menu.sprint.close.confirm')}')){ return false; };"
            value="${message(code:'is.ui.releasePlan.menu.sprint.close')}"
            remote="true"
            history="false"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && (sprint.state != Sprint.STATE_DONE || template)}"
             elementId="menu-edit-sprint-${sprint.id}">
    <is:link
            action="edit"
            controller="${controllerName}"
            subid="${sprint.id}"
            id="${sprint.parentRelease.id}"
            update="window-content-${controllerName}"
            value="${message(code:'is.ui.releasePlan.menu.sprint.update')}"
            remote="true"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && (sprint.state == Sprint.STATE_WAIT || template)}"
             elementId="menu-delete-sprint-${sprint.id}">
    <is:link
            action="delete"
            remote="true"
            id="${sprint.id}"
            history="false"
            controller="releasePlan"
            onSuccess="if(data.dialog){ jQuery(document.body).append(data.dialog); }else{ jQuery.event.trigger('remove_sprint',[data]); jQuery.icescrum.renderNotice('${g.message(code:'is.sprint.deleted')}'); }"
            value="${message(code:'is.ui.releasePlan.menu.sprint.delete')}"/>
</is:menuItem>
<is:menuItem rendered="${poOrSm && (sprint.state != Sprint.STATE_DONE || template)}"
             elementId="menu-unplan-sprint-${sprint.id}">
    <is:link
            action="unPlan"
            id="${sprint.id}"
            controller="sprint"
            before="if(!confirm('${message(code:'is.ui.releasePlan.menu.sprint.warning.dissociateAll')}')){ return false; }"
            onSuccess=" jQuery.event.trigger('sprintMesure_sprint',data.sprint); jQuery.event.trigger('unPlan_story',[data.stories]); jQuery.icescrum.renderNotice('${g.message(code:'is.sprint.stories.dissociated')}')"
            value="${message(code:'is.ui.releasePlan.menu.sprint.dissociateAll')}"
            remote="true"
            history="false"/>
</is:menuItem>
<entry:point id="${controllerName}-${actionName}-sprintMenu" model="[sprint:sprint]"/>