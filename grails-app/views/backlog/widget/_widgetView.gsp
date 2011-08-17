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
        id="widget-${id}"
        container="ul"
        emptyRendering="true"
        style="display:${stories ? 'block' : 'none'};"
        containerClass="list postit-rows"
        draggable="[
                    rendered:(request.productOwner || request.scrumMaster),
                    selector:'.postit-row',
                    helper:'clone',
                    appendTo:'body',
                    start:'jQuery(this).hide();',
                    stop:'if (jQuery(this).attr(\'remove\') == \'true\') { jQuery(this).remove(); } else { jQuery(this).show(); }'
                  ]"
        dblclickable='[rendered:(request.stakeHolder || request.inProduct), selector:".postit-row", callback:is.quickLook(params:"\"story.id=\"+obj.attr(\"elemid\")")]'
        value="${stories}"
        var="story">
    <is:cache  cache="storyCache_${story.id}" cacheResolver="backlogElementCacheResolver" key="postit-small">
        <li class="postit-row postit-row-story" elemId="${story.id}">
            <is:postitIcon name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}"/>
            </span>${story.id} - <is:truncated encodedHTML="true" size="30">${story.name.encodeAsHTML()}</is:truncated>
            <em>(${story.effort} ${story.effort > 1 ? 'pts' : 'pt'})</em>
        </li>
    </is:cache>
</is:backlogElementLayout>

<div class="box-blank" style="display:${stories ? 'none' : 'block'};">
    ${message(code: 'is.widget.backlog.empty')}
</div>

<entry:point id="${id}-${actionName}-widget" model="[stories:stories]"/>

<is:onStream
        on="#backlog-layout-widget-${id}"
        events="[[object:'story',events:['add','update','remove','estimate','plan','unPlan','associated','dissociated']]]"
        template="backlogWidget"/>