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
- Manuarii Stein (manuarii.stein@icescrum.com)
--}%

<g:if test="${actors}">
  <is:backlogElementLayout id="widget-${id}"
          container="ul"
          containerClass="list postit-rows"
          value="${actors}"
          var="actor"
          dblclickable='[restrictOnAccess:"inProduct()", selector:".postit-row", callback:is.quickLook(params:"\"actor.id=\"+obj.attr(\"elemId\")")]'>
    <li elemId="${actor.id}" class="postit-row postit-row-actor">
      <is:postitIcon/>
      <is:truncated size="30">${actor.name.encodeAsHTML()}</is:truncated>
    </li>
  </is:backlogElementLayout>
</g:if>
<g:else>
  <div class="box-content-layout">
    ${message(code:'is.widget.actor.empty')}
  </div>
</g:else>
<jq:jquery>
  <icep:notifications
        name="${id}Widget"
        reload="[update:'#widget-content-'+id,action:'list',params:[product:params.product]]"
        group="${params.product}-${id}"
        listenOn="#widget-content-${id}"/>
</jq:jquery>