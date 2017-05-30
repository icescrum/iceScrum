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
<form ng-submit="update(editableStory)"
      name='formHolder.storyForm'
      ng-class="{'form-editable': formEditable(), 'form-editing': formHolder.editing }"
      show-validation
      novalidate>
    <div class="panel-body">
        <div class="clearfix no-padding">
            <entry:point id="story-properties-before-properties"/>
            <div class="form-2-tiers">
                <label for="name">${message(code: 'is.story.name')}</label>
                <input required
                       ng-maxlength="100"
                       ng-focus="editForm(true)"
                       ng-disabled="!formEditable()"
                       name="name"
                       ng-model="editableStory.name"
                       type="text"
                       class="form-control important">
            </div>
            <div class="form-1-tier">
                <label for="type">${message(code: 'is.story.type')}</label>
                <ui-select class="form-control"
                           ng-click="editForm(true)"
                           ng-disabled="!formEditable()"
                           name="type"
                           ng-model="editableStory.type">
                    <ui-select-match><i class="fa fa-{{ $select.selected | storyTypeIcon }}"></i> {{ $select.selected | i18n:'StoryTypes' }}</ui-select-match>
                    <ui-select-choices repeat="storyType in storyTypes"><i class="fa fa-{{ ::storyType | storyTypeIcon }}"></i> {{ ::storyType | i18n:'StoryTypes' }}</ui-select-choices>
                </ui-select>
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
                      autofocus
                      placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
            <div class="atwho-preview form-control-static important"
                 ng-disabled="!formEditable()"
                 ng-show="!showDescriptionTextarea"
                 ng-click="clickDescriptionPreview($event, '${is.generateStoryTemplate(newLine: '\\n')}')"
                 ng-focus="focusDescriptionPreview($event)"
                 ng-mousedown="$parent.descriptionPreviewMouseDown = true"
                 ng-mouseup="$parent.descriptionPreviewMouseDown = false"
                 ng-class="{'placeholder': !editableStory.description}"
                 tabindex="0"
                 ng-bind-html="editableStory.description ? (editableStory.description | lineReturns | actorTag: editableStory.actor) : '${message(code: 'is.ui.backlogelement.nodescription')}'"></div>
        </div>
        <div class="clearfix no-padding">
            <div class="form-half">
                <label for="feature">${message(code: 'is.feature')}</label>
                <div ng-class="{'input-group': editableStory.feature.id && !isModal}">
                    <ui-select input-group-fix-width="38"
                               ng-click="editForm(true)"
                               ng-change="editForm(true)"
                               ng-disabled="!formEditable()"
                               class="form-control"
                               name="feature"
                               search-enabled="true"
                               ng-model="editableStory.feature">
                        <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.story.nofeature')}">
                            <i class="fa fa-sticky-note" ng-style="{color: $select.selected.color}"></i> {{ $select.selected.name }}
                        </ui-select-match>
                        <ui-select-choices repeat="feature in features | orFilter: { name: $select.search, uid: $select.search }">
                            <i class="fa fa-sticky-note" ng-style="{color: feature.color}"></i> <span ng-bind-html="feature.name | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                    <span class="input-group-btn" ng-if="editableStory.feature.id && !isModal">
                        <a ui-sref=".feature.details({featureId: editableStory.feature.id})"
                           title="{{ editableStory.feature.name }}"
                           class="btn btn-default">
                            <i class="fa fa-info-circle"></i>
                        </a>
                    </span>
                </div>
            </div>
            <div class="form-half">
                <label for="dependsOn">${message(code: 'is.story.dependsOn')}</label>
                <div ng-class="{'input-group':editableStory.dependsOn.id}">
                    <ui-select input-group-fix-width="38"
                               class="form-control"
                               ng-click="retrieveDependenceEntries(editableStory); editForm(true)"
                               ng-change="editForm(true)"
                               ng-disabled="!formEditable()"
                               name="dependsOn"
                               search-enabled="true"
                               ng-model="editableStory.dependsOn">
                        <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.story.nodependence')}">
                            {{ $select.selected | dependsOnLabel }}
                        </ui-select-match>
                        <ui-select-choices repeat="dependenceEntry in dependenceEntries | orFilter: { name: $select.search, uid: $select.search }">
                            <span ng-bind-html="dependenceEntry | dependsOnLabel | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                    <span class="input-group-btn" ng-show="editableStory.dependsOn.id">
                        <a href="#story/{{ editableStory.dependsOn.id }}"
                           title="{{ editableStory.dependsOn.name }}"
                           class="btn btn-default">
                            <i class="fa fa-info-circle"></i>
                        </a>
                    </span>
                </div>
                <div class="clearfix" style="margin-top: 15px;" ng-if="editableStory.dependences.length">
                    <strong>${message(code: 'is.story.dependences')} :</strong>
                    <span ng-repeat="dependence in editableStory.dependences track by dependence.id">{{ dependence.name }}</span>
                </div>
            </div>
        </div>
        <div class="form-group">
            <label for="tags">${message(code: 'is.backlogelement.tags')}</label>
            <ui-select ng-click="retrieveTags(); editForm(true)"
                       ng-disabled="!formEditable()"
                       class="form-control"
                       multiple
                       tagging
                       tagging-tokens="SPACE|,"
                       tagging-label="${message(code: 'todo.is.ui.tag.create')}"
                       ng-model="editableStory.tags">
                <ui-select-match placeholder="${message(code: 'is.ui.backlogelement.notags')}">{{ $item }}</ui-select-match>
                <ui-select-choices repeat="tag in tags | filter: $select.search">
                    <span ng-bind-html="tag | highlight: $select.search"></span>
                </ui-select-choices>
            </ui-select>
        </div>
        <div class="clearfix no-padding">
            <div class="form-1-quarter" ng-show="authorizedStory('updateEstimate', editableStory)">
                <label for="effort">${message(code: 'is.story.effort')}</label>
                <div class="input-group">
                    <ui-select ng-if="!isEffortCustom()"
                               class="form-control"
                               ng-click="editForm(true)"
                               ng-disabled="!formEditable()"
                               name="effort"
                               search-enabled="true"
                               ng-model="editableStory.effort">
                        <ui-select-match>{{ $select.selected }}</ui-select-match>
                        <ui-select-choices repeat="i in effortSuite(isEffortNullable(story)) | filter: $select.search">
                            <span ng-bind-html="'' + i | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                    <input type="number"
                           ng-if="isEffortCustom()"
                           class="form-control"
                           ng-focus="editForm(true)"
                           ng-disabled="!formEditable()"
                           name="effort"
                           min="0"
                           ng-model="editableStory.effort"/>
                    <span class="input-group-btn">
                        <button class="btn btn-default"
                                type="button"
                                name="edit-effort"
                                ng-click="showEditEffortModal(story)"><i class="fa fa-pencil"></i></button>
                    </span>
                </div>
            </div>
            <div class="form-3-quarters" ng-show="authorizedStory('updateParentSprint', editableStory)">
                <label for="parentSprint">${message(code: 'is.sprint')}</label>
                <ui-select ng-click="retrieveParentSprintEntries(); editForm(true)"
                           ng-change="editForm(true)"
                           ng-disabled="!formEditable()"
                           class="form-control"
                           name="parentSprint"
                           search-enabled="true"
                           ng-model="editableStory.parentSprint">
                    <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.story.noparentsprint')}">
                        {{ $select.selected.parentRelease.name + ' - ' + ($select.selected | sprintName) }}
                    </ui-select-match>
                    <ui-select-choices group-by="groupSprintByParentRelease" repeat="parentSprintEntry in parentSprintEntries | filter: { index: $select.search }">
                        <span ng-bind-html="parentSprintEntry | sprintName | highlight: $select.search"></span>
                    </ui-select-choices>
                </ui-select>
            </div>
        </div>
        <div class="clearfix no-padding">
            <div class="form-1-quarter">
                <label for="value">${message(code: 'is.story.value')}</label>
                <div class="input-group">
                    <ui-select class="form-control"
                               ng-click="editForm(true)"
                               ng-disabled="!formEditable()"
                               name="value"
                               search-enabled="true"
                               ng-model="editableStory.value">
                        <ui-select-match>{{ $select.selected }}</ui-select-match>
                        <ui-select-choices repeat="i in integerSuite | filter: $select.search">
                            <span ng-bind-html="'' + i | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                    <span class="input-group-btn" ng-if="authorizedStory('update', editableStory)">
                        <button class="btn btn-default"
                                type="button"
                                name="edit-value"
                                ng-click="showEditValueModal(story)"><i class="fa fa-pencil"></i></button>
                    </span>
                </div>
            </div>
            <div class="form-1-quarter" ng-show="editableStory.type == 2">
                <label for="affectVersion">${message(code: 'is.story.affectVersion')}</label>
                <ui-select class="form-control"
                           ng-click="retrieveVersions(); editForm(true)"
                           ng-change="editForm(true)"
                           ng-disabled="!formEditable()"
                           search-enabled="true"
                           tagging
                           tagging-tokens="SPACE|,"
                           tagging-label="${message(code: 'todo.is.ui.story.affectedVersion.new')}"
                           ng-model="editableStory.affectVersion">
                    <ui-select-match allow-clear="true" placeholder="${message(code: 'is.ui.story.noaffectversion')}">{{ $select.selected }}</ui-select-match>
                    <ui-select-choices repeat="version in versions | filter: $select.search">
                        <span ng-bind-html="version | highlight: $select.search"></span>
                    </ui-select-choices>
                </ui-select>
            </div>
            <div class="form-half">
                <label for="creator">${message(code: 'is.story.creator')}</label>
                <ui-select ng-click="editForm(true);searchCreator($select.search)"
                           ng-change="editForm(true)"
                           ng-disabled="!formEditable() || !authorizedStory('updateCreator', editableStory)"
                           class="form-control"
                           name="creator"
                           search-enabled="true"
                           ng-model="editableStory.creator">
                    <ui-select-match>
                        {{ $select.selected | userFullName }}
                    </ui-select-match>
                    <ui-select-choices refresh="searchCreator($select.search)"
                                       refresh-delay="100"
                                       repeat="creator in creators | orFilter: { username: $select.search, name: $select.search, email: $select.search }">
                        <span ng-bind-html="(creator | userFullName) | highlight: $select.search"></span>
                    </ui-select-choices>
                </ui-select>
            </div>
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
            <div class="markitup-preview important"
                 ng-disabled="!formEditable()"
                 ng-show="!showNotesTextarea"
                 ng-click="showNotesTextarea = formEditable()"
                 ng-focus="editForm(true); showNotesTextarea = formEditable()"
                 ng-class="{'placeholder': !editableStory.notes_html}"
                 tabindex="0"
                 ng-bind-html="editableStory.notes_html ? editableStory.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>'"></div>
        </div>
        <div class="form-group">
            <label>${message(code: 'is.backlogelement.attachment')} {{ story.attachments.length > 0 ? '(' + story.attachments.length + ')' : '' }}</label>
            <div ng-if="authorizedStory('upload', story)"
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
                    ng-disabled="!isDirty() || formHolder.storyForm.$invalid || formHolder.submitting"
                    type="submit">
                ${message(code: 'default.button.update.label')}
            </button>
            <button class="btn btn-danger"
                    ng-if="!isLatest() && !formHolder.submitting"
                    ng-disabled="!isDirty() || formHolder.storyForm.$invalid"
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
                    ng-click="resetStoryForm()">
                <i class="fa fa-warning"></i> ${message(code:'default.button.refresh.label')}
            </button>
        </div>
    </div>
</form>
