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

<%@ page import="grails.plugin.fluxiable.ActivityLink; grails.plugin.fluxiable.Activity; org.grails.comments.Comment; org.icescrum.core.domain.Story" %>
<div class="dashboard">
  <div class="colset-2-80 clearfix">
    <div class="col1">

      <is:panel id="panel-infos">
        <is:panelTitle>${message(code:'is.ui.backlogelement.information')}</is:panelTitle>
        <is:panelContext>
          <is:panelLine legend="${message(code:'is.backlogelement.name')}">${story.name.encodeAsHTML()}</is:panelLine>
          <is:panelLine legend="${message(code:'is.story.type')}">${message(code:typeCode)}</is:panelLine>
          <is:panelLine legend="${message(code:'is.feature')}" rendered="${story.feature != null}"><is:postitIcon name="${story.feature.name.encodeAsHTML()}" color="${story.feature.color}"/>${story.feature.name.encodeAsHTML()}</is:panelLine>
          <is:panelLine legend="${message(code:'is.story.effort')}" rendered="${story.effort != null}">${story.effort}</is:panelLine>
          <is:panelLine legend="${message(code:'is.story.rank')}" rendered="${story.state > Story.STATE_SUGGESTED}">${story.rank}</is:panelLine>
          <is:panelLine legend="${message(code:'is.sprint')}" rendered="${story.parentSprint != null}">
            <is:scrumLink controller="releasePlan" id="${story.parentSprint.parentRelease.id}">${message(code:'is.release')} ${story.parentSprint.parentRelease.orderNumber}</is:scrumLink> <is:scrumLink controller="sprintBacklog" id="${story.parentSprint.id}">${message(code:'is.sprint')} ${story.parentSprint.orderNumber}</is:scrumLink>
          </is:panelLine>
          <is:panelLine legend="${message(code:'is.story.origin')}" rendered="${story.origin != ''}">${story.origin.encodeAsHTML()}</is:panelLine>
          <is:panelLine legend="${message(code:'is.backlogelement.description')}"><is:storyTemplate displayBR="true" story="${story}"/></is:panelLine>
          <is:panelLine legend="${message(code:'is.backlogelement.notes')}">
            <g:if test="${story.notes}">
              <div class="rich-content">
                <wikitext:renderHtml markup="Textile">${story.notes}</wikitext:renderHtml>
              </div>
            </g:if>
          </is:panelLine>
          <g:if test="${story.totalAttachments}">
            <is:panelLine legend="${message(code:'is.ui.backlogelement.attachment',args:[story.totalAttachments > 1 ?'s':''])}">
                <is:attachedFiles bean="${story}" width="120" deletable="${false}" params="[product:params.product]" action="download" controller="${(story.state > Story.STATE_SUGGESTED)?'productBacklog':'sandbox'}" size="20"/>
            </is:panelLine>
          </g:if>
          <is:panelLine legend="${message(code:'is.permalink')}"><a href="${permalink}">${permalink}</a></is:panelLine>
        </is:panelContext>
      </is:panel>
      <div id="activities-wrapper">

        <g:render template="window/activities" model="[activities:activities, summary:summary, comments:comments, story:story]"/>
      </div>

    </div>

    <div class="col2">

      <is:panel id="panel-people">
        <is:panelTitle>${message(code:'is.ui.backlogelement.people')}</is:panelTitle>
        <is:panelContext>
          <is:panelLine legend="${message(code:'is.story.creator')}"><is:scrumLink controller="user" action="profile" id="${story.creator.username}">${story.creator.firstName.encodeAsHTML()} ${story.creator.lastName.encodeAsHTML()}</is:scrumLink></is:panelLine>
        </is:panelContext>
      </is:panel>

      <is:panel id="panel-dates">
        <is:panelTitle>${message(code:'is.ui.backlogelement.dates')}</is:panelTitle>
        <is:panelContext>
          <is:panelLine legend="${message(code:'is.story.date.suggested')}"><g:formatDate date="${story.suggestedDate}" formatName="is.date.format.short.time"/></is:panelLine>
          <is:panelLine legend="${message(code:'is.story.date.accepted')}" rendered="${story.acceptedDate != null}"><g:formatDate date="${story.acceptedDate}" formatName="is.date.format.short.time"/></is:panelLine>
          <is:panelLine legend="${message(code:'is.story.date.estimated')}" rendered="${story.estimatedDate != null}"><g:formatDate date="${story.estimatedDate}" formatName="is.date.format.short.time"/></is:panelLine>
          <is:panelLine legend="${message(code:'is.story.date.planned')}" rendered="${story.plannedDate != null}"><g:formatDate date="${story.plannedDate}" formatName="is.date.format.short.time"/></is:panelLine>
          <is:panelLine legend="${message(code:'is.story.date.inprogress')}" rendered="${story.inProgressDate != null}"><g:formatDate date="${story.inProgressDate}" formatName="is.date.format.short.time"/></is:panelLine>
          <is:panelLine legend="${message(code:'is.story.date.done')}" rendered="${story.doneDate != null}"><g:formatDate date="${story.doneDate}" formatName="is.date.format.short.time"/></is:panelLine>
        </is:panelContext>
      </is:panel>

      <is:panel id="panel-progress">
        <is:panelTitle>${message(code:'is.ui.backlogelement.progress')}</is:panelTitle>
        <is:panelContext>
          <is:panelLine legend="${message(code:'is.story.state')}">${message(code:storyStateCode)}</is:panelLine>
          <is:panelLine legend="${message(code:'is.ui.backlogelement.progress.tasks')}">
            ${tasksDone} / ${story.tasks?.size()}
          </is:panelLine>
        </is:panelContext>
      </is:panel>

      <is:panel id="panel-follow">
        <g:set var="followers" value="${story.getTotalFollowers()}"/>
        <is:panelTitle>${message(code:'is.followable')} - <b>${followers} ${message(code:'is.followable.followers', args:[followers > 1 ? 's' : ''])}</b></is:panelTitle>
        <is:panelContext>
          <is:panelLine legend="${message(code:'is.followable.status')}">
            <button id="start-follow"
                    onClick="${g.remoteFunction(action:'follow',
                                   controller:id,
                                   params:[product:params.product],
                                   id:story.id,
                                   before:'$(this).attr(\'disabled\',\'disabled\')',
                                   onSuccess:'jQuery(\'#panel-follow .panel-box-title b\').text(data.followers); jQuery(\'#start-follow\').hide(); jQuery(\'#stop-follow\').show(); jQuery(\'#start-follow\').removeAttr(\'disabled\')')}"
                    style="display:${isFollower?'none':'block'}"
                    class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
              <g:message code="is.followable.start"/>
            </button>
            <button id="stop-follow"
                    onClick="${g.remoteFunction(action:'unfollow',
                                   controller:id,
                                   params:[product:params.product],
                                   id:story.id,
                                   before:'$(this).attr(\'disabled\',\'disabled\')',
                                   onSuccess:'jQuery(\'#panel-follow .panel-box-title b\').text(data.followers); jQuery(\'#start-follow\').show(); jQuery(\'#stop-follow\').hide() ; jQuery(\'#stop-follow\').removeAttr(\'disabled\')')}"
                    style="display:${isFollower?'block':'none'}"
                    class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
              <g:message code="is.followable.stop"/>
            </button>
          </is:panelLine>
        </is:panelContext>
      </is:panel>

      <entry:point id="${id}-${actionName}-right" model="[story:story]"/>

    </div>
  </div>
</div>
<jq:jquery>
  <is:renderJavascript/>
  <icep:notifications
        name="${id}Window"
        reload="[update:'#window-content-'+id,action:'details',id:params.id, params:[product:params.product]]"
        before="var selTab = jQuery('#panel-activity .panel-tab-button .selected').attr('rel')"
        disabled="!(selTab == '#comments' && jQuery('#commentEditorContainer').is(':visible'))"
        group="${params.product}-${id}-${params.id}"
        listenOn="#window-content-${id}"/>
  <icep:notifications
        name="${id}Activities"
        before="var selTab = jQuery('#panel-activity .panel-tab-button .selected').attr('rel')"
        disabled="!(selTab == '#comments' && jQuery('#commentEditorContainer').is(':visible'))"
        reload="[update:'#activities-wrapper',action:'activitiesPanel',id:params.id, params:[product:params.product], onComplete:'function(){jQuery.icescrum.openTab(selTab);}']"
        group="${params.product}-${id}-${params.id}-activities"
        listenOn="#window-content-${id}"/>
  <icep:notifications
        name="${id}Followers"
        callback="${g.remoteFunction(controller:id,action:'followers',id:params.id, params:[product:params.product],onSuccess:'jQuery(\'#panel-follow .panel-box-title b\').text(data.followers);')}"
        group="${params.product}-${id}-${params.id}-followers"
        listenOn="#window-content-${id}"/>
</jq:jquery>