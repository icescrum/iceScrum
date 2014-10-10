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
            <h4>${message(code:"is.dialog.wizard.section.team")}</h4>
            <p class="help-block">${message(code:'is.dialog.wizard.section.team.description')}</p>
        </div>
        <div class="col-sm-5">
            <h4>${message(code:'is.team')}</h4>
            <label for="team.name">${message(code:'todo.is.ui.create.or.select.team')}</label>
            <p class="input-group typeahead">
                <input required
                       type="text"
                       name="team.name"
                       autofocus="autofocus"
                       class="form-control"
                       typeahead="team as team.name for team in searchTeam($viewValue)"
                       typeahead-loading="searching"
                       typeahead-on-select="selectTeam($item, $model, $label)"
                       typeahead-template-url="select.or.create.team.html"
                       ng-disabled="team.selected"
                       typeahead-wait-ms="250"
                       ng-model="team.name"
                       ng-required="isCurrentStep(2)">
                <span class="input-group-addon"><i class="fa" ng-click="unSelectTeam()" ng-class="{ 'fa-search': !searching, 'fa-refresh':searching, 'fa-close':team.selected }"></i></span>
            </p>
        </div>
        <div class="col-sm-7" ng-show="team.selected">
            <h4>{{ team.name }} <small>{{ team.members.length }} ${message(code:'todo.is.ui.team.members')}</small></h4>
            <div ng-show="!team.id">
                <label for="member.search">${message(code:'todo.is.ui.select.member')}</label>
                <p class="input-group typeahead">
                    <input type="text"
                           name="member.search"
                           id="member.search"
                           autofocus="autofocus"
                           class="form-control"
                           ng-model="member.name"
                           typeahead="member as member.name for member in searchMembers($viewValue)"
                           typeahead-loading="searchingMember"
                           typeahead-wait-ms="250"
                           typeahead-on-select="addTeamMember($item, $model, $label)"
                           typeahead-template-url="select.member.html">
                    <span class="input-group-addon">
                        <i class="fa" ng-click="unSelectTeam()" ng-class="{ 'fa-search': !searchingMember, 'fa-refresh':searchingMember, 'fa-close':member.name }"></i>
                    </span>
                </p>
            </div>
            <table class="table table-striped table-responsive">
                <thead>
                <tr>
                    <th>${message(code:'todo.is.ui.team.members')}</th>
                    <th>${message(code:'todo.is.ui.team.name')}</th>
                    <th class="text-right">${message(code:'todo.is.ui.team.role')}</th>
                </tr>
                </thead>
                <tbody ng-include="'wizard.members.list.html'"></tbody>
            </table>
        </div>
    </div>
</script>