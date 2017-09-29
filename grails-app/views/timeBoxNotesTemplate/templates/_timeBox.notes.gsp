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

<script type="text/ng-template" id="timeBoxNotesTemplates.timeBox.notes.html">
<div ng-controller="timeBoxNotesCtrl as ctrl">
    <div class="panel-body timeBoxNotes">
        <div class="form-group">
            <label for="select-template">{{message('todo.is.ui.'+timeBoxClass+'.notes.template')}}</label>
            <div class="input-group">
                <ui-select class="form-control"
                           ng-change="computeTimeBoxNotes()"
                           name="select-template"
                           ng-model="ctrl.template">
                    <ui-select-match
                            placeholder="${message(code: 'todo.is.ui.timeBox.notes.noTemplate')}">
                        {{ $select.selected.id }} - {{ $select.selected.name }}
                    </ui-select-match>
                    <ui-select-choices repeat="item in templates track by item.id">
                        {{:: item.id }} - {{ item.name }}
                    </ui-select-choices>
                </ui-select>
                <span class="input-group-btn">
                    <button class="btn btn-default"
                            type="button"
                            name="new"
                            ng-click="showNewTemplateModal()">
                        ${message(code: 'todo.is.ui.timeBox.notes.new')}
                    </button>
                </span>
            </div>
        </div>
        <hr>
        <div class="form-group">
            <div class="clearfix">
                <div class="pull-left">
                    <label for="content">{{message('todo.is.ui.'+timeBoxClass+'.notes.content')}}</label>
                </div>
                <button class="btn btn-default btn-sm pull-right"
                        ng-if="ctrl.template.id"
                        type="button"
                        name="edit"
                        ng-click="showEditTemplateModal(ctrl.template)">
                    <i class="fa fa-pencil"></i>
                </button>
            </div>
            <textarea class="form-control fixedRow"
                      select-on-focus
                      name="content"
                      ng-model="timeBoxNotes"
                      rows="15"
                      placeholder="${message(code: 'todo.is.ui.timeBox.notes.noContent')}"
                      readonly>
            </textarea>
        </div>
    </div>
</div>
</script>