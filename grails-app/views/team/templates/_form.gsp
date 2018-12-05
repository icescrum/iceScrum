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
<script type="text/ng-template" id="form.team.html">
<div class="row">
    <div class="col-sm-12">
        <h4>${message(code: "is.team")}</h4>
        <p class="form-text">
            <span ng-if="teamCreatable()">
                ${message(code: 'is.dialog.wizard.section.team.description')}
                ${message(code: 'is.ui.user.add' + (grailsApplication.config.icescrum.invitation.enable ? '' : '.invite'))}
            </span>
            <span ng-if="!teamCreatable()">
                ${message(code: 'todo.is.ui.projet.team.description')}
            </span>
            <documentation doc-url="roles-teams-projects"/>
        </p>
    </div>
    <div class="col-sm-4" style="margin-top: 11px;">
        <label for="team.name">{{ message(teamCreatable() ? 'todo.is.ui.create.or.select.team' : 'todo.is.ui.select.team' )}}</label>
        <p class="input-group">
            <input autocomplete="off"
                   type="text"
                   name="team.name"
                   autofocus
                   class="form-control"
                   placeholder="${message(code: 'todo.is.ui.team.noteam')}"
                   uib-typeahead="team as team.name for team in searchTeam($viewValue, teamCreatable())"
                   typeahead-loading="searching"
                   typeahead-wait-ms="150"
                   typeahead-on-select="selectTeam($item, $model, $label)"
                   typeahead-template-url="select.or.create.team.html"
                   typeahead-select-on-blur="true"
                   ng-readonly="team.selected"
                   ng-model="team.name"
                   ng-required="isCurrentStep(2, 'project')">
            <span class="input-group-after" ng-if="teamRemovable(team)">
                <span class="input-group-text">
                    <i class="fa"
                       ng-click="unSelectTeam()"
                       ng-class="{ 'fa-search': !searching, 'fa-refresh':searching, 'fa-close':team.selected }">
                    </i>
                </span>
            </span>
        </p>
        <div class="form-group" ng-if="type == 'editProject' && team.owner">
            <label>
                ${message(code: 'is.role.owner')}
                <entry:point id="project-team-list-owner"/>
            </label>
            <div>
                <img ng-src="{{ team.owner | userAvatar }}" height="24" width="24" class="img-rounded user-role" title="{{ team.owner.username }}">
                {{ team.owner | userFullName }}
            </div>
        </div>
        <button ng-if="teamManageable(team)"
                type="button"
                class="btn btn-primary"
                ng-click="manageTeam(team)">
            ${message(code: 'todo.is.ui.team.manage')}
        </button>
    </div>
    <div class="col-sm-8" ng-show="team.selected">
        <div ng-show="teamMembersEditable(team)">
            <label for="member.search">${message(code: 'todo.is.ui.select.member')}</label>
            <p class="input-group">
                <input autocomplete="off"
                       type="text"
                       name="member.search"
                       id="member.search"
                       autofocus
                       class="form-control"
                       placeholder="${message(code: 'is.ui.user.search.placeholder' + (grailsApplication.config.icescrum.user.search.enable ? '' : '.email'))}"
                       ng-model="member.name"
                       uib-typeahead="member as member.name for member in searchMembers($viewValue)"
                       typeahead-loading="searchingMember"
                       typeahead-min-length="2"
                       typeahead-wait-ms="250"
                       typeahead-on-select="addTeamMember($item, $model, $label)"
                       typeahead-template-url="select.member.html">
                <span class="input-group-after">
                    <span class="input-group-text">
                        <i class="fa" ng-class="{ 'fa-search': !searchingMember, 'fa-refresh':searchingMember, 'fa-close':member.name }"></i>
                    </span>
                </span>
            </p>
        </div>
        <table ng-if="team.members.length" class="table table-striped table-responsive">
            <thead>
                <tr>
                    <th colspan="2">${message(code: 'is.ui.team.members')} ({{ team.members.length }})</th>
                    <th class="text-right" style="font-weight: normal">${message(code: 'is.role.scrumMaster')}</th>
                </tr>
            </thead>
            <tbody ng-repeat="member in team.members"
                   ng-include="'wizard.members.list.html'">
            </tbody>
        </table>
        <div ng-if="team.members.length == 0">
            ${message(code: 'todo.is.ui.team.no.members')}
        </div>
    </div>
</div>
</script>
