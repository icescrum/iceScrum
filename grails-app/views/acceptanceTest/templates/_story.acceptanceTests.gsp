<%@ page import="org.icescrum.core.domain.AcceptanceTest.AcceptanceTestState" %>
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
<script type="text/ng-template" id="story.acceptanceTests.html">
<tr ng-show="story.acceptanceTests === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="readOnlyAcceptanceTest in story.acceptanceTests | orderBy:'dateCreated'" ng-controller="acceptanceTestCtrl">
    <td>
        <div class="content">
            <div ng-show="!getShowForm()">
                <div class="pull-right">
                    <button class="btn btn-xs btn-primary"
                            type="button"
                            tooltip-placement="left"
                            tooltip="${message(code:'todo.is.ui.acceptanceTest.edit')}"
                            ng-if="!readOnly()"
                            ng-click="setShowForm(true)"><span class="fa fa-pencil"></span></button>
                    <button class="btn btn-xs btn-danger"
                            type="button"
                            tooltip-placement="left"
                            tooltip="${message(code:'todo.is.ui.acceptanceTest.delete')}"
                            ng-if="!readOnly()"
                            ng-click="confirm('${message(code: 'is.confirm.delete')}', delete, [readOnlyAcceptanceTest, story])"><span class="fa fa-times"></span></button>
                </div>
                <div>
                    <span class="label label-default"
                          tooltip-placement="left"
                          tooltip="${message(code: 'is.backlogelement.id')}">{{ readOnlyAcceptanceTest.uid }}</span>
                    <strong>{{ readOnlyAcceptanceTest.name }}</strong>
                </div>
                <select ng-model="readOnlyAcceptanceTest.state"
                        ng-readonly="stateReadOnly()"
                        ng-change="switchState(readOnlyAcceptanceTest, story)"
                        ui-select2="selectAcceptanceTestStateOptions">
                    <is:options values="${is.internationalizeValues(map: AcceptanceTestState.asMap())}" />
                </select>
                <div ng-bind-html="readOnlyAcceptanceTest.description_html | sanitize"></div>
            </div>
            <div ng-include="'story.acceptanceTest.editor.html'" ng-show="getShowForm()" ng-init="formType='update'"></div>
        </div>
    </td>
</tr>
<tr ng-show="!story.acceptanceTests.length">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.acceptanceTest.empty')}</small>
    </td>
</tr>
</script>