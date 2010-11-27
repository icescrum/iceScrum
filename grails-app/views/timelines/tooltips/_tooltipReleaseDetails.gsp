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
  --}%

<%@ page import="org.icescrum.core.domain.Release" %>
<p>
  <span class="important"><g:message code="is.release.goal"/> :</span>
  ${release.goal}
</p>
<g:if test="${release.state == Release.STATE_DONE}">
  <p>
    <span class="important"><g:message code="is.release.velocity"/> :</span>
    ${release.releaseVelocity}
  </p>
</g:if>
<div class="drap-container" style="width:100%;float:left;margin-top:10px;">
  <div class="drap date-start" style="float:left;margin:0px">
    <g:formatDate date="${release.startDate}" formatName="is.date.format.short"/>
  </div>
  <div class="drap date-end" style="float:right;margin:0px">
    <g:formatDate date="${release.endDate}" formatName="is.date.format.short"/>
  </div>
</div>