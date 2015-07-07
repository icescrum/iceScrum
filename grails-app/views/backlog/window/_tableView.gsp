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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Story.TestState" %>
<g:set var="sumEfforts" value="${0}"/>
<g:set var="editableProperties" value="${ suiteSelect.length() > 8 ? [type:'selectui', values:suiteSelect] : [type:'text']}"/>
<is:tableView>
    <is:table id="story-table"
              style="${stories ? '' : 'display:none'};"
              sortableCols="true"
              editable="[controller:'story',action:'update',params:[product:params.product],onExitCell:'submit',success:'jQuery.event.trigger(\'update_story\',value.object);']">
        <is:tableHeader width="5%" class="table-cell-checkbox" name="">
            <g:checkBox name="checkbox-header"/>
        </is:tableHeader>
        <is:tableHeader width="5%" name="${message(code:'is.backlogelement.id')}"/>
        <is:tableHeader width="6%" name="${message(code:'is.story.rank')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.story.name')}"/>
        <is:tableHeader width="8%" name="${message(code:'is.story.type')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.feature')}"/>
        <is:tableHeader width="6%" name="${message(code:'is.story.effort')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.backlogelement.description')}"/>
        <is:tableHeader width="15%" name="${message(code:'is.backlogelement.notes')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.story.date.accepted')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.story.date.estimated')}"/>


        <is:tableRows in="${stories}" var="story" elemid="id" data-rank="rank">
            <g:set var="sumEfforts" value="${sumEfforts += story.effort ?: 0}"/>
            <is:tableColumn class="table-cell-checkbox">
                <g:if test="${!request.readOnly}">
                    <g:checkBox name="check-${story.id}"/>
                </g:if>
                <div class="dropmenu-action">
                    <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-story-${story.id}">
                        <span class="dropmenu-arrow">!</span>
                        <div class="dropmenu-content ui-corner-all">
                            <ul class="small">
                                <g:render template="/story/menu" model="[story:story]"/>
                            </ul>
                        </div>
                    </div>
                </div>
                <g:set var="comment" value="${story.totalComments}"/>
                <g:if test="${comment}">
                    <span class="table-comment"
                          title="${message(code: 'is.postit.comment.count', args: [comment, comment > 1 ? 's' : ''])}"></span>
                </g:if>
                <g:set var="attachment" value="${story.totalAttachments}"/>
                <g:if test="${attachment}">
                    <span class="table-attachment"
                          title="${message(code: 'is.postit.attachment', args: [attachment, attachment > 1 ? 's' : ''])}"></span>
                </g:if>
                <g:set var="testCount" value="${story.countAcceptanceTests()}"/>
                <g:if test="${testCount > 0}">
                    <g:set var="testCountByStateLabel" value="${story.countTestsByState().collect({ k, v -> message(code: k.toString()) + ': ' + v}).join(' / ')}" />
                    <span class="story-icon-acceptance-test icon-acceptance-test${story.testState}"
                          title="${message(code: 'is.postit.acceptanceTest.count', args: [testCount, testCount > 1 ? 's' : ''])} (${testCountByStateLabel})"></span>
                </g:if>
            </is:tableColumn>
            <is:tableColumn class="table-cell-postit-icon">
                <is:scrumLink id="${story.id}" controller="story">
                    ${story.uid}
                </is:scrumLink>
                <g:if test="${story.dependsOn}">
                    <a class="scrum-link dependsOn" data-elemid="${story.dependsOn.id}" href="#story/${story.dependsOn.id}">(${story.dependsOn.uid})</a>
                </g:if>
            </is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'rank',disabled:!request.productOwner,name:'rank',values:rankSelect]">${story.rank}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'text',disabled:!request.productOwner,name:'name']">${story.name.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type',values:typeSelect]"><is:bundle
                    bundle="storyTypes" value="${story.type}"/></is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'feature',disabled:!request.productOwner,detach:true,name:'feature.id',values:featureSelect]"><is:postitIcon
                    name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}"/><g:message
                    code="${story.feature?.name?.encodeAsHTML()?:message(code:'is.ui.backlog.choose.feature')}"/></is:tableColumn>
            <is:tableColumn
                    editable="${[id:'effort',disabled:!request.inProduct,name:'effort'] << editableProperties }">${is.storyEffort(effort: story.effort)}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">${story.description?.encodeAsHTML()?.encodeAsNL2BR()}</is:tableColumn>
            <is:tableColumn editable="[type:'richarea',disabled:!request.productOwner,name:'notes']"><div class="rich-content"><is:renderHtml>${story.notes}</is:renderHtml></div></is:tableColumn>
            <is:tableColumn>${story.acceptedDate ? g.formatDate(date: story.acceptedDate, formatName: 'is.date.format.short', timezone: story.backlog.preferences.timezone) : ''}</is:tableColumn>
            <is:tableColumn>${g.formatDate(date: story.estimatedDate, formatName: 'is.date.format.short', timezone: story.backlog.preferences.timezone)}</is:tableColumn>
        </is:tableRows>
    </is:table>
</is:tableView>

<g:render template="/backlog/window/blank" model="[show: stories ? false : true]"/>

<jq:jquery>
    jQuery('#window-title-bar-${controllerName} .content .details').html(' - <span id="stories-backlog-size">${stories?.size()?:0}</span> ${message(code: "is.ui.backlog.title.details.stories")} / <span id="stories-backlog-effort">${is.sprintPoints(points: sumEfforts)}</span> ${message(code: "is.ui.backlog.title.details.points")}');
    jQuery('tr[data-rank]').each(function() {
        $('div[name=rank]', $(this)).text($(this).data('rank'));
    });
</jq:jquery>

<is:onStream
        on="#story-table"
        events="[[object:'story',events:['add','accept','update','estimate','remove','unPlan','plan','associated','dissociated','returnToSandbox']]]"
        template="backlogWindow"/>
