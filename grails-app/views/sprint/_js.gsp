%{--
- Copyright (c) 2011 Kagilum SAS.
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
<%@ page import="org.icescrum.core.domain.Sprint" %>
<g:set var="poOrSm" value="${request.scrumMaster || request.productOwner}"/>

<g:set var="sprint" value="[id:'?**=this.id**?',
                          orderNumber:'?**=this.orderNumber**?',
                          state:'?**=this.state**?',
                          capacity:'?**=this.capacity**?',
                          parentRelease:[id:'?**=this.parentRelease.id**?'],
                          velocity:'?**=this.velocity**?',
                          startDate:'?**=this.startDate**?',
                          endDate:'?**=this.endDate**?',
                          description:'?**=description**?',
                          goal:'?**=this.goal**?']"/>

<template id="sprint-${id}-tmpl">
    <![CDATA[
    ?**
    var textState = jQuery.icescrum.sprint.states[this.state];
    var startDate = jQuery.icescrum.dateLocaleFormat(this.startDate);
    var endDate = jQuery.icescrum.dateLocaleFormat(this.endDate);
    var sprintMesure = (this.state != ${Sprint.STATE_WAIT}) ? this.capacity+' / '+this.velocity : this.capacity;
    **?
    <is:eventline onlyEvents="true">
        <is:event title="sprint ${sprint.orderNumber}" elemid="${sprint.id}">
        %{-- Header of the sprint column --}%
            <is:eventHeader class="state-${sprint.state}" style="position:relative;">
                <g:if test="${request.inProduct}">
                    <div class="event-header-label" onclick="$.icescrum.stopEvent(event).openWindow('sprintPlan/${sprint.id}');">
                </g:if>
                <g:else>
                    <div class="event-header-label">
                </g:else>
                ${message(code: 'is.sprint')} ${sprint.orderNumber} - <span class="state">?**=textState**?</span>

                <div class="event-header-velocity">
                    ?**=sprintMesure**?
                </div>

                </div>

                <div class="drap-container">
                    ${message(code: 'is.ui.releasePlan.from')} <strong>?**=startDate**?</strong>
                    ${message(code: 'is.ui.releasePlan.to')} <strong>?**=endDate**?</strong>
                    <is:menu class="dropmenu-action" id="${sprint.id}" contentView="/sprint/menu"
                             params="[id:id,sprint:sprint,template:true]"/>
                </div>

                <g:if test="${sprint.goal}">
                    <is:tooltipSprint
                            id="releasePlan-${sprint.orderNumber}"
                            title="${message(code:'is.sprint')} ${sprint.orderNumber}"
                            text="${sprint.goal}"
                            container="jQuery('.event-line-limiter')"/>
                </g:if>
            </is:eventHeader>

        %{-- Content of the sprint column --}%
            <is:eventContent
                    droppable="[
                            rendered:poOrSm,
                            hoverClass:'ui-drop-hover',
                            accept:'.postit-row-story',
                            drop:remoteFunction(action:'plan',
                                      controller:'story',
                                      onSuccess:'jQuery.event.trigger(\'plan_story\',data.story)',
                                      params: '\'product='+params.product+'&id=\'+ui.draggable.attr(\'elemId\')+\'&sprint.id='+sprint.id+'\'')]">
                <is:backlogElementLayout
                        id="plan-${id}-${sprint.id}"
                        sortable='[
                              rendered:request.productOwner,
                              handle:".postit-layout .postit-sortable",
                              connectWith:".backlog",
                              placeholder:"ui-drop-hover-postit-rect ui-corner-all",
                              update:"if(jQuery(\"#backlog-layout-plan-${sprint.id} .postit-rect\").index(ui.item) == -1 || ui.sender != undefined){return}else{${is.changeRank(selector:"#backlog-layout-plan-${id}-${sprint.id} .postit-rect",controller:id,action:"changeRank",name:"sprint.rank",params:"&product=${params.product}")}}",
                              receive:"event.stopPropagation();"+remoteFunction(action:"plan",
                                          controller:"story",
                                          onFailure: "jQuery(ui).sortable(\"cancel\");",
                                          onSuccess:"jQuery.event.trigger(\"lan_story\",data.story); if(data.oldSprint){  jQuery.event.trigger(\"sprintMesure_sprint\",data.oldSprint); }",
                                          params: "\"product=${params.product}&id=\"+ui.item.attr(\"elemId\")+\"&sprint.id=${sprint.id}&position=\"+(jQuery(\"#backlog-layout-plan-${id}-${sprint.id} .postit-rect\").index(ui.item)+1)")
                      ]'
                        dblclickable="[selector:'.postit-rect',callback:is.quickLook(params:'\'story.id=\'+jQuery.icescrum.postit.id(obj)')]"
                        emptyRendering="true">
                </is:backlogElementLayout>
            </is:eventContent>

        </is:event>
    </is:eventline>
    ]]>
</template>

<template id="sprint-${id}-update-tmpl">
    <![CDATA[
    ?**
    var textState = jQuery.icescrum.sprint.states[this.state];
    var startDate = jQuery.icescrum.dateLocaleFormat(this.startDate);
    var endDate = (this.state != ${Sprint.STATE_DONE}) ? jQuery.icescrum.dateLocaleFormat(this.endDate) : jQuery.icescrum.dateLocaleFormat(this.closeDate);
    var sprintMesure = (this.state != ${Sprint.STATE_WAIT}) ? this.velocity+' / '+this.capacity : this.capacity;
    **?
    <div class="event-header state-?**=this.state**?" class="state-${sprint.state}" style="position:relative;"
         elemid="${sprint.id}">
        <g:if test="${request.inProduct}">
            <div class="event-header-label" onclick="$.icescrum.stopEvent(event).openWindow('sprintPlan/${sprint.id}');">
        </g:if>
        <g:else>
            <div class="event-header-label">
        </g:else>
        ${message(code: 'is.sprint')} ${sprint.orderNumber} - <span class="state">?**=textState**?</span>

        <div class="event-header-velocity">
            ?**=sprintMesure**?
        </div>
    </div>

        <div class="drap-container">
            ${message(code: 'is.ui.releasePlan.from')} <strong>?**=startDate**?</strong>
            ${message(code: 'is.ui.releasePlan.to')} <strong>?**=endDate**?</strong>
            <is:menu class="dropmenu-action" id="${sprint.id}" contentView="/sprint/menu"
                     params="[id:id,sprint:sprint,template:true]"/>
        </div>

        <g:if test="${sprint.goal}">
            <is:tooltipSprint
                    id="releasePlan-${sprint.orderNumber}"
                    title="${message(code:'is.sprint')} ${sprint.orderNumber}"
                    text="${sprint.goal}"
                    container="jQuery('.event-line-limiter')"/>
        </g:if>
    </div>
    ]]>
</template>