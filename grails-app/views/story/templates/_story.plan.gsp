%{--
- Copyright (c) 2018 Kagilum.
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
<script type="text/ng-template" id="story.plan.html">
<is:modal form="submit(holder.parentSprint)"
          name="formHolder.storyPlanForm"
          validate="true"
          submitButton="${message(code: 'default.button.update.label')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'todo.is.ui.story.plan')}">
    <div>
        <label for="parentSprint"><i class="fa fa-tasks"></i> ${message(code: 'is.sprint')}</label>
        <ui-select ng-show="hasSprint()"
                   class="form-control"
                   name="parentSprint"
                   search-enabled="true"
                   required
                   ng-model="holder.parentSprint">
            <ui-select-match placeholder="${message(code: 'is.ui.story.noparentsprint')}">
                {{ $select.selected | sprintNameWithState }}
            </ui-select-match>
            <ui-select-choices group-by="'parentReleaseName'" repeat="parentSprintEntry in parentSprintEntries | filter: { index: $select.search }">
                <span ng-bind-html="parentSprintEntry | sprintNameWithState | highlight: $select.search"></span>
            </ui-select-choices>
        </ui-select>
        <a ng-if="!hasSprint()"
           ui-sref="planning"
           ng-click="$close()"
           class="btn btn-primary"
           role="button"
           tabindex="0">
            ${message(code: 'todo.is.ui.sprint.new')}
        </a>
    </div>
</is:modal>
</script>
