%{--
- Copyright (c) 2014 Kagilum.
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
<%@ page import="org.icescrum.core.domain.Story" %>
<script type="text/icescrum-template" id="tpl-story-menu">
<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
    <span class="fa fa-cog"></span> <span class="caret"></span>
</button>
<ul class="dropdown-menu" role="menu">
    **# if ($.icescrum.user.productOwner && story.state == $.icescrum.story.STATE_SUGGESTED) { **
    <li role="presentation" class="dropdown-header">${message(code:'todo.is.ui.menu.accept')}</li>
    <li>
        <a href="${createLink(action:'update',controller:'story', id:'** story.id **', params:['story.state':Story.STATE_ACCEPTED,product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="accept_story"
           data-ajax-notice="${message(code: 'is.story.acceptedAsStory').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.story'/>
        </a>
    </li>
    <li>
        <a href="${createLink(action:'acceptAsFeature',controller:'story', id:'** story.id **', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="accept_story"
           data-ajax-notice="${message(code: 'is.story.acceptedAsFeature').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.feature'/>
        </a>
    </li>
    **# if ($.icescrum.sprint.current) { **
    <li class="menu-accept-task">
        <a href="${createLink(action:'acceptAsTask',controller:'story', id:'** story.id **', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="accept_story"
           data-ajax-notice="${message(code: 'is.story.acceptedAsUrgentTask').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.task'/>
        </a>
    </li>
    **# } **
    **# } **
    <li role="presentation" class="divider"></li>
    <li role="presentation" class="dropdown-header">${message(code:'todo.is.ui.menu.common')}</li>
    **# if ($.icescrum.user.productOwner && _.contains([$.icescrum.story.STATE_ACCEPTED, $.icescrum.story.STATE_ESTIMATED], story.state)) { **
    <li>
        <a href="${createLink(action:'returnToSandbox', id:'** story.id **', controller:'story',params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="returnToSandbox_story"
           data-ajax-notice="${message(code: 'is.story.returnedToSandbox').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.ui.backlog.menu.returnToSandbox'/>
        </a>
    </li>
    **# } **
    **# if ($.icescrum.user.inProduct && _.contains([$.icescrum.story.STATE_PLANNED, $.icescrum.story.STATE_INPROGRESS], story.state)) { **
    <li>
        <a href="#sprintPlan/add/** story.parentSprint.id **/?story.id=** story.id **">
            <g:message code='is.ui.sprintPlan.kanban.recurrentTasks.add'/>
        </a>
    </li>
    **# } **
    **# if ($.icescrum.user.inProduct && story.state >= $.icescrum.story.STATE_SUGGESTED) { **
    <li>
        <a href="${createLink(action:'copy',controller:'story', id:'** story.id **', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="add_story"
           data-ajax-notice="${message(code: 'is.story.cloned').encodeAsJavaScript()}"
           data-ajax="true">
            <i class="glyphicon glyphicon-transfer"></i> <g:message code='is.ui.releasePlan.menu.story.clone'/>
        </a>
    </li>
    **# } **
    **# if ($.icescrum.user.poOrSm && story.state >= $.icescrum.story.STATE_PLANNED && story.state != $.icescrum.story.STATE_DONE) { **
    <li>
        <a href="${createLink(action:'unPlan',controller:'story', id:'** story.id **', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger='{"unPlan_story":"story","sprintMesure_sprint":"sprint"}'
           data-ajax-confirm="${message(code:'is.ui.releasePlan.menu.story.warning.dissociate').encodeAsJavaScript()}"
           data-ajax-notice="${message(code: 'is.sprint.stories.dissociated').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.ui.releasePlan.menu.story.dissociate'/>
        </a>
    </li>
    **# } **
    **# if ($.icescrum.user.poOrSm && story.state >= $.icescrum.story.STATE_PLANNED && story.state != $.icescrum.story.STATE_INPROGRESS) { **
    <li class="menu-shift-${sprint?.parentRelease?.id}-${(sprint?.orderNumber instanceof Integer ?sprint?.orderNumber + 1:sprint?.orderNumber)} ${nextSprintExist?'':'hidden'}">
        <a href="${createLink(action:'unPlan',controller:'story', id:'** story.id **',params:[product:'** jQuery.icescrum.product.pkey **',shiftToNext:true])}"
           data-ajax-trigger='{"unPlan_story":"story","sprintMesure_sprint":"sprint"}'
           data-ajax-notice="${message(code: 'is.story.shiftedToNext').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.ui.sprintPlan.menu.postit.shiftToNext'/>
        </a>
    </li>
    **# } **
    **# if ($.icescrum.user.productOwner && story.state == $.icescrum.story.STATE_INPROGRESS) { **
    <li>
        <a href="${createLink(action:'done',controller:'story', id:'** story.id **', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="done_story"
           data-ajax-notice="${message(code: 'is.story.declaredAsDone').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.ui.releasePlan.menu.story.done'/>
        </a>
    </li>
    **# } **
    **# if ($.icescrum.user.productOwner && story.state == $.icescrum.story.STATE_DONE && story.parentSprint.state == $.icescrum.sprint.STATE_INPROGRESS) { **
    <li>
        <a href="${createLink(action:'unDone',controller:'story', id:'** story.id **', params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax-trigger="unDone_story"
           data-ajax-notice="${message(code: 'is.story.declaredAsUnDone').encodeAsJavaScript()}"
           data-ajax="true">
            <g:message code='is.ui.releasePlan.menu.story.undone'/>
        </a>
    </li>
    **# } **
    <entry:point id="${controllerName}-postitMenu"/>
    **# if (($.icescrum.user.productOwner && story.state <= $.icescrum.story.STATE_ESTIMATED) || ($.icescrum.user.productOwner && story.state <= $.icescrum.story.STATE_SUGGESTED)) { **
    <li>
        <a href="${createLink(action:'openDialogDelete',controller:'story', id:'** story.id **',params:[product:'** jQuery.icescrum.product.pkey **'])}"
           data-ajax="$.icescrum.story.delete"
           data-ajax="true">
            <i class="text-danger glyphicon glyphicon-trash"></i> <span class="text-danger"><g:message code='is.ui.sandbox.menu.delete'/></span>
        </a>
    </li>
    **# } **
</ul>
</script>