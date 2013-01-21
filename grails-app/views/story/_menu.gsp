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
<g:set var="creator" value="${story.creator.id == user?.id && !request.archivedProduct && !request.readOnly}"/>

<li class="first">
    <a class="scrum-link" href="#story/${story.id}">
        <g:message code='is.ui.releasePlan.menu.story.details'/>
    </a>
</li>
<li>
    <a class="scrum-link" href="#story/${story.id}?tab=comments">
        <g:message code='is.ui.releasePlan.menu.story.commentable'/>
    </a>
</li>
<li>
    <a class="scrum-link" href="#story/${story.id}?tab=tests">
        <g:message code='is.ui.backlogelement.activity.test'/>
    </a>
</li>
<g:if test="${productOwner && (story.state == Story.STATE_SUGGESTED || template)}">
    <li id="menu-accept-${story.id}">
        <a href="${createLink(action:'accept',controller:'story',params:[type:'story',product:params.product],id:story.id)}"
           data-ajax-trigger="accept_story"
           data-ajax-notice="${message(code: 'is.story.acceptedAsStory').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.sandbox.menu.acceptAsStory'/>
        </a>
    </li>
    <li id="menu-accept-feature-${story.id}">
        <a href="${createLink(action:'accept',controller:'story',params:[type:'feature',product:params.product],id:story.id)}"
           data-ajax-trigger="accept_story"
           data-ajax-notice="${message(code: 'is.story.acceptedAsFeature').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.sandbox.menu.acceptAsFeature'/>
        </a>
    </li>
    <li class="menu-accept-task ${sprint?'':'hidden'}" id="menu-accept-task-${story.id}">
        <a href="${createLink(action:'accept',controller:'story',params:[type:'task',product:params.product],id:story.id)}"
           data-ajax-trigger="accept_story"
           data-ajax-notice="${message(code: 'is.story.acceptedAsUrgentTask').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.sandbox.menu.acceptAsUrgentTask'/>
        </a>
    </li>
</g:if>
<g:if test="${inProduct && (story.state == Story.STATE_PLANNED || story.state == Story.STATE_INPROGRESS || template)}">
    <li id="menu-add-task-${story.id}">
        <a href="#sprintPlan/add/${story.parentSprint.id}/?story.id=${story.id}">
           <g:message code='is.ui.sprintPlan.kanban.recurrentTasks.add'/>
        </a>
    </li>
</g:if>
<g:if test="${((productOwner && story.state >= Story.STATE_SUGGESTED && story.state != Story.STATE_DONE) || (creator && story.state == Story.STATE_SUGGESTED)) || template}">
    <li id="menu-edit-${story.id}">
        <a href="#${controllerName}/editStory/${referrer?:story.id}${referrer?'/?subid='+story.id:''}">
           <g:message code='is.ui.releasePlan.menu.story.update'/>
        </a>
    </li>
</g:if>
<g:if test="${(inProduct && story.state >= Story.STATE_SUGGESTED) || template}">
    <li id="menu-copy-${story.id}">
        <a href="${createLink(action:'copy',controller:'story',params:[product:params.product],id:story.id)}"
           data-ajax-trigger="add_story"
           data-ajax-notice="${message(code: 'is.story.cloned').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.releasePlan.menu.story.clone'/>
        </a>
    </li>
</g:if>
<g:if test="${(productOwner || scrumMaster) && (template || story.state >= Story.STATE_PLANNED && story.state != Story.STATE_DONE)}">
    <li id="menu-unplan-${story.id}">
        <a href="${createLink(action:'unPlan',controller:'story',params:[product:params.product],id:story.id)}"
           data-ajax-trigger='{"unPlan_story":"story","sprintMesure_sprint":"sprint"}'
           data-ajax-confirm="${message(code:'is.ui.releasePlan.menu.story.warning.dissociate').encodeAsJavaScript()}"
           data-ajax-notice="${message(code: 'is.sprint.stories.dissociated').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.releasePlan.menu.story.dissociate'/>
        </a>
    </li>
</g:if>
<g:if test="${(productOwner || scrumMaster) && (template || story.state >= Story.STATE_PLANNED && story.state <= Story.STATE_INPROGRESS)}">
     <li id="menu-shift-${story.id}" class="menu-shift-${sprint?.parentRelease?.id}-${(sprint?.orderNumber instanceof Integer ?sprint?.orderNumber + 1:sprint?.orderNumber)} ${nextSprintExist?'':'hidden'}">
         <a href="${createLink(action:'unPlan',controller:'story',params:[product:params.product,shiftToNext:true],id:story.id)}"
            data-ajax-trigger='{"unPlan_story":"story","sprintMesure_sprint":"sprint"}'
            data-ajax-notice="${message(code: 'is.story.shiftedToNext').encodeAsJavaScript()}"
            data-ajax="true">
            <g:message code='is.ui.sprintPlan.menu.postit.shiftToNext'/>
         </a>
     </li>
</g:if>
<g:if test="${productOwner && (story.state == Story.STATE_INPROGRESS || template)}">
     <li id="menu-done-${story.id}">
         <a href="${createLink(action:'done',controller:'story',params:[product:params.product],id:story.id)}"
             data-ajax-trigger="done_story"
             data-ajax-notice="${message(code: 'is.story.declaredAsDone').encodeAsJavaScript()}"
             data-ajax="true">
             <g:message code='is.ui.releasePlan.menu.story.done'/>
         </a>
     </li>
</g:if>
<g:if test="${productOwner && (template || story.state == Story.STATE_DONE && story.parentSprint.state == Sprint.STATE_INPROGRESS)}">
     <li id="menu-undone-${story.id}">
         <a href="${createLink(action:'unDone',controller:'story',params:[product:params.product],id:story.id)}"
              data-ajax-trigger="unDone_story"
              data-ajax-notice="${message(code: 'is.story.declaredAsUnDone').encodeAsJavaScript()}"
              data-ajax="true">
              <g:message code='is.ui.releasePlan.menu.story.undone'/>
         </a>
     </li>
</g:if>

<entry:point id="${controllerName}-postitMenu" model="[story:story,template:template,sprint:sprint]"/>

<g:if test="${(productOwner && story.state <= Story.STATE_ESTIMATED) || (creator && story.state == Story.STATE_SUGGESTED) || template}">
    <li id="menu-delete-${story.id}">
        <a href="${createLink(action:'delete',controller:'story',params:[product:params.product],id:story.id)}"
           data-ajax-trigger="remove_story"
           data-ajax-notice="${message(code: 'is.story.deleted').encodeAsJavaScript()}"
           data-ajax="true">
           <g:message code='is.ui.sandbox.menu.delete'/>
        </a>
    </li>
</g:if>