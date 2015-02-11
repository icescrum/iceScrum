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

<is:modal title="${message(code: 'is.dialog.edit')}" class="wizard" footer="false">
    <div class="row wizard-row">
        <ul class="steps-indicator col-sm-3 nav nav-list">
            <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('project') }">
                <a ng-click="setCurrentPanel('project')">${ message(code: 'is.dialog.wizard.section.project')}</a>
            </li>
            <li ng-class="{ current: isCurrentPanel('team') }">
                <a ng-click="setCurrentPanel('team')">${ message(code: 'is.dialog.wizard.section.team')}</a>
            </li>
            <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('practices') }">
                <a ng-click="setCurrentPanel('practices')">${ message(code: 'is.dialog.wizard.section.practices')}</a>
            </li>
            <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('planning') }">
                <a ng-click="setCurrentPanel('planning')">${ message(code: 'is.dialog.wizard.section.planning')}</a>
            </li>
            <li ng-if="authorizedProject('update', currentProject)" ng-class="{ current: isCurrentPanel('administration') }">
                <a ng-click="setCurrentPanel('administration')">${ message(code: 'is.dialog.wizard.section.administration')}</a>
            </li>
        </ul>
        <div class="steps col-sm-9" ng-switch="getCurrentPanel()">
            <section ng-switch-when="project"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.project')}">
                <div ng-include="'edit.general.project.html'"></div>
            </section>
            <section ng-switch-when="team"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.team')}">
                <div ng-include="'edit.members.project.html'"></div>
            </section>
            <section ng-switch-when="practices"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.practices')}">
                <div ng-include="'edit.practices.project.html'"></div>
            </section>
            <section ng-switch-when="planning"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.planning')}">
                <div ng-include="'edit.planning.project.html'"></div>
            </section>
            <section ng-switch-when="administration"
                     class="step current"
                     title="${ message(code: 'is.dialog.wizard.section.administration')}">
                <div ng-include="'edit.administration.project.html'"></div>
            </section>
        </div>
    </div>
</is:modal>