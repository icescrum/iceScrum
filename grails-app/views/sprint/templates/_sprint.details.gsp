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
<script type="text/ng-template" id="sprint.details.html">
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, sprint)"
     flow-drop-enabled="authorizedSprint('upload', sprint)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedSprint('upload', sprint) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <span>{{ release.name + ' - ' + (sprint | sprintName) }} </span>
            </div>
            <div class="right-title">
                <button class="btn btn-default elemid">{{ sprint.id }}</button>
                <button class="btn btn-default"
                        ng-if="authorizedSprint('activate', sprint)"
                        uib-tooltip="${message(code:'is.ui.releasePlan.menu.sprint.activate')}"
                        ng-click="confirm({ message: '${message(code: 'is.ui.releasePlan.menu.sprint.activate.confirm')}', callback: activate, args: [sprint] })">
                    <i class="fa fa-play"></i>
                </button>
                <button class="btn btn-default"
                        ng-if="authorizedSprint('close', sprint)"
                        uib-tooltip="${message(code:'is.ui.releasePlan.menu.sprint.close')}"
                        ng-click="confirm({ message: '${message(code: 'is.ui.releasePlan.menu.sprint.close.confirm')}', callback: close, args: [sprint] })">
                    <i class="fa fa-stop"></i>
                </button>
                <div class="btn-group"
                     ng-if="showSprintMenu()"
                     uib-dropdown>
                    <button type="button" class="btn btn-default" uib-dropdown-toggle>
                        <i class="fa fa-cog"></i> <i class="fa fa-caret-down"></i>
                    </button>
                    <ul uib-dropdown-menu class="pull-right" ng-include="'sprint.menu.html'"></ul>
                </div>
                <a ng-if="previousSprint"
                   class="btn btn-default"
                   role="button"
                   tabindex="0"
                   href="#{{:: viewName + '/' + (viewName == 'planning' ? sprint.parentRelease.id +  '/sprint/' : '') + previousSprint.id }}/details"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                <a ng-if="nextSprint"
                   class="btn btn-default"
                   role="button"
                   tabindex="0"
                   href="#{{:: viewName + '/' + (viewName == 'planning' ? sprint.parentRelease.id +  '/sprint/' : '') + nextSprint.id }}/details"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                <a class="btn btn-default"
                   href="{{:: $state.href('^') }}"
                   uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                    <i class="fa fa-times"></i>
                </a>
            </div>
        </h3>
        <visual-states ng-model="sprint" model-states="sprintStatesByName"/>
    </div>
    <div ui-view="details-tab">
        <form ng-submit="update(editableSprint)"
              name='formHolder.sprintForm'
              ng-class="{'form-editable':formHolder.editable, 'form-editing': formHolder.editing }"
              show-validation
              novalidate>
            <div class="panel-body">
                <div class="clearfix no-padding">
                    <div class="form-half">
                        <label for="sprint.startDate">${message(code:'is.sprint.startDate')}</label>
                        <div ng-class="{'input-group': authorizedSprint('updateStartDate', sprint)}">
                            <input type="text"
                                   class="form-control"
                                   required
                                   ng-focus="editForm(true)"
                                   name="sprint.startDate"
                                   ng-disabled="!authorizedSprint('updateStartDate', sprint)"
                                   ng-model="editableSprint.startDate"
                                   ng-model-options="{timezone: 'utc'}"
                                   uib-datepicker-popup
                                   datepicker-options="startDateOptions"
                                   is-open="startDateOptions.opened"/>
                            <span class="input-group-btn"
                                  ng-if="authorizedSprint('updateStartDate', sprint)">
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
                        <label for="sprint.endDate">${message(code:'is.sprint.endDate')}</label>
                        <div ng-class="{'input-group': authorizedSprint('updateEndDate', sprint)}">
                            <input type="text"
                                   class="form-control"
                                   required
                                   ng-focus="editForm(true)"
                                   name="sprint.endDate"
                                   ng-disabled="!authorizedSprint('updateEndDate', sprint)"
                                   ng-model="editableSprint.endDate"
                                   ng-model-options="{timezone: 'utc'}"
                                   uib-datepicker-popup
                                   datepicker-options="endDateOptions"
                                   is-open="endDateOptions.opened"/>
                            <span class="input-group-btn"
                                  ng-if="authorizedSprint('updateEndDate', sprint)">
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
                     ng-init="openChart('sprint', 'burnupTasks', sprint)">
                    <div uib-dropdown
                         class="pull-right">
                        <button class="btn btn-default btn-sm"
                                uib-tooltip="${message(code:'todo.is.ui.charts')}"
                                type="button"
                                uib-dropdown-toggle>
                            <i class="fa fa-bar-chart"></i> <i class="fa fa-caret-down"></i>
                        </button>
                        <ul uib-dropdown-menu>
                            <li><a href ng-click="openChart('sprint', 'burndownRemaining', sprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurndownRemainingChart')}</a></li>
                            <entry:point id="sprint-details-charts-bis"/>
                            <li><a href ng-click="openChart('sprint', 'burnupTasks', sprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurnupTasksChart')}</a></li>
                            <li><a href ng-click="openChart('sprint', 'burnupPoints', sprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurnupPointsChart')}</a></li>
                            <li><a href ng-click="openChart('sprint', 'burnupStories', sprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurnupStoriesChart')}</a></li>
                            <entry:point id="sprint-details-charts"/>
                        </ul>
                    </div>
                    <nvd3 options="options | merge: {chart:{height: 200}, title:{enable: false}}" data="data"></nvd3>
                </div>
                <div class="form-group">
                    <label for="deliveredVersion">${message(code:'is.sprint.deliveredVersion')}</label>
                    <input name="deliveredVersion"
                           ng-focus="editForm(true)"
                           ng-model="editableSprint.deliveredVersion"
                           type="text"
                           ng-maxlength="255"
                           class="form-control"
                           placeholder="${message(code: 'todo.is.ui.sprint.nodeliveredversion')}"/>
                </div>
                <div class="form-group" ng-if="sprint.state > sprintStatesByName.IN_PROGRESS">
                    <label for="retrospective">${message(code: 'is.sprint.retrospective')}</label>
                    <textarea is-markitup
                              class="form-control"
                              name="retrospective"
                              ng-model="editableSprint.retrospective"
                              is-model-html="editableSprint.retrospective_html"
                              ng-show="showRetrospectiveTextarea"
                              ng-blur="showRetrospectiveTextarea = false"
                              placeholder="${message(code: 'todo.is.ui.sprint.noretrospective')}"></textarea>
                    <div class="markitup-preview important"
                         ng-disabled="!formHolder.editable"
                         ng-show="!showRetrospectiveTextarea"
                         ng-click="showRetrospectiveTextarea = formHolder.editable"
                         ng-focus="editForm(true); showRetrospectiveTextarea = formHolder.editable"
                         ng-class="{'placeholder': !editableSprint.retrospective_html}"
                         tabindex="0"
                         ng-bind-html="(editableSprint.retrospective_html ? editableSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>') | sanitize"></div>
                </div>
                <div class="form-group">
                    <label for="goal">${message(code:'is.sprint.goal')}</label>
                    <textarea name="goal"
                              class="form-control important"
                              ng-focus="editForm(true)"
                              ng-disabled="!formHolder.editable"
                              ng-maxlength="5000"
                              ng-model="editableSprint.goal"
                              placeholder="${message(code: 'todo.is.ui.sprint.nogoal')}"></textarea>
                </div>
                <div class="form-group">
                    <label for="doneDefinition">${message(code: 'is.sprint.doneDefinition')}</label>
                    <textarea is-markitup
                              class="form-control"
                              name="doneDefinition"
                              ng-model="editableSprint.doneDefinition"
                              is-model-html="editableSprint.doneDefinition_html"
                              ng-show="showDoneDefinitionTextarea"
                              ng-blur="showDoneDefinitionTextarea = false"
                              placeholder="${message(code: 'todo.is.ui.sprint.nodonedefinition')}"></textarea>
                    <div class="markitup-preview important"
                         ng-disabled="!formHolder.editable"
                         ng-show="!showDoneDefinitionTextarea"
                         ng-click="showDoneDefinitionTextarea = formHolder.editable"
                         ng-focus="editForm(true); showDoneDefinitionTextarea = formHolder.editable"
                         ng-class="{'placeholder': !editableSprint.doneDefinition_html}"
                         tabindex="0"
                         ng-bind-html="(editableSprint.doneDefinition_html ? editableSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>') | sanitize"></div>
                </div>
                <div class="form-group">
                    <label>${message(code:'is.backlogelement.attachment')} {{ sprint.attachments.length > 0 ? '(' + sprint.attachments.length + ')' : '' }}</label>
                    <div ng-if="authorizedSprint('upload', sprint)"
                         ng-controller="attachmentNestedCtrl"
                         flow-init
                         flow-files-submitted="attachmentQuery($flow, sprint)">
                        <button type="button"
                                class="btn btn-default"
                                flow-btn>
                            <i class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}
                        </button>
                    </div>
                    <div class="form-control-static" ng-include="'attachment.list.html'">
                    </div>
                </div>
            </div>
            <div class="panel-footer" ng-if="formHolder.editing">
                <div class="btn-toolbar">
                    <button class="btn btn-primary"
                            ng-disabled="!isDirty() || formHolder.sprintForm.$invalid"
                            type="submit">
                        ${message(code:'default.button.update.label')}
                    </button>
                    <button class="btn confirmation btn-default"
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