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
--}%
<g:set var="sumEfforts" value="${0}"/>
<is:backlogElementLayout
        emptyRendering="true"
        style="display:${stories ? 'block' : 'none'};"
        id="window-${id}"
        selectable="[rendered:request.productOwner,
                    filter:'div.postit-story',
                    cancel:'.postit .postit-sortable, a, .mini-value, select, input',
                    selected:'jQuery.icescrum.dblclickSelectable(ui,300,function(obj){'+is.quickLook(params:'\'story.id=\'+jQuery.icescrum.postit.id(obj.selected)')+';})']"
        sortable='[rendered:request.productOwner,
                  handle:".postit-sortable",
                  containment:"#backlog-layout-window-backlog",
                  placeholder:"postit-placeholder ui-corner-all"]'
        droppable='[rendered:request.productOwner,
                  selector:".postit",
                  hoverClass: "ui-selected",
                  drop: remoteFunction(controller:"story",
                                       action:"associateFeature",
                                       onSuccess:"jQuery.event.trigger(\"update_story\",data)",
                                       params:"\"product="+params.product+"&feature.id=\"+ui.draggable.attr(\"elemid\")+\"&story.id=\"+jQuery(\".postit-layout .postit-id\", jQuery(this)).text()"
                                       ),
                  accept: ".postit-row-feature"]'
        dblclickable='[rendered:!request.productOwner,
                       selector:".postit",
                       callback:is.quickLook(params:"\"story.id=\"+obj.attr(\"elemid\")")]'

        changeRank='[selector:".postit-story",controller:"story",action:"rank",name:"story.rank",params:[product:params.product]]'
        editable="[controller:'story',
                  action:'estimate',
                  on:'div.backlog .postit-story .mini-value.editable',
                  rendered:(request.teamMember || request.scrumMaster),
                  findId:'jQuery(this).parents(\'.postit-story:first\').attr(\'elemid\')',
                  type:'selectui',
                  name:'story.effort',
                  before:'$(this).next().hide();',
                  cancel:'jQuery(original).next().show();',
                  values:suiteSelect,
                  callback:'if (value == \'?\'){jQuery(this).next().html(\''+message(code:'is.story.state.accepted')+'\');}else{jQuery(this).next().html(\''+message(code:'is.story.state.estimated')+'\')} $(this).next().show(); $.icescrum.story.backlogTitleDetails();',
                  params:[product:params.product]]"
        value="${stories}"
        var="story">
        <g:set var="sumEfforts" value="${sumEfforts += story.effort ?: 0}"/>
    <is:cache  cache="storyCache" key="postit-${story.id}-${story.lastUpdated}">
        <g:include view="/story/_postit.gsp" model="[id:id,story:story,user:user,sortable:request.productOwner]" params="[product:params.product]"/>
    </is:cache>
</is:backlogElementLayout>

<g:include view="/backlog/window/_blank.gsp" model="[stories:stories,id:id]"/>

<jq:jquery>
    jQuery('#window-title-bar-${id} .content .details').html(' - <span id="stories-backlog-size">${stories?.size()?:0}</span> ${message(code: "is.ui.backlog.title.details.stories")} / <span id="stories-backlog-effort">${sumEfforts}</span> ${message(code: "is.ui.backlog.title.details.points")}');
</jq:jquery>

<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;}jQuery.icescrum.dblclickSelectable(null,null,function(obj){${is.quickLook(params:'\'story.id=\'+jQuery.icescrum.postit.id(obj.selected)')}},true);"
             scope="${id}"/>
<is:shortcut key="ctrl+a" callback="jQuery('#backlog-layout-window-${id} .ui-selectee').addClass('ui-selected');"/>
<is:onStream
        on="#backlog-layout-window-${id}"
        events="[[object:'story',events:['add','accept','update','remove','estimate','unPlan','plan','associated','dissociated']]]"
        template="backlogWindow"/>