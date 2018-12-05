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
<h4>${message(code: "todo.is.ui.project.planning")}</h4>
<div class="row">
    <div class="form-half">
        <label for="project.startDate">${message(code: 'is.dialog.wizard.project.startDate')}</label>
        <div class="input-group">
            <span class="input-group-before">
                <button type="button" class="btn btn-secondary" ng-click="openDatepicker($event, startDateOptions)"><i class="fa fa-calendar"></i></button>
            </span>
            <input type="text"
                   class="form-control"
                   name="project.startDate"
                   ng-model="project.startDate"
                   ng-model-options="{timezone: 'utc'}"
                   uib-datepicker-popup
                   is-open="startDateOptions.opened"
                   datepicker-options="startDateOptions"
                   ng-required="isCurrentStep(4, 'project')"/>
        </div>
    </div>
    <div class="form-half">
        <label for="project.preferences.timezone">${message(code: 'is.project.preferences.timezone')}</label>
        <ui-select required="required"
                   class="form-control"
                   ng-required="isCurrentStep(4, 'project')"
                   name="project.preferences.timezone"
                   search-enabled="true"
                   ng-model="project.preferences.timezone">
            <ui-select-match placeholder="${message(code: 'todo.is.ui.project.notimezone')}">{{ timezones[$select.selected] }}</ui-select-match>
            <ui-select-choices repeat="timezoneKey in timezoneKeys | filter: $select.search">
                <span ng-bind-html="timezones[timezoneKey] | highlight: $select.search"></span>
            </ui-select-choices>
        </ui-select>
    </div>
</div>
<div class="row">
    <div class="form-half">
        <label for="estimatedSprintsDuration">${message(code: 'is.project.preferences.planification.estimatedSprintsDuration')}</label>
        <div class="input-group">
            <input class="form-control"
                   type="number"
                   name="project.preferences.estimatedSprintsDuration"
                   id="estimatedSprintsDuration"
                   min="2"
                   ng-pattern="/^[0-9]+$/"
                   ng-required="isCurrentStep(4, 'project')"
                   ng-change="computePlanning()"
                   ng-model="project.preferences.estimatedSprintsDuration">
            <div class="input-group-after">
                <div class="input-group-text">${message(code: 'is.dialog.wizard.project.days')}</div>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="form-half">
        <label ng-if="type == 'newProject'"
               for="initializeProject">
            <input type="checkbox"
                   name="project.initialize"
                   id="initializeProject"
                   ng-model="project.initialize">
            ${message(code: 'todo.is.ui.project.planning.initialize')}
        </label>
        <label ng-if="type != 'newProject'"
               for="hideWeekend">
            <input type="checkbox"
                   name="project.preferences.hideWeekend"
                   id="hideWeekend"
                   ng-model="project.preferences.hideWeekend">
            ${message(code: 'is.project.preferences.project.hideWeekend')}
        </label>
    </div>
</div>
<div class="row" ng-if="project.initialize">
    <div class="form-half">
        <label for="project.firstSprint">${message(code: 'is.dialog.wizard.firstSprint')}</label>
        <div class="input-group">
            <span class="input-group-before">
                <button type="button" class="btn btn-secondary" ng-click="openDatepicker($event, firstSprintOptions)"><i class="fa fa-calendar"></i></button>
            </span>
            <input type="text"
                   class="form-control"
                   name="project.firstSprint"
                   ng-model="project.firstSprint"
                   ng-model-options="{timezone: 'utc'}"
                   uib-datepicker-popup
                   is-open="firstSprintOptions.opened"
                   datepicker-options="firstSprintOptions"
                   ng-class="{current:step.selected}"
                   ng-required="isCurrentStep(4, 'project')"/>
        </div>
    </div>
    <div class="form-half">
        <label for="project.endDate" class="text-right">${message(code: 'is.dialog.wizard.project.endDate')}</label>
        <div class="input-group">
            <input type="text"
                   class="form-control text-right"
                   name="project.endDate"
                   ng-model="project.endDate"
                   ng-model-options="{timezone: 'utc'}"
                   uib-datepicker-popup
                   is-open="endDateOptions.opened"
                   datepicker-options="endDateOptions"
                   ng-class="{current:step.selected}"
                   ng-required="isCurrentStep(4, 'project')"/>
            <span class="input-group-after">
                <button type="button" class="btn btn-secondary" ng-click="openDatepicker($event, endDateOptions)"><i class="fa fa-calendar"></i></button>
            </span>
        </div>
    </div>
    <div class="col-sm-12 form-group">
        <uib-progress class="form-control-static form-bar" max="totalDuration">
            <uib-bar ng-repeat="sprint in sprints"
                     class="{{ $last ? 'last-bar' : '' }}"
                     uib-tooltip-template="'sprint.tooltip.html'"
                     type="todo"
                     value="project.preferences.estimatedSprintsDuration">
                {{ sprint.index }}
            </uib-bar>
        </uib-progress>
    </div>
    <div class="col-sm-12 form-group">
        <label for="vision">${message(code: 'is.release.vision')}</label>
        <textarea at
                  is-markitup
                  name="project.vision"
                  class="form-control"
                  placeholder="${message(code: 'todo.is.ui.release.novision')}"
                  ng-model="project.vision"
                  ng-show="showVisionTextarea"
                  ng-blur="delayCall(toggleVision, [false])"
                  is-model-html="project.vision_html"></textarea>
        <div class="markitup-preview"
             tabindex="0"
             ng-show="!showVisionTextarea"
             ng-click="toggleVision(true)"
             ng-focus="toggleVision(true)"
             ng-class="{'placeholder': !project.vision_html}"
             ng-bind-html="project.vision_html ? project.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>'"></div>
    </div>
</div>
</script>
