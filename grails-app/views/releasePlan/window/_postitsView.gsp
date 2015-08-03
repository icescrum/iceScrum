%{--
- Copyright (c) 2014 Kagilum SAS.
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
<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Sprint;" %>
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>

<is:eventline container="#window-content-${controllerName}" elemid="${release.id}"
              focus="${activeSprint ? activeSprint.id : sprints ? sprints.last().id : null}"
              style="display:${sprints?'block':'none'};">
    <g:each in="${sprints}" var="sprint" status="u">
            <g:set var="nextSprintExist" value="${sprint.hasNextSprint}"/>
            <is:event title="${message(code:'is.sprint')} ${sprint.orderNumber}"
                      elemid="${sprint.id}">
            %{-- Header of the sprint column --}%
                <is:eventHeader class="state-${sprint.state}">
                    <div class="event-header-label">
                        <div class="event-header-velocity">
                            <g:if test="${Sprint.STATE_WAIT == sprint.state}">
                                ${sprint.capacity?.toInteger()}
                            </g:if>
                            <g:else>
                                ${sprint.velocity?.toInteger()} / ${sprint.capacity?.toInteger()}
                            </g:else>
                        </div>
                        <div class="event-header-title">
                            <g:if test="${request.inProduct}">
                                <a href="#sprintPlan/${sprint.id}">
                            </g:if>
                            ${message(code: 'is.sprint')} ${sprint.orderNumber} - <span class="state"><is:bundle bundle="sprintStates" value="${sprint.state}"/></span>
                            <g:if test="${request.inProduct}">
                                </a>
                            </g:if>
                        </div>
                    </div>
                    <div class="drap-container">
                        ${message(code: 'is.ui.releasePlan.from')} <strong><g:formatDate date="${sprint.startDate}"
                                                                                         formatName="is.date.format.short" timeZone="${release.parentProduct.preferences.timezone}"/></strong>
                        ${message(code: 'is.ui.releasePlan.to')} <strong><g:formatDate date="${sprint.endDate}"
                                                                                       formatName="is.date.format.short" timeZone="${release.parentProduct.preferences.timezone}"/></strong>
                        <div class="dropmenu-action">
                            <div data-dropmenu="true" class="dropmenu" data-top="0" data-offset="0" data-noWindows="false" id="menu-postit-sprint-${sprint.id}">
                                <span class="dropmenu-arrow">!</span>
                                <div class="dropmenu-content ui-corner-all">
                                    <ul class="small">
                                        <g:render template="/sprint/menu" model="[sprint:sprint]"/>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="tooltip">
                        <span class="tooltip-title">${message(code:'is.sprint')} ${sprint.orderNumber} ${sprint.deliveredVersion ? '('+sprint.deliveredVersion+')' : ''}</span>
                        ${sprint.goal?.encodeAsHTML() ?: ''}
                    </div>
                </is:eventHeader>

            %{-- Content of the sprint column --}%
                <is:eventContent
                        droppable="[
                            rendered:(poOrSm && sprint.state != Sprint.STATE_DONE),
                            hoverClass:'ui-drop-hover',
                            accept:'.postit-row-story-backlog',
                            drop:remoteFunction(action:'plan',
                                      controller:'story',
                                      onSuccess:'ui.draggable.attr(\'remove\',\'true\'); jQuery.event.trigger(\'plan_story\',data.story)',
                                      params: '\'product='+params.product+'&id=\'+ui.draggable.data(\'elemid\')+\'&sprint.id='+sprint.id+'\'')]">
                    %{-- Commented out because it doesn't compile when creating war
                    <is:backlogElementLayout
                            id="plan-${controllerName}-${sprint.id}"
                            sortable='[
                              rendered:poOrSm && sprint.state != Sprint.STATE_DONE,
                              handle:".postit-layout .postit-sortable",
                              connectWith:".backlog",
                              containment:".event-overflow",
                              change:"jQuery.icescrum.story.checkDependsOnPostitsView(ui);",
                              placeholder:"ui-drop-hover-postit-rect ui-corner-all",
                              update:"if(jQuery(\"#backlog-layout-plan-${controllerName}-${sprint.id} .postit-rect\").index(ui.item) == -1 || ui.sender != undefined){return}else{${is.changeRank(selector:"#backlog-layout-plan-${controllerName}-${sprint.id} .postit-rect",controller:"story",action:"rank",name:"story.rank",onSuccess:"jQuery.icescrum.story.updateRank(params,data,\"#backlog-layout-plan-${controllerName}-${sprint.id}\");", params:[product:params.product])}}",
                              receive:"event.stopPropagation();"+remoteFunction(action:"plan",
                                          controller:"story",
                                          onFailure: "jQuery(ui.sender).sortable(\"cancel\");",
                                          onSuccess:"jQuery.event.trigger(\"plan_story\",data.story); if(data.oldSprint){ jQuery.event.trigger(\"sprintMesure_sprint\",data.oldSprint); }",
                                          params: "\"product=${params.product}&id=\"+ui.item.data(\"elemid\")+\"&sprint.id=${sprint.id}&position=\"+(jQuery(\"#backlog-layout-plan-${controllerName}-${sprint.id} .postit-rect\").index(ui.item)+1)")
                      ]'
                            dblclickable="[selector:'.postit-rect',callback:'$.icescrum.displayQuicklook(obj)']"
                            value="${sprint.stories?.sort{it.rank}}"
                            var="story"
                            emptyRendering="true">
                            <g:render template="/story/postit"
                                      model="[story:story,rect:true,user:user,sortable:(request.productOwner && story.state != Story.STATE_DONE),sprint:sprint,nextSprintExist:nextSprintExist,referrer:release.id]"/>
                    </is:backlogElementLayout>--}%
                </is:eventContent>

            </is:event>
    </g:each>
</is:eventline>

<g:render template="/releasePlan/window/blankSprint" model="[show:sprints ? false : true,release:release]"/>

<jq:jquery>
    $('#window-title-bar-${controllerName} .content').html('${message(code: "is.ui." + controllerName)} - ${release.name?.encodeAsJavaScript()}  - ${is.bundle(bundle: 'releaseStates', value: release.state)} - [${g.formatDate(date: release.startDate, formatName: 'is.date.format.short', timeZone:release.parentProduct.preferences.timezone)} -> ${g.formatDate(date: release.endDate, formatName: 'is.date.format.short',timeZone:release.parentProduct.preferences.timezone)}]');
    <is:editable controller="story"
                 action='update'
                 on='div.backlog .postit-story .mini-value.editable'
                 findId="jQuery(this).parents('.postit-story:first').data(\'elemid\')"
                 type="selectui"
                 name="story.effort"
                 before="jQuery(this).next().hide();"
                 cancel="jQuery(original).next().show();"
                 values="${suiteSelect}"
                 restrictOnNotAccess='teamMember() or scrumMaster()'
                 ajaxoptions = "{dataType:'json'}"
                 callback="jQuery(this).next().show();jQuery(this).html(value.effort);jQuery.event.trigger('sprintMesure_sprint', value.parentSprint);"
                 params="[product:params.product]"/>
</jq:jquery>

<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;} jQuery.icescrum.dblclickSelectable(null,null,\$.icescrum.displayQuicklook,true);"
             scope="${controllerName}"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'story',events:['update']],[object:'feature',events:['update']]]"
        template="releasePlan"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'sprint',events:['add','update','remove','activate','close','sprintMesure']]]"
        template="window"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'release',events:['close']]]"
        callback="jQuery('.close-release-' + release.id).remove();"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'feature',events:['update']]]"/>