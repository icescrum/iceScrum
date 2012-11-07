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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%

<%@ page import="org.icescrum.core.domain.Story;" %>
<g:set var="creator" value="${story.creator.id == user?.id}"/>
<g:set var="canEdit" value="${(request.productOwner && story.state >= Story.STATE_SUGGESTED && story.state != Story.STATE_DONE) || (creator && story.state == Story.STATE_SUGGESTED)}"/>
<g:if test="${canEdit}">
    <li class="navigation-item">
        <a class="tool-button button-n"
           href="#${controllerName}/editStory/${story.id}"
           title="${message(code:'is.ui.backlogelement.toolbar.update')}"
           alt="${message(code:'is.ui.backlogelement.toolbar.update')}">
            <span class="start"></span>
            <span class="content">
                ${message(code: 'is.ui.backlogelement.toolbar.update')}
            </span>
            <span class="end"></span>
        </a>
    </li>
</g:if>

%{--View--}%
<g:if test="${request.productOwner && story.state == Story.STATE_SUGGESTED}">

    <is:panelButton
            id="accept-display"
            arrow="true"
            separator="${canEdit}"
            text="${message(code:'is.ui.backlogelement.toolbar.accept')}">
        <ul>
            <li class="first">
                <a href="${createLink(action:'accept',controller:'story',params:[type:'story',product:params.product],id:story.id)}"
                   data-ajax-trigger="accept_story"
                   data-ajax-notice="${message(code: 'is.story.acceptedAsStory').encodeAsJavaScript()}"
                   data-ajax="true">
                   <g:message code='is.ui.backlogelement.toolbar.acceptAsStory'/>
                </a>
            </li>

            <g:if test="${!sprint}">
                <li class="last">
            </g:if>
            <g:else>
                <li>
            </g:else>
            <a href="${createLink(action:'accept',controller:'story',params:[type:'feature',product:params.product],id:story.id)}"
               data-ajax-notice="${message(code: 'is.story.acceptedAsFeature').encodeAsJavaScript()}"
               data-ajax-success="#feature"
               data-ajax="true">
               <g:message code='is.ui.backlogelement.toolbar.acceptAsFeature'/>
            </a>
        </li>

            <g:if test="${sprint}">
                <li class="last">
                    <a href="${createLink(action:'accept',controller:'story',params:[type:'task',product:params.product],id:story.id)}"
                       data-ajax-notice="${message(code: 'is.story.acceptedAsUrgentTask').encodeAsJavaScript()}"
                       data-ajax-success="#sprintPlan"
                       data-ajax="true">
                       <g:message code='is.ui.backlogelement.toolbar.acceptAsUrgentTask'/>
                    </a>
                </li>
            </g:if>

        </ul>
    </is:panelButton>
</g:if>

<g:if test="${(request.productOwner && story.state <= Story.STATE_ESTIMATED) || (creator && story.state == Story.STATE_SUGGESTED)}">

    <li class="navigation-item ${request.productOwner && story.state == Story.STATE_SUGGESTED ? 'separator' : ''}">
        <a class="tool-button button-n"
           href="${createLink(controller:'story', action:'delete',id:story.id,params:[product:params.product])}"
           data-ajax-notice="${message(code:'is.story.deleted').encodeAsJavaScript()}"
           data-ajax-trigger="remove_story"
           data-ajax-success="#${story.state > Story.STATE_SUGGESTED ? 'backlog' : 'sandbox'}"
           data-ajax="true"
           title="${message(code:'is.ui.backlogelement.toolbar.delete')}"
           alt="${message(code:'is.ui.backlogelement.toolbar.delete')}">
                <span class="start"></span>
                <span class="content">
                    ${message(code: 'is.ui.backlogelement.toolbar.delete')}
                </span>
                <span class="end"></span>
        </a>
    </li>
</g:if>

<entry:point id="${controllerName}-${actionName}-toolbar"/>

<div class="navigation-right-toolbar">

    <g:if test="${previous}">
        <li class="navigation-item">
            <a class="tool-button button-n"
               href="#${controllerName}/${previous.id}"
               title="${message(code:'is.ui.backlogelement.toolbar.previous')}"
               alt="${message(code:'is.ui.backlogelement.toolbar.previous')}">
                    <span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.backlogelement.toolbar.previous')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>
    </g:if>

    <g:if test="${next}">
        <li class="navigation-item ${previous ? 'separator' : ''}">
            <a class="tool-button button-n"
               href="#${controllerName}/${next.id}"
               title="${message(code:'is.ui.backlogelement.toolbar.next')}"
               alt="${message(code:'is.ui.backlogelement.toolbar.next')}"><span class="start"></span>
                    <span class="content">
                        ${message(code: 'is.ui.backlogelement.toolbar.next')}
                    </span>
                    <span class="end"></span>
            </a>
        </li>
    </g:if>

</div>