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
<%@ page import="org.icescrum.core.domain.Task" %>
<g:set var="inProduct" value="${request.inProduct}"/>
<g:set var="tMOrSm" value="${request.teamMember || request.scrumMaster}"/>
<g:set var="columns"
       value="[[key: (Task.STATE_WAIT), name: 'is.task.state.wait'],[key: (Task.STATE_BUSY), name: 'is.task.state.inprogress'],[key: (Task.STATE_DONE), name: 'is.task.state.done']]"/>
<g:set var="story" value="[id:'?**=this.id**?',
                            testState:'?**=this.testState**?',
                            uid:'?**=this.uid**?',
                            feature:[color:'?**=color**?'],
                            rank:'?**=this.rank**?',
                            creator:[id:'?**=user_id**?'],
                            parentSprint:[id:'?**=this.parentSprint.id**?',parentRelease:'?**=this.parentSprint.parentReleaseId**?'],
                            name:'?**=name**?',
                            totalComments:'?**=this.totalComments**?',
                            totalAttachments:'?**=this.totalAttachments**?']"/>
<g:set var="user" value="[id:'?**=this.id**?']"/>

<template id="postit-story-sandbox-tmpl">
    <g:render template="/story/jsPostit" model="[id:'sandbox',sortable:request.productOwner,editable:tMOrSm]"/>
</template>

<template id="postit-story-backlog-tmpl">
    <g:render template="/story/jsPostit" model="[id:'backlog',sortable:request.productOwner,editable:tMOrSm]"/>
</template>

<template id="postit-row-story-sandbox-tmpl">
    <![CDATA[
    ?**
    var name =  this.name ? this.name : '';
    var truncatedName = name.length > 30 ? name.substring(0,30)+'...' : name;
    var color = this.feature ? this.feature.color : '';
    **?
    <li class="postit-row postit-row-story postit-row-story-sandbox" data-elemid="${story.id}">
        <is:postitIcon name="${story.name}" color="${story.feature.color}"/>
        ?**=this.uid **? - ?**=truncatedName**?
    </li>
    ]]>
</template>

<template id="postit-story-releasePlan-tmpl">
    <g:render template="/story/jsPostit" model="[id:'releasePlan',editable:tMOrSm,rect:true, referrer:story.parentSprint.parentRelease]"/>
</template>

<template id="postit-story-sprintPlan-tmpl">
    <is:kanban onlyRows="true">
        <is:kanbanRow class="row-story" elemid="${story.id}">
            <is:kanbanColumn elementId="column-story-${story.id}" key="story">
                <g:render template="/story/jsPostit" model="[id:'sprintPlan',rect:false, editable:tMOrSm, referrer:story.parentSprint.id]"/>
            </is:kanbanColumn>
            <g:each in="${columns}" var="column">
                <is:kanbanColumn elementId="column-story-${story.id}-${column.key}" key="${column.key}"/>
            </g:each>
        </is:kanbanRow>
    </is:kanban>
</template>

<entry:point id="story-template" model="[story:story,user:user,tMOrSm:tMOrSm,inProduct:inProduct,columns:columns]"/>