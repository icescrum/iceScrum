<%@ page import="org.icescrum.core.utils.BundleUtils" %>
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
<script type="text/ng-template" id="form.practices.html">
    <h4>${message(code:"is.dialog.wizard.section.practices")}</h4>
    <h5>${message(code:"is.dialog.wizard.section.practices.backlog")}</h5>
    <p class="help-block">${message(code:'is.dialog.wizard.section.project.practices.backlog.help')}</p>
    <div class="row">
        <div class="form-group" ng-class="{'col-sm-6': !project.preferences.noEstimation, 'col-sm-12': project.preferences.noEstimation}">
            <label for="noEstimation">${message(code:'is.product.preferences.planification.noEstimation')}</label>
            <div class="radio">
                <label class="checkbox-inline">
                    <input type="radio"
                           name="project.preferences.noEstimation"
                           id="noEstimation"
                           ng-model="project.preferences.noEstimation"
                           ng-value="true">
                    ${message(code:'is.yes')}
                </label>
                <label class="checkbox-inline">
                    <input type="radio"
                           name="project.preferences.noEstimation"
                           id="noEstimation"
                           ng-model="project.preferences.noEstimation"
                           ng-value="false">
                    ${message(code:'is.no')}
                </label>
            </div>
        </div>
        <div class="form-group col-sm-12" ng-class="{'col-sm-6': !project.preferences.noEstimation}" ng-show="!project.preferences.noEstimation">
            <label for="estimationSuite">${message(code:'is.product.preferences.planification.estimationSuite')}</label>
            <select class="form-control"
                    name="type"
                    id="estimationSuite"
                    ng-disabled="project.preferences.noEstimation"
                    ng-model="project.planningPokerGameType"
                    ui-select2>
                <is:options values="${is.internationalizeValues(map: BundleUtils.planningPokerGameSuites)}" />
            </select>
        </div>
    </div>
    <h5>${message(code:"is.dialog.wizard.section.practices.sprint")}</h5>
    <p class="help-block">${message(code:'is.dialog.wizard.section.project.practices.sprint.help')}</p>
    <div class="row">
        <div class="form-group col-sm-12">
            <label for="sprintDuration">${message(code:'is.product.preferences.planification.estimatedSprintsDuration')}</label>
            <input required
                   type="text"
                   name="project.preferences.sprintDuration"
                   id="sprintDuration"
                   ng-pattern="/^[0-9]+$/"
                   ng-required="isCurrentStep(3)"
                   ng-model="project.preferences.sprintDuration">
        </div>
    </div>
    <div class="row">
        <div class="form-group col-sm-6">
            <label for="displayRecurrentTasks">${message(code:'is.product.preferences.sprint.displayRecurrentTasks')}</label>
            <div class="radio">
                <label class="checkbox-inline">
                    <input type="radio"
                           name="project.preferences.displayRecurrentTasks"
                           id="displayRecurrentTasks"
                           ng-model="project.preferences.displayRecurrentTasks"
                           ng-value="true">
                    ${message(code:'is.yes')}
                </label>
                <label class="checkbox-inline">
                    <input type="radio"
                           name="project.preferences.displayRecurrentTasks"
                           ng-model="project.preferences.displayRecurrentTasks"
                           id="displayRecurrentTasks"
                           ng-value="false">
                    ${message(code:'is.no')}
                </label>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label for="displayUrgentTasks">${message(code:'is.product.preferences.sprint.displayUrgentTasks')}</label>
            <div class="radio">
                <label class="checkbox-inline">
                    <input type="radio"
                           name="project.preferences.displayUrgentTasks"
                           id="displayUrgentTasks"
                           ng-model="project.preferences.displayUrgentTasks"
                           ng-value="true">
                    ${message(code:'is.yes')}
                </label>
                <label class="checkbox-inline">
                    <input type="radio"
                           name="project.preferences.displayUrgentTasks"
                           id="displayUrgentTasks"
                           ng-model="project.preferences.displayUrgentTasks"
                           ng-value="false">
                    ${message(code:'is.no')}
                </label>
            </div>
        </div>
    </div>
</script>