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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<%@ page import="org.icescrum.core.domain.Story" %>
<g:set var="tMOrSm" value="${request.teamMember || request.scrumMaster}"/>
<is:postit id="${story.id}"
           dependsOn="${story.dependsOn ? [id:story.dependsOn.id, uid:story.dependsOn.uid] : null}"
           miniId="${story.uid}"
           title="${story.name}"
           titleSize="${story.state == Story.STATE_SUGGESTED ? 24 : 17}"
           styleClass="story type-story-${story.type}"
           type="story"
           rect="${rect?:false}"
           typeNumber="${story.type}"
           menu="[id:'story-'+story.id,template:'/story/menu',params:[story:story, user:user, sprint:sprint, nextSprintExist:nextSprintExist, referrer:referrer]]"
           typeTitle="${is.bundle(bundle:'storyTypes',value:story.type) + (story.type == Story.TYPE_DEFECT && story.affectVersion?' ('+story.affectVersion+')':'')}"
           attachment="${story.totalAttachments}"
           miniValue="${story.state > Story.STATE_SUGGESTED ? story.effort >= 0 ? story.effort :'?' : null}"
           color="${story.feature?.color}"
           stateText="${story.state > Story.STATE_SUGGESTED ? is.bundle(bundle:'storyStates',value:story.state) : ''}"
           editableEstimation="${tMOrSm && story.state != Story.STATE_DONE}"
           sortable="[disabled:!sortable]"
           acceptanceTestCount="${story.countAcceptanceTests()}"
           testState="${story.testState}"
           testStateLabel="${message(code: story.testStateEnum.toString())}"
           comment="${story.totalComments >= 0 ? story.totalComments : ''}">
            <g:if test="${!rect}">
                <is:truncated size="50" encodedHTML="true"><is:storyTemplate story="${story}"/></is:truncated>
            </g:if>
            <g:if test="${story.name?.length() > 17 || is.storyTemplate(story:story)?.length() > 50 || rect}">
                <div class="tooltip">
                    <span class="tooltip-title">${story.name}</span>
                    ${is.storyTemplate(story:story)?:''}
                </div>
            </g:if>
</is:postit>