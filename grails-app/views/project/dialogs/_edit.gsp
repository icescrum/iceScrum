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

<is:modal title="${message(code: 'todo.is.ui.project.edit')}" class="modal-split" footer="${false}">
    <div class="row">
        <div class="col-xs-12 col-sm-3 modal-split-left">
            <ul class="nav nav-pills nav-fill flex-column">
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('general') }"
                       ng-click="setCurrentPanel('general')">
                        ${message(code: 'is.dialog.wizard.section.project')}
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('actors') }"
                       ng-click="setCurrentPanel('actors')">
                        ${message(code: 'is.ui.actor.actors')}
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('team') }"
                       ng-click="setCurrentPanel('team')">
                        ${message(code: 'is.dialog.wizard.section.team')}
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('practices') }"
                       ng-click="setCurrentPanel('practices')">
                        ${message(code: 'todo.is.ui.project.practices')}
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('planning') }"
                       ng-click="setCurrentPanel('planning')">
                        ${message(code: 'todo.is.ui.project.planning')}
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('administration') }"
                       ng-click="setCurrentPanel('administration')">
                        ${message(code: 'is.ui.administration')}
                    </a>
                </li>
                <entry:point id="project-edit-left"/>
                <li class="nav-item"
                    ng-repeat="appWithSettings in appsWithSettings">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel(appWithSettings.id) }"
                       ng-click="setCurrentPanel(appWithSettings.id)">
                        {{ appWithSettings.name }}
                    </a>
                </li>
            </ul>
        </div>
        <div class="col-xs-12 col-sm-9 modal-split-right" ng-switch="getCurrentPanel()">
            <section ng-switch-when="general"
                     title="${message(code: 'is.dialog.wizard.section.project')}">
                <div ng-include="'edit.general.project.html'"></div>
            </section>
            <section ng-switch-when="actors"
                     title="${message(code: 'is.ui.actor.actors')}">
                <div ng-include="'edit.general.actors.html'"></div>
            </section>
            <section ng-switch-when="team"
                     title="${message(code: 'is.dialog.wizard.section.team')}">
                <div ng-include="'edit.members.project.html'"></div>
            </section>
            <section ng-switch-when="practices"
                     title="${message(code: 'todo.is.ui.project.practices')}">
                <div ng-include="'edit.practices.project.html'"></div>
            </section>
            <section ng-switch-when="planning"
                     title="${message(code: 'todo.is.ui.project.planning')}">
                <div ng-include="'edit.planning.project.html'"></div>
            </section>
            <section ng-switch-when="administration"
                     title="${message(code: 'is.ui.administration')}">
                <div ng-include="'edit.administration.project.html'"></div>
            </section>
            <entry:point id="project-edit-right"/>
            <section ng-if="isCurrentPanel(appWithSettings.id)"
                     ng-repeat="appWithSettings in appsWithSettings"
                     ng-include="appWithSettings.projectSettings.template"
                     title="{{ appWithSettings.name }}">
            </section>
        </div>
    </div>
</is:modal>