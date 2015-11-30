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
<script type="text/ng-template" id="sprint.new.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            ${message(code: "todo.is.ui.sprint.new")}
            <a class="pull-right visible-on-hover btn btn-default"
               href="#/{{ ::viewName }}"
               uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                <i class="fa fa-times"></i>
            </a>
        </h3>
    </div>
    <div class="right-properties new panel-body">
        <div class="help-block">${message(code:'is.ui.sprint.help')}</div>
        <form ng-submit="save(sprint, false)"
              name='formHolder.sprintForm'
              novalidate>
            <div class="form-group">
                <label for="sprint.parentRelease">${message(code:'is.sprint.parentRelease')}</label>
                <ui-select class="form-control"
                           ng-model="sprint.parentRelease"
                           on-select="selectRelease(sprint.parentRelease)"
                           required>
                    <ui-select-match>{{ $select.selected.name }}</ui-select-match>
                    <ui-select-choices repeat="editableRelease in editableReleases">{{ editableRelease.name }}</ui-select-choices>
                </ui-select>
            </div>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="sprint.startDate">${message(code:'is.sprint.startDate')}</label>
                    <div class="input-group">
                        <span class="input-group-btn">
                            <button type="button"
                                    class="btn btn-default"
                                    ng-click="openDatepicker($event, startDateOptions)">
                                <i class="fa fa-calendar"></i>
                            </button>
                        </span>
                        <input type="text"
                               class="form-control"
                               required
                               name="sprint.startDate"
                               ng-model="sprint.startDate"
                               uib-datepicker-popup
                               min-date="minStartDate"
                               max-date="maxStartDate"
                               is-open="startDateOptions.opened"/>
                    </div>
                </div>
                <div class="form-half">
                    <label for="sprint.endDate" class="text-right">${message(code:'is.sprint.endDate')}</label>
                    <div class="input-group">
                        <input type="text"
                               class="form-control text-right"
                               required
                               name="sprint.endDate"
                               ng-model="sprint.endDate"
                               uib-datepicker-popup
                               min-date="minEndDate"
                               is-open="endDateOptions.opened"/>
                        <span class="input-group-btn">
                            <button type="button"
                                    class="btn btn-default"
                                    ng-click="openDatepicker($event, endDateOptions)">
                                <i class="fa fa-calendar"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div class="btn-toolbar pull-right">
                <button class="btn btn-primary pull-right"
                        ng-disabled="formHolder.sprintForm.$invalid"
                        uib-tooltip="${message(code:'default.button.create.label')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'default.button.create.label')}
                </button>
                <button class="btn btn-primary pull-right"
                        ng-disabled="formHolder.sprintForm.$invalid"
                        uib-tooltip="${message(code:'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                        tooltip-append-to-body="true"
                        hotkey="{'shift+return': hotkeyClick }"
                        hotkey-allow-in="INPUT"
                        type='button'
                        ng-click="save(sprint, true)">
                    ${message(code:'todo.is.ui.create.and.continue')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>
