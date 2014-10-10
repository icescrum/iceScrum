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

<is:modal title="${message(code:'is.dialog.wizard')}" class="wizard" footer="${false}">
    <form name="newProjectForm"
          show-validation
          novalidate>
        <wizard class="row">
            <wz-step title="${message(code:"is.dialog.wizard.section.project")}">
                <ng-include src="'form.project.html'"></ng-include>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-next value="${message(code:'todo.is.ui.wizard.step2')}" />
                </div>
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.team")}">
                <ng-include src="'form.team.html'"></ng-include>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="!team.members.length > 0" wz-next value="${message(code:'todo.is.ui.wizard.step3')}" />
                </div>
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.options")}">
                <ng-include src="'form.practices.html'"></ng-include>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-next value="${message(code:'todo.is.ui.wizard.step4')}" />
                </div>
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.starting")}">
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-next value="${message(code:'todo.is.ui.wizard.finish')}" />
                </div>
            </wz-step>
        </wizard>
    </form>
</is:modal>