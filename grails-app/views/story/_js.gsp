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
<%@ page import="org.icescrum.core.domain.Task" %>
<g:set var="inProduct" value="${request.inProduct}"/>
<g:set var="tMOrSm" value="${request.teamMember || request.scrumMaster}"/>
<g:set var="columns"
       value="[[key: (Task.STATE_WAIT), name: 'is.task.state.wait'],[key: (Task.STATE_BUSY), name: 'is.task.state.inprogress'],[key: (Task.STATE_DONE), name: 'is.task.state.done']]"/>
<g:set var="story" value="[id:'?**=this.id**?',
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
    <g:include view="/story/_jsPostit.gsp" params="[product:params.product]"
               model="[id:'sandbox',sortable:request.productOwner,editable:tMOrSm]"/>
</template>

<template id="table-row-story-sandbox-tmpl">
    <![CDATA[
    ?**
    var color = this.feature ? this.feature.color : '';
    var acceptanceTestCount = this.acceptanceTests ? this.acceptanceTests.length : 0;
    var name =  this.name ? this.name : '';
    var description =  this.description ? this.description : '&nbsp;';
    var typeTitle = $.icescrum.story.types[this.type];
    var feature = this.feature ? this.feature.name : '${message(code: 'is.ui.sandbox.manage.chooseFeature')}';
    this.parentSprint = this.parentSprint ? this.parentSprint.id : '';
    var notes = '&nbsp;';
    if (this.notes) {
    var id = this.id;
    $.get($.icescrum.o.baseUrl + 'textileParser', {data:this.notes,withoutHeader:true, async:false}, function(data){
    $('.table-line[data-elemid='+id+'] .table-cell-richarea[name=notes]').html(data);
    });
    }
    **?
    <is:table onlyRows="true">
        <is:tableRow elemid="${story.id}" version="?**=this.version**?">
            <is:tableColumn class="table-cell-checkbox">
                <g:checkBox name="check-${story.id}"/>
                <div class="dropmenu-action">
                   <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-story-${story.id}">
                       <span class="dropmenu-arrow">!</span>
                       <div class="dropmenu-content ui-corner-all">
                           <ul class="small">
                               <g:render template="/story/menu" model="[controllerName:'sandbox', story:story, sprint:sprint, template:true]"/>
                           </ul>
                       </div>
                   </div>
               </div>
                <span class="table-comment"
                      title="${message(code: 'is.postit.comment.count', args: [story.totalComments, ''])}"></span>
                <span class="table-attachment"
                      title="${message(code: 'is.postit.attachment', args: [story.totalAttachments, ''])}"></span>
                <span class="table-acceptance-test"
                          title="${message(code: 'is.postit.acceptanceTest.count', args: ['?**=acceptanceTestCount**?', ''])}"></span>
            </is:tableColumn>
            <is:tableColumn class="table-cell-postit-icon">
                <is:scrumLink id="${story.id}" controller="story">
                    ${story.uid}
                </is:scrumLink>
            </is:tableColumn>
            <is:tableColumn
                    editable="[type:'text',highlight:true,disabled:!request.productOwner,name:'name']">${story.name}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type']">?**=typeTitle**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'feature',disabled:!request.productOwner,detach:true,name:'feature.id']"><is:postitIcon
                    name="${story.name}" color="${story.feature.color}"/>?**=feature**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">?**=description**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'richarea',disabled:!request.productOwner,name:'notes']">?**=notes**?</is:tableColumn>
        </is:tableRow>
    </is:table>
    ]]>
</template>

<template id="postit-story-backlog-tmpl">
    <g:include view="/story/_jsPostit.gsp" params="[product:params.product]"
               model="[id:'backlog',sortable:request.productOwner,editable:tMOrSm]"/>
</template>

<template id="table-row-story-backlog-tmpl">
    <![CDATA[
    ?**
    var color = this.feature ? this.feature.color : '';
    var acceptanceTestCount = this.acceptanceTests ? this.acceptanceTests.length : 0;
    var name =  this.name ? this.name : '';
    var description =  this.description ? this.description : '&nbsp;';
    var typeTitle = $.icescrum.story.types[this.type];
    var feature = this.feature ? this.feature.name : '${message(code: 'is.ui.sandbox.manage.chooseFeature')}';
    var effort = this.state > 1 ? (this.effort != null ? this.effort : '?') : '';
    var acceptedDate = jQuery.icescrum.dateLocaleFormat(this.acceptedDate);
    var estimatedDate = this.estimatedDate ? jQuery.icescrum.dateLocaleFormat(this.estimatedDate) : '';
    this.parentSprint = this.parentSprint ? this.parentSprint.id : '';
    var notes = '&nbsp;';
    if (this.notes) {
    var id = this.id;
    $.get($.icescrum.o.baseUrl + 'textileParser', {data:this.notes,withoutHeader:true, async:false}, function(data){
    $('.table-line[data-elemid='+id+'] .table-cell-richarea[name=notes]').html(data);
    });
    }
    **?
    <is:table onlyRows="true">
        <is:tableRow data-rank="${story.rank}"
                     elemid="${story.id}"
                     version="?**=this.version**?">
            <is:tableColumn class="table-cell-checkbox">
                <g:checkBox name="check-${story.id}"/>
                <div class="dropmenu-action">
                   <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-story-${story.id}">
                       <span class="dropmenu-arrow">!</span>
                       <div class="dropmenu-content ui-corner-all">
                           <ul class="small">
                               <g:render template="/story/menu" model="[controllerName:'backlog',story:story,template:true]"/>
                           </ul>
                       </div>
                   </div>
               </div>
                <span class="table-comment"
                      title="${message(code: 'is.postit.comment.count', args: [story.totalComments, ''])}"></span>
                <span class="table-attachment"
                      title="${message(code: 'is.postit.attachment', args: [story.totalAttachments, ''])}"></span>
                <span class="table-acceptance-test"
                          title="${message(code: 'is.postit.acceptanceTest.count', args: ['?**=acceptanceTestCount**?', ''])}"></span>
            </is:tableColumn>
            <is:tableColumn class="table-cell-postit-icon">
                <is:scrumLink id="${story.id}" controller="story">
                    ${story.uid}
                </is:scrumLink>
            </is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'rank',disabled:!request.productOwner,name:'rank']"></is:tableColumn>
            <is:tableColumn editable="[type:'text',disabled:!request.productOwner,name:'name']">${story.name}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type']">?**=typeTitle**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'feature',disabled:!request.productOwner,detach:true,name:'feature.id']"><is:postitIcon
                    name="${story.name}" color="${story.feature.color}"/>?**=feature**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'effort',disabled:!inProduct,name:'effort']">?**=effort**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">?**=description**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'richarea',disabled:!request.productOwner,name:'notes']">?**=notes**?</is:tableColumn>
            <is:tableColumn>?**=acceptedDate**?</is:tableColumn>
            <is:tableColumn>?**=estimatedDate**?</is:tableColumn>
        </is:tableRow>
    </is:table>
    ]]>
</template>

<template id="postit-row-story-backlog-tmpl">
    <![CDATA[
    ?**
    var name =  this.name ? this.name : '';
    var truncatedName = name.length > 30 ? name.substring(0,30)+'...' : name;
    var color = this.feature ? this.feature.color : '';
    **?
    <li class="postit-row postit-row-story postit-row-story-backlog" data-elemid="${story.id}">
        <is:postitIcon name="${story.name}" color="${story.feature.color}"/>
        ?**=this.uid **? - ?**=truncatedName**? <em>(?**=this.effort **? pts)</em>
    </li>
    ]]>
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
    <g:include view="/story/_jsPostit.gsp" params="[product:params.product]"
               model="[id:'releasePlan',editable:tMOrSm,rect:true, referrer:story.parentSprint.parentRelease]"/>
</template>

<template id="postit-story-sprintPlan-tmpl">
    <is:kanban onlyRows="true">
        <is:kanbanRow class="row-story" elemid="${story.id}">
            <is:kanbanColumn elementId="column-story-${story.id}" key="story">
                <g:include view="/story/_jsPostit.gsp" params="[product:params.product]"
                           model="[id:'sprintPlan',rect:false, editable:tMOrSm, referrer:story.parentSprint.id]"/>
            </is:kanbanColumn>
            <g:each in="${columns}" var="column">
                <is:kanbanColumn elementId="column-story-${story.id}-${column.key}" key="${column.key}"/>
            </g:each>
        </is:kanbanRow>
    </is:kanban>
</template>