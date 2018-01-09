%{--
- Copyright (c) 2017 Kagilum.
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
<script type="text/ng-template" id="form.projects.portfolio.html">
<label for="project.name">${message(code: 'todo.is.ui.project.create.or.select')}</label>
<div class="input-group" style="margin-bottom:15px;" ng-if="portfolio.projects.length < 10">
    <input autocomplete="off"
           type="text"
           autofocus
           name="project.name"
           class="form-control"
           uib-typeahead="project as project.name for project in searchProject($viewValue)"
           typeahead-loading="searching"
           typeahead-wait-ms="250"
           typeahead-on-select="selectProject($item); "
           typeahead-template-url="select.or.create.project.html"
           ng-model="formHolder.projectSelection"
           ng-disabled="portfolio.projects.length >= 10">
    <span class="input-group-addon"><i class="fa fa-search"></i></span>
</div>
<div class="alert alert-warning" role="alert" style="margin-bottom: 15px;" ng-if="portfolio.projects.length >= 10">
    ${message(code: 'is.ui.portfolio.limit.projects')}
</div>
<table class="table table-striped table-bordered" ng-if="portfolio.projects.length > 0">
    <thead>
        <th>${message(code: 'is.project.name')}</th>
        <th>${message(code: 'is.project.startDate')}</th>
        <th>${message(code: 'is.project.preferences.planification.estimatedSprintsDuration')}</th>
        <th>${message(code: 'todo.is.ui.project.productOwners')}</th>
        <th>${message(code: 'is.team')}</th>
        <th></th>
    </thead>
    <tbody>
        <tr ng-repeat="project in portfolio.projects" is-watch="project">
            <td>
                {{:: project.name }}
                <i ng-class="['fa', {'fa-eye text-danger': !project.preferences.hidden, 'fa-eye-splash text-success': project.preferences.hidden }]"></i>
                <div class="bg-success"
                     ng-if="project.new"
                     style="display: inline-block;padding-left: 2px;padding-right: 2px;font-weight:bold;">${message(code: 'is.ui.new')}</div>
            </td>
            <td>{{:: project.startDate | dayShort }}</td>
            <td>{{:: project.preferences.estimatedSprintsDuration }} ${g.message(code: 'is.dialog.wizard.project.days').toLowerCase()}</td>
            <td>{{:: project.productOwners | displayNames }}</td>
            <td>{{:: project.team.name }} ({{:: (project.team.scrumMasters.length + project.team.members.length) }})</td>
            <td>
                <button class="btn btn-default btn-sm btn-model"
                        ng-model="foo" %{-- Hack to make form dirty --}%
                        ng-click="removeProject(project)"
                        type="button">
                    <i class="fa fa-times"></i>
                </button>
            </td>
        </tr>
    </tbody>
</table>
</script>