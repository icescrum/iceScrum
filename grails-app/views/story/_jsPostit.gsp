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
                          dependsOn:[id:'?**=dependsOnId**?', uid:'?**=dependsOnUid**?'],
                          parentSprint:[id:'?**=parentSprint**?'],
                          description:'?**=description**?',
                          testState:'?**=this.testState**?',
                          totalComments:'?**=this.totalComments**?',
                          totalAttachments:'?**=this.totalAttachments**?']"/>
<![CDATA[
?**
    var color = this.feature ? this.feature.color : '';
    var name =  this.name ? this.name : '';
    var size = this.state == $.icescrum.story.STATE_SUGGESTED ? 24 : 17;
    var truncatedName = name.length > size ? name.substring(0,size)+'...' : name;
    var description = this.description ? jQuery.icescrum.story.storyTemplate(this.description) : '';
    var effort = this.state > 1 ? (this.effort != null ? this.effort : '?') : '';
    var truncatedDescription = description.length > 50 ? description.substring(0,50)+'...' : description;
    var textState = this.state > 1 ? jQuery.icescrum.story.states[this.state] : '';
    var typeTitle = $.icescrum.story.types[this.type] + (this.type == 2 && this.affectVersion ? ' ('+ this.affectVersion+')' : '');
    var parentReleaseID = this.parentSprint ? this.parentSprint.parentReleaseId : '';
    var sprintOrderNumber = this.parentSprint ? this.parentSprint.orderNumber + 1 : '';
    var parentSprint = this.parentSprint ? this.parentSprint.id : '';
    var dependsOnId = this.dependsOn ? this.dependsOn.id : '';
    var dependsOnUid = this.dependsOn ? this.dependsOn.uid : '';
    var testCount = this.acceptanceTests ? this.acceptanceTests.length : 0;
    description = description.formatLine();
**?
<is:postit id="${story.id}"
           miniId="${story.uid}"
           dependsOn="${story.dependsOn}"
           title="?**=truncatedName**?"
           type="story"
           rect="${rect}"
           notruncate="true"
           menu="[id:'story-'+story.id,template:'/story/menu',params:[controllerName:id, story:story, sprint:sprint, template:true, referrer:referrer]]"
           attachment="${story.totalAttachments}"
           typeNumber="${story.type}"
           typeTitle="?**=typeTitle**?"
           miniValue="?**=effort**?"
           sortable='[rendered:sortable]'
           color="?**=color**?"
           editableEstimation="${editable}"
           stateText="?**=textState**?"
           testState="${story.testState}"
           testCount="?**=testCount**?"
           comment="${story.totalComments}">
            <g:if test="${rect}">
                <div class="tooltip">
                    <span class="tooltip-title">${story.name}</span>
                    ${story.description}
                </div>
            </g:if>
            <g:else>
                ?**=truncatedDescription**?
                ?**if (truncatedDescription.length > 50 || truncatedName.length > 17) {**?
                <div class="tooltip">
                    <span class="tooltip-title">${story.name}</span>
                    ${story.description}
                </div>
                ?**}**?
            </g:else>
</is:postit>