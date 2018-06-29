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

<script type="text/ng-template" id="task.estimation.html">
<is:modal form="submit(editableTask)"
          submitButton="${message(code: 'default.button.update.label')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.task.estimation')}">
    <entry:point id="task-estimation-before"/>
    <div class="form-group">
        <label for="estimation">${message(code: 'is.task.estimation')}</label>
        <div class="input-group minus-plus-group">
            <span class="input-group-btn">
                <button class="btn btn-default"
                        type="button"
                        ng-click="editableTask.estimation = minus(editableTask.estimation);">
                    <i class="fa fa-minus"></i>
                </button>
            </span>
            <input type="number"
                   class="form-control"
                   autofocus
                   name="estimation"
                   min="0"
                   ng-model="editableTask.estimation"/>
            <span class="input-group-btn">
                <button class="btn btn-default"
                        type="button"
                        ng-click="editableTask.estimation = plus(editableTask.estimation);">
                    <i class="fa fa-plus"></i>
                </button>
            </span>
        </div>
    </div>
</is:modal>
</script>
