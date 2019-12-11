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
<script type="text/ng-template" id="story.tasks.html">
<div class="card-body story-tasks" ng-controller="taskSortableStoryCtrl">
    <div ng-repeat="taskEntry in tasksByState"
         class="mb-5">
        <h5 class="text-center mb-3"
            ng-class="::{ 'mt-2':!$first }"
            ng-bind-html="taskEntry.label">
        </h5>
        <div is-disabled="!isTaskSortableByState(taskEntry.state)"
             as-sortable="taskSortableOptions | merge: sortableScrollOptions()"
             ng-model="taskEntry.tasks">
            <div class="story-task font-size-sm" ng-repeat="task in taskEntry.tasks" as-sortable-item>
                <div class="row align-items-baseline">
                    <div class="col-sm-8">
                        <span class="mr-1" ng-if="isTaskSortableByState(taskEntry.state)" as-sortable-item-handle>{{:: task.uid }}</span>
                        <span class="mr-1" ng-if="!isTaskSortableByState(taskEntry.state)">{{:: task.uid }}</span>
                        <a class="text-accent" ui-sref=".task.details({taskId: task.id})">{{ task.name }}</a>
                    </div>
                    <div class="col-sm-4 d-flex justify-content-between align-items-baseline" ng-controller="taskCtrl">
                        <span class="state-title state-title-small mr-2">
                            <span class="state-dot" ng-class="'task-state-dot-' + task.state"></span>
                            <span class="d-none d-xl-block text-nowrap">{{ (task.state | i18n: 'TaskStates') }}</span>
                        </span>
                        <div class="btn-menu" uib-dropdown>
                            <shortcut-menu ng-model="task" model-menus="menus" view-type="'list'" btn-sm="true" btn-secondary="true"></shortcut-menu>
                            <div uib-dropdown-toggle></div>
                            <div uib-dropdown-menu ng-init="itemType = 'task'" template-url="item.menu.html"></div>
                        </div>
                    </div>
                </div>
                <div ng-if="task.description">
                    <p class="description form-control-plaintext" ng-bind-html="task.description | lineReturns"></p>
                </div>
                <hr ng-if="!$last" class="w-50 mt-2"/>
            </div>
        </div>
    </div>
    <div class="form-text text-center"
         ng-if="selected.tasks !== undefined && !selected.tasks.length">
        ${message(code: 'is.ui.task.help.story')}
        <documentation doc-url="features-stories-tasks#tasks"/>
    </div>
</div>
<div class="card-footer"
     ng-if="authorizedTask('create', {parentStory: selected})"
     ng-controller="taskStoryCtrl">
    <div ng-include="'story.task.new.html'"></div>
</div>
</script>