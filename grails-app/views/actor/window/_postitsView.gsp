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
--}%
<is:backlogElementLayout
        id="window-${controllerName}"
        emptyRendering="true"
        style="display:${actors ? 'block' : 'none'};"
        selectable="[rendered:request.productOwner,
                    filter:'div.postit-actor',
                    selected:'jQuery.icescrum.dblclickSelectable(ui,300,function(obj){'+is.quickLook(params:'\'actor.id=\'+jQuery.icescrum.postit.id(obj.selected)')+';})']"
        value="${actors}"
        dblclickable='[rendered:!request.productOwner,selector:".postit",callback:is.quickLook(params:"\"actor.id=\"+obj.attr(\"elemId\")")]'
        var="actor">
        <is:cache cache="actorCache" key="postit-${actor.id}-${actor.lastUpdated}">
            <g:include view="/actor/_postit.gsp" model="[actor:actor]" params="[product:params.product]"/>
        </is:cache>
</is:backlogElementLayout>

<g:include view="/actor/window/_blank.gsp" model="[actors:actors]"/>


<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;}jQuery.icescrum.dblclickSelectable(null,null,function(obj){${is.quickLook(params:'\'actor.id=\'+jQuery.icescrum.postit.id(obj.selected)')}},true);"
             scope="${controllerName}"/>
<is:shortcut key="ctrl+a" callback="jQuery('#backlog-layout-window-${controllerName} .ui-selectee').addClass('ui-selected');"/>
<is:onStream
        on="#backlog-layout-window-${controllerName}"
        events="[[object:'actor',events:['add','update','remove']]]"
        template="window"/>