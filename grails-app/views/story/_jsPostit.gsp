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
<g:set var="user" value="[id:'?**=this.id**?']"/>

<g:set var="sprint" value="[parentRelease:[id:'?**=parentReleaseID**?'],
                            orderNumber:'?**=sprintOrderNumber**?']"/>

<g:set var="story" value="[id:'?**=this.id**?',
                          uid:'?**=this.uid**?',
                          type:'?**=this.type**?',
                          feature:[color:'?**=color**?'],
                          creator:[id:'?**=user_id**?'],
                          effort:'?**=this.effort**?',
                          name:'?**=name**?',
                          parentSprint:[id:'?**=parentSprint**?'],
                          description:'?**=description**?',
                          totalComments:'?**=this.totalComments**?',
                          totalAttachments:'?**=this.totalAttachments**?']"/>
<![CDATA[
?**
    var color = this.feature ? this.feature.color : '';
    var name =  this.name ? this.name : '';
    var size = this.state == $.icescrum.story.STATE_SUGGESTED ? 24 : 17;
    var truncatedName = name.length > size ? name.substring(0,size)+'...' : name;
    var description =  this.description ? this.description : '&nbsp;';
    var effort = this.state > 1 ? (this.effort != null ? this.effort : '?') : '';
    var truncatedDescription = description.length > 50 ? description.substring(0,50)+'...' : description;
    var textState = this.state > 1 ? jQuery.icescrum.story.states[this.state] : '';
    var typeTitle = $.icescrum.story.types[this.type];
    var parentReleaseID = this.parentSprint ? this.parentSprint.parentReleaseId : '';
    var sprintOrderNumber = this.parentSprint ? this.parentSprint.orderNumber + 1 : '';
    var parentSprint = this.parentSprint ? this.parentSprint.id : '';
    description = description.formatLine();
**?
<is:postit id="${story.id}"
           miniId="${story.uid}"
           title="?**=truncatedName**?"
           type="story"
           rect="${rect}"
           notruncate="true"
           attachment="${story.totalAttachments}"
           typeNumber="${story.type}"
           typeTitle="?**=typeTitle**?"
           miniValue="?**=effort**?"
           sortable='[rendered:sortable]'
           color="?**=color**?"
           editableEstimation="${editable}"
           stateText="?**=textState**?"
           comment="${story.totalComments}">
    ?**=truncatedDescription**?
    <is:postitMenu id="story-${story.id}" contentView="/story/menu"
                   params="[id:id, story:story, sprint:sprint, template:true, referrer:referrer]"/>

    ?**if (truncatedDescription.length > 50 || truncatedName.length > 17) {**?
    <is:tooltipPostit
            type="story"
            id="${story.id}"
            title="${story.name}"
            text="${story.description}"
            apiBeforeShow="if(jQuery('#dropmenu').is(':visible')){return false;}"
            container="jQuery('#window-content-${id}')"/>
    ?**}**?
</is:postit>
]]>