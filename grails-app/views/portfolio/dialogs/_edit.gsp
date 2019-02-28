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

<is:modal title="${message(code: 'is.ui.portfolio.edit')}" class="wizard split-modal" footer="${false}">
    <div class="row">
        <div class="col-xs-12 col-sm-3">
            <ul class="nav nav-pills nav-fill">
                <li class="nav-item"
                    ng-if="authorizedPortfolio('update', currentPortfolio)">
                    <a class="nav-link"
                       href
                       ng-click="setCurrentPanel('general')"
                       ng-class="{ active: isCurrentPanel('general') }">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.dialog.wizard.section.portfolio')}</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href
                       ng-click="setCurrentPanel('projects')"
                       ng-class="{ active: isCurrentPanel('projects') }">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.dialog.wizard.section.portfolio.projects')}</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href
                       ng-click="setCurrentPanel('members')"
                       ng-class="{ active: isCurrentPanel('members') }">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.dialog.wizard.section.portfolio.members')}</span>
                    </a>
                </li>
                <li class="nav-item"
                    ng-if="authorizedPortfolio('update', currentPortfolio)">
                    <a class="nav-link"
                       href
                       ng-click="setCurrentPanel('administration')"
                       ng-class="{ active: isCurrentPanel('administration') }">
                        <span class="hidden-xs hidden-sm">${message(code: 'is.ui.administration')}</span>
                    </a>
                </li>
            </ul>
        </div>
        <div class="col-xs-12 col-sm-9" ng-switch="getCurrentPanel()">
            <section ng-switch-when="general"
                     class="step current"
                     title="${message(code: 'is.dialog.wizard.section.portfolio')}">
                <div ng-include="'edit.general.portfolio.html'"></div>
            </section>
            <section ng-switch-when="projects"
                     class="step current"
                     title="${message(code: 'is.dialog.wizard.section.portfolio.projects')}">
                <div ng-include="'edit.projects.portfolio.html'"></div>
            </section>
            <section ng-switch-when="members"
                     class="step current"
                     title="${message(code: 'is.dialog.wizard.section.portfolio.members')}">
                <div ng-include="'edit.members.portfolio.html'"></div>
            </section>
            <section ng-switch-when="administration"
                     class="step current"
                     title="${message(code: 'is.ui.danger.zone')}">
                <div ng-include="'edit.administration.portfolio.html'"></div>
            </section>
        </div>
    </div>
</is:modal>