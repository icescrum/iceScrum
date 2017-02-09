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
<script type="text/ng-template" id="task.details.html">
<div class="panel panel-light"
     flow-init
     flow-drop
     flow-files-submitted="attachmentQuery($flow, task)"
     flow-drop-enabled="authorizedTask('upload', task)"
     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
     flow-drag-leave="dropClass='panel panel-light'"
     ng-class="authorizedTask('upload', task) && dropClass">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <span><strong>{{:: task.uid }}</strong>&nbsp;<span class="item-name">{{ task.name }}</span></span>
            </div>
            <div class="right-title">
                <div style="margin-bottom:10px">
                    <span ng-if="task.responsible"
                          uib-tooltip="${message(code: 'is.task.responsible')} {{ task.responsible | userFullName }}">
                        <img ng-src="{{ task.responsible | userAvatar }}"
                             class="{{ task.responsible | userColorRoles }}"
                             alt="{{ task.responsible | userFullName }}"
                             height="30px"/>
                    </span>
                    <div class="btn-group">
                        <a ng-if="previousTask"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           href="{{:: currentStateUrl(previousTask.id) }}"><i class="fa fa-caret-left" title="${message(code: 'is.ui.backlogelement.toolbar.previous')}"></i></a>
                        <a ng-if="nextTask"
                           class="btn btn-default"
                           role="button"
                           tabindex="0"
                           href="{{:: currentStateUrl(nextTask.id) }}"><i class="fa fa-caret-right" title="${message(code: 'is.ui.backlogelement.toolbar.next')}"></i></a>
                    </div>
                    <a ng-if="!isModal"
                       class="btn btn-default"
                       href="{{:: $state.href('^.^') }}"
                       uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                        <i class="fa fa-times"></i>
                    </a>
                </div>
                <div class="btn-group" role="group">
                    <shortcut-menu ng-model="task" model-menus="menus" view-name="details"></shortcut-menu>
                    <div class="btn-group" uib-dropdown>
                        <button type="button" class="btn btn-default" uib-dropdown-toggle>
                            <i class="fa fa-ellipsis-h"></i></i>
                        </button>
                        <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'task'" template-url="item.menu.html"></ul>
                    </div>
                </div>
            </div>
        </h3>
        <visual-states ng-model="task" model-states="taskStatesByName"/>
    </div>
    <ul class="nav nav-tabs nav-justified">
        <li role="presentation" ng-class="{'active':!$state.params.taskTabId}">
            <a href="{{ tabUrl() }}"
               uib-tooltip="${message(code: 'todo.is.ui.details')}">
                <i class="fa fa-lg fa-edit"></i>
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.taskTabId == 'activities'}">
            <a href="{{ tabUrl('activities') }}"
               uib-tooltip="{{ task.activities && task.activities.length ? message('is.fluxiable.' + task.activities[0].code) : '' }}">
                <i class="fa fa-lg fa-clock-o"></i>
            </a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.taskTabId == 'comments'}">
            <a href="{{ tabUrl('comments') }}"
               uib-tooltip="${message(code: 'todo.is.ui.comments')}">
                <i class="fa fa-lg" ng-class="task.comments_count ? 'fa-comment' : 'fa-comment-o'"></i>
                <span class="badge">{{ task.comments_count || '' }}</span>
            </a>
        </li>
        <entry:point id="task-details-tab-button"/>
    </ul>
    <div ui-view="details-tab">
        <form ng-submit="update(editableTask)"
              name='formHolder.taskForm'
              ng-class="{'form-editable':formHolder.editable(), 'form-editing': formHolder.editing }"
              show-validation
              novalidate>
            <div class="panel-body">
                <div class="clearfix no-padding">
                    <div class="form-2-tiers">
                        <label for="name">${message(code: 'is.task.name')}</label>
                        <div ng-class="{'input-group': formHolder.editable()}">
                            <input required
                                   ng-maxlength="100"
                                   ng-focus="editForm(true)"
                                   ng-disabled="!formHolder.editable()"
                                   name="name"
                                   ng-model="editableTask.name"
                                   type="text"
                                   class="form-control">
                            <span class="input-group-btn" ng-if="formHolder.editable()">
                                <button colorpicker
                                        class="btn {{ editableTask.color | contrastColor }}"
                                        type="button"
                                        ng-style="{'background-color': editableTask.color}"
                                        colorpicker-position="left"
                                        colorpicker-with-input="true"
                                        ng-focus="editForm(true)"
                                        value="#bf3d3d"
                                        name="color"
                                        colors="mostUsedColors"
                                        ng-model="editableTask.color"><i class="fa fa-pencil"></i></button>
                            </span>
                        </div>
                    </div>
                    <div ng-if="task.parentStory" class="form-1-tier">
                        <label for="parentStory">${message(code: 'is.story')}</label>
                        <input class="form-control" disabled="disabled" type="text" value="{{ task.parentStory.name }}"/>
                    </div>
                    <div ng-if="task.type" class="form-1-tier">
                        <label for="type">${message(code: 'is.task.type')}</label>
                        <input class="form-control" disabled="disabled" type="text" value="{{ task.type | i18n: 'TaskTypes' }}"/>
                    </div>
                </div>
                <div class="form-group">
                    <label for="description">${message(code: 'is.backlogelement.description')}</label>
                    <textarea class="form-control important"
                              ng-maxlength="3000"
                              ng-focus="editForm(true)"
                              ng-disabled="!formHolder.editable()"
                              placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                              name="description"
                              ng-model="editableTask.description"></textarea>
                </div>
                <div class="form-group">
                    <label for="responsible">${message(code: 'is.task.responsible')}</label>
                    <ui-select ng-click="editForm(true)"
                               ng-change="editForm(true)"
                               ng-disabled="!formHolder.editable() || !authorizedTask('setResponsible', editableTask)"
                               class="form-control"
                               name="responsible"
                               search-enabled="true"
                               ng-model="editableTask.responsible">
                        <ui-select-match>
                            {{ $select.selected | userFullName }}
                        </ui-select-match>
                        <ui-select-choices refresh="searchResponsible($select.search)"
                                           refresh-day="100"
                                           repeat="responsible in responsibles | orFilter: { username: $select.search, name: $select.search, email: $select.search }">
                            <span ng-bind-html="(responsible | userFullName) | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>
                <div class="form-group">
                    <label for="tags">${message(code: 'is.backlogelement.tags')}</label>
                    <ui-select class="form-control"
                               ng-click="retrieveTags(); editForm(true)"
                               ng-disabled="!formHolder.editable()"
                               multiple
                               tagging
                               tagging-tokens="SPACE|,"
                               tagging-label="${message(code: 'todo.is.ui.tag.create')}"
                               ng-model="editableTask.tags">
                        <ui-select-match placeholder="${message(code: 'is.ui.backlogelement.notags')}">{{ $item }}</ui-select-match>
                        <ui-select-choices repeat="tag in tags | filter: $select.search">
                            <span ng-bind-html="tag | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>
                <div class="clearfix no-padding">
                    <div class="form-1-tier">
                        <label for="estimation">${message(code: 'is.task.estimation')}</label>
                        <input type="number"
                               min="0"
                               class="form-control"
                               ng-focus="editForm(true)"
                               ng-disabled="!formHolder.editable()"
                               name="estimation"
                               ng-model="editableTask.estimation"/>
                    </div>
                    <div ng-if="task.sprint" class="form-2-tiers">
                        <label for="backlog">${message(code: 'is.sprint')}</label>
                        <input class="form-control" disabled="disabled" type="text" value="{{ task.sprint.parentRelease.name + ' - ' + (task.sprint | sprintName) }}"/>
                    </div>
                </div>
                <div class="form-group">
                    <label for="notes">${message(code: 'is.backlogelement.notes')}</label>
                    <textarea is-markitup
                              class="form-control"
                              ng-maxlength="5000"
                              name="notes"
                              ng-model="editableTask.notes"
                              is-model-html="editableTask.notes_html"
                              ng-show="showNotesTextarea"
                              ng-blur="showNotesTextarea = false"
                              placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                    <div class="markitup-preview important"
                         ng-disabled="!formHolder.editable()"
                         ng-show="!showNotesTextarea"
                         ng-click="showNotesTextarea = formHolder.editable()"
                         ng-focus="editForm(true); showNotesTextarea = formHolder.editable()"
                         ng-class="{'placeholder': !editableTask.notes_html}"
                         tabindex="0"
                         ng-bind-html="editableTask.notes_html ? editableTask.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>'"></div>
                </div>
                <div class="form-group">
                    <label>${message(code: 'is.backlogelement.attachment')} {{ task.attachments.length > 0 ? '(' + task.attachments.length + ')' : '' }}</label>
                    <div ng-if="authorizedTask('upload', task)"
                         ng-controller="attachmentNestedCtrl"
                         flow-init
                         flow-files-submitted="attachmentQuery($flow, task)">
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
                            ng-if="isLatest()"
                            ng-disabled="!isDirty() || formHolder.taskForm.$invalid"
                            type="submit">
                        ${message(code: 'default.button.update.label')}
                    </button>
                    <button class="btn btn-danger"
                            ng-if="!isLatest() && !formHolder.submitting"
                            ng-disabled="!isDirty() || formHolder.taskForm.$invalid"
                            type="submit">
                        ${message(code: 'default.button.override.label')}
                    </button>
                    <button class="btn btn-default"
                            type="button"
                            ng-click="editForm(false)">
                        ${message(code: 'is.button.cancel')}
                    </button>
                    <button class="btn btn-warning"
                            type="button"
                            ng-if="!isLatest() && !formHolder.submitting"
                            ng-click="resetTaskForm()">
                        <i class="fa fa-warning"></i> ${message(code: 'default.button.refresh.label')}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
</script>
