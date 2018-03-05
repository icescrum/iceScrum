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
<div class="tasks panel-body" ng-controller="taskSortableStoryCtrl">
    <table class="table" as-sortable="taskSortableOptions | merge: sortableScrollOptions()" ng-model="tasks">
        <tr class="task-for-story" ng-repeat="task in tasks" as-sortable-item>
            <td class="content">
                <div class="clearfix no-padding">
                    <div class="col-sm-8">
                        <span class="name">
                            <span as-sortable-item-handle="authorizedTask('rank', task) && task.state == 0">=</span>
                            <a ui-sref=".task.details({taskId: task.id})"
                               class="link"><strong>{{:: task.uid }}</strong>&nbsp;&nbsp;{{ task.name }}</a>
                        </span>
                    </div>
                    <div class="col-sm-4 text-right" ng-controller="taskCtrl">
                        <div class="btn-group">
                            <shortcut-menu ng-model="task" model-menus="menus" view-type="'list'" btn-sm="true"></shortcut-menu>
                            <div class="btn-group btn-group-sm" uib-dropdown>
                                <button type="button" class="btn btn-default" uib-dropdown-toggle>
                                    <i class="fa fa-caret-down"></i>
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
        <tr ng-show="selected.tasks !== undefined && !selected.tasks.length">
            <td class="empty-content">
                <small>${message(code: 'todo.is.ui.task.empty')}</small>
            </td>
        </tr>
    </table>
</div>
<div class="panel-footer" ng-controller="taskStoryCtrl">
    <div ng-if="authorizedTask('create', {parentStory: selected})" ng-include="'story.task.new.html'"></div>
</div>
</script>