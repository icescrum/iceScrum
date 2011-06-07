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
--}%

<is:backlogElementLayout id="widget-${id}"
                         container="ul"
                         emptyRendering="true"
                         style="display:${features ? 'block' : 'none'};"
                         containerClass="list postit-rows"
                         draggable='[
            restrictOnAccess:"productOwner() or scrumMaster()",
            selector:".postit-row",
            helper:"clone",
            appendTo:"body",
            start:"jQuery(this).hide();",
            stop:"jQuery(this).show();"
          ]'
                         value="${features}"
                         var="feature"
                         dblclickable='[restrictOnAccess:"inProduct()", selector:".postit-row", callback:is.quickLook(params:"\"feature.id=\"+obj.attr(\"elemId\")")]'>
    <li elemId="${feature.id}" class="postit-row postit-row-feature">
        <is:postitIcon name="${feature.name.encodeAsHTML()}" color="${feature.color}"/>
        <is:truncated size="30" encodedHTML="true">${feature.name.encodeAsHTML()}</is:truncated>
    </li>
</is:backlogElementLayout>

<div class="box-blank" style="display:${features ? 'none' : 'block'};">
    ${message(code: 'is.widget.feature.empty')}
</div>

<entry:point id="${id}-${actionName}-widget" model="[feature:feature]"/>
<is:onStream
        on="#backlog-layout-widget-${id}"
        events="[[object:'feature',events:['add','update','remove']]]"
        template="widget"/>