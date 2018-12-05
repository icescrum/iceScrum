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
<div class="tasks card-body" ng-controller="taskSortableStoryCtrl">
    <table class="table" ng-repeat="(taskState, tasks) in tasksByState">
        <thead>
            <tr>
                <th style="border-top: 0; border-bottom: 0; padding:0">
                    <div class="text-center" style="margin-top:30px;margin-bottom:10px;font-size:15px;">
                        {{ (taskState | i18n: 'TaskStates') + ' (' + tasks.length + ')' }}
                    </div>
                </th>
            </tr>
        </thead>
        <tbody style="border-top: 0;"
               is-disabled="!isTaskSortableByState(taskState)"
               as-sortable="taskSortableOptions | merge: sortableScrollOptions()"
               ng-model="tasks">
            <tr class="task-for-story" ng-repeat="task in tasks" as-sortable-item>
                <td class="content">
                    <div class="clearfix no-padding">
                        <div class="col-sm-8">
                            <span class="name">
                                <i class="fa fa-drag-handle" ng-if="isTaskSortableByState(taskState)" as-sortable-item-handle></i>
                                <a ui-sref=".task.details({taskId: task.id})" class="link">
                                    <strong>{{:: task.uid }}</strong>&nbsp;&nbsp;{{ task.name }}
                                </a>
                            </span>
                        </div>
                        <div class="col-sm-4 text-right" ng-controller="taskCtrl">
                            <div class="btn-group">
                                <shortcut-menu ng-model="task" model-menus="menus" view-type="'list'" btn-sm="true"></shortcut-menu>
                                <div class="btn-group btn-group-sm" uib-dropdown>
                                    <button type="button" class="btn btn-secondary" uib-dropdown-toggle>
                                    </button>
                                    <ul uib-dropdown-menu class="pull-right" ng-init="itemType = 'task'" template-url="item.menu.html"></ul>
                                </div>
                                <visual-states ng-model="task" model-states="taskStatesByName"/>
                            </div>
                        </div>
                    </div>
                    <div class="clearfix no-padding" ng-if="task.description">
                        <p class="description form-control-static" ng-bind-html="task.description | lineReturns"></p>
                    </div>
                    <hr ng-if="!$last"/>
                </td>
            </tr>
        </tbody>
    </table>
    <div class="form-text text-center"
         ng-if="selected.tasks !== undefined && !selected.tasks.length">
        ${message(code: 'is.ui.task.help.story')}
        <documentation doc-url="features-stories-tasks#tasks"/>
    </div>
</div>
<div class="card-footer" ng-controller="taskStoryCtrl">
    <div ng-if="authorizedTask('create', {parentStory: selected})" ng-include="'story.task.new.html'"></div>
</div>
</script>