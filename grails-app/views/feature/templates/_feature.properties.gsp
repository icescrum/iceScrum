<form ng-submit="update(editableFeature)"
      name='formHolder.featureForm'
      ng-class="{'form-editable': formEditable(), 'form-editing': formHolder.editing }"
      show-validation
      novalidate>
    <div class="panel-body">
        <div class="form-group">
            <label for="name">${message(code:'is.feature.name')}</label>
            <input required
                   ng-maxlength="100"
                   ng-focus="editForm(true)"
                   ng-disabled="!formEditable()"
                   name="name"
                   ng-model="editableFeature.name"
                   type="text"
                   class="form-control">
        </div>
        <div class="clearfix no-padding">
            <div class="form-half">
                <label for="type">${message(code:'is.feature.type')}</label>
                <div class="input-group">
                    <ui-select class="form-control"
                               ng-click="editForm(true)"
                               ng-disabled="!formEditable()"
                               name="type"
                               ng-model="editableFeature.type">
                        <ui-select-match><i class="fa fa-{{ $select.selected | featureTypeIcon }}"></i> {{ $select.selected | i18n:'FeatureTypes' }}</ui-select-match>
                        <ui-select-choices repeat="featureType in featureTypes"><i class="fa fa-{{ ::featureType | featureTypeIcon }}"></i> {{ ::featureType | i18n:'FeatureTypes' }}</ui-select-choices>
                    </ui-select>
                    <span class="input-group-btn" ng-if="formEditable()">
                        <button colorpicker
                                class="btn {{ editableFeature.color | contrastColor }}"
                                type="button"
                                ng-style="{'background-color': editableFeature.color}"
                                colorpicker-position="top"
                                ng-focus="editForm(true)"
                                value="#bf3d3d"
                                ng-click="refreshAvailableColors()"
                                colors="availableColors"
                                name="color"
                                ng-model="editableFeature.color"><i class="fa fa-pencil"></i></button>
                    </span>
                </div>
            </div>
            <div class="form-half">
                <label for="value">${message(code:'is.feature.value')}</label>
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
            <label for="description">${message(code:'is.backlogelement.description')}</label>
            <textarea class="form-control"
                      ng-maxlength="3000"
                      ng-focus="editForm(true)"
                      ng-disabled="!formEditable()"
                      placeholder="${message(code:'is.ui.backlogelement.nodescription')}"
                      name="description"
                      ng-model="editableFeature.description"></textarea>
        </div>
        <div class="form-group">
            <label for="tags">${message(code:'is.backlogelement.tags')}</label>
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
        <div class="form-group">
            <label for="notes">${message(code:'is.backlogelement.notes')}</label>
            <textarea is-markitup
                      class="form-control"
                      ng-maxlength="5000"
                      name="notes"
                      ng-model="editableFeature.notes"
                      is-model-html="editableFeature.notes_html"
                      ng-show="showNotesTextarea"
                      ng-blur="showNotesTextarea = false"
                      placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
            <div class="markitup-preview"
                 ng-disabled="!formEditable()"
                 ng-show="!showNotesTextarea"
                 ng-click="showNotesTextarea = formEditable()"
                 ng-focus="editForm(true); showNotesTextarea = formEditable()"
                 ng-class="{'placeholder': !editableFeature.notes_html}"
                 tabindex="0"
                 ng-bind-html="editableFeature.notes_html ? editableFeature.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>'"></div>
        </div>
        <div class="form-group">
            <label>${message(code:'is.backlogelement.attachment')} {{ feature.attachments_count > 0 ? '(' + feature.attachments_count + ')' : '' }}</label>
            <div ng-if="authorizedFeature('upload', feature)"
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
                    ng-if="isLatest() || formHolder.submitting"
                    ng-disabled="!isDirty() || formHolder.featureForm.$invalid || formHolder.submitting"
                    type="submit">
                ${message(code:'default.button.update.label')}
            </button>
            <button class="btn btn-danger"
                    ng-if="!isLatest() && !formHolder.submitting"
                    ng-disabled="!isDirty() || formHolder.featureForm.$invalid"
                    type="submit">
                ${message(code:'default.button.override.label')}
            </button>
            <button class="btn btn-default"
                    type="button"
                    ng-click="editForm(false)">
                ${message(code:'is.button.cancel')}
            </button>
            <button class="btn btn-warning"
                    type="button"
                    ng-if="!isLatest() && !formHolder.submitting"
                    ng-click="resetFeatureForm()">
                <i class="fa fa-warning"></i> ${message(code:'default.button.refresh.label')}
            </button>
        </div>
    </div>
</form>