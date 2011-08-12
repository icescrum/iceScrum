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
<g:set var="feature" value="[type:'?**=this.type**?',
                             color:'?**=this.color**?',
                             id:'?**=this.id**?',
                             name:'?**=name**?',
                             rank:'?**=this.rank**?',
                             value:'?**=this.value**?',
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
    <is:postit id="${feature.id}"
               miniId="${feature.id}"
               title="?**=truncatedName**?"
               type="feature"
               notruncate="true"
               sortable='[rendered:request.productOwner]'
               attachment="${feature.totalAttachments}"
               typeNumber="${feature.type}"
               color="${feature.color}"
               controller="${id}">
        ?**=truncatedDescription**?
        <is:postitMenu id="feature-${feature.id}" contentView="/feature/menu" params="[id:id, feature:feature]"
                       rendered="${request.productOwner}"/>
        ?**if (truncatedDescription.length > 50 || truncatedName.length > 17) {**?
        <is:tooltipPostit
                type="feature"
                id="${feature.id}"
                title="${feature.name}"
                text="${feature.description}"
                apiBeforeShow="if(jQuery('#dropmenu').is(':visible')){return false;}"
                container="jQuery('#window-content-feature')"/>
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
    <li class="postit-row postit-row-feature" elemid="${feature.id}">
        <is:postitIcon name="${feature.name}" color="${feature.color}"/>
        ?**=truncatedName**?
    </li>
    ]]>
</template>

<template id="table-row-${id}-tmpl">
    <![CDATA[
    ?**
    var description =  this.description ? this.description : '';
    var name =  this.name ? this.name : '';
    var type = $.icescrum.feature.types[this.type];
    var effort = 0;
    var stories = 0;
    var storiesDone = 0;
    $(this.stories).each(function(){
    stories++;
    effort += this.effort;
    storiesDone += (this.state == 3 ? 1 : 0);
    });
    effort = effort == 0 ? '' : effort;
    storiesDone = storiesDone == 0 ? '' : storiesDone;
    **?
    <is:table onlyRows="true">
        <is:tableRow elemid="${feature.id}" rowid="table-row-feature-">
            <is:tableColumn class="table-cell-checkbox">
                <g:checkBox name="check-${feature.id}"/>
                <is:menu class="dropmenu-action" yoffset="4" id="${feature.id}" contentView="/feature/menu"
                         params="[id:id, feature:feature]" rendered="${request.productOwner}"/>
                <g:set var="attachment" value="${feature.totalAttachments}"/>
                <g:if test="${attachment}">
                    <span class="table-attachment"
                          title="${message(code: 'is.postit.attachment', args: [attachment, attachment instanceof Integer && attachment > 1 ? 's' : ''])}"></span>
                </g:if>
            </is:tableColumn>
            <is:tableColumn class="table-cell-postit-icon">
                <is:postitIcon name="${feature.name}" color="${feature.color}"/>
            </is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'rank',name:'rank',values:rankSelect,disabled:!request.productOwner]">${feature.rank}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',disabled:!request.productOwner,name:'value',values:suiteSelect]">${feature.value}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type',values:typeSelect]">?**=type**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'text',disabled:!request.productOwner,name:'name']">${feature.name.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">${feature.description}</is:tableColumn>
            <is:tableColumn>?**=effort**?</is:tableColumn>
            <is:tableColumn>?**=stories**?</is:tableColumn>
            <is:tableColumn>?**=storiesDone**?</is:tableColumn>
        </is:tableRow>
    </is:table>
    ]]>
</template>