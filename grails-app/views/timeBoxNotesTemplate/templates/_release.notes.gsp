%{--
- Copyright (c) 2017 Kagilum.
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
- Colin Bontemps (cbontemps@kagilum.com)
--}%

<script type="text/ng-template" id="timeBoxNotesTemplates.release.notes.html">
<div ng-controller="releaseNotesCtrl">
    <div class="panel-body">
        <div class="form-group">
            <label for="template">${message(code: 'todo.is.ui.release.notes.template')}</label>
            <div class="input-group">
                <ui-select class="form-control"
                           input-group-fix-width="38"
                           ng-change="computeReleaseNotes()"
                           name="template"
                           ng-model="template">
                    <ui-select-match
                            placeholder="${message(code: 'todo.is.ui.release.notes.noTemplate')}">{{ $select.selected.name }}</ui-select-match>
                    <ui-select-choices repeat="template in templates">
                        <span ng-bind-html="template.name"></span>
                    </ui-select-choices>
                </ui-select>
                <span class="input-group-btn" ng-if="template.id">
                    <button class="btn btn-default"
                            type="button"
                            name="edit-value"
                            ng-click="showEditTemplateModal(template)"><i class="fa fa-pencil"></i></button>
                </span>
            </div>
        </div>
        <hr>
        <div class="form-group">
            <label for="content">${message(code: 'todo.is.ui.release.notes.content')}</label>
            <textarea class="form-control fixedRow"
                      name="content"
                      ng-model="releaseNotes"
                      rows="15"
                      placeholder="${message(code: 'todo.is.ui.release.notes.noContent')}"
                      readonly>
            </textarea>
        </div>
    </div>
</div>
</script>