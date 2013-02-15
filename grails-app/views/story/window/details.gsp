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

<%@ page import="grails.plugin.fluxiable.ActivityLink; grails.plugin.fluxiable.Activity;org.icescrum.core.domain.Story" %>
<div class="dashboard" id="details-${story.id}" data-elemid="${story.id}">
    <div class="colset-2-80 clearfix">
        <div class="col1">

            <is:panel id="panel-infos">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.information')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine
                            legend="${message(code:'is.backlogelement.id')}">${story.uid}</is:panelLine>
                    <is:panelLine
                            legend="${message(code:'is.backlogelement.name')}">${story.name.encodeAsHTML()}</is:panelLine>
                    <is:panelLine legend="${message(code:'is.story.type')}">${message(code: typeCode)}</is:panelLine>
                    <g:if test="${story.affectVersion}">
                        <is:panelLine legend="${message(code:'is.story.affectVersion')}">${story.affectVersion}</is:panelLine>
                    </g:if>
                    <is:panelLine legend="${message(code:'is.feature')}" rendered="${story.feature != null}"
                                  id="${'detail-feature-'+story.feature?.id}">
                        <is:postitIcon name="${story.feature.name.encodeAsHTML()}"
                                       color="${story.feature.color}"/>${story.feature.name.encodeAsHTML()}
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.story.effort')}"
                                  rendered="${story.effort != null}">${story.effort}</is:panelLine>
                    <is:panelLine legend="${message(code:'is.story.rank')}"
                                  rendered="${story.state > Story.STATE_SUGGESTED}">${story.rank}</is:panelLine>
                    <is:panelLine legend="${message(code:'is.sprint')}" rendered="${story.parentSprint != null}">
                        <is:scrumLink controller="releasePlan"
                                      id="${story.parentSprint.parentRelease.id}">${message(code: 'is.release')} ${story.parentSprint.parentRelease.orderNumber}</is:scrumLink> <is:scrumLink
                            controller="sprintPlan"
                            id="${story.parentSprint.id}">${message(code: 'is.sprint')} ${story.parentSprint.orderNumber}</is:scrumLink>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.story.dependsOn')}">
                        <g:if test="${story.dependsOn}">
                            <is:scrumLink controller="story" id="${story.dependsOn.id}">${story.dependsOn.name}</is:scrumLink>
                        </g:if>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.story.dependences')}">
                        <g:if test="${story.dependences}">
                            <g:each var="depend" status="i" in="${story.dependences}">
                                <is:scrumLink controller="story" id="${depend.id}">${depend.name}</is:scrumLink>${i < story.dependences.size() - 1 ? ', ' : ''}
                            </g:each>
                        </g:if>
                    </is:panelLine>
                    <is:panelLine legend="${message(code:'is.story.origin')}"
                                  rendered="${story.origin}">${story.origin?.encodeAsHTML()?:null}</is:panelLine>
                    <is:panelLine legend="${message(code:'is.backlogelement.description')}"><is:storyTemplate
                            displayBR="true" story="${story}"/></is:panelLine>
                    <is:panelLine legend="${message(code:'is.backlogelement.notes')}">
                        <g:if test="${story.notes}">
                            <div class="rich-content">
                                <wikitext:renderHtml markup="Textile">${story.notes}</wikitext:renderHtml>
                            </div>
                        </g:if>
                    </is:panelLine>
                    <is:panelLine
                            legend="${message(code:'is.ui.backlogelement.attachment',args:[story.totalAttachments > 1 ?'s':''])}">
                        <g:if test="${story.totalAttachments}">
                        <is:attachedFiles bean="${story}" deletable="${false}"
                                          params="[product:params.product]"
                                          preview="true"
                                          size="20"/>
                        </g:if>
                    </is:panelLine>
                    <is:panelLine legend="${story.type == Story.TYPE_DEFECT ? message(code:'is.story.deliveredVersion.defect') : message(code:'is.story.deliveredVersion')}"
                                  rendered="${story.deliveredVersion != null}">
                        ${story.deliveredVersion}
                    </is:panelLine>
                    <g:if test="${story.tags}">
                        <is:panelLine legend="${message(code:'is.backlogelement.tags')}">
                                <g:each var="tag" status="i" in="${story.tags}">
                                    <a href="#finder?tag=${tag}">${tag}</a>${i < story.tags.size() - 1 ? ', ' : ''}
                                </g:each>
                        </is:panelLine>
                    </g:if>
                    <is:panelLine legend="${message(code:'is.permalink')}">
                        <a href="${permalink}">${permalink}</a>
                    </is:panelLine>
                </is:panelContext>
            </is:panel>

            <is:panel id="panel-activity">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.activity')}</is:panelTitle>
                <is:panelTabButton id="panel-box-1">
                    <a rel="#summary" class="${!params.tab || 'summary' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.summary')}</a>
                    <a rel="#tests" class="${params.tab && 'tests' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.test')}</a>
                    <a rel="#tasks" class="${params.tab && 'tasks' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.task')}</a>
                    <a rel="#comments" class="${params.tab && 'comments' in params.tab ? 'selected' : ''}">${message(code: 'is.ui.backlogelement.activity.comments')}</a>
                    <entry:point id="${controllerName}-${actionName}-tab-button" model="[tab:params.tab]"/>
                </is:panelTabButton>
                <div id="panel-tab-contents-1" class="panel-tab-contents">
                    <g:include  action="summaryPanel" controller="story" params="[product:params.product, id:story.id]"/>
                    <g:render template="window/tasks" model="[story:story]"/>
                    <g:render template="window/tests" model="[story:story, user:user]"/>
                    <g:render template="/comment/comments" model="[commentable:story, product:story.backlog]"/>
                    <entry:point id="${controllerName}-${actionName}-tab-entry" model="[story:story]"/>
                </div>
                <jq:jquery>
                    $("#panel-box-1 a").live('hover',function(){
                        $(this).each(function() {
                          var item = $(this);
                          var rel = $(item.attr('rel'));
                          item.click(function(){
                            $("#panel-tab-contents-1 .tab-selected").hide();
                            $("#panel-tab-contents-1 .tab-selected").removeClass("tab-selected");
                            $("#panel-box-1 .selected").removeClass("selected");
                            item.addClass("selected");
                            rel.addClass("tab-selected");
                            rel.show();
                            return false;
                          });
                        });
                    });
                </jq:jquery>
            </is:panel>

        </div>

        <div class="col2">

            <is:panel id="panel-people">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.people')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine legend="${message(code:'is.story.creator')}"><is:scrumLink controller="user"
                                                                                             action="profile"
                                                                                             id="${story.creator.username}">${story.creator.firstName.encodeAsHTML()} ${story.creator.lastName.encodeAsHTML()}</is:scrumLink></is:panelLine>
                </is:panelContext>
            </is:panel>

            <g:if test="${story.state >= Story.STATE_SUGGESTED}">
                <is:panel id="panel-dates">
                    <is:panelTitle>${message(code: 'is.ui.backlogelement.dates')}</is:panelTitle>
                    <is:panelContext>
                        <is:panelLine legend="${message(code:'is.story.date.suggested')}"><g:formatDate date="${story.suggestedDate}"
                                                                                                        formatName="is.date.format.short.time"
                                                                                                        timeZone="${story.backlog.preferences.timezone}"/></is:panelLine>
                        <is:panelLine legend="${message(code:'is.story.date.accepted')}"
                                      rendered="${story.acceptedDate != null}"><g:formatDate date="${story.acceptedDate}"
                                                                                             formatName="is.date.format.short.time"
                                                                                             timeZone="${story.backlog.preferences.timezone}"/></is:panelLine>
                        <is:panelLine legend="${message(code:'is.story.date.estimated')}"
                                      rendered="${story.estimatedDate != null}"><g:formatDate date="${story.estimatedDate}"
                                                                                              formatName="is.date.format.short.time"
                                                                                              timeZone="${story.backlog.preferences.timezone}"/></is:panelLine>
                        <is:panelLine legend="${message(code:'is.story.date.planned')}"
                                      rendered="${story.plannedDate != null}"><g:formatDate date="${story.plannedDate}"
                                                                                            formatName="is.date.format.short.time"
                                                                                            timeZone="${story.backlog.preferences.timezone}"/></is:panelLine>
                        <is:panelLine legend="${message(code:'is.story.date.inprogress')}"
                                      rendered="${story.inProgressDate != null}"><g:formatDate date="${story.inProgressDate}" formatName="is.date.format.short.time"
                                                                                            timeZone="${story.backlog.preferences.timezone}"/></is:panelLine>
                        <is:panelLine legend="${message(code:'is.story.date.done')}"
                                      rendered="${story.doneDate != null}"><g:formatDate date="${story.doneDate}"
                                                                                         formatName="is.date.format.short.time"
                                                                                         timeZone="${story.backlog.preferences.timezone}"/></is:panelLine>
                    </is:panelContext>
                </is:panel>
            </g:if>

            <is:panel id="panel-progress">
                <is:panelTitle>${message(code: 'is.ui.backlogelement.progress')}</is:panelTitle>
                <is:panelContext>
                    <is:panelLine
                            legend="${message(code:'is.story.state')}">${message(code: storyStateCode)}</is:panelLine>
                    <g:if test="${story.state >= Story.STATE_PLANNED}">
                        <is:panelLine legend="${message(code:'is.ui.backlogelement.progress.tasks')}">
                            ${tasksDone} / ${story.tasks?.size()}
                        </is:panelLine>
                    </g:if>
                </is:panelContext>
            </is:panel>

            <is:panel id="panel-follow">
                <g:set var="followers" value="${story.getTotalFollowers()}"/>
                <is:panelTitle>${message(code: 'is.followable')} - <b>${followers} ${message(code: 'is.followable.followers', args: [followers > 1 ? 's' : ''])}</b></is:panelTitle>
                <is:panelContext>
                    <is:panelLine legend="${message(code:'is.followable.status')}">
                        <button id="start-follow"
                                onClick="${g.remoteFunction(action: 'follow',
                                        params: [product: params.product],
                                        id: story.id,
                                        before: '$(this).attr(\'disabled\',\'disabled\')',
                                        onSuccess: 'jQuery(\'#panel-follow .panel-box-title b\').text(data.followers); jQuery(\'#start-follow\').hide(); jQuery(\'#stop-follow\').show(); jQuery(\'#start-follow\').removeAttr(\'disabled\')')}"
                                style="display:${isFollower ? 'none' : 'block'}"
                                class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
                            <g:message code="is.followable.start"/>
                        </button>
                        <button id="stop-follow"
                                onClick="${g.remoteFunction(action: 'unfollow',
                                        params: [product: params.product],
                                        id: story.id,
                                        before: '$(this).attr(\'disabled\',\'disabled\')',
                                        onSuccess: 'jQuery(\'#panel-follow .panel-box-title b\').text(data.followers); jQuery(\'#start-follow\').show(); jQuery(\'#stop-follow\').hide() ; jQuery(\'#stop-follow\').removeAttr(\'disabled\')')}"
                                style="display:${isFollower ? 'block' : 'none'}"
                                class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only'>
                            <g:message code="is.followable.stop"/>
                        </button>
                    </is:panelLine>
                </is:panelContext>
            </is:panel>

            <entry:point id="${controllerName}-${actionName}-right" model="[story:story]"/>

        </div>
    </div>
</div>
<is:onStream
            on="#details-${story.id}"
            events="[[object:'story',events:['remove']]]"
            callback="if ( story.id != jQuery(this).data('elemid') ){ return; } jQuery.icescrum.alertDeleteOrUpdateObject('${message(code:'is.story.deleted')}','project',true);"/>
<is:onStream
            on="#details-${story.id}"
            events="[[object:'story',events:['estimate','inProgress','done','unDone','plan','unPlan','associated','dissociated']]]"
            callback="if ( story.id != jQuery(this).data('elemid') ){ return; } document.location.reload();"/>

<is:onStream
            on="#details-${story.id}"
            events="[[object:'story',events:['accept']]]"
            callback="if ( story.id != jQuery(this).data('elemid') ){ return; } var next = jQuery('#next-story'); document.location.hash = next.length ? next.find('a').attr('href') : '#sandbox';"/>

<is:onStream
            on="#details-${story.id}"
            events="[[object:'comment',events:['add','update','remove']]]"
            constraint="comment.backlogElement == ${story.id}"
            template="storyDetail"/>
<is:onStream
            on="#details-${story.id}"
            events="[[object:'comment',events:['add','update','remove']]]"
            constraint="comment.backlogElement == ${story.id}"
            template="storyDetailSummary"/>
<is:onStream
            on="#details-${story.id}"
            events="[[object:'acceptancetest',events:['add','update','remove']]]"
            constraint="acceptancetest.parentStory.id == ${story.id}"
            template="storyDetail"/>