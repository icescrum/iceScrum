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
<form ng-submit="update(editableRelease)"
      name='formHolder.releaseForm'
      ng-class="{'form-editable': formEditable(), 'form-editing': formHolder.editing }"
      show-validation
      novalidate>
    <div class="panel-body">
        <div class="clearfix no-padding">
            <div class="form-3-quarters">
                <label for="name">${message(code: 'is.release.name')}</label>
                <input required
                       name="name"
                       ng-focus="editForm(true)"
                       ng-disabled="!formEditable()"
                       ng-model="editableRelease.name"
                       type="text"
                       class="form-control"
                       placeholder="${message(code: 'is.ui.release.noname')}"/>
            </div>
            <div class="form-1-quarter">
                <label for="firstSprintIndex">${message(code: 'is.release.firstSprintIndex')}</label>
                <input required
                       name="firstSprintIndex"
                       ng-focus="editForm(true)"
                       ng-disabled="!formEditable()"
                       ng-model="editableRelease.firstSprintIndex"
                       type="number"
                       class="form-control"/>
            </div>
        </div>
        <div class="clearfix no-padding">
            <div class="form-half">
                <label for="release.startDate">${message(code: 'is.release.startDate')}</label>
                <div ng-class="{'input-group': authorizedRelease('updateDates', release)}">
                    <input type="text"
                           class="form-control"
                           required
                           ng-focus="editForm(true)"
                           name="release.startDate"
                           ng-disabled="!authorizedRelease('updateDates', release)"
                           ng-model="editableRelease.startDate"
                           ng-model-options="{timezone: 'utc'}"
                           uib-datepicker-popup
                           datepicker-options="startDateOptions"
                           is-open="startDateOptions.opened"/>
                    <span class="input-group-btn"
                          ng-if="authorizedRelease('updateDates', release)">
                        <button type="button"
                                class="btn btn-default"
                                ng-focus="editForm(true)"
                                ng-click="openDatepicker($event, startDateOptions)">
                            <i class="fa fa-calendar"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="form-half">
                <label for="release.endDate">${message(code: 'is.release.endDate')}</label>
                <div ng-class="{'input-group': authorizedRelease('updateDates', release)}">
                    <input type="text"
                           class="form-control"
                           required
                           ng-focus="editForm(true)"
                           name="release.endDate"
                           ng-disabled="!authorizedRelease('updateDates', release)"
                           ng-model="editableRelease.endDate"
                           ng-model-options="{timezone: 'utc'}"
                           uib-datepicker-popup
                           datepicker-options="endDateOptions"
                           is-open="endDateOptions.opened"/>
                    <span class="input-group-btn"
                          ng-if="authorizedRelease('updateDates', release)">
                        <button type="button"
                                class="btn btn-default"
                                ng-focus="editForm(true)"
                                ng-click="openDatepicker($event, endDateOptions)">
                            <i class="fa fa-calendar"></i>
                        </button>
                    </span>
                </div>
            </div>
        </div>
        <div class="chart"
             ng-controller="chartCtrl"
             ng-init="openChart('release', 'burndown', release)">
            <div uib-dropdown
                 ng-controller="projectChartCtrl"
                 class="pull-right">
                <div class="btn-group visible-on-hover">
                    <button class="btn btn-default btn-sm"
                            ng-click="openChartInModal(chartParams)"
                            type="button">
                        <i class="fa fa-search-plus"></i>
                    </button>
                    <button class="btn btn-default btn-sm"
                            ng-click="saveChart(chartParams)"
                            type="button">
                        <i class="fa fa-floppy-o"></i>
                    </button>
                </div>
                <button class="btn btn-default btn-sm"
                        uib-tooltip="${message(code: 'todo.is.ui.charts')}"
                        type="button"
                        uib-dropdown-toggle>
                    <i class="fa fa-bar-chart"></i> <i class="fa fa-caret-down"></i>
                </button>
                <ul uib-dropdown-menu>
                    <li ng-repeat="chart in projectCharts.release"><a href ng-click="openChart('release', chart.id, release)">{{ message(chart.name) }}</a></li>
                </ul>
            </div>
            <nvd3 options="options | merge: {chart:{height: 200}, title:{enable: false}}" data="data"></nvd3>
        </div>
        <div class="form-group">
            <label for="vision">${message(code: 'is.ui.releasePlan.toolbar.vision')}</label>
            <textarea at
                      is-markitup
                      ng-maxlength="5000"
                      class="form-control"
                      name="vision"
                      ng-model="editableRelease.vision"
                      is-model-html="editableRelease.vision_html"
                      ng-show="showVisionTextarea"
                      ng-blur="showVisionTextarea = false"
                      placeholder="${message(code: 'todo.is.ui.release.novision')}"></textarea>
            <div class="markitup-preview"
                 ng-disabled="!formEditable()"
                 ng-show="!showVisionTextarea"
                 ng-click="showVisionTextarea = formEditable()"
                 ng-focus="editForm(true); showVisionTextarea = formEditable()"
                 ng-class="{'placeholder': !editableRelease.vision_html}"
                 tabindex="0"
                 ng-bind-html="editableRelease.vision_html ? editableRelease.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>'"></div>
        </div>
        <div class="form-group">
            <label>${message(code: 'is.backlogelement.attachment')} {{ release.attachments_count > 0 ? '(' + release.attachments_count + ')' : '' }}</label>
            <div ng-if="authorizedRelease('upload', release)"
                 ng-controller="attachmentNestedCtrl">
                <button type="button"
                        class="btn btn-default"
                        flow-btn>
                    <i class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}
                </button>
                <entry:point id="attachment-add-buttons"/>
            </div>
            <div class="form-control-static" ng-include="'attachment.list.html'">
            </div>
        </div>
    </div>
    <div class="panel-footer" ng-if="isModal || formHolder.editing">
        <div class="btn-toolbar" ng-class="[{ 'pull-right' : isModal }]">
            <button class="btn btn-primary"
                    ng-if="formHolder.editing && (isLatest() || application.submitting)"
                    ng-disabled="!isDirty() || formHolder.releaseForm.$invalid || application.submitting"
                    type="submit">
                ${message(code: 'default.button.update.label')}
            </button>
            <button class="btn btn-danger"
                    ng-if="formHolder.editing && !isLatest() && !application.submitting"
                    ng-disabled="!isDirty() || formHolder.releaseForm.$invalid"
                    type="submit">
                ${message(code: 'default.button.override.label')}
            </button>
            <button class="btn btn-default"
                    type="button"
                    ng-if="(!isModal && formHolder.editing) || (isModal && isDirty())"
                    ng-click="editForm(false)">
                ${message(code: 'is.button.cancel')}
            </button>
            <button class="btn btn-warning"
                    type="button"
                    ng-if="isDirty() && !isLatest() && !application.submitting"
                    ng-click="resetReleaseForm()">
                <i class="fa fa-warning"></i> ${message(code: 'default.button.refresh.label')}
            </button>
            <button class="btn btn-default"
                    type="button"
                    ng-if="isModal && !isDirty()"
                    ng-click="$close()">
                ${message(code: 'is.button.close')}
            </button>
        </div>
    </div>
</form>