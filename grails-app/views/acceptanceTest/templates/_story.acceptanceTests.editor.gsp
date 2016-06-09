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

<script type="text/ng-template" id="story.acceptanceTest.editor.html">
<form ng-submit="save(editableAcceptanceTest, selected)"
      name="formHolder.acceptanceTestForm"
        class="form-editable form-editing"
      show-validation
      novalidate>
    <div class="clearfix no-padding">
        <div class="col-sm-8 form-group">
            <div class="input-group">
                <span class="input-group-addon">42</span>
                <input required
                       type="text"
                       ng-maxlength="255"
                       name="name"
                       ng-model="editableAcceptanceTest.name"
                       autofocus
                       class="form-control"
                       placeholder="${message(code: 'is.ui.backlogelement.noname')}">
            </div>
        </div>
        <div class="col-sm-4 form-group">
            <ui-select class="form-control"
                       name="state"
                       ng-model="editableAcceptanceTest.state"
                       ng-disabled="!authorizedAcceptanceTest('updateState', editableAcceptanceTest)">
                <ui-select-match>
                    <span ng-class="'text-'+($select.selected | acceptanceTestColor)"><i class='fa fa-check'></i> {{ $select.selected | i18n:'AcceptanceTestStates' }}</span>
                </ui-select-match>
                <ui-select-choices repeat="acceptanceTestState in acceptanceTestStates">
                    <span ng-class="'text-'+(acceptanceTestState | acceptanceTestColor)"><i class='fa fa-check'></i> {{ acceptanceTestState | i18n:'AcceptanceTestStates' }}</span>
                </ui-select-choices>
            </ui-select>
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
    <div class="btn-toolbar">
        <button class="btn btn-primary pull-right"
                ng-disabled="!formHolder.acceptanceTestForm.$dirty || formHolder.acceptanceTestForm.$invalid"
                type="submit">
            ${message(code:'default.button.create.label')}
        </button>
    </div>
</form>
</script>
