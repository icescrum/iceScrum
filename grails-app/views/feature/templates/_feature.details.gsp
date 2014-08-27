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
<div class="panel panel-default">
    <div class="panel-heading"
         fixed="#right"
         fixed-offset-top="1"
         fixed-offset-width="-2">
        <h3 class="panel-title row">
            <div class="the-title">
                <span>{{ feature.name }}</span>
            </div>
            <div class="the-id">
                <div class="pull-right">
                    <span class="label label-default"
                          tooltip="${message(code: 'is.backlogelement.id')}">{{ feature.uid }}</span>
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
                 ng-if="authorizedFeature('menu')"
                 tooltip="${message(code: 'todo.is.ui.actions')}"
                 tooltip-append-to-body="true">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                    <span class="fa fa-cog"></span> <span class="caret"></span>
                </button>
                <ul class="dropdown-menu" ng-include="'feature.menu.html'"></ul>
            </div>
            <button type="button"
                    tabindex="-1"
                    popover-title="${message(code:'is.permalink')}"
                    popover="{{ serverUrl + '/TODOPKEY-F' + feature.uid }}"
                    popover-append-to-body="true"
                    popover-placement="left"
                    class="btn btn-default">
                <i class="fa fa-link"></i>
            </button>
            <button class="btn btn-primary"
                    type="button"
                    tooltip="${message(code:'todo.is.ui.editable.enable')}"
                    ng-if="authorizedFeature('update', feature) && !getEditableMode(feature)"
                    ng-click="enableEditableFeatureMode()"><span class="fa fa-pencil"></span></button>
            <button class="btn btn-default"
                    type="button"
                    tooltip="${message(code:'todo.is.ui.editable.disable')}"
                    ng-if="getEditableFeatureMode(feature)"
                    ng-click="confirm({ message: '${message(code: 'todo.is.ui.dirty.confirm')}', callback: disableEditableFeatureMode, condition: isDirty() })"><span class="fa fa-pencil-square-o"></span></button>
            <div class="btn-group pull-right">
                <button name="attachments" class="btn btn-default"
                        ng-click="setTabSelected('attachments')"
                        tooltip="{{ feature.attachments.length }} ${message(code:'todo.is.backlogelement.attachments')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-paperclip"></span>
                    <span class="badge" ng-show="feature.attachments_count">{{ feature.attachments_count }}</span>
                </button>
                <button name="stories" class="btn btn-default"
                        ng-click="setTabSelected('stories')"
                        tooltip="{{ feature.stories_count }} ${message(code:'todo.is.feature.stories')}"
                        tooltip-append-to-body="true">
                    <span class="fa fa-tasks"></span>
                    <span class="badge" ng-show="feature.stories_count">{{ feature.stories_count }}</span>
                </button>
            </div>
        </div>
    </div>

    <div class="panel-body">
        <form ng-submit="update(editableFeature)"
              ng-class="{'form-disabled': !getEditableFeatureMode(feature)}"
              name='featureForm'
              show-validation
              novalidate>
            <div class="form-group">
                <label for="feature.name">${message(code:'is.feature.name')}</label>
                <input required
                       ng-disabled="!getEditableFeatureMode(feature)"
                       name="editableFeature.name"
                       ng-model="editableFeature.name"
                       type="text"
                       class="form-control">
            </div>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="feature.type">${message(code:'is.feature.type')}</label>
                    <div class="input-group">
                        <select class="form-control"
                                ng-disabled="!getEditableFeatureMode(feature)"
                                ng-model="editableFeature.type"
                                ui-select2>
                            <is:options values="${is.internationalizeValues(map: BundleUtils.featureTypes)}" />
                        </select>
                        <span class="input-group-btn" ng-if="getEditableFeatureMode(feature)">
                            <button colorpicker
                                    class="btn {{ editableFeature.color | contrastColor }}"
                                    type="button"
                                    style="background-color:{{ editableFeature.color }};"
                                    colorpicker-position="top"
                                    value="#bf3d3d"
                                    ng-model="editableFeature.color"><i class="fa fa-pencil"></i></button>
                        </span>
                    </div>
                </div>
                <div class="form-half">
                    <label for="feature.value">${message(code:'is.feature.value')}</label>
                    <select class="form-control"
                            ng-disabled="!getEditableFeatureMode(feature)"
                            ng-model="editableFeature.value"
                            ui-select2>
                        <is:options values="${PlanningPokerGame.getInteger(PlanningPokerGame.INTEGER_SUITE)}" />
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label for="feature.description">${message(code:'is.backlogelement.description')}</label>
                <textarea class="form-control"
                          ng-disabled="!getEditableFeatureMode(feature)"
                          placeholder="${message(code:'is.ui.backlogelement.nodescription')}"
                          ng-model="editableFeature.description"></textarea>
            </div>
            <div class="form-group">
                <label for="feature.tags">${message(code:'is.backlogelement.tags')}</label>
                <input type="hidden"
                       ng-disabled="!getEditableFeatureMode(feature)"
                       class="form-control"
                       value="{{ editableFeature.tags.join(',') }}"
                       ng-model="editableFeature.tags"
                       data-placeholder="${message(code:'is.ui.backlogelement.notags')}"
                       ui-select2="selectTagsOptions"/>
            </div>
            <div class="form-group">
                <label for="feature.notes">${message(code:'is.backlogelement.notes')}</label>
                <textarea is-markitup
                          class="form-control"
                          ng-model="editableFeature.notes"
                          is-model-html="editableFeature.notes_html"
                          ng-show="showNotesTextarea"
                          ng-blur="showNotesTextarea = false"
                          placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="!getEditableFeatureMode(feature)"
                     ng-show="!showNotesTextarea"
                     ng-click="showNotesTextarea = getEditableFeatureMode(feature)"
                     ng-focus="showNotesTextarea = getEditableFeatureMode(feature)"
                     ng-class="{'placeholder': !editableFeature.notes_html}"
                     tabindex="0"
                     ng-bind-html="(editableFeature.notes_html ? editableFeature.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
            </div>
            <div class="btn-toolbar" ng-if="getEditableFeatureMode(editableFeature)">
                <button class="btn btn-primary pull-right"
                        ng-class="{ disabled: !isDirty() }"
                        tooltip="${message(code:'todo.is.ui.update')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.update')}
                </button>
                <button class="btn confirmation btn-default pull-right"
                        ng-class="{ disabled: !isDirty() }"
                        tooltip-append-to-body="true"
                        tooltip="${message(code:'is.button.cancel')}"
                        type="button"
                        ng-click="initEditableFeature()">
                    ${message(code:'is.button.cancel')}
                </button>
            </div>
        </form>
        <tabset type="{{ tabsType }}">
            <tab select="$state.params.tabId ? setTabSelected('attachments') : ''"
                 heading="${message(code: 'is.ui.backlogelement.attachment')}"
                 active="tabSelected.attachments">
            </tab>
            <tab select="stories(feature); setTabSelected('stories');"
                 heading="${message(code: 'todo.is.feature.stories')}"
                 active="tabSelected.stories">
                <table class="table table-striped">
                    <tbody ng-include="'nested.stories.html'" ng-init="selected = feature"></tbody>
                </table>
            </tab>
        </tabset>
    </div>
</div>
</script>
