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
<form ng-submit="update(editableFeature)"
      name='formHolder.featureForm'
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
        <div class="form-group">
            <label for="name">${message(code: 'is.feature.name')}</label>
            <div class="input-group">
                <input required
                       ng-maxlength="100"
                       ng-focus="editForm(true)"
                       ng-disabled="!formEditable()"
                       name="name"
                       autocomplete="off"
                       ng-model="editableFeature.name"
                       type="text"
                       class="form-control">
                <span class="input-group-append" ng-if="formEditable()">
                    <button colorpicker
                            class="btn btn-sm btn-colorpicker {{ editableFeature.color | contrastColor }}"
                            type="button"
                            ng-style="{'background-color': editableFeature.color}"
                            colorpicker-position="left"
                            colorpicker-with-input="true"
                            ng-click="editForm(true); refreshAvailableColors();"
                            value="#bf3d3d"
                            name="color"
                            colors="availableColors"
                            ng-model="editableFeature.color">${message(code: 'todo.is.ui.color')}</button>
                </span>
            </div>
        </div>
        <div class="row is-form-row">
            <div class="form-half">
                <label for="type">${message(code: 'is.feature.type')}</label>
                <ui-select class="form-control"
                           ng-click="editForm(true)"
                           ng-disabled="!formEditable()"
                           name="type"
                           ng-model="editableFeature.type">
                    <ui-select-match><i class="{{ $select.selected | featureTypeIcon }}"></i> {{ $select.selected | i18n:'FeatureTypes' }}</ui-select-match>
                    <ui-select-choices repeat="featureType in featureTypes"><i class="{{ ::featureType | featureTypeIcon }}"></i> {{ ::featureType | i18n:'FeatureTypes' }}</ui-select-choices>
                </ui-select>
            </div>
            <div class="form-half">
                <label for="value">${message(code: 'is.feature.value')}</label>
                <ui-select class="form-control"
                           ng-click="editForm(true)"
                           ng-disabled="!formEditable()"
                           name="value"
                           search-enabled="true"
                           ng-model="editableFeature.value">
                    <ui-select-match>{{ $select.selected }}</ui-select-match>
                    <ui-select-choices repeat="i in integerSuite | filter: $select.search">
                        <span ng-bind-html="'' + i | highlight: $select.search"></span>
                    </ui-select-choices>
                </ui-select>
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
                      ng-model="editableFeature.description"></textarea>
        </div>
        <div class="form-group"
             ng-if="showTags">
            <label for="tags" class="d-flex align-items-center justify-content-between">
                <div>${message(code: 'is.backlogelement.tags')}</div>
                <entry:point id="item-properties-inside-tag"/>
            </label>
            <ui-select class="form-control"
                       ng-click="retrieveTags(); editForm(true)"
                       ng-disabled="!formEditable()"
                       multiple
                       tagging
                       tagging-tokens="SPACE|,"
                       tagging-label="${message(code: 'todo.is.ui.tag.create')}"
                       ng-model="editableFeature.tags">
                <ui-select-match placeholder="${message(code: 'is.ui.backlogelement.notags')}">{{ $item }}</ui-select-match>
                <ui-select-choices repeat="tag in tags | filter: $select.search">
                    <span ng-bind-html="tag | highlight: $select.search"></span>
                </ui-select-choices>
            </ui-select>
        </div>
        <entry:point id="feature-properties-after-tag"/>
        <div class="form-group">
            <label for="notes">${message(code: 'is.backlogelement.notes')}</label>
            <textarea at
                      is-markitup
                      class="form-control"
                      ng-maxlength="5000"
                      name="notes"
                      ng-model="editableFeature.notes"
                      is-model-html="editableFeature.notes_html"
                      ng-show="showNotesTextarea"
                      ng-blur="showNotesTextarea = false"
                      placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
            <div class="markitup-preview form-control"
                 ng-disabled="!formEditable()"
                 ng-show="!showNotesTextarea"
                 ng-focus="editForm(true); showNotesTextarea = formEditable()"
                 ng-class="{'placeholder': !editableFeature.notes_html}"
                 tabindex="0"
                 bind-html-scope="markitupCheckboxOptions()"
                 bind-html-compile="editableFeature.notes_html ? editableFeature.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>'"></div>
        </div>
        <label>${message(code: 'is.backlogelement.attachment')} {{ feature.attachments_count > 0 ? '(' + feature.attachments_count + ')' : '' }}</label>
        <div class="attachments attachments-bordered">
            <div ng-if="authorizedFeature('upload', feature)" ng-controller="attachmentNestedCtrl" class="upload-and-apps row">
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
        <div class="btn-toolbar">
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
                    ng-click="resetFeatureForm()">
                <i class="fa fa-warning"></i> ${message(code: 'default.button.refresh.label')}
            </button>
            <button class="btn btn-danger"
                    ng-if="formHolder.editing && !isLatest() && !application.submitting"
                    ng-disabled="!isDirty() || formHolder.featureForm.$invalid"
                    type="submit">
                ${message(code: 'default.button.override.label')}
            </button>
            <button class="btn btn-primary"
                    ng-if="formHolder.editing && (isLatest() || application.submitting)"
                    ng-disabled="!isDirty() || formHolder.featureForm.$invalid || application.submitting"
                    type="submit">
                ${message(code: 'default.button.update.label')}
            </button>
        </div>
    </div>
</form>