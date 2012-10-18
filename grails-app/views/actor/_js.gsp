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
<g:set var="actor" value="[id:'?**=this.id**?',
                           uid:'?**=this.uid**?',
                           name:'?**=name**?',
                           description:'?**=description**?',
                           totalAttachments:'?**=this.totalAttachments**?']"/>

<template id="postit-${id}-tmpl">
    <![CDATA[
    ?**
    var name =  this.name ? this.name : '';
    var truncatedName = name.length > 17 ? name.substring(0,17)+'...' : name;
    var description =  this.description ? this.description : '';
    var truncatedDescription = description.length > 50 ? description.substring(0,50)+'...' : description;
    description = description.formatLine();
    **?
    <is:postit id="${actor.id}"
               miniId="${actor.uid}"
               title="?**=truncatedName**?"
               type="actor"
               menu="[id:'actor-'+actor.id,template:'/actor/menu',params:[controllerName:id, actor:actor], rendered:request.productOwner]"
               notruncate="true"
               attachment="${actor.totalAttachments}"
               controller="${id}">
        ?**=truncatedDescription**?
        ?**if (truncatedDescription.length > 50 || truncatedName.length > 17) {**?
        <div class="tooltip">
            <span class="tooltip-title">${actor.name}</span>
            ${actor.description}
        </div>
        ?**}**?
    </is:postit>
    ]]>
</template>

<template id="postit-row-${id}-tmpl">
    <![CDATA[
    ?**
    var name =  this.name ? this.name : '';
    var truncatedName = name.length > 30 ? name.substring(0,30)+'...' : name;
    **?
    <li class="postit-row postit-row-actor" data-elemid="${actor.id}">
        <span class="postit-icon postit-icon-yellow"></span>
        ?**=truncatedName**?
    </li>
    ]]>
</template>

<template id="table-row-${id}-tmpl">
    <![CDATA[
    ?**
    var name =  this.name ? this.name : '';
    var description =  this.description ? this.description : '';
    var instances = $.icescrum.actor.instances[this.instances];
    var expertnessLevel = $.icescrum.actor.expertnessLevel[this.expertnessLevel];
    var useFrequency = $.icescrum.actor.useFrequency[this.useFrequency];
    var stories = this.stories ? this.stories.length : 0;
    **?
    <is:table onlyRows="true">
        <is:tableRow elemid="${actor.id}" rowid="table-row-actor-">
            <is:tableColumn class="table-cell-checkbox">
                <g:checkBox name="check-${actor.id}"/>
                <g:if test="${productOwner}">
                    <div class="dropmenu-action">
                        <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-actor-${actor.id}">
                            <span class="dropmenu-arrow">!</span>
                            <div class="dropmenu-content ui-corner-all">
                                <ul class="small">
                                    <g:render template="/actor/menu" model="[controllerName:id, actor:actor]"/>
                                </ul>
                            </div>
                        </div>
                    </div>
                </g:if>
                <g:set var="attachment" value="${actor.totalAttachments}"/>
                <g:if test="${attachment}">
                    <span class="table-attachment"
                          title="${message(code: 'is.postit.attachment', args: [attachment, attachment instanceof Integer && attachment > 1 ? 's' : ''])}"></span>
                </g:if>
            </is:tableColumn>
            <is:tableColumn editable="[type:'text',disabled:!productOwner,name:'name']">${actor.name}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!productOwner,name:'description']">?**=description**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'level',name:'expertnessLevel',values:levelsSelect,disabled:!productOwner]">?**=expertnessLevel**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!productOwner,name:'satisfactionCriteria']">${actor.satisfactionCriteria}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'useFrequency',name:'useFrequency',values:frequenciesSelect,disabled:!productOwner]">?**=useFrequency**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'instances',name:'instances',values:instancesSelect,disabled:!productOwner]">?**=instances**?</is:tableColumn>
            <is:tableColumn>?**=stories**?</is:tableColumn>
        </is:tableRow>
    </is:table>
    ]]>
</template>