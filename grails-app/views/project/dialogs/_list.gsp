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

<is:modal title="${message(code: 'todo.is.ui.projects')}"
          form="openProject(project)"
          submitButton="${message(code: 'todo.is.ui.open')}"
          class="split-modal">
    <div class="row">
        <div class="left-panel col-sm-3">
            <div class="left-panel-header">
                <div class="input-group">
                    <input type="text"
                           ng-model="projectSearch"
                           ng-change="searchProjects()"
                           ng-model-options="{debounce: 300}"
                           class="form-control"
                           placeholder="${message(code: 'todo.is.ui.search.action')}">
                    <span class="input-group-btn">
                        <button class="btn btn-default"
                                type="button"
                                ng-click="projectSearch = null; searchProjects()">
                            <i class="fa" ng-class="projectSearch ? 'fa-times' : 'fa-search'"></i>
                        </button>
                    </span>
                </div>
            </div>
            <ul class="left-panel-body nav nav-list">
                <li ng-class="{ 'current': currentProject.id == project.id }" ng-repeat="currentProject in projects">
                    <a ng-click="selectProject(currentProject)" href>{{ currentProject.name }}</a>
                </li>
            </ul>
            <div class="left-panel-bottom">
                <div uib-pagination
                     boundary-links="true"
                     previous-text="&lsaquo;" next-text="&rsaquo;" first-text="&laquo;" last-text="&raquo;"
                     class="pagination-sm"
                     max-size="3"
                     total-items="projectCount"
                     items-per-page="projectsPerPage"
                     ng-model="currentPage"
                     ng-change="searchProjects()">
                </div>
            </div>
        </div>
        <div class="right-panel col-sm-9" ng-switch="projects != undefined && projects.length == 0">
            <div ng-switch-when="true">
                ${message(code: 'todo.is.ui.project.noproject')}
            </div>
            <div class="col-md-12" ng-switch-default>
                <div ng-include="'project.summary.html'"></div>
            </div>
        </div>
    </div>
</is:modal>