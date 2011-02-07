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
<ul>
  <li>${message(code:"is.ui.details.team.name")}:
  <strong>${currentTeam.name.encodeAsHTML()}</strong>
  </li>
  <li>${message(code:"is.ui.details.role.name")}: <is:scrumLink controller="members"><strong> <is:displayRole /> </strong></is:scrumLink></li>
  <g:if test="${user}">
    <li><is:avatar userid="${user.id}"/></li>
  </g:if>
</ul>