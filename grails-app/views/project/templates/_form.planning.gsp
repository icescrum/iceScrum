<%@ page import="org.icescrum.core.utils.BundleUtils" %>
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
<script type="text/ng-template" id="form.planning.project.html">
    <h4>${message(code:"is.dialog.wizard.section.planning")}</h4>
    <p class="help-block">${message(code:'is.dialog.wizard.section.project.planning.help')}</p>
    <div class="row">
        <div class="form-half">
            <label for="project.preferences.timezone">${message(code:'is.product.preferences.timezone')}</label>
            <is:localeTimeZone required="required"
                               class="form-control"
                               ng-required="isCurrentStep(4)"
                               name="project.preferences.timezone"
                               ng-model="project.preferences.timezone"
                               ui-select2=""></is:localeTimeZone>
        </div>
        <div class="form-half">
            <label for="project.startDate">${message(code:'is.dialog.wizard.project.startDate')}</label>
            <div class="input-group">
                <span class="input-group-btn">
                    <button type="button" class="btn btn-default" ng-click="openDatepicker($event, startDate)"><i class="fa fa-calendar"></i></button>
                </span>
                <input type="text"
                       class="form-control"
                       name="project.startDate"
                       ng-model="project.startDate"
                       uib-datepicker-popup
                       is-open="startDate.opened"
                       max-date="projectMaxStartDate"
                       ng-required="isCurrentStep(4)"/>
            </div>
        </div>
        <div class="form-half" ng-if="type != 'newProject'">
            <label for="hideWeekend" class="checkbox-inline">
                <input type="checkbox"
                       name="project.preferences.hideWeekend"
                       id="hideWeekend"
                       ng-model="project.preferences.hideWeekend">
                ${message(code:'is.product.preferences.project.hideWeekend')}
            </label>
        </div>
    </div>
    <div class="row" ng-if="type == 'newProject'">
        <div class="form-half">
            <label for="initializeProject" class="checkbox-inline">
                <input type="checkbox"
                       name="project.initialize"
                       id="initializeProject"
                       ng-model="project.initialize">
                ${message(code:'is.product.preferences.sprint.initialize')}
            </label>
        </div>
    </div>
    <div class="row" ng-if="project.initialize">
        <div class="form-group col-md-4">
            <label for="project.firstSprint">${message(code:'is.dialog.wizard.firstSprint')}</label>
            <div class="input-group">
                <span class="input-group-btn">
                    <button type="button" class="btn btn-default" ng-click="openDatepicker($event, firstSprint)"><i class="fa fa-calendar"></i></button>
                </span>
                <input type="text"
                       class="form-control"
                       name="project.firstSprint"
                       ng-model="project.firstSprint"
                       ng-change="computePlanning()"
                       uib-datepicker-popup
                       is-open="firstSprint.opened"
                       min-date="sprintMinStartDate"
                       max-date="sprintMaxStartDate"
                       ng-class="{current:step.selected}"
                       ng-required="isCurrentStep(4)"/>
            </div>
        </div>
        <div class="form-group col-md-4">
            <label for="estimatedSprintsDuration">${message(code:'is.product.preferences.planification.estimatedSprintsDuration')}</label>
            <div class="input-group">
                <input class="form-control"
                       type="number"
                       name="project.preferences.estimatedSprintsDuration"
                       id="estimatedSprintsDuration"
                       ng-pattern="/^[0-9]+$/"
                       ng-required="isCurrentStep(4)"
                       ng-change="computePlanning()"
                       ng-model="project.preferences.estimatedSprintsDuration">
                <div class="input-group-addon">${message(code:'is.dialog.wizard.project.days')}</div>
            </div>
        </div>
        <div class="form-group col-md-4">
            <label for="project.endDate" class="text-right">${message(code:'is.dialog.wizard.project.endDate')}</label>
            <div class="input-group">
                <input type="text"
                       class="form-control text-right"
                       name="project.endDate"
                       ng-model="project.endDate"
                       ng-change="computePlanning()"
                       uib-datepicker-popup
                       is-open="endDate.opened"
                       min-date="projectMinEndDate"
                       ng-class="{current:step.selected}"
                       ng-required="isCurrentStep(4)"/>
                <span class="input-group-btn">
                    <button type="button" class="btn btn-default" ng-click="openDatepicker($event, endDate)"><i class="fa fa-calendar"></i></button>
                </span>
            </div>
        </div>
        <div class="col-sm-12 form-group">
            <uib-progress class="form-control-static form-bar" max="totalDuration">
                <uib-bar ng-repeat="sprint in sprints"
                     class="{{ $last ? 'last-bar' : '' }}"
                     uib-tooltip-template="'sprint.tooltip.html'"
                     type="default"
                     value="project.preferences.estimatedSprintsDuration">
                    #{{ sprint.orderNumber }}
                </uib-bar>
            </uib-progress>
        </div>
        <div class="col-sm-12 form-group">
            <label for="vision">${message(code:'is.release.vision')}</label>
            <textarea is-markitup
                      name="project.vision"
                      class="form-control"
                      placeholder="${message(code: 'todo.is.ui.product.vision.placeholder')}"
                      ng-model="project.vision"
                      ng-show="showVisionTextarea"
                      ng-blur="showVisionTextarea = false"
                      is-model-html="project.vision_html"></textarea>
            <div class="markitup-preview"
                 tabindex="0"
                 ng-show="!showVisionTextarea"
                 ng-click="showVisionTextarea = true"
                 ng-focus="showVisionTextarea = true"
                 ng-class="{'placeholder': !project.vision_html}"
                 ng-bind-html="(project.vision_html ? project.vision_html : '<p>${message(code: 'todo.is.ui.product.vision.placeholder')}</p>') | sanitize"></div>
        </div>
    </div>
</script>