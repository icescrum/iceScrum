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

<script type="text/ng-template" id="form.members.project.html">
<h4>${message(code: "todo.is.ui.project.members")}</h4>
<p class="help-block">${message(code: 'todo.is.ui.project.members.help')}</p>
<div class="row">
    <div class="col-sm-4" ng-if="projectMembersEditable(project)">
        <label for="productOwners.search">${message(code: 'todo.is.ui.select.productowner')}</label>
        <p class="input-group">
            <input autocomplete="off"
                   type="text"
                   name="productOwner.search"
                   id="productOwner.search"
                   class="form-control"
                   placeholder="${message(code: 'todo.is.ui.select.notext')}"
                   ng-model="po.name"
                   uib-typeahead="po as po.name for po in searchUsers($viewValue, true)"
                   typeahead-append-to-body="true"
                   typeahead-loading="searchingPo"
                   typeahead-min-length="2"
                   typeahead-wait-ms="250"
                   typeahead-on-select="addUser($item, 'po')"
                   typeahead-template-url="select.member.html">
            <span class="input-group-addon">
                <i class="fa" ng-class="{ 'fa-search': !searchingPo, 'fa-refresh':searchingPo }"></i>
            </span>
        </p>
    </div>
    <div ng-class="projectMembersEditable(project) ? 'col-sm-8' : 'col-sm-12' ">
        <label ng-if="project.productOwners.length">${message(code: 'todo.is.ui.project.productOwners')} ({{ project.productOwners.length }})</label>
        <div ng-class="{'list-users': project.productOwners.length > 0}">
            <ng-include ng-init="role = 'po';" ng-repeat="user in project.productOwners" src="'user.item.project.html'"></ng-include>
        </div>
    </div>
</div>
<div class="row" ng-show="project.preferences.hidden">
    <div class="col-sm-4" ng-if="projectMembersEditable(project)">
        <label for="stakeHolders.search">${message(code: 'todo.is.ui.select.stakeholder')}</label>
        <p class="input-group">
            <input autocomplete="off"
                   type="text"
                   name="stakeHolder.search"
                   id="stakeHolder.search"
                   class="form-control"
                   placeholder="${message(code: 'todo.is.ui.select.notext')}"
                   ng-model="sh.name"
                   uib-typeahead="sh as sh.name for sh in searchUsers($viewValue)"
                   typeahead-append-to-body="true"
                   typeahead-loading="searchingSh"
                   typeahead-min-length="2"
                   typeahead-wait-ms="250"
                   typeahead-on-select="addUser($item, 'sh')"
                   typeahead-template-url="select.member.html">
            <span class="input-group-addon">
                <i class="fa" ng-class="{ 'fa-search': !searchingSh, 'fa-refresh':searchingSh }"></i>
            </span>
        </p>
    </div>
    <div ng-class="projectMembersEditable(project) ? 'col-sm-8' : 'col-sm-12' ">
        <label ng-if="project.stakeHolders.length">${message(code: 'todo.is.ui.project.stakeholders')} ({{ project.stakeHolders.length }})</label>
        <div ng-class="{'list-users': project.stakeHolders.length > 0}">
            <ng-include ng-init="role = 'sh';" ng-repeat="user in project.stakeHolders" src="'user.item.project.html'"></ng-include>
        </div>
    </div>
</div>
</script>