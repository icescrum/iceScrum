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
<div class="acceptanceTests panel-body">
    <table class="table">
        <tr ng-repeat="acceptanceTest in selected.acceptanceTests | orderBy:'dateCreated'" ng-controller="acceptanceTestCtrl">
            <td class="content">
                <form name="formHolder.acceptanceTestForm"
                      ng-class="{ 'form-editing': formHolder.editing, 'form-editable': formEditable() }"
                      show-validation
                      novalidate>
                    <div class="clearfix no-padding form-group">
                        <div class="col-sm-7">
                            <div class="input-group">
                                <span class="input-group-addon no-style"><strong>{{ editableAcceptanceTest.uid }}</strong></span>
                                <input required
                                       ng-maxlength="255"
                                       ng-focus="editForm(true)"
                                       ng-blur="update(editableAcceptanceTest, selected)"
                                       type="text"
                                       name="name"
                                       ng-model="editableAcceptanceTest.name"
                                       class="form-control"
                                       placeholder="${message(code: 'is.ui.backlogelement.noname')}">
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <ui-select class="form-control"
                                       ng-click="editForm(true)"
                                       on-select="update(editableAcceptanceTest, selected)"
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
                                <button type="button" class="btn btn-default" uib-dropdown-toggle>
                                    <i class="fa fa-ellipsis-h"></i> <i class="fa fa-caret-down"></i>
                                </button>
                                <ul uib-dropdown-menu class="pull-right">
                                    <li>
                                        <a href ng-click="showAcceptanceTestDescriptionTextarea = true;">
                                            ${message(code:'is.ui.backlogelement.comment.edit')}
                                        </a>
                                    </li>
                                    <li>
                                        <a href ng-click="confirmDelete({ callback: delete, args: [acceptanceTest, selected] })">
                                            ${message(code:'default.button.delete.label')}
                                        </a>
                                    </li>
                                </ul>
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
                                  ng-blur="update(editableAcceptanceTest, selected); blurAcceptanceTestDescription()"
                                  placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
                        <div class="markitup-preview important"
                             ng-show="!showAcceptanceTestDescriptionTextarea"
                             ng-click="editForm(true); showAcceptanceTestDescriptionTextarea = true"
                             ng-focus="editForm(true); focusAcceptanceTestDescription()"
                             ng-class="{'placeholder': !editableAcceptanceTest.description_html}"
                             tabindex="0"
                             ng-bind-html="editableAcceptanceTest.description_html ? editableAcceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>'"></div>
                    </div>
                </form>
                <hr ng-if="!$last"/>
            </td>
        </tr>
        <tr ng-show="selected.acceptanceTests !== undefined && !selected.acceptanceTests.length">
            <td class="empty-content">
                <small>${message(code:'todo.is.ui.acceptanceTest.empty')}</small>
            </td>
        </tr>
    </table>
</div>
<div class="panel-footer" ng-controller="acceptanceTestCtrl">
    <div ng-if="authorizedAcceptanceTest('create', selected)" ng-include="'story.acceptanceTest.editor.html'"></div>
</div>
</script>
