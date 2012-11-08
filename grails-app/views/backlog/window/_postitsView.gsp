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
        id="window-${controllerName}"
        selectable="[rendered:request.productOwner,
                    filter:'div.postit-story',
                    cancel:'.postit .postit-sortable, a, .mini-value, select, input',
                    selected:'jQuery.icescrum.dblclickSelectable(ui,300,$.icescrum.displayQuicklook)']"
        sortable='[rendered:request.productOwner,
                  handle:".postit-sortable",
                  receive:"var rank = jQuery(\".postit-row-story\",this).index() + 1; jQuery(\".postit-row-story\",this).remove(); if (rank == 0) { return; } "+remoteFunction(controller:"story",
                                         action:"accept",
                                         onSuccess:"jQuery.event.trigger(\"accept_story\",data)",
                                         params:"\"product="+params.product+"&id=\"+ui.item.data(\"elemid\")+\"&type=story&rank=\"+rank"),
                  containment:"#window-content-backlog",
                  change:"jQuery.icescrum.story.checkDependsOnPostitsView(ui);",
                  placeholder:"postit-placeholder postit-story ui-corner-all"]'
        droppable='[rendered:request.productOwner,
                  selector:".postit",
                  hoverClass: "ui-selected",
                  drop: remoteFunction(controller:"story",
                                       action:"associateFeature",
                                       onSuccess:"jQuery.event.trigger(\"update_story\",data)",
                                       params:"\"product="+params.product+"&feature.id=\"+ui.draggable.data(\"elemid\")+\"&id=\"+jQuery(this).data(\"elemid\")"),
                  accept: ".postit-row-feature"]'
        dblclickable='[rendered:!request.productOwner,
                       selector:".postit",
                       callback:"\$.icescrum.displayQuicklook(obj);"]'

        changeRank='[selector:".postit-story",
                     controller:"story",
                     action:"rank",
                     name:"story.rank",
                     onSuccess:"jQuery.icescrum.story.updateRank(params,data,\"#backlog-layout-window-backlog\");",
                     params:[product:params.product]]'
        editable="[controller:'story',
                  action:'estimate',
                  on:'div.backlog .postit-story .mini-value.editable',
                  rendered:(request.teamMember || request.scrumMaster),
                  findId:'jQuery(this).parents(\'.postit-story:first\').data(\'elemid\')',
                  type:'selectui',
                  name:'story.effort',
                  before:'$(this).next().hide();',
                  cancel:'jQuery(original).next().show();',
                  values:suiteSelect,
                  ajaxoptions:'{dataType:\'json\'}',
                  callback:'if (!jQuery.isNumeric(value.effort)){jQuery(this).html(\'?\'); jQuery(this).next().html(\''+message(code:'is.story.state.accepted')+'\');}else{ jQuery(this).html(value.effort); jQuery(this).next().html(\''+message(code:'is.story.state.estimated')+'\')} $(this).next().show(); $.icescrum.story.backlogTitleDetails(); ',
                  params:[product:params.product]]"
        value="${stories}"
        var="story">
        <g:set var="sumEfforts" value="${sumEfforts += story.effort ?: 0}"/>
    <is:cache  cache="storyCache" key="postit-${story.id}-${story.lastUpdated}">
        <g:render template="/story/postit" model="[story:story,user:user,sortable:request.productOwner]"/>
    </is:cache>
</is:backlogElementLayout>

<g:render template="/backlog/window/blank" model="[show:stories ? false : true]"/>

<jq:jquery>
    jQuery('#window-title-bar-${controllerName} .content .details').html(' - <span id="stories-backlog-size">${stories?.size()?:0}</span> ${message(code: "is.ui.backlog.title.details.stories")} / <span id="stories-backlog-effort">${sumEfforts}</span> ${message(code: "is.ui.backlog.title.details.points")}');
</jq:jquery>

<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;}jQuery.icescrum.dblclickSelectable(null,null,\$.icescrum.displayQuicklook,true);"
             scope="${controllerName}"/>
<is:shortcut key="ctrl+a" callback="jQuery('#backlog-layout-window-${controllerName} .ui-selectee').addClass('ui-selected');"/>
<is:onStream
        on="#backlog-layout-window-${controllerName}"
        events="[[object:'story',events:['add','accept','update','remove','estimate','unPlan','plan','associated','dissociated']]]"
        template="backlogWindow"/>

<is:onStream
        on="#backlog-layout-window-${controllerName}"
        events="[[object:'feature',events:['update']]]"/>