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
--}%
<%@ page import="org.icescrum.core.domain.Sprint" %>
<p>
  <span class="important"><g:message code="is.sprint.goal"/> :</span>
  ${sprint.goal.encodeAsHTML()}
</p>
<p>
<g:if test="${sprint.state == org.icescrum.core.domain.Sprint.STATE_DONE}">
<p>
  <span class="important"><g:message code="is.sprint.velocity"/> :</span>
  ${sprint.velocity}
</p>
</g:if>
<g:else>
<p>
  <span class="important"><g:message code="is.sprint.capacity"/> :</span>
  ${sprint.capacity}
</p>
</g:else>
<div class="drap-container" style="width:100%;float:left;margin-top:10px;">
  <div class="drap date-start" style="float:left;margin:0px">
    <g:formatDate date="${sprint.startDate}" formatName="is.date.format.short"/>
  </div>
  <div class="drap date-end" style="float:right;margin:0px">
    <g:formatDate date="${sprint.endDate}" formatName="is.date.format.short"/>
  </div>
</div>