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
<tr>
    <td>
        <form ng-submit="save(task, selected)"
              name="formHolder.taskForm"
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="col-sm-1">
                    <button class="btn btn-default elemid" disabled="disabled">42</button>
                </div>
                <div class="form-group col-sm-8">
                    <input required
                           ng-maxlength="100"
                           type="text"
                           name="name"
                           ng-model="task.name"
                           placeholder="${message(code: 'is.ui.backlogelement.noname')}"
                           class="form-control">
                </div>
                <div class="form-group col-sm-3">
                    <input name="estimation"
                           ng-model="task.estimation"
                           type="number"
                           step="any"
                           placeholder="${message(code: 'todo.is.ui.task.noestimate')}"
                           class="form-control text-right">
                </div>
            </div>
            <div class="form-group">
                <textarea name="description"
                          ng-model="task.description"
                          msd-elastic
                          ng-maxlength="3000"
                          placeholder="${message(code: 'is.ui.backlogelement.nodescription')}"
                          class="form-control"></textarea>
            </div>
            <div class="btn-toolbar pull-right">
                <button class="btn btn-primary pull-right"
                        ng-disabled="!formHolder.taskForm.$dirty || formHolder.taskForm.$invalid"
                        tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.save')}
                </button>
            </div>
        </form>
    </td>
</tr>
</script>