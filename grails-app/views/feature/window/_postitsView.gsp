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
        style="display:${!features ? 'none' : 'block'};"
        selectable="[rendered:request.productOwner,
                    filter:'div.postit-feature',
                    cancel:'.postit .postit-sortable, a',
                    selected:'jQuery.icescrum.dblclickSelectable(ui,300,function(obj){'+is.quickLook(params:'\'feature.id=\'+jQuery.icescrum.postit.id(obj.selected)')+';})']"
        sortable='[rendered:request.productOwner,
                  containment:"#window-content-feature",
                  handle:".postit-sortable",
                  placeholder:"postit-placeholder ui-corner-all"]'
        changeRank='[selector:".postit",controller:controllerName,action:"rank",name:"feature.rank",params:[product:params.product]]'
        dblclickable='[rendered:!request.productOwner,
                               selector:".postit",
                               callback:is.quickLook(params:"\"feature.id=\"+obj.attr(\"elemId\")")]'
        value="${features}"
        var="feature">
        <is:cache cache="featureCache" key="postit-${feature.id}-${feature.lastUpdated}">
            <g:include view="/feature/_postit.gsp" model="[feature:feature,user:user]" params="[product:params.product]"/>
        </is:cache>
</is:backlogElementLayout>

<g:include view="/feature/window/_blank.gsp" model="[features:features]"/>

<is:shortcut key="space"
             callback="if(jQuery('#dialog').dialog('isOpen') == true){jQuery('#dialog').dialog('close'); return false;}jQuery.icescrum.dblclickSelectable(null,null,function(obj){${is.quickLook(params:'\'feature.id=\'+jQuery.icescrum.postit.id(obj.selected)')}},true);"
             scope="${controllerName}"/>
<is:shortcut key="ctrl+a" callback="jQuery('#backlog-layout-window-${controllerName} .ui-selectee').addClass('ui-selected');"/>
<is:onStream
        on="#backlog-layout-window-${controllerName}"
        events="[[object:'feature',events:['add','update','remove']]]"
        template="features"/>