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
<script type="text/ng-template" id="release.details.html">
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, release)"
     flow-drop-enabled="authorizedRelease('upload', release)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedRelease('upload', release) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <span>{{ release.name }}</span>
            </div>
            <div class="right-title">
                <button class="btn btn-default elemid">{{ release.id }}</button>
                <div class="btn-group"
                     uib-dropdown>
                    <button type="button" class="btn btn-default" uib-dropdown-toggle>
                        <i class="fa fa-cog"></i> <i class="caret"></i>
                    </button>
                    <ul class="uib-dropdown-menu pull-right" ng-include="'release.menu.html'"></ul>
                </div>
                <a ng-if="previousRelease"
                   class="btn btn-default"
                   role="button"
                   tabindex="0"
                   href="#{{ ::viewName }}/{{ ::previousRelease.id }}/details"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                <a ng-if="nextRelease"
                   class="btn btn-default"
                   role="button"
                   tabindex="0"
                   href="#{{ ::viewName }}/{{ ::nextRelease.id }}/details"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                <a class="btn btn-default"
                   href="{{:: $state.href('^') }}"
                   uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                    <i class="fa fa-times"></i>
                </a>
            </div>
        </h3>
    </div>
    <div ui-view="details-tab">
        <form ng-submit="update(editableRelease)"
              name='formHolder.releaseForm'
              ng-class="{'form-editable':formHolder.editable, 'form-editing': formHolder.editing }"
              show-validation
              novalidate>
            <div class="panel-body">
                <div class="clearfix no-padding">
                    <div class="form-group">
                        <label for="name">${message(code:'is.release.name')}</label>
                        <input required
                               name="name"
                               ng-focus="editForm(true)"
                               ng-disabled="!formHolder.editable"
                               ng-model="editableRelease.name"
                               type="text"
                               class="form-control"
                               placeholder="${message(code: 'is.ui.release.noname')}"/>
                    </div>
                    <div class="form-half">
                        <label for="release.startDate">${message(code:'is.release.startDate')}</label>
                        <div ng-class="{'input-group': authorizedRelease('updateDates', release)}">
                            <input type="text"
                                   class="form-control"
                                   required
                                   ng-focus="editForm(true)"
                                   name="release.startDate"
                                   ng-disabled="!authorizedRelease('updateDates', release)"
                                   ng-model="editableRelease.startDate"
                                   uib-datepicker-popup
                                   min-date="minStartDate"
                                   max-date="maxStartDate"
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
                        <label for="release.endDate">${message(code:'is.release.endDate')}</label>
                        <div ng-class="{'input-group': authorizedRelease('updateDates', release)}">
                            <input type="text"
                                   class="form-control"
                                   required
                                   ng-focus="editForm(true)"
                                   name="release.endDate"
                                   ng-disabled="!authorizedRelease('updateDates', release)"
                                   ng-model="editableRelease.endDate"
                                   uib-datepicker-popup
                                   min-date="minEndDate"
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
                     ng-init="openReleaseChart('burndown', release)">
                    <div uib-dropdown
                         class="pull-right">
                        <button class="btn btn-default btn-sm"
                                uib-tooltip="${message(code:'todo.is.ui.charts')}"
                                type="button"
                                uib-dropdown-toggle>
                            <span class="fa fa-bar-chart"></span>&nbsp;<span class="caret"></span>
                        </button>
                        <ul class="uib-dropdown-menu">
                            <li><a href ng-click="openReleaseChart('burndown', release)">${message(code: 'is.chart.releaseBurndown')}</a></li>
                            <li><a href ng-click="openReleaseChart('parkingLot', release)">${message(code: 'is.chart.releaseParkingLot')}</a></li>
                            <li><a href ng-click="openMoodChart('releaseUserMood')">${message(code: 'is.chart.releaseUserMood')}</a></li>
                        </ul>
                    </div>
                    <nvd3 options="options | merge: {chart:{height: 200}, title:{enable: false}}" data="data"></nvd3>
                </div>
                <div class="form-group">
                    <label for="vision">${message(code:'is.ui.releasePlan.toolbar.vision')}</label>
                    <textarea is-markitup
                              ng-maxlength="5000"
                              class="form-control"
                              name="vision"
                              ng-model="editableRelease.vision"
                              is-model-html="editableRelease.vision_html"
                              ng-show="showVisionTextarea"
                              ng-blur="showVisionTextarea = false"
                              placeholder="${message(code: 'todo.is.ui.release.novision')}"></textarea>
                    <div class="markitup-preview"
                         ng-disabled="!formHolder.editable"
                         ng-show="!showVisionTextarea"
                         ng-click="showVisionTextarea = formHolder.editable"
                         ng-focus="editForm(true); showVisionTextarea = formHolder.editable"
                         ng-class="{'placeholder': !editableRelease.vision_html}"
                         tabindex="0"
                         ng-bind-html="(editableRelease.vision_html ? editableRelease.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>') | sanitize"></div>
                </div>
                <div class="form-group">
                    <label>${message(code:'is.backlogelement.attachment')} {{ release.attachments.length > 0 ? '(' + release.attachments.length + ')' : '' }}</label>
                    <div ng-if="authorizedRelease('upload', release)">
                        <button type="button" class="btn btn-default" flow-btn><i
                                class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}</button>
                    </div>
                    <div class="form-control-static" ng-include="'attachment.list.html'">
                    </div>
                </div>
            </div>
            <div class="panel-footer" ng-if="formHolder.editing">
                <div class="btn-toolbar">
                    <button class="btn btn-primary"
                            ng-disabled="!isDirty() || formHolder.releaseForm.$invalid"
                            uib-tooltip="${message(code:'default.button.update.label')} (RETURN)"
                            type="submit">
                        ${message(code:'default.button.update.label')}
                    </button>
                    <button class="btn confirmation btn-default"
                            uib-tooltip="${message(code:'is.button.cancel')}"
                            type="button"
                            ng-click="editForm(false)">
                        ${message(code:'is.button.cancel')}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
</script>