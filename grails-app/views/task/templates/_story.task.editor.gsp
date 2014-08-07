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
<table class="table">
    <tbody>
    <tr>
        <td ng-switch="showForm">
            <button ng-switch-default
                    class="btn btn-sm btn-primary pull-right"
                    type="button"
                    ng-click="setShowForm(true)"
                    tooltip="${message(code:'todo.is.ui.task.new')}"
                    tooltip-placement="left"
                    tooltip-append-to-body="body">
                <span class="fa fa-plus"></span>
            </button>
            <button ng-switch-when="true"
                    class="btn btn-sm btn-default pull-right"
                    type="button"
                    ng-click="setShowForm(false)"
                    tooltip="${message(code:'todo.is.ui.hide')}"
                    tooltip-placement="left"
                    tooltip-append-to-body="body">
                <span class="fa fa-minus"></span>
            </button>
        </td>
    </tr>
    <tr ng-show="showForm">
        <td>
            <form show-validation
                  ng-submit="save(task, selected)">
                <div class="clearfix no-padding">
                    <div class="form-group col-sm-9">
                        <label>${message(code:'is.backlogelement.name')}</label>
                        <input required
                               type="text"
                               focus-me="{{ showForm }}"
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
                <div class="btn-toolbar pull-right">
                    <button class="btn btn-primary pull-right"
                            tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                            tooltip-append-to-body="true"
                            type="submit">
                        ${message(code:'todo.is.ui.save')}
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
        </td>
    </tr>
    </tbody>
</table>
</script>