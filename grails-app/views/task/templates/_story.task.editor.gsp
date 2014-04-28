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
--}%

<script type="text/ng-template" id="story.task.new.html">
<table class="table" ng-init="showTaskForm = false">
    <tbody>
    <tr>
        <td>
            <button class="btn btn-sm pull-right"
                    ng-class="{'btn-danger':showTaskForm, 'btn-primary':!showTaskForm}"
                    ng-click="$parent.showTaskForm = !$parent.showTaskForm"
                    tooltip="${message(code:'todo.is.ui.task.new')}"
                    tooltip-append-to-body="body">
                <span class="fa" ng-class="{'fa-times':showTaskForm, 'fa-plus':!showTaskForm}"></span>
            </button>
        </td>
    </tr>
    <tr ng-show="showTaskForm">
        <td>
            <form ng-controller="taskCtrl" ng-submit="save(task, selected)">
                <div class="clearfix no-padding">
                    <div class="form-group col-sm-9">
                        <label>${message(code:'is.backlogelement.name')}</label>
                        <input required
                               type="text"
                               ng-model="task.name"
                               class="form-control">
                    </div>
                    <div class="form-group col-sm-3">
                        <label>${message(code:'is.task.estimation')}</label>
                        <input ng-model="task.estimation"
                               type="number"
                               step="any"
                               pattern="[0-9]+([\.|,][0-9]+)?"
                               class="form-control">
                    </div>
                </div>
                <div class="form-group">
                    <label>${message(code:'is.backlogelement.description')}</label>
                    <textarea ng-model="task.description" style="min-height:50px;" class="form-control"></textarea>
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