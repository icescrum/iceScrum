<%@ page import="org.icescrum.core.utils.BundleUtils" %>

<form ng-submit="update(editableStory)"
      name='formHolder.storyForm'
      ng-class="{'form-editable':formHolder.editable, 'form-editing': formHolder.editing }"
      show-validation
      novalidate>
    <div class="panel-body">
        <div class="clearfix no-padding">
            <div class="form-half">
                <label for="name">${message(code: 'is.story.name')}</label>
                <input required
                       ng-maxlength="100"
                       ng-focus="editForm(true)"
                       ng-disabled="!formHolder.editable"
                       name="name"
                       ng-model="editableStory.name"
                       type="text"
                       class="form-control">
            </div>

            <div class="form-half">
                <label for="feature">${message(code: 'is.feature')}</label>

                <div ng-class="{'input-group':editableStory.feature.id, 'select2-border':editableStory.feature.id}">
                    <input type="hidden"
                           ng-focus="editForm(true)"
                           ng-disabled="!formHolder.editable"
                           class="form-control"
                           value="{{ editableStory.feature.id ? editableStory.feature : '' }}"
                           name="feature"
                           ng-model="editableStory.feature"
                           ui-select2-tamere="selectFeatureOptions"
                           data-placeholder="${message(code: 'is.ui.story.nofeature')}"/>
                    <span class="input-group-btn" ng-show="editableStory.feature.id">
                        <a href="#feature/{{ editableStory.feature.id }}"
                           title="{{ editableStory.feature.name }}"
                           class="btn btn-default">
                            <i class="fa fa-external-link"></i>
                        </a>
                    </span>
                </div>
            </div>
        </div>

        <div class="clearfix no-padding">
            <div class="form-group"
                 ng-class="{ 'form-half' : editableStory.type == 2 }">
                <label for="type">${message(code: 'is.story.type')}</label>
                <select class="form-control"
                        ng-focus="editForm(true)"
                        ng-disabled="!formHolder.editable"
                        name="type"
                        ng-model="editableStory.type"
                        ui-select2-tamere>
                    <is:options values="${is.internationalizeValues(map: BundleUtils.storyTypes)}"/>
                </select>
            </div>

            <div class="form-half"
                 ng-show="editableStory.type == 2">
                <label for="affectVersion">${message(code: 'is.story.affectVersion')}</label>
                <input class="form-control"
                       ng-focus="editForm(true)"
                       ng-disabled="!formHolder.editable"
                       type="hidden"
                       value="{{ editableStory.affectVersion  }}"
                       name="affectVersion"
                       ng-model="editableStory.affectVersion"
                       ui-select2-tamere="selectAffectionVersionOptions"
                       data-placeholder="${message(code: 'is.ui.story.noaffectversion')}"/>
            </div>
        </div>

        <div class="clearfix no-padding">
            <div class="form-group"
                 ng-class="{ 'form-half' : authorizedStory('updateEstimate', editableStory) }">
                <label for="value">${message(code: 'is.story.value')}</label>

                <div class="input-group">
                    <select class="form-control"
                            ng-focus="editForm(true)"
                            ng-disabled="!formHolder.editable"
                            name="value"
                            ng-model="editableStory.value"
                            ng-options="i for i in integerSuite"
                            ui-select2-tamere>
                    </select>
                    <span class="input-group-btn" ng-if="authorizedStory('update', editableStory)">
                        <button class="btn btn-default"
                                type="button"
                                name="edit-value"
                                ng-click="showEditValueModal(story)"><i class="fa fa-pencil"></i></button>
                    </span>
                </div>
            </div>

            <div class="form-half"
                 ng-show="authorizedStory('updateEstimate', editableStory)"
                 ng-switch="isEffortCustom()">
                <label for="effort">${message(code: 'is.story.effort')}</label>

                <div class="input-group">
                    <select ng-switch-default
                            class="form-control"
                            ng-focus="editForm(true)"
                            ng-disabled="!formHolder.editable"
                            name="effort"
                            ng-model="editableStory.effort"
                            ui-select2-tamere>
                        <option ng-show="isEffortNullable(story)" value="?">?</option>
                        <option ng-repeat="i in effortSuite()" value="{{ i }}">{{ i }}</option>
                    </select>
                    <input type="number"
                           ng-switch-when="true"
                           class="form-control"
                           ng-focus="editForm(true)"
                           ng-disabled="!formHolder.editable"
                           name="effort"
                           ng-model="editableStory.effort"/>
                    <span class="input-group-btn">
                        <button class="btn btn-default"
                                type="button"
                                name="edit-effort"
                                ng-click="showEditEffortModal(story)"><i class="fa fa-pencil"></i></button>
                    </span>
                </div>
            </div>
        </div>

        <div class="form-group"
             ng-show="authorizedStory('updateParentSprint', editableStory)">
            <label for="parentSprint">${message(code: 'is.sprint')}</label>
            <input type="hidden"
                   ng-focus="editForm(true)"
                   ng-disabled="!formHolder.editable"
                   class="form-control"
                   value="{{ editableStory.parentSprint.id ? editableStory.parentSprint : '' }}"
                   name="parentSprint"
                   ng-model="editableStory.parentSprint"
                   ui-select2-tamere="selectParentSprintOptions"
                   data-placeholder="${message(code: 'is.ui.story.noparentsprint')}"/>
        </div>

        <div class="form-group">
            <label for="dependsOn">${message(code: 'is.story.dependsOn')}</label>

            <div ng-class="{'input-group':editableStory.dependsOn.id}">
                <input type="hidden"
                       ng-focus="editForm(true)"
                       ng-disabled="!formHolder.editable"
                       style="width:100%;"
                       class="form-control"
                       value="{{ editableStory.dependsOn.id ? editableStory.dependsOn : '' }}"
                       name="dependsOn"
                       ng-model="editableStory.dependsOn"
                       ui-select2-tamere="selectDependsOnOptions"
                       data-placeholder="${message(code: 'is.ui.story.nodependence')}"/>
                <span class="input-group-btn" ng-show="editableStory.dependsOn.id">
                    <a href="#story/{{ editableStory.dependsOn.id }}"
                       title="{{ editableStory.dependsOn.name }}"
                       class="btn btn-default">
                        <i class="fa fa-external-link"></i>
                    </a>
                </span>
            </div>

            <div class="clearfix" style="margin-top: 15px;" ng-if="editableStory.dependences.length">
                <strong>${message(code: 'is.story.dependences')} :</strong>
                <a class="scrum-link" title="{{ dependence.name }}"
                   ng-repeat="dependence in editableStory.dependences track by dependence.id">{{ dependence.name }}</a>
            </div>
        </div>

        <div class="form-group">
            <label for="description">${message(code: 'is.backlogelement.description')}</label>
            <textarea class="form-control"
                      ng-maxlength="3000"
                      name="description"
                      ng-model="editableStory.description"
                      ng-show="showDescriptionTextarea"
                      ng-blur="blurDescription('${is.generateStoryTemplate(newLine: '\\n')}')"
                      at="atOptions"
                      focus-me="{{ showDescriptionTextarea }}"
                      placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>

            <div class="atwho-preview form-control-static"
                 ng-disabled="!formHolder.editable"
                 ng-show="!showDescriptionTextarea"
                 ng-click="clickDescriptionPreview($event, '${is.generateStoryTemplate(newLine: '\\n')}')"
                 ng-focus="focusDescriptionPreview($event)"
                 ng-mousedown="$parent.descriptionPreviewMouseDown = true"
                 ng-mouseup="$parent.descriptionPreviewMouseDown = false"
                 ng-class="{'placeholder': !editableStory.description}"
                 tabindex="0"
                 ng-bind-html="(editableStory.description ? (editableStory | storyDescriptionHtml) : '${message(code: 'is.ui.backlogelement.nodescription')}') | sanitize"></div>
        </div>

        <div class="form-group">
            <label for="tags">${message(code: 'is.backlogelement.tags')}</label>
            <input type="hidden"
                   ng-focus="editForm(true)"
                   ng-disabled="!formHolder.editable"
                   class="form-control"
                   value="{{ editableStory.tags.join(',') }}"
                   name="tags"
                   ng-model="editableStory.tags"
                   data-placeholder="${message(code: 'is.ui.backlogelement.notags')}"
                   ui-select2-tamere="selectTagsOptions"/>
        </div>

        <div class="form-group">
            <label for="notes">${message(code: 'is.backlogelement.notes')}</label>
            <textarea is-markitup
                      ng-maxlength="5000"
                      class="form-control"
                      name="notes"
                      ng-model="editableStory.notes"
                      is-model-html="editableStory.notes_html"
                      ng-show="showNotesTextarea"
                      ng-blur="showNotesTextarea = false"
                      placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>

            <div class="markitup-preview"
                 ng-disabled="!formHolder.editable"
                 ng-show="!showNotesTextarea"
                 ng-click="showNotesTextarea = formHolder.editable"
                 ng-focus="editForm(true); showNotesTextarea = formHolder.editable"
                 ng-class="{'placeholder': !editableStory.notes_html}"
                 tabindex="0"
                 ng-bind-html="(editableStory.notes_html ? editableStory.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
        </div>

        <div class="form-group">
            <label>${message(code: 'is.backlogelement.attachment')} {{ story.attachments.length > 0 ? '(' + story.attachments.length + ')' : '' }}</label>

            <div ng-if="authorizedStory('upload', story)">
                <button type="button" class="btn btn-default"><i
                        class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}</button>
            </div>

            <div class="form-control-static">
                <div class="drop-zone">
                    <h2>${message(code: 'todo.is.ui.drop.here')}</h2>
                </div>
                <table class="table table-striped attachments" ng-controller="attachmentCtrl">
                    <tbody ng-include="'attachment.list.html'"></tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="panel-footer" ng-if="formHolder.editing">
        <div class="btn-toolbar">
            <button class="btn btn-primary"
                    ng-disabled="!isDirty() || formHolder.storyForm.$invalid"
                    uib-tooltip="${message(code: 'default.button.update.label')} (RETURN)"
                    tooltip-append-to-body="true"
                    type="submit">
                ${message(code: 'default.button.update.label')}
            </button>
            <button class="btn confirmation btn-default"
                    tooltip-append-to-body="true"
                    uib-tooltip="${message(code: 'is.button.cancel')}"
                    type="button"
                    ng-click="editForm(false)">
                ${message(code: 'is.button.cancel')}
            </button>
        </div>
    </div>
</form>