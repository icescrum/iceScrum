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
<form ng-submit="save(editableAcceptanceTest, getSelected())"
      name="formHolder.acceptanceTestForm"
      show-validation
      novalidate>
    <div class="clearfix no-padding">
        <div class="col-sm-1">
            <p class="elemid form-control-static">42</p>
        </div>
        <div class="col-sm-8 form-group">
            <input required
                   type="text"
                   ng-maxlength="255"
                   name="name"
                   ng-model="editableAcceptanceTest.name"
                   class="form-control"
                   placeholder="${message(code: 'is.ui.backlogelement.noname')}">
        </div>
        <div class="col-sm-3 form-group">
            <select class="form-control"
                    name="state"
                    ng-model="editableAcceptanceTest.state"
                    ng-readonly="!authorizedAcceptanceTest('updateState', editableAcceptanceTest)"
                    ui-select2="selectAcceptanceTestStateOptions">
                <is:options values="${is.internationalizeValues(map: AcceptanceTestState.asMap())}" />
            </select>
        </div>
    </div>
    <div class="form-group">
        <textarea is-markitup
                  msd-elastic
                  class="form-control"
                  ng-maxlength="1000"
                  name="description"
                  ng-model="editableAcceptanceTest.description"
                  is-model-html="editableAcceptanceTest.description_html"
                  ng-show="showAcceptanceTestDescriptionTextarea"
                  ng-blur="showAcceptanceTestDescriptionTextarea = false; (editableAcceptanceTest.description.trim() != '${is.generateAcceptanceTestTemplate()}'.trim()) || (editableAcceptanceTest.description = '')"
                  placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"></textarea>
        <div class="markitup-preview"
             ng-show="!showAcceptanceTestDescriptionTextarea"
             ng-click="showAcceptanceTestDescriptionTextarea = true"
             ng-focus="showAcceptanceTestDescriptionTextarea = true; editableAcceptanceTest.description || (editableAcceptanceTest.description = '${is.generateAcceptanceTestTemplate()}')"
             ng-class="{'placeholder': !editableAcceptanceTest.description_html}"
             tabindex="0"
             ng-bind-html="(editableAcceptanceTest.description_html ? editableAcceptanceTest.description_html : '<p>${message(code: 'is.ui.backlogelement.nodescription')}</p>') | sanitize"></div>
    </div>
    <div class="btn-toolbar pull-right">
        <button class="btn btn-primary pull-right"
                ng-disabled="!formHolder.acceptanceTestForm.$dirty || formHolder.acceptanceTestForm.$invalid"
                tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                tooltip-append-to-body="true"
                type="submit">
            ${message(code:'todo.is.ui.save')}
        </button>
    </div>
</form>
</script>
