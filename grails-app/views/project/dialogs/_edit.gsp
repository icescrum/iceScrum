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

<is:modal title="${message(code: 'todo.is.ui.project.edit')}" class="wizard split-modal" footer="${false}">
    <div class="row">
        <div class="col-xs-12 col-sm-3">
            <ul class="nav nav-pills nav-fill">
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('general') }"
                       ng-click="setCurrentPanel('general')">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.dialog.wizard.section.project')}</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('actors') }"
                       ng-click="setCurrentPanel('actors')">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.ui.actor.actors')}</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('team') }"
                       ng-click="setCurrentPanel('team')">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.dialog.wizard.section.team')}</span>
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('practices') }"
                       ng-click="setCurrentPanel('practices')">
                        <span class="hidden-xs hidden-sm">${message(code: 'todo.is.ui.project.practices')}</span>
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('planning') }"
                       ng-click="setCurrentPanel('planning')">
                        <span class="hidden-xs hidden-sm">${message(code: 'todo.is.ui.project.planning')}</span>
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedProject('update', currentProject)">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel('administration') }"
                       ng-click="setCurrentPanel('administration')">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.ui.administration')}</span>
                    </a>
                </li>
                <entry:point id="project-edit-left"/>
                <li class="nav-item"
                    ng-repeat="appWithSettings in appsWithSettings">
                    <a class="nav-link"
                       href
                       ng-class="{ active: isCurrentPanel(appWithSettings.id) }"
                       ng-click="setCurrentPanel(appWithSettings.id)">
                        <span class="hidden-xs hidden-sm">{{ appWithSettings.name }}</span>
                    </a>
                </li>
            </ul>
        </div>
        <div class="col-xs-12 col-sm-9" ng-switch="getCurrentPanel()">
            <section ng-switch-when="general"
                     class="step current"
                     title="${message(code: 'is.dialog.wizard.section.project')}">
                <div ng-include="'edit.general.project.html'"></div>
            </section>
            <section ng-switch-when="actors"
                     class="step current"
                     title="${message(code: 'is.ui.actor.actors')}">
                <div ng-include="'edit.general.actors.html'"></div>
            </section>
            <section ng-switch-when="team"
                     class="step current"
                     title="${message(code: 'is.dialog.wizard.section.team')}">
                <div ng-include="'edit.members.project.html'"></div>
            </section>
            <section ng-switch-when="practices"
                     class="step current"
                     title="${message(code: 'todo.is.ui.project.practices')}">
                <div ng-include="'edit.practices.project.html'"></div>
            </section>
            <section ng-switch-when="planning"
                     class="step current"
                     title="${message(code: 'todo.is.ui.project.planning')}">
                <div ng-include="'edit.planning.project.html'"></div>
            </section>
            <section ng-switch-when="administration"
                     class="step current"
                     title="${message(code: 'is.ui.administration')}">
                <div ng-include="'edit.administration.project.html'"></div>
            </section>
            <entry:point id="project-edit-right"/>
            <section ng-if="isCurrentPanel(appWithSettings.id)"
                     class="step current"
                     ng-repeat="appWithSettings in appsWithSettings"
                     ng-include="appWithSettings.projectSettings.template"
                     title="{{ appWithSettings.name }}">
            </section>
        </div>
    </div>
</is:modal>