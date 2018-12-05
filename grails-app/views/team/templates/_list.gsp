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
<script type="text/ng-template" id="wizard.members.list.html">
<tr>
    <td>
        <a class="btn btn-danger btn-sm btn-model"
           ng-model="foo" %{-- Hack to make form dirty --}%
           ng-click="removeTeamMember(member)"
           ng-show="teamMembersEditable(team)">
            <i class="fa fa-close"></i>
        </a>
        <img ng-src="{{ member | userAvatar }}" height="24" width="24" class="img-rounded user-role" title="{{ member.username }}">
    </td>
    <td>
        <span title="{{ member.username + ' (' + member.email + ')' }}" class="text-overflow">{{ member | userFullName }}</span>
        <span ng-show="!member.id"><small>${message(code: 'is.ui.user.will.be.invited')} <i class="fa fa-envelope text-muted"></i></small></span>
    </td>
    <td class="text-right">
        <input type="checkbox" ng-change='scrumMasterChanged(member)' name="member.role" ng-model="member.scrumMaster" ng-disabled="!teamMembersEditable(team) || member.productOwner">
    </td>
</tr>
</script>