<ul class="browse-list">
  %{--
  - Copyright (c) 2010 iceScrum Technologies.
  -
  - This file is part of iceScrum.
  -
  - iceScrum is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Lesser General Public License as published by
  - the Free Software Foundation, either version 3 of the License.
  -
  - iceScrum is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU General Public License for more details.
  -
  - You should have received a copy of the GNU Lesser General Public License
  - along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
  --}%

<g:each in="${browserCollection}" var="c">
    <li>
      <is:link class="noline" remote="true" history="false" onSuccess="\$('#${name}-details').tabs('destroy');\$('#${name}-details').tabs();"
              update="${name}-details" controller="${controllerName}" action="${actionDetails}" params="[id:c.id]">
        <div class="browse-item">
          <img src="${resource(dir: is.currentThemeImage(), file: 'choose/default.png')}" class="ico">
          <p><strong>${c.label}</strong></p>
          <p>${c.extra}</p>
        </div>
      </is:link>
    </li>
  </g:each>
</ul>
<jq:jquery>
  $('.colset-2 .col1 .browse-item').hover(function(){
  $(this).addClass('browse-item-hover');
}, function() {
  $(this).removeClass('browse-item-hover');
}).click(function(){
  $('.colset-2 .col1 .browse-item').removeClass('browse-item-active');
  $(this).addClass('browse-item-active');
  });
</jq:jquery>

<ul class="bar-pagination pagination clearfix">
  <g:if test="${offset >= max}"><li class="pagination-previous"><is:link remote="true" history="false" params="[offset:Math.max(offset-max,0) ,term:term]" update="${name}-column" controller="${controllerName}" action="${actionName}"><g:message code="is.ui.autocompletechoose.prev"/></is:link></li></g:if>
  <g:if test="${offset < total-max}"><li class="pagination-next"><is:link remote="true" history="false" params="[offset:Math.min(offset+max,total) ,term:term]" update="${name}-column" controller="${controllerName}" action="${actionName}"><g:message code="is.ui.autocompletechoose.next"/></is:link></li></g:if>
</ul>
