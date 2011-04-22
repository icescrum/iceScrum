%{--
- Copyright (c) 2011 Kagilum.
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
<%@ page import="org.icescrum.core.domain.Release" %>
<strong><g:message code="is.release.goal"/>: </strong>${release.goal.encodeAsHTML()}
<table class="table-tooltip-sprint">
    <g:if test="${release.state != Release.STATE_WAIT}">
    <tr>
        <td class="entry-title"><g:message code="is.release.velocity"/>: </td>
        <td class="entry-value">${release.releaseVelocity}</td>
    </tr>
    </g:if>
    <tr>
        <td class="entry-title"><g:message code="is.release.startDate"/>: </td>
        <td class="entry-value"><g:formatDate date="${release.startDate}" formatName="is.date.format.short" timeZone="${user?.preferences?.timezone?:null}"/></td>
    </tr>
    <tr>
        <td class="entry-title"><g:message code="is.release.endDate"/>: </td>
        <td class="entry-value"><g:formatDate date="${release.endDate}" formatName="is.date.format.short" timeZone="${user?.preferences?.timezone?:null}"/></td>
    </tr>
</table>