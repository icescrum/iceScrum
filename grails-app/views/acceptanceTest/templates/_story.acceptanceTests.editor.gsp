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

<script type="text/ng-template" id="story.acceptanceTest.editor.html">
<table class="table" ng-init="showAcceptanceTestForm = false">
    <tbody>
    <tr>
        <td>
            <button class="btn btn-sm pull-right"
                    ng-class="{'btn-danger':showAcceptanceTestForm, 'btn-primary':!showAcceptanceTestForm}"
                    ng-click="$parent.showAcceptanceTestForm = !$parent.showAcceptanceTestForm"
                    tooltip="${message(code:'todo.is.ui.acceptanceTest.new')}"
                    tooltip-append-to-body="body">
                <span class="fa" ng-class="{'fa-times':showAcceptanceTestForm, 'fa-plus':!showAcceptanceTestForm}"></span>
            </button>
        </td>
    </tr>
    <tr ng-show="showAcceptanceTestForm">
        <td>
            <form ng-controller="acceptanceTestCtrl"
                  ng-submit="save(acceptanceTest, selected)"
                  show-validation>
                <div class="clearfix no-padding">
                    <div class="form-group col-sm-9">
                        <label>${message(code:'is.backlogelement.name')}</label>
                        <input required
                               type="text"
                               ng-model="acceptanceTest.name"
                               focus-me="{{ showAcceptanceTestForm }}"
                               class="form-control"
                               placeholder="${message(code: 'is.ui.backlogelement.noname')}">
                    </div>
                </div>
                <div class="form-group">
                    <label>${message(code:'is.backlogelement.description')}</label>
                    <textarea is-markitup
                              class="form-control"
                              ng-model="acceptanceTest.description"
                              ng-readonly="readOnly()"
                              is-model-html="acceptanceTest.description_html"
                              ng-show="showDescriptionTextarea"
                              ng-blur="showDescriptionTextarea = false"
                              placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
                    <div class="markitup-preview"
                         ng-show="!showDescriptionTextarea"
                         ng-click="showDescriptionTextarea = true"
                         ng-focus="showDescriptionTextarea = true"
                         ng-class="{'placeholder': !acceptanceTest.description_html}"
                         tabindex="0"
                         ng-bind-html="(acceptanceTest.description_html ? acceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>') | sanitize"></div>
                </div>
                <button class="btn btn-primary pull-right"
                        tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.save')}
                </button>
            </form>
        </td>
    </tr>
    </tbody>
</table>
</script>