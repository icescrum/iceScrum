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
<tr ng-show="selected.acceptanceTests === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="readOnlyAcceptanceTest in selected.acceptanceTests" ng-controller="acceptanceTestCtrl">
    <td>
        <div class="content">
            <div ng-show="!getShowForm()">
                <div class="pull-right">
                    <a href
                       class="btn btn-xs btn-primary"
                       role="button"
                       tooltip-placement="left"
                       tooltip="${message(code:'todo.is.ui.acceptanceTest.edit')}"
                       ng-if="!readOnly()"
                       ng-click="setShowForm(true)"><i class="fa fa-pencil"></i></a>
                    <a href
                       class="btn btn-xs btn-danger"
                       role="button"
                       tooltip-placement="left"
                       tooltip="${message(code:'todo.is.ui.acceptanceTest.delete')}"
                       ng-if="!readOnly()"
                       ng-click="delete(readOnlyAcceptanceTest, selected)"><i class="fa fa-times"></i></a>
                    <a href
                       class="btn btn-xs"
                       role="button"
                       ng-class="{${AcceptanceTestState.TOCHECK.id}:'btn-default', ${AcceptanceTestState.FAILED.id}:'btn-danger', ${AcceptanceTestState.SUCCESS.id}:'btn-success'}[readOnlyAcceptanceTest.state]"
                       ng-click="switchState(readOnlyAcceptanceTest, selected)"
                       tooltip-placement="left"
                       tooltip="${message(code:'todo.is.ui.acceptanceTest.state')}">
                        <i class="fa fa-check"/>
                    </a>
                </div>
                <div>
                    <span class="label label-default"
                          tooltip-placement="left"
                          tooltip="${message(code: 'is.backlogelement.id')}">{{ readOnlyAcceptanceTest.uid }}</span>
                    <strong>{{ readOnlyAcceptanceTest.name }}</strong>
                </div>
                <br/>
                <div ng-bind-html="readOnlyAcceptanceTest.description_html | sanitize"></div>
            </div>
            <div ng-include ng-show="getShowForm()" ng-init="formType='update'" src="'story.acceptanceTest.editor.html'"></div>
        </div>
    </td>
</tr>
<tr ng-show="!selected.acceptanceTests.length">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.acceptanceTest.empty')}</small>
    </td>
</tr>
</script>