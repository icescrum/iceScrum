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
<form ng-submit="update(editableTask)"
      name='formHolder.taskForm'
      ng-class="{'form-editable': formEditable(), 'form-editing': formHolder.editing }"
      show-validation
      novalidate>
    <div class="panel-body">
        <div class="clearfix no-padding">
            <div class="form-2-tiers">
                <label for="name">${message(code: 'is.task.name')}</label>
                <div ng-class="{'input-group': formEditable()}">
                    <input required
                           ng-maxlength="100"
                           ng-focus="editForm(true)"
                           ng-disabled="!formEditable()"
                           name="name"
                           ng-model="editableTask.name"
                           type="text"
                           class="form-control">
                    <span class="input-group-btn" ng-if="formEditable()">
                        <button colorpicker
                                class="btn {{ editableTask.color | contrastColor }}"
                                type="button"
                                ng-style="{'background-color': editableTask.color}"
                                colorpicker-position="left"
                                colorpicker-with-input="true"
                                ng-click="editForm(true); refreshMostUsedColors();"
                                value="#bf3d3d"
                                name="color"
                                colors="mostUsedColors"
                                ng-model="editableTask.color"><i class="fa fa-pencil"></i> ${message(code: 'todo.is.ui.color')}</button>
                    </span>
                </div>
            </div>
            <div ng-if="task.parentStory" class="form-1-tier">
                <label for="parentStory"><i class="fa fa-sticky-note"></i> ${message(code: 'is.story')}</label>
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
                      ng-disabled="!formEditable()"
                      placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                      name="description"
                      ng-model="editableTask.description"></textarea>
        </div>
        <entry:point id="task-detail-middle"/>
        <div class="form-group">
            <label for="tags">${message(code: 'is.backlogelement.tags')}</label>
            <ui-select class="form-control"
                       ng-click="retrieveTags(); editForm(true)"
                       ng-disabled="!formEditable()"
                       name="tags"
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
            <div class="form-half">
                <label for="estimation"><i class="fa {{ task.state | taskStateIcon }}"></i> ${message(code: 'is.task.estimation')}</label>
                <input type="number"
                       min="0"
                       class="form-control"
                       ng-focus="editForm(true)"
                       ng-disabled="!formEditable()"
                       name="estimation"
                       ng-model="editableTask.estimation"/>
            </div>
            <div ng-if="editableTask.initial != null" class="form-half">
                <label for="initial">${message(code: 'is.task.initial.long')}</label>
                <input class="form-control"
                       ng-disabled="true"
                       name="initial"
                       ng-model="editableTask.initial"/>
            </div>
        </div>
        <div ng-if="task.sprint" class="form-group">
            <label for="backlog"><i class="fa fa-tasks"></i> ${message(code: 'is.sprint')}</label>
            <input class="form-control" disabled="disabled" type="text" value="{{ task.sprint.parentRelease.name + ' - ' + (task.sprint | sprintName) }}"/>
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
                 ng-disabled="!formEditable()"
                 ng-show="!showNotesTextarea"
                 ng-click="showNotesTextarea = formEditable()"
                 ng-focus="editForm(true); showNotesTextarea = formEditable()"
                 ng-class="{'placeholder': !editableTask.notes_html}"
                 tabindex="0"
                 ng-bind-html="editableTask.notes_html ? editableTask.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>'"></div>
        </div>
        <div class="form-group">
            <label>${message(code: 'is.backlogelement.attachment')} {{ task.attachments_count > 0 ? '(' + task.aattachments_count + ')' : '' }}</label>
            <div ng-if="authorizedTask('upload', task)"
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
    <div class="panel-footer" ng-if="formHolder.editing">
        <div class="btn-toolbar">
            <button class="btn btn-primary"
                    ng-if="isLatest() || application.submitting"
                    ng-disabled="!isDirty() || formHolder.taskForm.$invalid || application.submitting"
                    type="submit">
                ${message(code: 'default.button.update.label')}
            </button>
            <button class="btn btn-danger"
                    ng-if="!isLatest() && !application.submitting"
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
                    ng-if="!isLatest() && !application.submitting"
                    ng-click="resetTaskForm()">
                <i class="fa fa-warning"></i> ${message(code: 'default.button.refresh.label')}
            </button>
        </div>
    </div>
</form>