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
<script type="text/ng-template" id="story.acceptanceTests.html">
<div class="card-body font-size-sm story-acceptanceTests" ng-controller="acceptanceTestListCtrl">
    <entry:point id="acceptanceTests-before-list"/>
    <div is-disabled="!isAcceptanceTestSortable()"
         as-sortable="acceptanceTestSortableOptions | merge: sortableScrollOptions()"
         ng-model="selected.acceptanceTests">
        <div ng-repeat="acceptanceTest in selected.acceptanceTests"
             class="story-acceptanceTest"
             as-sortable-item ng-controller="acceptanceTestCtrl">
            <form name="formHolder.acceptanceTestForm"
                  ng-class="{ 'form-editing': formHolder.editing, 'form-editable': formEditable() }"
                  ng-submit="update(editableAcceptanceTest, selected)"
                  show-validation
                  novalidate>
                <div class="row is-form-row form-group align-items-center">
                    <div class="col-sm-1 pr-0 text-nowrap">
                        <span ng-if="authorizedAcceptanceTest('rank', selected)" as-sortable-item-handle>{{:: editableAcceptanceTest.uid }}</span>
                        <span ng-if="!authorizedAcceptanceTest('rank', selected)">{{:: editableAcceptanceTest.uid }}</span>
                    </div>
                    <div class="col-sm-6 pr-0">
                        <input required
                               ng-maxlength="255"
                               ng-focus="editForm(true)"
                               type="text"
                               name="name"
                               ng-model="editableAcceptanceTest.name"
                               autocomplete="off"
                               ng-change="editForm(true)"
                               class="form-control"
                               placeholder="${message(code: 'is.ui.backlogelement.noname')}">
                    </div>
                    <div class="col-sm-4 pr-0">
                        <ui-select class="form-control"
                                   ng-click="authorizedAcceptanceTest('updateState', selected) && editForm(true)"
                                   on-select="selectAcceptanceTestState(editableAcceptanceTest, selected)"
                                   name="state"
                                   ng-model="editableAcceptanceTest.state"
                                   ng-disabled="!authorizedAcceptanceTest('updateState', selected)">
                            <ui-select-match>
                                <span ng-class="'text-'+($select.selected | acceptanceTestColor)"><i class="{{ $select.selected | acceptanceTestIcon }}"></i> {{ $select.selected | i18n:'AcceptanceTestStates' }}</span>
                            </ui-select-match>
                            <ui-select-choices repeat="acceptanceTestState in acceptanceTestStates">
                                <span ng-class="'text-'+(acceptanceTestState | acceptanceTestColor)"><i class='{{ acceptanceTestState | acceptanceTestIcon }}'></i> {{ acceptanceTestState | i18n:'AcceptanceTestStates' }}</span>
                            </ui-select-choices>
                        </ui-select>
                    </div>
                    <div class="col-sm-1 pr-0 pl-0">
                        <div class="btn-group" ng-show="formDeletable() || formEditable()" uib-dropdown>
                            <button type="button"
                                    class="btn btn-link btn-sm"
                                    uib-dropdown-toggle>
                            </button>
                            <div uib-dropdown-menu ng-init="itemType = 'acceptanceTest'" template-url="item.menu.html"></div>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <textarea is-markitup
                              class="form-control"
                              ng-maxlength="1000"
                              name="description"
                              ng-model="editableAcceptanceTest.description"
                              is-model-html="editableAcceptanceTest.description_html"
                              ng-show="showAcceptanceTestDescriptionTextarea"
                              ng-blur="delayCall(blurAcceptanceTestDescription)"
                              placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
                    <div class="markitup-preview form-control no-fixed-height"
                         ng-show="!showAcceptanceTestDescriptionTextarea"
                         ng-focus="editAcceptanceTestDescription()"
                         ng-class="{'placeholder': !editableAcceptanceTest.description_html}"
                         tabindex="0"
                         bind-html-scope="markitupCheckboxOptions('description')"
                         bind-html-compile="editableAcceptanceTest.description_html ? editableAcceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>'"></div>
                </div>
                <div class="btn-toolbar justify-content-end mb-3"
                     ng-if="formHolder.editing">
                    <button class="btn btn-secondary btn-sm"
                            ng-click="resetAcceptanceTestForm(true)"
                            type="button">
                        ${message(code: 'is.button.cancel')}
                    </button>
                    <button class="btn btn-primary btn-sm"
                            ng-disabled="!formHolder.acceptanceTestForm.$dirty || formHolder.acceptanceTestForm.$invalid || application.submitting"
                            ng-click="update(editableAcceptanceTest, selected)"
                            type="submit">
                        ${message(code: 'default.button.update.label')}
                    </button>
                </div>
            </form>
            <hr ng-if="!$last" class="w-50 mt-2"/>
        </div>
        <div ng-show="selected.acceptanceTests_count === 0"
             class="empty-content">
            <div class="form-text">
                ${message(code: 'is.ui.acceptanceTest.help')}
                <documentation doc-url="features-stories-tasks#acceptancetests"/>
            </div>
        </div>
    </div>
</div>
<div class="card-footer" ng-controller="acceptanceTestCtrl">
    <div ng-if="authorizedAcceptanceTest('create', selected)" ng-include="'story.acceptanceTest.editor.html'"></div>
</div>
</script>
