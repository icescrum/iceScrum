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
- Stephane Maldini (stephane.maldini@icescrum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<%@ page import="org.icescrum.core.domain.Story; org.icescrum.core.domain.Story.TestState" %>
<is:tableView>
    <is:table style="${stories ? '' : 'display:none'};"
              id="story-table"
              sortableCols="true"
              editable="[controller:'story',action:'update',params:[product:params.product],onExitCell:'submit']">

        <is:tableHeader width="5%" class="table-cell-checkbox" name="">
            <g:checkBox name="checkbox-header" checked="false"/>
        </is:tableHeader>
        <is:tableHeader width="5%" name="${message(code:'is.backlogelement.id')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.story.name')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.story.type')}"/>
        <is:tableHeader width="10%" name="${message(code:'is.feature')}"/>
        <is:tableHeader width="30%" name="${message(code:'is.backlogelement.description')}"/>
        <is:tableHeader width="30%" name="${message(code:'is.backlogelement.notes')}"/>

        <is:tableRows in="${stories}" var="story" elemid="id">
            <is:tableColumn class="table-cell-checkbox">
                <g:if test="${!request.readOnly}">
                    <g:checkBox name="check-${story.id}"/>
                </g:if>
                <div class="dropmenu-action">
                    <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-story-${story.id}">
                        <span class="dropmenu-arrow">!</span>
                        <div class="dropmenu-content ui-corner-all">
                            <ul class="small">
                                <g:render template="/story/menu" model="[story:story, sprint:sprint, user:user]"/>
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
                    editable="[type:'text',highlight:true,disabled:!request.productOwner,name:'name']">${story.name.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type',values:typeSelect]"><is:bundle
                    bundle="storyTypes" value="${story.type}"/></is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'feature',disabled:!request.productOwner,detach:true,name:'feature.id',values:featureSelect]"><is:postitIcon
                    name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}"/><g:message
                    code="${story.feature?.name?.encodeAsHTML()?:message(code:'is.ui.sandbox.manage.chooseFeature')}"/></is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">${story.description?.encodeAsHTML()?.encodeAsNL2BR()}</is:tableColumn>
            <is:tableColumn editable="[type:'richarea',disabled:!request.productOwner,name:'notes']"><div class="rich-content"><is:renderHtml>${story.notes}</is:renderHtml></div></is:tableColumn>
        </is:tableRows>
    </is:table>
</is:tableView>

<g:render template="/sandbox/window/blank" model="[show:stories ? false : true]"/>

<is:dropImport id="${controllerName}" description="is.ui.sandbox.drop.import" action="dropImport" success="jQuery(document.body).append(data.dialog);attachOnDomUpdate(jQuery('.ui-dialog'));"/>
<is:onStream
        on="#story-table"
        events="[[object:'story',events:['add','update','remove','accept','associated','dissociated','returnToSandbox']]]"
        template="sandbox"/>

<is:onStream
        on="#story-table"
        events="[[object:'sprint',events:['close','activate']]]"/>

<jq:jquery>
    jQuery('#window-title-bar-${controllerName} .content .details').html(' (<span id="stories-sandbox-size">${stories?.size()}</span>)');
</jq:jquery>