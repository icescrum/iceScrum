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
<form ng-submit="submitForm(formType, acceptanceTest, selected)"
      show-validation>
    <div class="clearfix no-padding">
        <div class="col-md-6 form-group">
            <label>${message(code:'is.backlogelement.name')}</label>
            <input required
                   type="text"
                   ng-model="acceptanceTest.name"
                   focus-me="{{ getShowForm() }}"
                   class="form-control"
                   placeholder="${message(code: 'is.ui.backlogelement.noname')}">
        </div>
        <div class="col-md-6 form-group">
            <label>${message(code:'is.ui.acceptanceTest.state')}</label>
            <select class="form-control"
                    ng-model="acceptanceTest.state"
                    ng-readonly="stateReadOnly()"
                    ui-select2="selectAcceptanceTestStateOptions">
                <is:options values="${is.internationalizeValues(map: AcceptanceTestState.asMap())}" />
            </select>
        </div>
    </div>
    <div class="form-group">
        <label>${message(code:'is.backlogelement.description')}</label>
        <textarea is-markitup
                  class="form-control"
                  ng-model="acceptanceTest.description"
                  is-model-html="acceptanceTest.description_html"
                  ng-show="showDescriptionTextarea"
                  ng-blur="showDescriptionTextarea = false; (acceptanceTest.description.trim() != '${is.generateAcceptanceTestTemplate()}'.trim()) || (acceptanceTest.description = '')"
                  placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
        <div class="markitup-preview"
             ng-show="!showDescriptionTextarea"
             ng-click="showDescriptionTextarea = true"
             ng-focus="showDescriptionTextarea = true; acceptanceTest.description || (acceptanceTest.description = '${is.generateAcceptanceTestTemplate()}')"
             ng-class="{'placeholder': !acceptanceTest.description_html}"
             tabindex="0"
             ng-bind-html="(acceptanceTest.description_html ? acceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>') | sanitize"></div>
    </div>
    <div class="btn-toolbar pull-right">
        <button ng-if="formType == 'save'"
                class="btn btn-primary pull-right"
                tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                tooltip-append-to-body="true"
                type="submit">
            ${message(code:'todo.is.ui.save')}
        </button>
        <button ng-if="formType == 'update'"
                class="btn btn-primary pull-right"
                tooltip="${message(code:'todo.is.ui.update')} (RETURN)"
                tooltip-append-to-body="true"
                type="submit">
            ${message(code:'todo.is.ui.update')}
        </button>
        <button class="btn confirmation btn-default pull-right"
                tooltip-append-to-body="true"
                tooltip="${message(code:'is.button.cancel')} (ESCAPE)"
                type="button"
                ng-click="cancel()">
            ${message(code:'is.button.cancel')}
        </button>
    </div>
</form>
</script>
