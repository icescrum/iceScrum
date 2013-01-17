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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<is:backlogElementLayout
        id="window-${controllerName}"
        emptyRendering="true"
        containerClass="connectableToWidgetSandbox"
        style="display:${!features ? 'none' : 'block'};"
        selectable="[rendered:request.productOwner,
                    filter:'div.postit-feature',
                    cancel:'.postit .postit-sortable, a',
                    selected:'jQuery.icescrum.dblclickSelectable(ui,300,$.icescrum.displayQuicklook)']"
        sortable='[rendered:request.productOwner,
                  containment:"#window-content-feature",
                  handle:".postit-sortable",
                  receive:"var rank = jQuery(\".postit-row-story\",this).index() + 1; jQuery(\".postit-row-story\",this).remove(); if (rank == 0) { return; } "+
                          remoteFunction(controller:"story",
                                         action:"accept",
                                         onSuccess:"jQuery.event.trigger(\"accept_story\",data)",
                                         params:"\"product="+params.product+"&id=\"+ui.item.data(\"elemid\")+\"&type=feature&rank=\"+rank"),
                  placeholder:"postit-placeholder ui-corner-all"]'
        changeRank='[selector:".postit",controller:controllerName,action:"rank",name:"feature.rank",params:[product:params.product]]'
        dblclickable='[rendered:!request.productOwner,
                               selector:".postit",
                               callback:"\$.icescrum.displayQuicklook(obj);"]'
        value="${features}"
        var="feature">
        <is:cache cache="featureCache" key="postit-${feature.id}-${feature.lastUpdated}">
            <g:render template="/feature/postit" model="[feature:feature,user:user]"/>
        </is:cache>
</is:backlogElementLayout>

<g:render template="/feature/window/blank" model="[show : features ? false : true]"/>

<jq:jquery>
    jQuery('#window-title-bar-${controllerName} .content .details').html(' (<span id="features-size">${features?.size()}</span>)');
</jq:jquery>

<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;}jQuery.icescrum.dblclickSelectable(null,null,\$.icescrum.displayQuicklook,true);"
             scope="${controllerName}"/>
<is:shortcut key="ctrl+a" callback="jQuery('#backlog-layout-window-${controllerName} .ui-selectee').addClass('ui-selected');"/>
<is:onStream
        on="#backlog-layout-window-${controllerName}"
        events="[[object:'feature',events:['add','update','remove']]]"
        template="features"/>