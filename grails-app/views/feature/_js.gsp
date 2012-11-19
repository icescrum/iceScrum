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
                             uid:'?**=this.uid**?',
                             name:'?**=name**?',
                             rank:'?**=this.rank**?',
                             countDoneStories:'?**=this.countDoneStories**?',
                             effort:'?**=this.effort**?',
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
    var textState = jQuery.icescrum.feature.states[this.state];
    **?
    <is:postit id="${feature.id}"
               miniId="${feature.uid}"
               title="?**=truncatedName**?"
               type="feature"
               stateText="?**=textState**?"
               notruncate="true"
               miniValue="${feature.value}"
               menu="[id:'feature-'+feature.id,template:'/feature/menu',params:[controllerName:id, feature:feature],rendered:request.productOwner]"
               sortable='[rendered:request.productOwner]'
               attachment="${feature.totalAttachments}"
               typeNumber="${feature.type}"
               color="${feature.color}"
               controller="${id}">
        ?**=truncatedDescription**?
        ?**if (truncatedDescription.length > 50 || truncatedName.length > 17) {**?
        <div class="tooltip">
            <span class="tooltip-title">${feature.name}</span>
            ${feature.description}
        </div>
        ?**}**?    </is:postit>
    ]]>
</template>

<template id="postit-row-${id}-tmpl">
    <![CDATA[
    ?**
    var name =  this.name ? this.name : '';
    var truncatedName = name.length > 30 ? name.substring(0,30)+'...' : name;
    **?
    <li class="postit-row postit-row-feature" data-elemid="${feature.id}">
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
    **?
    <is:table onlyRows="true">
        <is:tableRow    data-rank="${feature.rank}"
                        elemid="${feature.id}"
                        rowid="table-row-feature-"
                        version="?**=this.version**?">
            <is:tableColumn class="table-cell-checkbox">
                <g:checkBox name="check-${feature.id}"/>
                <g:if test="${request.productOwner}">
                    <div class="dropmenu-action">
                        <div data-dropmenu="true" class="dropmenu" data-top="13" data-offset="4" data-noWindows="false" id="menu-table-feature-${feature.id}">
                            <span class="dropmenu-arrow">!</span>
                            <div class="dropmenu-content ui-corner-all">
                                <ul class="small">
                                    <g:render template="/feature/menu" model="[controllerName:id, feature:feature]"/>
                                </ul>
                            </div>
                        </div>
                    </div>
                </g:if>
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
                    editable="[type:'selectui',id:'rank',name:'rank',values:rankSelect,disabled:!request.productOwner]"></is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',disabled:!request.productOwner,name:'value',values:suiteSelect]">${feature.value}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'selectui',id:'type',disabled:!request.productOwner,name:'type',values:typeSelect]">?**=type**?</is:tableColumn>
            <is:tableColumn
                    editable="[type:'text',disabled:!request.productOwner,name:'name']">${feature.name.encodeAsHTML()}</is:tableColumn>
            <is:tableColumn
                    editable="[type:'textarea',disabled:!request.productOwner,name:'description']">${feature.description}</is:tableColumn>
            <is:tableColumn>${feature.effort}</is:tableColumn>
            <is:tableColumn>?**=this.stories.length**?</is:tableColumn>
            <is:tableColumn>${feature.countDoneStories}</is:tableColumn>
        </is:tableRow>
    </is:table>
    ]]>
</template>

<entry:point id="feature-template" model="[feature:feature,id:id]"/>