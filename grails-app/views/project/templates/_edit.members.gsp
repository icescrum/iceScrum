<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
%{--
- Copyright (c) 2015 Kagilum.
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

<script type="text/ng-template" id="edit.members.project.html">
<form role='form'
      ng-controller="editProjectMembersCtrl"
      show-validation
      novalidate
      ng-submit='updateProjectTeam(project)'
      name="formHolder.editMembersForm">
    <ng-include ng-controller="teamCtrl" src="'form.team.html'"></ng-include>
    <ng-include src="'form.members.project.html'"></ng-include>
    <div class="btn-toolbar">
        <button type="button"
                role="button"
                class="btn btn-danger"
                ng-click="confirm({ message: '${message(code: 'is.dialog.members.leave.team.confirm')}', callback: leaveTeam, args: [project] })"
                uib-tooltip="${message(code: 'is.dialog.members.leave.team')}">
            <i class="fa fa-times"></i> ${ message(code: 'is.dialog.members.leave.team')}
        </button>
    </div>
    <div class="btn-toolbar pull-right">
        <button type="button"
                role="button"
                class="btn btn-default"
                uib-tooltip="${ message(code:'is.button.cancel')}"
                ng-click="resetTeamForm()">
            ${ message(code:'is.button.cancel')}
        </button>
        <button type='submit'
                role="button"
                class='btn btn-primary'
                ng-disabled="!formHolder.editMembersForm.$dirty || formHolder.editMembersForm.$invalid">
            ${message(code:'is.button.update')}
        </button>
    </div>
</form>
</script>