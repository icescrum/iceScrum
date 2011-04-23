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

<g:set var="poOrSm" value="${sec.access([expression:'productOwner() or scrumMaster()'], {true})}"/>
<g:set var="productOwner" value="${sec.access([expression:'productOwner()'], {true})}"/>


<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Sprint;" %>
<is:releaseView>
<is:eventline eventFocus="${activeSprint?.orderNumber}" container=".window-content" id="releasePlan">
  <g:each in="${sprints}" var="sprint" status="u">
    <is:event title="sprint ${sprint.orderNumber}">
    %{-- Header of the sprint column --}%
      <is:eventHeader class="state-${sprint.state}" style="position:relative;">
        <sec:access expression="inProduct()">
          <div class="event-header-label" onclick="$.icescrum.stopEvent(event).openWindow('sprintBacklog/${sprint.id}');">
        </sec:access>
        <sec:noAccess expression="inProduct()">
          <div class="event-header-label">
        </sec:noAccess>
          ${message(code: 'is.sprint')} ${sprint.orderNumber} - <span class="state"><is:bundleFromController bundle="SprintStateBundle" value="${sprint.state}"/></span>
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
          ${message(code: 'is.ui.releasePlan.from')} <strong><g:formatDate date="${sprint.startDate}" formatName="is.date.format.short"/></strong>
          ${message(code: 'is.ui.releasePlan.to')} <strong><g:formatDate date="${sprint.endDate}" formatName="is.date.format.short"/></strong>
          <is:menu class="dropmenu-action" id="${sprint.id}" contentView="window/menu" params="[id:id,sprint:sprint,nextSprint:nextSprint]"/>
        </div>
        
        <g:if test="${sprint.goal}">
          <is:tooltipSprint
                  id="releasePlan-${sprint.orderNumber}"
                  title="${message(code:'is.sprint')} ${sprint.orderNumber}"
                  text="${sprint.goal.encodeAsHTML()}"
                  container="\$('.event-line-limiter')"/>%{--#event-id-releasePlan-${sprint.orderNumber} .event-header--}%
        </g:if>
      </is:eventHeader>

    %{-- Content of the sprint column --}%
      <is:eventContent
              elemId="${sprint.id}"
              droppable="[
                        rendered:(poOrSm && sprint.state != Sprint.STATE_DONE),
                        hoverClass:'ui-drop-hover',
                        accept:'.postit-row-story',
                        drop:remoteFunction(action:'associateStory',
                                  controller:'releasePlan',
                                  onSuccess:'ui.draggable.remove()',
                                  update:'window-content-'+id,
                                  id:params.id,
                                  params: '\'product='+params.product+'&story.id=\'+ui.draggable.attr(\'elemId\')+\'&sprint.id=\'+$(this).attr(\'elemId\')')]">
        <is:backlogElementLayout
                id="plan-${sprint.id}"
                sortable='[
                          rendered:productOwner,
                          handle:".postit-layout .postit-label",
                          connectWith:".backlog",
                          placeholder:"ui-drop-hover-postit-rect ui-corner-all",
                          disabled:"${sprint.state == Sprint.STATE_DONE}",
                          cancel: ".ui-selectable-disabled",
                          update:"if(\$(\"#backlog-layout-plan-${sprint.id} .postit-rect\").index(ui.item) == -1 || ui.sender != undefined){return}else{${is.changeRank(selector:"#backlog-layout-plan-${sprint.id} .postit-rect",controller:id,action:"changeRank",params:"&idsprint=${sprint.id}&product=${params.product}",onFailure:"${is.notice(xhr:"XMLHttpRequest")}")}}",
                          receive:"event.stopPropagation();"+remoteFunction(action:"associateStory",
                                      controller:"releasePlan",
                                      update:"window-content-${id}",
                                      id:params.id,
                                      onFailure: "\$(ui).sortable(\"cancel\");" + is.notice(xhr:"XMLHttpRequest"),
                                      params: "\"product=${params.product}&story.id=\"+ui.item.attr(\"elemId\")+\"&sprint.id=${sprint.id}&position=\"+(\$(\"#backlog-layout-plan-${sprint.id} .postit-rect\").index(ui.item)+1)")
                  ]'
                dblclickable="[selector:'.postit-rect',
                               callback:is.quickLook(params:'\'story.id=\'+$(obj).icescrum(\'postit\').id()')]"
                value="${sprint.stories?.sort{it.rank}}"

                var="story"
                emptyRendering="true">
          <is:postit title="${story.name}"
                  id="${story.id}"
                  miniId="${story.id}"
                  rect="true"
                  attachment="${story.totalAttachments}"
                  styleClass="story task${story.state == Story.STATE_DONE ? ' ui-selectable-disabled':''}"
                  type="story"
                  typeNumber="${story.type}"
                  typeTitle="${is.bundleFromController(bundle:'StoryTypesBundle',value:story.type)}"
                  sortable='[rendered:productOwner, disabled:story.state == Story.STATE_DONE]'
                  miniValue="${story.effort >= 0 ? story.effort :'?'}"
                  editableEstimation="${story?.state != Story.STATE_DONE}"
                  color="${story.feature?.color ?: 'yellow'}"
                  stateText="${is.bundleFromController(bundle:'StoryStateBundle',value:story.state)}"
                  comment="${story.totalComments >= 0 ? story.totalComments : ''}">
            <is:postitMenu id="${story.id}" contentView="window/planMenu" params="[id:id, story:story]"/>
          </is:postit>
          <is:tooltipPostit
                            type="story"
                            id="${story.id}"
                            title="${story.name.encodeAsHTML()}"
                            text="${is.storyTemplate(story:story)}"
                            apiBeforeShow="if(\$('#dropmenu').is(':visible') || \$('#postit-story-${story.id} .mini-value.editable').hasClass('editable-hover') || \$('#postit-story-${story.id}').hasClass('ui-sortable-helper')) return false;"
                            container="\$('#window-content-${id}')"/>
        </is:backlogElementLayout>
      </is:eventContent>

    </is:event>
  </g:each>
</is:eventline>

</is:releaseView>
<jq:jquery>
  jQuery("#window-content-${id}").removeClass('window-content-toolbar');
  jQuery("#window-id-${id}").focus();
  jQuery('#window-title-bar-${id} .content').html('${message(code:"is.ui."+id)} - ${release.name}  - ${is.bundleFromController(bundle:'ReleaseStateBundle',value:release.state)} - [${g.formatDate(date:release.startDate, formatName:'is.date.format.short')} -> ${g.formatDate(date:release.endDate, formatName:'is.date.format.short')}]');
  <is:renderNotice />
  <icep:notifications
        name="${id}Window"
        reload="[update:'#window-content-'+id,action:'index',id:releaseId,params:[product:params.product]]"
        group="${params.product}-${id}-${releaseId}"
        listenOn="#window-content-${id}"/>
  <is:renderJavascript />
  <is:editable controller="productBacklog"
             action='estimate'
             on='.postit-story .mini-value.editable'
             findId="\$(this).parent().parent().parent().attr(\'elemID\')"
             type="selectui"
             before="\$(this).next().hide();"
             cancel="\$(original).next().show();"
             values="${suiteSelect}"
             restrictOnNotAccess='teamMember() or scrumMaster()'
             callback="\$(this).next().show();"
             params="[product:params.product]"/>
</jq:jquery>

<is:shortcut key="space" callback="if(\$('#dialog').dialog('isOpen') == true){\$('#dialog').dialog('close'); return false;}\$.icescrum.dblclickSelectable(null,null,function(obj){${is.quickLook(params:'\'story.id=\'+jQuery(obj.selected).icescrum(\'postit\').id()')},true);" scope="${id}"/>