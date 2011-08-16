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
<%@ page import="org.icescrum.core.domain.Sprint" %>
<strong><g:message code="is.sprint.goal"/>: </strong>${sprint.goal?.encodeAsHTML()}
<table class="table-tooltip-sprint">
    <tr>
        <td class="entry-title"><g:message code="is.sprint.capacity"/>: </td>
        <td class="entry-value">${sprint.capacity}</td>
    </tr>
    <g:if test="${sprint.state != Sprint.STATE_WAIT}">
    <tr>
        <td class="entry-title"><g:message code="is.sprint.velocity"/>: </td>
        <td class="entry-value">${sprint.velocity}</td>
    </tr>
    </g:if>
    <tr>
        <td class="entry-title"><g:message code="is.sprint.startDate"/>: </td>
        <td class="entry-value"><g:formatDate date="${sprint.startDate}" formatName="is.date.format.short" timeZone="${release.parentProduct.preferences.timezone}"/></td>
    </tr>
    <tr>
        <td class="entry-title"><g:message code="is.sprint.endDate"/>: </td>
        <td class="entry-value"><g:formatDate date="${sprint.endDate}" formatName="is.date.format.short" timeZone="${release.parentProduct.preferences.timezone}"/></td>
    </tr>
</table>