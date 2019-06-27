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
<div class="story-acceptanceTests card-body" ng-controller="acceptanceTestListCtrl">
    <entry:point id="acceptanceTests-before-list"/>
    <div is-disabled="!isAcceptanceTestSortable()"
         as-sortable="acceptanceTestSortableOptions | merge: sortableScrollOptions()"
         ng-model="selected.acceptanceTests">
        <div ng-repeat="acceptanceTest in selected.acceptanceTests"
             as-sortable-item ng-controller="acceptanceTestCtrl">
            <form name="formHolder.acceptanceTestForm"
                  ng-class="{ 'form-editing': formHolder.editing, 'form-editable': formEditable() }"
                  ng-submit="update(editableAcceptanceTest, selected)"
                  show-validation
                  novalidate>
                <div class="row is-form-row form-group align-items-center">
                    <div class="col-sm-1">
                        <i class="fa fa-drag-handle" ng-if="authorizedAcceptanceTest('rank', selected)" as-sortable-item-handle></i>
                        <strong class="text-accent">{{:: editableAcceptanceTest.uid }}</strong>
                    </div>
                    <div class="col-sm-6">
                        <input required
                               ng-maxlength="255"
                               ng-focus="editForm(true)"
                               type="text"
                               name="name"
                               ng-model="editableAcceptanceTest.name"
                               ng-change="editForm(true)"
                               class="form-control"
                               placeholder="${message(code: 'is.ui.backlogelement.noname')}">
                    </div>
                    <div class="col-sm-4">
                        <ui-select class="form-control"
                                   ng-click="authorizedAcceptanceTest('updateState', selected) && editForm(true)"
                                   on-select="selectAcceptanceTestState(editableAcceptanceTest, selected)"
                                   name="state"
                                   ng-model="editableAcceptanceTest.state"
                                   ng-disabled="!authorizedAcceptanceTest('updateState', selected)">
                            <ui-select-match>
                                <span ng-class="'text-'+($select.selected | acceptanceTestColor)"><i class='fa fa-check'></i> {{ $select.selected | i18n:'AcceptanceTestStates' }}</span>
                            </ui-select-match>
                            <ui-select-choices repeat="acceptanceTestState in acceptanceTestStates">
                                <span ng-class="'text-'+(acceptanceTestState | acceptanceTestColor)"><i class='fa fa-check'></i> {{ acceptanceTestState | i18n:'AcceptanceTestStates' }}</span>
                            </ui-select-choices>
                        </ui-select>
                    </div>
                    <div class="col-sm-1 text-right">
                        <div class="btn-group btn-group-sm" ng-show="formDeletable() || formEditable()" uib-dropdown>
                            <button type="button"
                                    class="btn btn-secondary"
                                    uib-dropdown-toggle>
                            </button>
                            <div uib-dropdown-menu class="dropdown-menu-right">
                                <a href
                                   class="dropdown-item"
                                   ng-click="copy(acceptanceTest, selected)">
                                    ${message(code: 'is.ui.copy')}
                                </a>
                                <a href
                                   class="dropdown-item"
                                   ng-click="confirmDelete({ callback: delete, args: [acceptanceTest, selected] })">
                                    ${message(code: 'default.button.delete.label')}
                                </a>
                            </div>
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
                         ng-click="editAcceptanceTestDescription()"
                         ng-focus="editAcceptanceTestDescription()"
                         ng-class="{'placeholder': !editableAcceptanceTest.description_html}"
                         tabindex="0"
                         ng-bind-html="editableAcceptanceTest.description_html ? editableAcceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>'"></div>
                </div>
                <div class="btn-toolbar"
                     ng-if="formHolder.editing">
                    <button class="btn btn-primary float-right"
                            ng-disabled="!formHolder.acceptanceTestForm.$dirty || formHolder.acceptanceTestForm.$invalid || application.submitting"
                            ng-click="update(editableAcceptanceTest, selected)"
                            type="submit">
                        ${message(code: 'default.button.update.label')}
                    </button>
                    <button class="btn btn-secondary float-right"
                            ng-click="resetAcceptanceTestForm()"
                            type="button">
                        ${message(code: 'is.button.cancel')}
                    </button>
                </div>
            </form>
            <hr ng-if="!$last"/>
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
