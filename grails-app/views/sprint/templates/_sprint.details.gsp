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
<div class="panel panel-default"
     ng-if="sprint"
     flow-drop
     flow-files-submitted="attachmentQuery($flow, sprint)"
     flow-drop-enabled="authorizedSprint('upload', sprint)"
     flow-drag-enter="class='panel panel-default drop-enabled'"
     flow-drag-leave="class='panel panel-default'"
     flow-init
     ng-class="authorizedSprint('upload', sprint) && class">
    <div id="sprint-header"
         class="panel-heading"
         fixed="#main-content .details:first" fixed-offset-width="10">
        <h3 class="panel-title row">
            <div class="the-title">
                <span>{{ sprint.parentRelease.name }} {{ sprint.orderNumber}} </span>
            </div>
            <div class="the-id">
                <div class="pull-right">
                    <button class="btn btn-xs btn-default"
                            disabled="disabled">{{ sprint.id }}</button>
                    <a ng-if="previous"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#sprintPlan/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="next"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#sprintPlan/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                </div>
            </div>
        </h3>
        <div class="actions">
            <div class="actions-left">
                <div class="btn-group"
                     uib-dropdown
                     uib-tooltip="${message(code: 'todo.is.ui.actions')}"
                     tooltip-append-to-body="true">
                    <button type="button" class="btn btn-default" uib-dropdown-toggle>
                        <span class="fa fa-cog"></span> <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu" ng-include="'sprint.menu.html'"></ul>
                </div>
            </div>
        </div>
    </div>
    <div id="right-sprint-container"
         class="panel-body">
        <form ng-submit="update(editableSprint)"
              name='formHolder.sprintForm'
              class="form-editable"
              ng-mouseleave="formHover(false)"
              ng-mouseover="formHover(true)"
              ng-class="{'form-editing': getShowSprintForm(sprint)}"
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-group">
                    <label for="sprint.parentRelease">${message(code:'is.sprint.parentRelease')}</label>
                    <div class="form-control-static">{{ sprint.parentRelease.name }}</div>
                </div>
                <div class="form-half">
                    <label for="sprint.startDate">${message(code:'is.sprint.startDate')}</label>
                    <div ng-class="{'input-group': authorizedSprint('update', sprint)}">
                        <span class="input-group-btn"
                              ng-if="authorizedSprint('update', sprint)">
                            <button type="button"
                                    class="btn btn-default"
                                    ng-focus="editForm(true)"
                                    ng-click="openDatepicker($event, startDateOptions)">
                                <i class="fa fa-calendar"></i>
                            </button>
                        </span>
                        <input type="text"
                               class="form-control"
                               required
                               ng-focus="editForm(true)"
                               name="sprint.startDate"
                               ng-model="editableSprint.startDate"
                               uib-datepicker-popup
                               min-date="minStartDate"
                               max-date="maxStartDate"
                               is-open="startDateOptions.opened"/>
                    </div>
                </div>
                <div class="form-half">
                    <label for="sprint.endDate" class="text-right">${message(code:'is.sprint.endDate')}</label>
                    <div ng-class="{'input-group': authorizedSprint('update', sprint)}">
                        <input type="text"
                               class="form-control text-right"
                               required
                               ng-focus="editForm(true)"
                               name="sprint.endDate"
                               ng-model="editableSprint.endDate"
                               uib-datepicker-popup
                               min-date="minEndDate"
                               max-date="maxEndDate"
                               is-open="endDateOptions.opened"/>
                        <span class="input-group-btn"
                              ng-if="authorizedSprint('update', sprint)">
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
            <div class="form-group">
                <label for="goal">${message(code:'is.ui.sprintPlan.toolbar.goal')}</label>
                <textarea name="goal"
                          class="form-control"
                          ng-focus="editForm(true)"
                          ng-maxlength="5000"
                          msd-elastic
                          ng-model="editableSprint.goal"
                          placeholder="${message(code: 'todo.is.ui.sprint.nogoal')}"></textarea>
            </div>
            <div class="btn-toolbar" ng-if="getShowSprintForm(sprint) && getEditableMode()">
                <button class="btn btn-primary pull-right"
                        ng-disabled="!isDirty() || formHolder.sprintForm.$invalid"
                        uib-tooltip="${message(code:'default.button.update.label')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'default.button.update.label')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        uib-tooltip="${message(code:'is.button.cancel')}"
                        type="button"
                        ng-click="editForm(false)">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <div class="form-group">
                <label>${message(code:'is.backlogelement.attachment')} {{ sprint.attachments.length > 0 ? '(' + sprint.attachments.length + ')' : '' }}</label>
                <div ng-if="authorizedSprint('upload', sprint)">
                    <button type="button" flow-btn class="btn btn-default"><i class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}</button>
                </div>
                <div class="form-control-static">
                    <div class="drop-zone">
                        <h2>${message(code:'todo.is.ui.drop.here')}</h2>
                    </div>
                    <table class="table table-striped attachments" ng-controller="attachmentCtrl">
                        <tbody ng-include="'attachment.list.html'"></tbody>
                    </table>
                </div>
            </div>
        </form>
    </div>
</div>
</script>