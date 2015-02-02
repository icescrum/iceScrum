<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
%{--
- Copyright (c) 2014 Kagilum.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<is:modal title="${message(code:'is.dialog.wizard')}"
          name="editProjectMembersForm"
          form="updateProjectTeam(project)"
          submitButton="${message(code:'is.button.update')}"
          closeButton="${message(code:'is.button.cancel')}">
    <ng-include ng-controller="teamCtrl" src="'form.team.html'"></ng-include>
    <ng-include src="'form.members.project.html'"></ng-include>
    <button class="btn btn-danger"
            type="button"
            role="button"
            class="btn btn-danger"
            ng-click="confirm({ message: '${message(code: 'is.dialog.members.leave.team.confirm')}', callback: leaveTeam, args: [project] })"
            tooltip="${message(code: 'is.dialog.members.leave.team')}"
            tooltip-append-to-body="true">
        <i class="fa fa-times"></i> ${ message(code: 'is.dialog.members.leave.team')}
    </button>
</is:modal>