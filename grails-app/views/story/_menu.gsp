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
<g:set var="inProduct" value="${request.inProduct}"/>
<g:set var="productOwner" value="${request.productOwner}"/>
<g:set var="teamMember" value="${request.teamMember}"/>
<g:set var="scrumMaster" value="${request.scrumMaster}"/>
<g:set var="creator" value="${story.creator.id == user?.id}"/>

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

<g:if test="${story.state == Story.STATE_SUGGESTED || template}">
    <is:postitMenuItem rendered="${productOwner}" elementId="menu-accept-${story.id}">
        <is:link id="${story.id}"
                 action="accept"
                 params="[type:'story']"
                 remote="true"
                 controller="story"
                 onSuccess="jQuery.event.trigger('accept_story',data); jQuery.icescrum.renderNotice('${message(code: 'is.story.acceptedAsStory')}')"
                 value="${message(code:'is.ui.sandbox.menu.acceptAsStory')}"
                 history='false'/>
    </is:postitMenuItem>

    <is:postitMenuItem rendered="${productOwner}" elementId="menu-accept-feature-${story.id}">
        <is:link id="${story.id}"
                 action="accept"
                 controller="story"
                 params="[type:'feature']"
                 remote="true"
                 onSuccess="jQuery.event.trigger('accept_story',data); jQuery.icescrum.renderNotice('${message(code: 'is.story.acceptedAsFeature')}')"
                 value="${message(code:'is.ui.sandbox.menu.acceptAsFeature')}"
                 history='false'/>
    </is:postitMenuItem>

    <is:postitMenuItem class="menu-accept-task ${sprint?'':'hidden'}"
                       rendered="${productOwner && (template || story.state == Story.STATE_SUGGESTED)}"
                       elementId="menu-accept-task-${story.id}">
        <is:link id="${story.id}"
                 action="accept"
                 controller="story"
                 params="[type:'task']"
                 remote="true"
                 onSuccess="jQuery.event.trigger('accept_story',data); jQuery.icescrum.renderNotice('${message(code:'is.story.acceptedAsUrgentTask')}')"
                 value="${message(code:'is.ui.sandbox.menu.acceptAsUrgentTask')}"
                 history='false'/>
    </is:postitMenuItem>
</g:if>

<!--<g:if test="${(scrumMaster || teamMember) && ((story.state >= Story.STATE_ACCEPTED && story.state < Story.STATE_DONE && session.currentView == 'postitsView' ) || template)}">
    <is:postitMenuItem rendered="${session.currentView == 'postitsView'}">
      <is:link
            elementId="menu-estimate-${story.id}"
            disabled="true"
            history="false"
            value="${message(code:'is.ui.backlog.menu.estimate')}"
            onclick="jQuery('#postit-story-${story.id}').find('.mini-value').click();"
            />
    </is:postitMenuItem>

    <is:postitMenuItem rendered="${session.currentView == 'tableView'}">
      <is:link
            elementId="menu-estimate-${story.id}"
            disabled="true"
            history="false"
            value="${message(code:'is.ui.backlog.menu.estimate')}"
            onclick="jQuery('#postit-story-${story.id}').find('.mini-value').click();"
            />
    </is:postitMenuItem>
</g:if>-->

<is:postitMenuItem
        rendered="${inProduct && (story.state == Story.STATE_PLANNED || story.state == Story.STATE_INPROGRESS || template)}">
    <is:link
            elementId="menu-add-task-${story.id}"
            action="add"
            id="${story.parentSprint.id}"
            controller="sprintPlan"
            params="['story.id':story.id]"
            remote="true"
            alt="${message(code:'is.ui.sprintPlan.kanban.recurrentTasks.add')}"
            update="window-content-${id}">
        ${message(code: 'is.ui.sprintPlan.kanban.recurrentTasks.add')}
    </is:link>
</is:postitMenuItem>

<is:postitMenuItem
        rendered="${((productOwner && story.state != Story.STATE_DONE) || (creator && story.state == Story.STATE_SUGGESTED)) || template}"
        elementId="menu-edit-${story.id}">
    <is:link
            action="editStory"
            controller="${id}"
            id="${referrer?:story.id}"
            update="window-content-${id}"
            subid="${referrer?story.id:null}"
            value="${message(code:'is.ui.releasePlan.menu.story.update')}"
            history="true"
            remote="true"/>
</is:postitMenuItem>

<is:postitMenuItem rendered="${inProduct}">
    <is:link id="${story.id}"
             action="copy"
             controller="story"
             remote="true"
             history="false"
             onSuccess="jQuery.event.trigger('add_story',data); jQuery.icescrum.renderNotice('${g.message(code:'is.story.cloned')}')"
             value="${message(code:'is.ui.releasePlan.menu.story.clone')}"/>
</is:postitMenuItem>

<is:postitMenuItem
        rendered="${(productOwner && story.state <= Story.STATE_ESTIMATED) || (creator && story.state == Story.STATE_SUGGESTED) || template}"
        elementId="menu-delete-${story.id}">
    <is:link id="${story.id}"
             action="delete"
             controller="story"
             remote="true"
             onSuccess="jQuery.event.trigger('remove_story',data); jQuery.icescrum.renderNotice('${message(code:'is.story.deleted')}')"
             value="${message(code:'is.ui.sandbox.menu.delete')}"
             history='false'/>
</is:postitMenuItem>

<is:postitMenuItem
        rendered="${(productOwner || scrumMaster) && (template || story.state >= Story.STATE_PLANNED && story.state != Story.STATE_DONE)}"
        elementId="menu-unplan-${story.id}">
    <is:link
            history="false"
            id="${story.id}"
            action="unPlan"
            controller="story"
            remote="true"
            onSuccess=" jQuery.event.trigger('sprintMesure_sprint',data.sprint); jQuery.event.trigger('unPlan_story',data.story); jQuery.icescrum.renderNotice('${g.message(code:'is.sprint.stories.dissociated')}')"
            value="${message(code:'is.ui.releasePlan.menu.story.dissociate')}"/>
</is:postitMenuItem>

<is:postitMenuItem
        class="menu-shift-${sprint?.parentRelease?.id}-${(sprint?.orderNumber instanceof Integer ?sprint?.orderNumber + 1:sprint?.orderNumber)} ${nextSprintExist?'':'hidden'}"
        rendered="${(productOwner || scrumMaster) && (template || story.state >= Story.STATE_PLANNED && story.state <= Story.STATE_INPROGRESS)}"
        elementId="menu-shift-${story.id}">
    <is:link id="${story.id}"
             action="unPlan"
             remote="true"
             history="false"
             params="[shiftToNext:true]"
             controller="story"
             onSuccess="jQuery.event.trigger('unPlan_story',data.story); jQuery.icescrum.renderNotice('${g.message(code: 'is.story.shiftedToNext')}')"
             value="${message(code:'is.ui.sprintPlan.menu.postit.shiftToNext')}"/>
</is:postitMenuItem>

<is:postitMenuItem rendered="${productOwner && (story.state == Story.STATE_INPROGRESS || template)}"
                   elementId="menu-done-${story.id}">
    <is:link
            history="false"
            id="${story.id}"
            controller="story"
            action="done"
            remote="true"
            onSuccess="jQuery.event.trigger('done_story',data); jQuery.icescrum.renderNotice('${g.message(code:'is.story.declaredAsDone')}')"
            value="${message(code:'is.ui.releasePlan.menu.story.done')}"/>
</is:postitMenuItem>

<is:postitMenuItem
        rendered="${productOwner && (template || story.state == Story.STATE_DONE && story.parentSprint.state == Sprint.STATE_INPROGRESS)}"
        elementId="menu-undone-${story.id}">
    <is:link
            history="false"
            id="${story.id}"
            action="unDone"
            controller="story"
            remote="true"
            onSuccess="jQuery.event.trigger('unDone_story',data); jQuery.icescrum.renderNotice('${g.message(code:'is.story.declaredAsUnDone')}')"
            value="${message(code:'is.ui.releasePlan.menu.story.undone')}"/>
</is:postitMenuItem>
<entry:point id="${id}-${actionName}-postitMenu" model="[story:story]"/>