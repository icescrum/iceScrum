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
    <div class="card-body">
        <div class="drop-zone d-flex align-items-center justify-content-center">
            <div>
                <asset:image src="application/upload.svg" width="70" height="70"/>
                <span class="drop-text">${message(code: 'todo.is.ui.drop.here')}</span>
            </div>
        </div>
        <div class="row is-form-row">
            <div class="form-2-tiers">
                <label for="name">${message(code: 'is.task.name')}</label>
                <div ng-class="{'input-group': formEditable()}">
                    <input required
                           ng-maxlength="100"
                           ng-focus="editForm(true)"
                           ng-disabled="!formEditable()"
                           name="name"
                           ng-model="editableTask.name"
                           autocomplete="off"
                           type="text"
                           class="form-control">
                    <span class="input-group-append" ng-if="formEditable()">
                        <button colorpicker
                                class="btn btn-sm btn-colorpicker {{ editableTask.color | contrastColor }}"
                                type="button"
                                ng-style="{'background-color': editableTask.color}"
                                colorpicker-position="left"
                                colorpicker-with-input="true"
                                ng-click="editForm(true); refreshMostUsedColors();"
                                value="#bf3d3d"
                                name="color"
                                colors="mostUsedColors"
                                ng-model="editableTask.color">${message(code: 'todo.is.ui.color')}</button>
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
            <textarea at
                      class="form-control"
                      ng-maxlength="3000"
                      ng-focus="editForm(true)"
                      ng-disabled="!formEditable()"
                      placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                      name="description"
                      ng-model="editableTask.description"></textarea>
        </div>
        <div class="form-group"
             ng-if="showResponsible()">
            <label for="responsible" class="d-flex align-items-center justify-content-between">
                ${message(code: 'is.task.responsible')}
                <entry:point id="task-properties-inside-responsible"/>
            </label>
            <div class="d-flex">
                <div class="avatar {{ editableTask.responsible | userColorRoles }} mr-2">
                    <img ng-src="{{ editableTask.responsible | userAvatar }}" height="32px"/>
                </div>
                <input class="form-control"
                       disabled="disabled"
                       type="text"
                       value="{{ editableTask.responsible | userFullName }}"/>
            </div>
        </div>
        <entry:point id="task-properties-middle"/>
        <div class="form-group"
             ng-if="showTags">
            <label for="tags" class="d-flex align-items-center justify-content-between">
                <div>${message(code: 'is.backlogelement.tags')}</div>
                <entry:point id="item-properties-inside-tag"/>
            </label>
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
        <entry:point id="task-properties-after-tag"/>
        <div class="row is-form-row task-estimate-row">
            <div class="form-half">
                <label for="estimation" class="d-flex align-items-center justify-content-between">
                    <div>${message(code: 'is.task.estimation')}</div>
                    <entry:point id="task-properties-inside-estimation"/>
                </label>
                <div class="input-group">
                    <span class="input-group-prepend">
                        <button class="btn btn-secondary btn-sm"
                                ng-if="authorizedTask('updateEstimate', editableTask)"
                                type="button"
                                ng-click="editForm(true); editableTask.estimation = minus(editableTask.estimation);">
                            <i class="fa fa-minus"></i>
                        </button>
                    </span>
                    <input type="number"
                           min="0"
                           class="form-control"
                           ng-focus="editForm(true)"
                           ng-disabled="!formEditable() || !authorizedTask('updateEstimate', editableTask)"
                           name="estimation"
                           ng-model="editableTask.estimation"/>
                    <span class="input-group-append">
                        <button class="btn btn-secondary btn-sm"
                                ng-if="authorizedTask('updateEstimate', editableTask)"
                                type="button"
                                ng-click="editForm(true); editableTask.estimation = plus(editableTask.estimation);">
                            <i class="fa fa-plus"></i>
                        </button>
                    </span>
                </div>
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
            <label for="backlog">${message(code: 'is.sprint')}</label>
            <input class="form-control" disabled="disabled" type="text" value="{{ task.sprint.parentRelease.name + ' - ' + (task.sprint | sprintName) }}"/>
        </div>
        <div class="form-group">
            <label for="notes">${message(code: 'is.backlogelement.notes')}</label>
            <textarea at
                      is-markitup
                      class="form-control"
                      ng-maxlength="5000"
                      name="notes"
                      ng-model="editableTask.notes"
                      is-model-html="editableTask.notes_html"
                      ng-show="showNotesTextarea"
                      ng-blur="showNotesTextarea = false"
                      placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
            <div class="markitup-preview form-control"
                 ng-disabled="!formEditable()"
                 ng-show="!showNotesTextarea"
                 ng-click="showNotesTextarea = formEditable()"
                 ng-focus="editForm(true); showNotesTextarea = formEditable()"
                 ng-class="{'placeholder': !editableTask.notes_html}"
                 tabindex="0"
                 ng-bind-html="editableTask.notes_html ? editableTask.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>'"></div>
        </div>
        <label>${message(code: 'is.backlogelement.attachment')} {{ task.attachments_count > 0 ? '(' + task.attachments_count + ')' : '' }}</label>
        <div class="attachments attachments-bordered">
            <div ng-if="authorizedTask('upload', task)" ng-controller="attachmentNestedCtrl" class="upload-and-apps row">
                <div class="upload-file col-6">
                    <span class="attachment-icon"></span><span flow-btn class="link">${message(code: 'todo.is.ui.attachment.add')}</span>&nbsp;<span class="d-none d-md-inline">${message(code: 'todo.is.ui.attachment.drop')}</span>
                </div>
                <div class="upload-apps col-6">
                    <entry:point id="attachment-add-buttons"/>
                </div>
            </div>
            <div ng-include="'attachment.list.html'"></div>
        </div>
    </div>
    <div class="card-footer" ng-if="isModal || formHolder.editing">
        <div class="btn-toolbar" ng-class="[{ 'text-right' : isModal }]">
            <button class="btn btn-secondary"
                    type="button"
                    ng-if="isModal && !isDirty()"
                    ng-click="$close()">
                ${message(code: 'is.button.close')}
            </button>
            <button class="btn btn-secondary"
                    type="button"
                    ng-if="(!isModal && formHolder.editing) || (isModal && isDirty())"
                    ng-click="editForm(false)">
                ${message(code: 'is.button.cancel')}
            </button>
            <button class="btn btn-warning"
                    type="button"
                    ng-if="isDirty() && !isLatest() && !application.submitting"
                    ng-click="resetTaskForm()">
                <i class="fa fa-warning"></i> ${message(code: 'default.button.refresh.label')}
            </button>
            <button class="btn btn-danger"
                    ng-if="formHolder.editing && !isLatest() && !application.submitting"
                    ng-disabled="!isDirty() || formHolder.taskForm.$invalid"
                    type="submit">
                ${message(code: 'default.button.override.label')}
            </button>
            <button class="btn btn-primary"
                    ng-if="formHolder.editing && (isLatest() || application.submitting)"
                    ng-disabled="!isDirty() || formHolder.taskForm.$invalid || application.submitting"
                    type="submit">
                ${message(code: 'default.button.update.label')}
            </button>
        </div>
    </div>
</form>