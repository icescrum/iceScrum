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
    <div class="row wizard-row">
        <div class="left-panel col-xs-12 col-sm-3">
            <ul class="left-panel-body nav nav-list">
                <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('general') }">
                    <a ng-click="setCurrentPanel('general')"><i class="fa fa-pencil"></i> <span class="hidden-xs hidden-sm">${ message(code: 'is.dialog.wizard.section.project')}</span></a>
                </li>
                <li ng-class="{ current: isCurrentPanel('prodfoo') }">
                    <a ng-click="setCurrentPanel('actors')"><i class="fa fa-child"></i> <span class="hidden-xs hidden-sm">${ message(code: 'is.ui.actor.actors')}</span></a>
                </li>
                <li ng-class="{ current: isCurrentPanel('team') }">
                    <a ng-click="setCurrentPanel('team')"><i class="fa fa-users"></i> <span class="hidden-xs hidden-sm">${ message(code: 'is.dialog.wizard.section.team')}</span></a>
                </li>
                <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('practices') }">
                    <a ng-click="setCurrentPanel('practices')"><i class="fa fa-sliders"></i> <span class="hidden-xs hidden-sm">${ message(code: 'todo.is.ui.project.practices')}</span></a>
                </li>
                <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('planning') }">
                    <a ng-click="setCurrentPanel('planning')"><i class="fa fa-calendar"></i> <span class="hidden-xs hidden-sm">${ message(code: 'todo.is.ui.project.planning')}</span></a>
                </li>
                <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('administration') }">
                    <a ng-click="setCurrentPanel('administration')"><i class="fa fa-cogs"></i> <span class="hidden-xs hidden-sm">${ message(code: 'todo.is.ui.project.administration')}</span></a>
                </li>
                <entry:point id="project-edit-left"/>
            </ul>
        </div>
        <div class="right-panel steps col-xs-12 col-sm-9" ng-switch="getCurrentPanel()">
            <section ng-switch-when="general"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.project')}">
                <div ng-include="'edit.general.project.html'"></div>
            </section>
            <section ng-switch-when="actors"
                     class="step current"
                     title="${ message(code: 'is.ui.actor.actors')}">
                <div ng-include="'edit.general.prodfoo.html'"></div>
            </section>
            <section ng-switch-when="team"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.team')}">
                <div ng-include="'edit.members.project.html'"></div>
            </section>
            <section ng-switch-when="practices"
                     class="step current"
                     title="${ message(code: 'todo.is.ui.project.practices')}">
                <div ng-include="'edit.practices.project.html'"></div>
            </section>
            <section ng-switch-when="planning"
                     class="step current"
                     title="${ message(code: 'todo.is.ui.project.planning')}">
                <div ng-include="'edit.planning.project.html'"></div>
            </section>
            <section ng-switch-when="administration"
                     class="step current"
                     title="${ message(code: 'todo.is.ui.project.administration')}">
                <div ng-include="'edit.administration.project.html'"></div>
            </section>
            <entry:point id="project-edit-right"/>
        </div>
    </div>
</is:modal>