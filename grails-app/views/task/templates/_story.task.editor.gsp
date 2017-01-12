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

<script type="text/ng-template" id="story.task.new.html">
    <form ng-submit="save(task, selected)"
          class="form-editable form-editing"
          name="formHolder.taskForm"
          show-validation
          novalidate>
        <div class="clearfix no-padding">
            <div class="form-group col-sm-8">
                <input required
                       ng-maxlength="100"
                       type="text"
                       name="name"
                       ng-model="task.name"
                       autofocus
                       placeholder="${message(code: 'is.ui.task.noname')}"
                       class="form-control">
            </div>
            <div class="form-group col-sm-4">
                <input name="estimation"
                       ng-model="task.estimation"
                       type="number"
                       step="any"
                       placeholder="${message(code: 'is.task.estimation')}"
                       class="form-control text-right">
            </div>
        </div>
        <div class="form-group">
            <textarea name="description"
                      ng-model="task.description"
                      ng-maxlength="3000"
                      placeholder="${message(code: 'is.backlogelement.description')}"
                      class="form-control"></textarea>
        </div>
        <div class="btn-toolbar">
            <button class="btn btn-primary pull-right"
                    ng-disabled="!formHolder.taskForm.$dirty || formHolder.taskForm.$invalid"
                    type="submit">
                ${message(code:'default.button.create.label')}
            </button>
        </div>
    </form>
</script>