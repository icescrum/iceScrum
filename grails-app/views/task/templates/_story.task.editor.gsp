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
      name="formHolder.taskForm"
      ng-class="['form-editable form-editing', formHolder.formExpanded ? 'form-expanded' : 'form-not-expanded']"
      show-validation
      novalidate>
    <div class="clearfix no-padding">
        <div class="form-group" ng-class="formHolder.formExpanded ? 'col-sm-8' : 'col-sm-12'" ng-click="formHolder.formExpanded = true;">
            <div ng-class="{'input-group': !formHolder.formExpanded}">
                <input required
                       ng-maxlength="100"
                       type="text"
                       name="name"
                       ng-model="task.name"
                       ng-focus="formHolder.formExpanded = true;"
                       placeholder="${message(code: 'is.ui.task.noname')}"
                       class="form-control">
                <span class="input-group-btn visible-hidden">
                    <button class="btn btn-primary" type="button" ng-click="formHolder.formExpanded = true;"><i class="fa fa-plus"></i></button>
                </span>
            </div>
        </div>
        <div class="form-group col-sm-4 hidden-not-expanded">
            <input name="estimation"
                   ng-model="task.estimation"
                   type="number"
                   min="0"
                   step="any"
                   ng-blur="formHolder.formExpanded = task.name || task.description || task.estimation;"
                   placeholder="${message(code: 'is.task.estimation')}"
                   class="form-control text-right">
        </div>
    </div>
    <div class="form-group hidden-not-expanded">
        <textarea at
                  name="description"
                  ng-model="task.description"
                  ng-maxlength="3000"
                  placeholder="${message(code: 'is.backlogelement.description')}"
                  class="form-control"></textarea>
    </div>
    <div class="btn-toolbar">
        <button class="btn btn-primary pull-right"
                ng-disabled="!formHolder.taskForm.$dirty || formHolder.taskForm.$invalid || application.submitting"
                type="submit">
            ${message(code: 'default.button.create.label')}
        </button>
        <button class="btn btn-default pull-right"
                ng-click="formHolder.formExpanded = false;"
                type="button">
            ${message(code: 'is.button.cancel')}
        </button>
    </div>
</form>
</script>