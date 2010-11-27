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
<h3>
<g:message code="is.dialog.about.contributors.title"/></h3>
<p class="description">
  <g:message code="is.dialog.about.contributors.description"/>
</p>
<p>
  <a href="${contributors.link}" target="_blank">
    <strong><g:message code="is.dialog.about.contributors.becoming"/></strong>
  </a>
</p>
<div class="list">
  <g:each status="i" var="contributor" in="${contributors.contributor}">
    <div class="member-mini unselectable">
      <img class="ico" src="${(contributor.image != '')?resource(dir: 'infos', file: 'images/'+contributor.image):resource(dir: is.currentThemeImage(), file: 'avatars/avatar.png')}" />
      <p><strong>${contributor.firstName} ${contributor.lastName}</strong></p>
      <g:if test="${contributor.to != ''}">
        <p><g:message code="is.dialog.about.contributors.contributor.off"/> ${contributor.from} - ${contributor.to}</p>
      </g:if>
      <g:else>
        <p><g:message code="is.dialog.about.contributors.contributor.on"/> ${contributor.from} </p>
      </g:else>
    </div>
  </g:each>
</div>