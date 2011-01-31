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
<ul>
  <li>${message(code: "is.product")}:
    <strong>${currentProduct.name.encodeAsHTML()}</strong>
    <sec:access expression='productOwner() or scrumMaster()'><is:remoteDialog
            action="openProperties"
            controller="project"
            params="[product:currentProduct.id]"
            valid="[action:'update',controller:'project',onSuccess:'\$(\'#project-details ul li:first strong\').text(data.name); \$.icescrum.renderNotice(data.notice);']"
            title="is.dialog.project.title"
            width="600"
            resizable="false"
            draggable="false">(<g:message code='default.button.edit.label'/>)</is:remoteDialog>
    </sec:access>
  </li>
  <li>${message(code:"is.role")}: <is:scrumLink controller="members"><strong> <is:displayRole /> </strong></is:scrumLink></li>
  <g:if test="${user}">
    <li><is:avatar userid="${user.id}"/></li>
  </g:if>
</ul>