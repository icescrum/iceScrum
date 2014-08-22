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

<script type="text/ng-template" id="story.acceptanceTest.editor.html">
<form ng-submit="saveOrUpdate(formType, editableAcceptanceTest, selected)"
      name="formHolder.acceptanceTestForm"
      show-validation
      novalidate>
    <div class="clearfix no-padding">
        <div class="col-md-6 form-group">
            <label>${message(code:'is.backlogelement.name')}</label>
            <input required
                   type="text"
                   ng-model="editableAcceptanceTest.name"
                   focus-me="{{ getShowAcceptanceTestForm() }}"
                   class="form-control"
                   placeholder="${message(code: 'is.ui.backlogelement.noname')}">
        </div>
        <div class="col-md-6 form-group">
            <label>${message(code:'is.ui.acceptanceTest.state')}</label>
            <select class="form-control"
                    ng-model="editableAcceptanceTest.state"
                    ng-readonly="!authorizedAcceptanceTest('updateState', editableAcceptanceTest)"
                    ui-select2="selectAcceptanceTestStateOptions">
                <is:options values="${is.internationalizeValues(map: AcceptanceTestState.asMap())}" />
            </select>
        </div>
    </div>
    <div class="form-group">
        <label>${message(code:'is.backlogelement.description')}</label>
        <textarea is-markitup
                  class="form-control"
                  ng-model="editableAcceptanceTest.description"
                  is-model-html="editableAcceptanceTest.description_html"
                  ng-show="showDescriptionTextarea"
                  ng-blur="showDescriptionTextarea = false; (editableAcceptanceTest.description.trim() != '${is.generateAcceptanceTestTemplate()}'.trim()) || (editableAcceptanceTest.description = '')"
                  placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
        <div class="markitup-preview"
             ng-show="!showDescriptionTextarea"
             ng-click="showDescriptionTextarea = true"
             ng-focus="showDescriptionTextarea = true; editableAcceptanceTest.description || (editableAcceptanceTest.description = '${is.generateAcceptanceTestTemplate()}')"
             ng-class="{'placeholder': !editableAcceptanceTest.description_html}"
             tabindex="0"
             ng-bind-html="(editableAcceptanceTest.description_html ? editableAcceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>') | sanitize"></div>
    </div>
    <div class="btn-toolbar pull-right">
        <button ng-if="formType == 'save'"
                class="btn btn-primary pull-right"
                ng-class="{ disabled: !formHolder.acceptanceTestForm.$dirty || formHolder.acceptanceTestForm.$invalid }"
                tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                tooltip-append-to-body="true"
                type="submit">
            ${message(code:'todo.is.ui.save')}
        </button>
        <button ng-if="formType == 'update'"
                class="btn btn-primary pull-right"
                ng-class="{ disabled: !formHolder.acceptanceTestForm.$dirty || formHolder.acceptanceTestForm.$invalid }"
                tooltip="${message(code:'todo.is.ui.update')} (RETURN)"
                tooltip-append-to-body="true"
                type="submit">
            ${message(code:'todo.is.ui.update')}
        </button>
        <button class="btn confirmation btn-default pull-right"
                tooltip-append-to-body="true"
                tooltip="${message(code:'is.button.cancel')} (ESCAPE)"
                type="button"
                ng-click="resetAcceptanceTestForm()">
            ${message(code:'is.button.cancel')}
        </button>
    </div>
</form>
</script>
