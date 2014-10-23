<%@ page import="org.icescrum.core.domain.PlanningPokerGame; org.icescrum.core.utils.BundleUtils" %>
%{--
- Copyright (c) 2014 Kagilum.
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
<div class="panel panel-default"
     flow-drop
     flow-files-submitted="attachmentQuery($flow, feature)"
     flow-drop-enabled="authorizedFeature('upload', feature)"
     flow-drag-enter="class='panel panel-default drop-enabled'"
     flow-drag-leave="class='panel panel-default'"
     flow-init
     ng-class="authorizedFeature('upload', feature) && class">
    <div class="panel-heading"
         fixed="#right"
         fixed-offset-width="-2">
        <h3 class="panel-title row">
            <div class="the-title">
                <span>{{ feature.name }}</span>
            </div>
            <div class="the-id">
                <div class="pull-right">
                    <button class="btn btn-xs btn-default"
                            disabled="disabled">{{ feature.uid }}</button>
                    <a ng-if="previous"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#feature/{{ previous.id }}"><i class="fa fa-caret-left" title="${message(code:'is.ui.backlogelement.toolbar.previous')}"></i></a>
                    <a ng-if="next"
                       class="btn btn-xs btn-default"
                       role="button"
                       tabindex="0"
                       href="#feature/{{ next.id }}"><i class="fa fa-caret-right" title="${message(code:'is.ui.backlogelement.toolbar.next')}"></i></a>
                </div>
            </div>
        </h3>
        <div class="actions">
            <div class="btn-group"
                 tooltip="${message(code: 'todo.is.ui.actions')}"
                 tooltip-append-to-body="true">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    <span class="fa fa-cog"></span> <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" ng-include="'feature.menu.html'"></ul>
            </div>
            <div class="btn-group pull-right">
                <button name="attachments" class="btn btn-default"
                        ng-click="setTabSelected('attachments')"
                        tooltip="{{ feature.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-paperclip"></span>
                    <span class="badge" ng-show="feature.attachments.length">{{ feature.attachments.length }}</span>
                </button>
                <button name="stories" class="btn btn-default"
                        ng-click="setTabSelected('stories')"
                        tooltip="{{ feature.stories_ids.length }} ${message(code:'todo.is.feature.stories')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-tasks"></span>
                    <span class="badge" ng-show="feature.stories_ids.length">{{ feature.stories_ids.length }}</span>
                </button>
            </div>
        </div>
    </div>

    <div class="panel-body">
        <form ng-submit="update(editableFeature)"
              name='formHolder.featureForm'
              class="form-editable"
              ng-mouseleave="formHover(false)"
              ng-mouseover="formHover(true)"
              ng-class="{'form-editing': getShowFeatureForm(feature)}"
              show-validation
              novalidate>
            <div class="form-group">
                <label for="name">${message(code:'is.feature.name')}</label>
                <input required
                       ng-maxlength="100"
                       ng-focus="editForm(true)"
                       ng-disabled="!getShowFeatureForm(feature)"
                       name="name"
                       ng-model="editableFeature.name"
                       type="text"
                       class="form-control">
            </div>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="type">${message(code:'is.feature.type')}</label>
                    <div class="input-group">
                        <select class="form-control"
                                ng-focus="editForm(true)"
                                ng-disabled="!getShowFeatureForm(feature)"
                                name="type"
                                ng-model="editableFeature.type"
                                ui-select2>
                            <is:options values="${is.internationalizeValues(map: BundleUtils.featureTypes)}" />
                        </select>
                        <span class="input-group-btn" ng-if="getShowFeatureForm(feature)">
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
                    <select class="form-control"
                            ng-focus="editForm(true)"
                            ng-disabled="!getShowFeatureForm(feature)"
                            name="value"
                            ng-model="editableFeature.value"
                            ui-select2>
                        <is:options values="${PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)}" />
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label for="description">${message(code:'is.backlogelement.description')}</label>
                <textarea class="form-control"
                          ng-maxlength="3000"
                          ng-focus="editForm(true)"
                          ng-disabled="!getShowFeatureForm(feature)"
                          placeholder="${message(code:'is.ui.backlogelement.nodescription')}"
                          name="description"
                          ng-model="editableFeature.description"></textarea>
            </div>
            <div class="form-group">
                <label for="tags">${message(code:'is.backlogelement.tags')}</label>
                <input type="hidden"
                       ng-focus="editForm(true)"
                       ng-disabled="!getShowFeatureForm(feature)"
                       class="form-control"
                       value="{{ editableFeature.tags.join(',') }}"
                       name="tags"
                       ng-model="editableFeature.tags"
                       data-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                       ui-select2="selectTagsOptions"/>
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
                     ng-disabled="!getShowFeatureForm(feature)"
                     ng-show="!showNotesTextarea"
                     ng-click="showNotesTextarea = getShowFeatureForm(feature)"
                     ng-focus="editForm(true); showNotesTextarea = getShowFeatureForm(feature)"
                     ng-class="{'placeholder': !editableFeature.notes_html}"
                     tabindex="0"
                     ng-bind-html="(editableFeature.notes_html ? editableFeature.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
            </div>
            <div class="btn-toolbar" ng-if="getShowFeatureForm(editableFeature) && getEditableMode()">
                <button class="btn btn-primary pull-right"
                        ng-disabled="!isDirty() || formHolder.featureForm.$invalid"
                        tooltip="${message(code:'todo.is.ui.update')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.update')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        tooltip-append-to-body="true"
                        tooltip="${message(code:'is.button.cancel')}"
                        type="button"
                        ng-click="editForm(false)">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
            <div class="form-group">
                <label>${message(code:'is.backlogelement.attachment')}</label>
                <div ng-if="authorizedFeature('upload', feature)">
                    <button type="button" flow-btn class="btn btn-default"><i class="fa fa-upload"></i> todo.is.ui.new.upload</button>
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
<div class="panel panel-default">
    <div class="panel-body">
        <tabset type="tabs nav-tabs-google">
            <tab select="stories(feature); ($state.params.tabId ? setTabSelected('stories') : '');"
                 heading="${message(code: 'todo.is.feature.stories')}"
                 active="tabSelected.stories">
                <table class="table">
                    <tbody ng-include="'nested.stories.html'"></tbody>
                </table>
            </tab>
        </tabset>
    </div>
</div>
</script>
