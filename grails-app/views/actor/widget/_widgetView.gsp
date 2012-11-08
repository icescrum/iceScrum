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

<is:backlogElementLayout id="widget-${controllerName}"
                         style="display:${actors ? 'block' : 'none'};"
                         container="ul"
                         emptyRendering="true"
                         containerClass="list postit-rows"
                         value="${actors}"
                         var="actor"
                         dblclickable='[rendered:request.inProduct || request.stakeHolder, selector:".postit-row", callback:"\$.icescrum.displayQuicklook(obj);"]'>
    <is:cache cache="actorCache" key="postit-small-${actor.id}-${actor.lastUpdated}">
        <li data-elemid="${actor.id}" id="postit-row-actor-${actor.id}" class="postit-row postit-row-actor">
            <is:postitIcon/>
            <is:truncated size="30" encodedHTML="true">${actor.name.encodeAsHTML()}</is:truncated>
        </li>
    </is:cache>
</is:backlogElementLayout>

<div class="box-blank" style="display:${actors ? 'none' : 'block'};">
    ${message(code: 'is.widget.actor.empty')}
</div>

<entry:point id="${controllerName}-${actionName}-widget" model="[actors:actors]"/>
<is:onStream
        on="#backlog-layout-widget-${controllerName}"
        events="[[object:'actor',events:['add','update','remove']]]"
        template="widget"/>