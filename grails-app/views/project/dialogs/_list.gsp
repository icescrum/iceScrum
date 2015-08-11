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

<is:modal title="${message(code: 'is.dialog.browse.projects')}"
          form="openProject(selectedProject)"
          submitButton="${message(code:'todo.is.ui.open')}"
          class="split-modal"
          footer="false">
    <div class="row">
        <ul class="left-panel col-sm-3 nav nav-list">
            <div class="input-group">
                <input type="text" ng-model="projectSearch" ng-change="searchProjects()" ng-model-options="{debounce: 300}" class="form-control" placeholder="todo.is.ui.search">
                <span class="input-group-btn">
                    <button class="btn btn-default" type="button"><span class="fa fa-search"></span></button>
                </span>
            </div>
            <li ng-class="{ 'current': selectedProject.id == project.id }" ng-repeat="project in projects">
                <a ng-click="selectProject(project)" href>{{ project.name }}</a>
            </li>
            <pagination boundary-links="true"
                        previous-text="&lsaquo;" next-text="&rsaquo;" first-text="&laquo;" last-text="&raquo;"
                        class="pagination-sm"
                        max-size="3"
                        total-items="totalProjects"
                        items-per-page="projectsPerPage"
                        ng-model="currentPage"
                        ng-change="searchProjects()">
            </pagination>
        </ul>
        <div class="right-panel col-sm-9" ng-switch="projects != undefined && projects.length == 0">
            <div ng-switch-when="true">
                ${ message(code: 'is.dialog.browse.noproject') }
            </div>
            <table ng-switch-default class="table">
                <tr>
                    <td>name</td>
                    <td>{{ selectedProject.name }}</td>
                </tr>
                <tr>
                    <td>pkey</td>
                    <td>{{ selectedProject.pkey }}</td>
                </tr>
                <tr>
                    <td>description</td>
                    <td>{{ selectedProject.description }}</td>
                </tr>
                <tr>
                    <td>startDate</td>
                    <td>{{ selectedProject.startDate }}</td>
                </tr>
                <tr>
                    <td>releases_count</td>
                    <td>{{ selectedProject.releases_count }}</td>
                </tr>
                <tr>
                    <td>features_count</td>
                    <td>{{ selectedProject.features_count }}</td>
                </tr>
                <tr>
                    <td>stories_count</td>
                    <td>{{ selectedProject.stories_count }}</td>
                </tr>
                <tr>
                    <td>actors_count</td>
                    <td>{{ selectedProject.actors_count }}</td>
                </tr>
            </table>
        </div>
    </div>
</is:modal>