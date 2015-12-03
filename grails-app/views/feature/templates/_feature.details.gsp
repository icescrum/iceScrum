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
<script type="text/ng-template" id="feature.details.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                <span>{{ feature.name }}</span>
            </div>
            <div class="right-title">
                <button class="btn btn-default elemid">{{ feature.uid }}</button>
                <div class="btn-group"
                     uib-dropdown
                     uib-tooltip="${message(code: 'todo.is.ui.actions')}"
                     tooltip-append-to-body="true">
                    <button type="button" class="btn btn-default" uib-dropdown-toggle>
                        <span class="fa fa-cog"></span> <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu pull-right" ng-include="'feature.menu.html'"></ul>
                </div>
                <a ng-if="previousFeature"
                   class="btn btn-default"
                   role="button"
                   tabindex="0"
                   href="#{{ ::viewName }}/{{ ::previousFeature.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                <a ng-if="nextFeature"
                   class="btn btn-default"
                   role="button"
                   tabindex="0"
                   href="#{{ ::viewName }}/{{ ::nextFeature.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                <a class="btn btn-default"
                   href="#{{ ::viewName }}"
                   uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                    <i class="fa fa-times"></i>
                </a>
            </div>
        </h3>
    </div>
    <ul class="nav nav-tabs nav-justified">
        <li role="presentation" ng-class="{'active':!$state.params.tabId}">
            <a href="#{{ ::viewName }}/{{ ::feature.id }}"
               href="#"><i class="fa fa-lg fa-edit"></i></a>
        </li>
        <li role="presentation" ng-class="{'active':$state.params.tabId == 'stories'}">
            <a href="#{{ ::viewName }}/{{ ::feature.id }}/stories"
               uib-tooltip="{{ feature.stories_ids.length | orElse: 0 }} ${message(code:'todo.is.ui.feature.stories.count')}"
               tooltip-append-to-body="true">
                <i class="fa fa-lg fa-sticky-note"></i>
                <span class="badge" ng-show="feature.stories_ids.length">{{ feature.stories_ids.length }}</span>
            </a>
        </li>
    </ul>
    <div ui-view="details-tab">
        <form ng-submit="update(editableFeature)"
              name='formHolder.featureForm'
              ng-class="{'form-editable':formHolder.editable, 'form-editing': formHolder.editing }"
              show-validation
              novalidate>
            <div class="panel-body">
                <div class="form-group">
                    <label for="name">${message(code:'is.feature.name')}</label>
                    <input required
                           ng-maxlength="100"
                           ng-focus="editForm(true)"
                           ng-disabled="!formHolder.editable"
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
                                       ng-disabled="!formHolder.editable"
                                       name="type"
                                       ng-model="editableFeature.type">
                                <ui-select-match><i class="fa fa-{{ $select.selected | featureTypeIcon }}"></i> {{ $select.selected | i18n:'FeatureTypes' }}</ui-select-match>
                                <ui-select-choices repeat="featureType in featureTypes"><i class="fa fa-{{ ::featureType | featureTypeIcon }}"></i> {{ ::featureType | i18n:'FeatureTypes' }}</ui-select-choices>
                            </ui-select>
                            <span class="input-group-btn" ng-if="formHolder.editable">
                                <button colorpicker
                                        class="btn {{ editableFeature.color | contrastColor }}"
                                        type="button"
                                        style="background-color:{{ editableFeature.color }};"
                                        colorpicker-position="top"
                                        ng-focus="editForm(true)"
                                        value="#bf3d3d"
                                        name="color"
                                        ng-model="editableFeature.color"><i class="fa fa-pencil"></i></button>
                            </span>
                        </div>
                    </div>
                    <div class="form-half">
                        <label for="value">${message(code:'is.feature.value')}</label>
                        <ui-select class="form-control"
                                   ng-click="editForm(true)"
                                   ng-disabled="!formHolder.editable"
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
                              ng-disabled="!formHolder.editable"
                              placeholder="${message(code:'is.ui.backlogelement.nodescription')}"
                              name="description"
                              ng-model="editableFeature.description"></textarea>
                </div>
                <div class="form-group">
                    <label for="tags">${message(code:'is.backlogelement.tags')}</label>
                    <ui-select class="form-control"
                               ng-click="retrieveTags(); editForm(true)"
                               ng-disabled="!formHolder.editable"
                               multiple
                               tagging
                               tagging-tokens="SPACE|,"
                               tagging-label=""
                               ng-model="editableStory.tags">
                        <ui-select-match placeholder="${message(code:'is.ui.backlogelement.notags')}">{{ $item }}</ui-select-match>
                        <ui-select-choices repeat="tag in tags">{{ tag }}</ui-select-choices>
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
                         ng-disabled="!formHolder.editable"
                         ng-show="!showNotesTextarea"
                         ng-click="showNotesTextarea = formHolder.editable"
                         ng-focus="editForm(true); showNotesTextarea = formHolder.editable"
                         ng-class="{'placeholder': !editableFeature.notes_html}"
                         tabindex="0"
                         ng-bind-html="(editableFeature.notes_html ? editableFeature.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
                </div>
                <div class="form-group">
                    <label>${message(code:'is.backlogelement.attachment')} {{ feature.attachments.length > 0 ? '(' + feature.attachments.length + ')' : '' }}</label>
                    <div ng-if="authorizedFeature('upload', feature)">
                        <button type="button" class="btn btn-default"><i class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}</button>
                    </div>
                    <div class="form-control-static">
                        <table class="table table-striped attachments">
                            <tbody ng-include="'attachment.list.html'"></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="panel-footer" ng-if="formHolder.editing">
                <div class="btn-toolbar">
                    <button class="btn btn-primary"
                            ng-disabled="!isDirty() || formHolder.featureForm.$invalid"
                            uib-tooltip="${message(code:'default.button.update.label')} (RETURN)"
                            tooltip-append-to-body="true"
                            type="submit">
                        ${message(code:'default.button.update.label')}
                    </button>
                    <button class="btn confirmation btn-default"
                            tooltip-append-to-body="true"
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