<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
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

<is:modal title="${message(code:'is.dialog.wizard')}" class="wizard" footer="false">
    <form name="newProjectForm"
          ng-init="project.preferences.hidden = ${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.project.private.default)};"
          show-validation
          novalidate>
        <wizard class="row wizard-row">
            <wz-step title="${message(code:"is.dialog.wizard.section.project")}" icon="fa fa-pencil">
                <ng-include src="'form.general.project.html'"></ng-include>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-next value="${message(code:'todo.is.ui.wizard.step2')}" />
                </div>
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.team")}" icon="fa fa-users">
                <div ng-controller="teamCtrl">
                    <ng-include src="'form.team.html'"></ng-include>
                    <ng-include src="'form.members.project.html'"></ng-include>
                    <div class="wizard-next">
                        <input type="submit" class="btn btn-default" ng-disabled="!team.members.length > 0" wz-next value="${message(code:'todo.is.ui.wizard.step3')}" />
                    </div>
                </div>
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.options")}" icon="fa fa-sliders">
                <ng-include src="'form.practices.project.html'"></ng-include>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-next value="${message(code:'todo.is.ui.wizard.step4')}" />
                </div>
            </wz-step>
            <wz-step title="${message(code:"todo.is.ui.planning")}" icon="fa fa-calendar">
                <ng-include src="'form.planning.project.html'"></ng-include>
                <div class="wizard-next">
                    <input type="submit" class="btn btn-default" ng-disabled="newProjectForm.$invalid" wz-finish="createProject(project)" value="${message(code:'todo.is.ui.wizard.finish')}" />
                </div>
            </wz-step>
        </wizard>
    </form>
</is:modal>