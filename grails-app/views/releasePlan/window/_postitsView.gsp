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
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Sprint;" %>
<g:set var="poOrSm" value="${request.productOwner || request.scrumMaster}"/>

<is:eventline container="#window-content-${id}" elemid="${release.id}"
              focus="${activeSprint ? activeSprint.id : sprints ? sprints.last().id : null}"
              style="display:${sprints?'block':'none'};">
    <g:each in="${sprints}" var="sprint" status="u">
            <g:set var="nextSprintExist" value="${sprint.hasNextSprint}"/>
            <is:event title="${message(code:'is.sprint')} ${sprint.orderNumber}"
                      elemid="${sprint.id}"
                      cacheable="[cache:'SprintCache',key:'sprintEvent',disabled:sprint.state != Sprint.STATE_DONE]">
            %{-- Header of the sprint column --}%
                <is:eventHeader class="state-${sprint.state}">
                    <g:if test="${request.inProduct}">
                        <div class="event-header-label" onclick="$.icescrum.stopEvent(event).openWindow('sprintPlan/${sprint.id}');">
                    </g:if>
                    <g:else>
                        <div class="event-header-label">
                    </g:else>
                    ${message(code: 'is.sprint')} ${sprint.orderNumber} - <span class="state"><is:bundle
                        bundle="sprintStates" value="${sprint.state}"/></span>

                    <div class="event-header-velocity">
                        <g:if test="${Sprint.STATE_WAIT == sprint.state}">
                            ${sprint.capacity?.toInteger()}
                        </g:if>
                        <g:else>
                            ${sprint.velocity?.toInteger()} / ${sprint.capacity?.toInteger()}
                        </g:else>
                    </div>

                    </div>

                    <div class="drap-container">
                        ${message(code: 'is.ui.releasePlan.from')} <strong><g:formatDate date="${sprint.startDate}"
                                                                                         formatName="is.date.format.short" timeZone="${release.parentProduct.preferences.timezone}"/></strong>
                        ${message(code: 'is.ui.releasePlan.to')} <strong><g:formatDate date="${sprint.endDate}"
                                                                                       formatName="is.date.format.short" timeZone="${release.parentProduct.preferences.timezone}"/></strong>
                        <is:menu class="dropmenu-action" id="sprint-${sprint.id}" contentView="/sprint/menu"
                                 params="[id:id,sprint:sprint]"/>
                    </div>

                    <g:if test="${sprint.goal}">
                        <is:tooltipSprint
                                id="${sprint.id}"
                                title="${message(code:'is.sprint')} ${sprint.orderNumber}"
                                text="${sprint.goal.encodeAsHTML()}"
                                container="jQuery('#window-content-releasePlan')"/>
                    </g:if>
                </is:eventHeader>

            %{-- Content of the sprint column --}%
                <is:eventContent
                        droppable="[
                            rendered:(poOrSm && sprint.state != Sprint.STATE_DONE),
                            hoverClass:'ui-drop-hover',
                            accept:'.postit-row-story',
                            drop:remoteFunction(action:'plan',
                                      controller:'story',
                                      onSuccess:'ui.draggable.attr(\'remove\',\'true\'); jQuery.event.trigger(\'plan_story\',data.story)',
                                      params: '\'product='+params.product+'&id=\'+ui.draggable.attr(\'elemid\')+\'&sprint.id='+sprint.id+'\'')]">
                    <is:backlogElementLayout
                            id="plan-${id}-${sprint.id}"
                            sortable='[
                              rendered:poOrSm && sprint.state != Sprint.STATE_DONE,
                              handle:".postit-layout .postit-sortable",
                              connectWith:".backlog",
                              placeholder:"ui-drop-hover-postit-rect ui-corner-all",
                              update:"if(jQuery(\"#backlog-layout-plan-${id}-${sprint.id} .postit-rect\").index(ui.item) == -1 || ui.sender != undefined){return}else{${is.changeRank(selector:"#backlog-layout-plan-${id}-${sprint.id} .postit-rect",controller:"story",action:"rank",name:"story.rank",params:"&product=${params.product}")}}",
                              receive:"event.stopPropagation();"+remoteFunction(action:"plan",
                                          controller:"story",
                                          onFailure: "jQuery(ui).sortable(\"cancel\");",
                                          onSuccess:"jQuery.event.trigger(\"plan_story\",data.story); if(data.oldSprint){ jQuery.event.trigger(\"sprintMesure_sprint\",data.oldSprint); }",
                                          params: "\"product=${params.product}&id=\"+ui.item.attr(\"elemid\")+\"&sprint.id=${sprint.id}&position=\"+(jQuery(\"#backlog-layout-plan-${id}-${sprint.id} .postit-rect\").index(ui.item)+1)")
                      ]'
                            dblclickable="[selector:'.postit-rect',callback:is.quickLook(params:'\'story.id=\'+$.icescrum.postit.id(obj)')]"
                            value="${sprint.stories?.sort{it.rank}}"
                            var="story"
                            emptyRendering="true">
                            <is:cache cache="storyCache" key="postit-rect-${story.id}-${story.lastUpdated}">
                                <g:include view="/story/_postit.gsp"
                                           model="[id:id,story:story,rect:true,user:user,sortable:(request.productOwner && story.state != Story.STATE_DONE),sprint:sprint,nextSprintExist:nextSprintExist,referrer:release.id]"
                                           params="[product:params.product]"/>
                            </is:cache>
                    </is:backlogElementLayout>
                </is:eventContent>

            </is:event>
    </g:each>
</is:eventline>

<g:include view="/releasePlan/window/_blankSprint.gsp" model="[sprints:sprints,id:id,release:release]"
           params="[product:params.product]"/>

<jq:jquery>
    jQuery('#window-title-bar-${id} .content').html('${message(code: "is.ui." + id)} - ${release.name}  - ${is.bundle(bundle: 'releaseStates', value: release.state)} - [${g.formatDate(date: release.startDate, formatName: 'is.date.format.short', timeZone:release.parentProduct.preferences.timezone)} -> ${g.formatDate(date: release.endDate, formatName: 'is.date.format.short',timeZone:release.parentProduct.preferences.timezone)}]');
    <is:editable controller="story"
                 action='estimate'
                 on='div.backlog .postit-story .mini-value.editable'
                 findId="jQuery(this).parents('.postit-story:first').attr(\'elemid\')"
                 type="selectui"
                 name="story.effort"
                 before="jQuery(this).next().hide();"
                 cancel="jQuery(original).next().show();"
                 values="${suiteSelect}"
                 restrictOnNotAccess='teamMember() or scrumMaster()'
                 callback="jQuery(this).next().show();"
                 params="[product:params.product]"/>
</jq:jquery>

<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;} jQuery.icescrum.dblclickSelectable(null,null,function(obj){${is.quickLook(params:'\'story.id=\'+jQuery.icescrum.postit.id(obj.selected)')}},true);"
             scope="${id}"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'story',events:['update','estimate','unPlan','plan','done','unDone','inProgress','associated','dissociated']]]"
        template="releasePlan"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'sprint',events:['add','update','remove','activate','close','sprintMesure']]]"
        template="window"/>

<is:onStream
        on=".event-overflow"
        events="[[object:'release',events:['close']]]"
        callback="jQuery('.close-release-' + release.id).remove();"/>