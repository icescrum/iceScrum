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
- Stephane Maldini (stephane.maldini@icescrum.com)
--}%
<div class="browse-member">
  <ul class="browse-list clearfix">
<g:each in="${products}" var="p">
      <li>
        <div class="browse-item">
          <img src="${resource(dir: is.currentThemeImage(), file: 'choose/default.png')}" class="ico">
          <p><strong>${p.name.encodeAsHTML()}</strong></p>
        </div>
      </li>
    </g:each>
  </ul>
  <ul class="bar-pagination pagination clearfix">
    <g:if test="${offset >= max}"><li class="pagination-previous"><is:link remote="true" history="false" params="[offset:Math.min(offset-max,0),id:team.id]" update="tabs-products" action="${actionName}"><g:message code="is.ui.autocompletechoose.prev"/></is:link></li></g:if>
    <g:if test="${offset < total-max}"><li class="pagination-next"><is:link remote="true" history="false" params="[offset:Math.min(offset+max,total),id:team.id]" update="tabs-products" action="${actionName}"><g:message code="is.ui.autocompletechoose.next"/></is:link></li></g:if>
  </ul>
</div>