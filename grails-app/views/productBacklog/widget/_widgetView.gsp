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
- Vincent Barrier (vincent.barrier@icescrum.com)
- Damien vitrac (damien@oocube.com)
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%
<g:if test="${stories}">

  <is:backlogElementLayout
          id="widget-${id}"
          container="ul"
          containerClass="list postit-rows"
          draggable='[
                    restrictOnAccess:"productOwner() or scrumMaster()",
                    selector:".postit-row",
                    helper:"clone",
                    appendTo:"body",
                    start:"jQuery(this).hide();",
                    stop:"jQuery(this).show();"
                  ]'
          dblclickable='[restrictOnAccess:"inProduct()", selector:".postit-row", callback:is.quickLook(params:"\"story.id=\"+obj.attr(\"elemId\")")]'
          value="${stories}"
          var="story">
    <li class="postit-row postit-row-story" elemId="${story.id}">
      <is:postitIcon name="${story.feature?.name?.encodeAsHTML()}" color="${story.feature?.color}" />
      </span>${story.id} - <is:truncated encodedHTML="true" size="30">${story.name.encodeAsHTML()}</is:truncated> <em>(${story.effort} ${story.effort > 1 ? 'pts' : 'pt'})</em>
    </li>
  </is:backlogElementLayout>
</g:if>
<g:else>
  <div class="box-content-layout">
    ${message(code:'is.widget.productBacklog.empty')}
  </div>
</g:else>
<entry:point id="${id}-${actionName}-widget" model="[stories:stories]"/>
<jq:jquery>
  <icep:notifications
        name="${id}Widget"
        reload="[update:'#widget-content-'+id+' .scrollbar-wrapper',action:'list',params:[product:params.product]]"
        group="${params.product}-${id}"
        listenOn="#widget-content-${id}"/>
</jq:jquery>