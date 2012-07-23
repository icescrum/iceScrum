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
        id="widget-${controllerName}"
        container="ul"
        emptyRendering="true"
        style="display:${stories ? 'block' : 'none'};"
        containerClass="list postit-rows"
        draggable="[
                    rendered:(request.productOwner),
                    selector:'.postit-row',
                    helper:'clone',
                    connectToSortable:'#backlog-layout-window-backlog, #backlog-layout-window-feature',
                    appendTo:'body',
                    start:'jQuery(this).hide();',
                    stop:'debugger; if (jQuery(this).attr(\'remove\') == \'true\') { jQuery(this).remove(); } else { jQuery(this).show(); }'
                  ]"
        dblclickable='[rendered:(request.stakeHolder || request.inProduct), selector:".postit-row", callback:is.quickLook(params:"\"story.id=\"+obj.attr(\"elemid\")")]'
        value="${stories}"
        var="story">
    <is:cache  cache="storyCache" key="postit-small-${story.id}-${story.lastUpdated}">
        <li class="postit-row postit-row-story" elemId="${story.id}">
            <is:postitIcon name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}"/>
            </span>${story.uid} - <is:truncated encodedHTML="true" size="30">${story.name.encodeAsHTML()}</is:truncated>
        </li>
    </is:cache>
</is:backlogElementLayout>

<div class="box-blank" style="display:${stories ? 'none' : 'block'};">
    ${message(code: 'is.widget.sandbox.empty')}
</div>

<entry:point id="${controllerName}-${actionName}-widget" model="[stories:stories]"/>

<is:onStream
        on="#backlog-layout-widget-${controllerName}"
        events="[[object:'story',events:['add','update','remove','accept']]]"
        template="sandboxWidget"/>

<is:onStream
        on="#backlog-layout-widget-${controllerName}"
        events="[[object:'feature',events:['update']]]"/>