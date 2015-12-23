%{--
- Copyright (c) 2015 Kagilum SAS
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

<div class="panel panel-light"
     ng-class="{'sortable-disabled': !isSortingSprintPlan(sprint)}">
    <div class="panel-heading">
        <h3 class="panel-title">
            <a href ng-click="openSprint()">
                {{ sprint.parentRelease.name + ' ' + sprint.orderNumber }}
            </a>
            <div class="btn-group pull-right visible-on-hover">
                <g:if test="${params?.printable}">
                    <button type="button"
                            class="btn btn-default"
                            uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                            ng-click="print($event)"
                            ng-href="{{ ::viewName }}/print"
                            hotkey="{'P': hotkeyClick }"><span class="fa fa-print"></span>
                    </button>
                </g:if>
                <g:if test="${params?.fullScreen}">
                    <button type="button"
                            class="btn btn-default"
                            ng-show="!app.isFullScreen"
                            ng-click="fullScreen()"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                            hotkey="{'F': fullScreen }"><span class="fa fa-expand"></span>
                    </button>
                    <button type="button"
                            class="btn btn-default"
                            ng-show="app.isFullScreen"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')}"
                            ng-click="fullScreen()"><span class="fa fa-compress"></span>
                    </button>
                </g:if>
            </div>
        </h3>
    </div>
    <table class="panel-body table">
        <thead>
            <tr>
                <th style="width:16%; text-align:center;">
                    Type
                </th>
                <th style="width:28%; text-align:center;">
                    <span>${message(code: 'is.task.state.wait')}</span>
                </th>
                <th style="width:28%; text-align:center;">
                    <span>${message(code: 'is.task.state.inprogress')}</span>
                </th>
                <th style="width:28%; text-align:center;">
                    <span>${message(code: 'is.task.state.done')}</span>
                </th>
            </tr>
        </thead>
        <tbody ng-controller="taskSprintCtrl">
            <tr>
                <td style="width:16%">
                    ${message(code: 'is.ui.sprintPlan.kanban.urgentTasks')}
                </td>
                <td style="width:28%"
                    class="postits grid-group"
                    ng-model="tasksByTypeByState[11][taskState]"
                    ng-init="taskType = 11"
                    as-sortable="taskSortableOptions | merge: sortableScrollOptions('tbody')"
                    is-disabled="!isSortingSprintPlan(sprint)"
                    ng-repeat="taskState in taskStates">
                    <div ng-repeat="task in tasksByTypeByState[11][taskState]"
                         as-sortable-item
                         class="postit-container">
                        <div ng-include="'task.html'"></div>
                    </div>
                    <div class="postit-container">
                        <a type="button"
                           ng-if="taskState == 0"
                           class="btn btn-primary"
                           ng-click="openNewTaskByType(11)"
                           href>
                            <i class="fa fa-plus"></i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr>
                <td style="width:16%">
                    ${message(code: 'is.ui.sprintPlan.kanban.recurrentTasks')}
                </td>
                <td style="width:28%"
                    class="postits grid-group"
                    ng-model="tasksByTypeByState[10][taskState]"
                    ng-init="taskType = 10"
                    as-sortable="taskSortableOptions | merge: sortableScrollOptions('tbody')"
                    is-disabled="!isSortingSprintPlan(sprint)"
                    ng-repeat="taskState in taskStates">
                    <div ng-repeat="task in tasksByTypeByState[10][taskState]"
                         as-sortable-item
                         class="postit-container">
                        <div ng-include="'task.html'"></div>
                    </div>
                    <div class="postit-container">
                        <a type="button"
                           ng-if="taskState == 0"
                           ng-click="openNewTaskByType(10)"
                           class="btn btn-primary "
                           href>
                            <i class="fa fa-plus"></i>
                        </a>
                    </div>
                </td>
            </tr>
            <tr ng-repeat="story in backlog.stories"
                ng-class="{'sortable-disabled': !isSortingStory(story)}">
                <td style="width:16%"
                    class="postits grid-group"
                    ng-controller="storyCtrl">
                    <div class="postit-container">
                        <div ng-include="'story.html'"></div>
                    </div>
                </td>
                <td style="width:28%"
                    class="postits grid-group"
                    ng-model="tasksByStoryByState[story.id][taskState]"
                    as-sortable="taskSortableOptions | merge: sortableScrollOptions('tbody')"
                    is-disabled="!isSortingSprintPlan(sprint) || !isSortingStory(story)"
                    ng-repeat="taskState in taskStates">
                    <div ng-repeat="task in tasksByStoryByState[story.id][taskState]"
                         as-sortable-item
                         class="postit-container">
                        <div ng-include="'task.html'"></div>
                    </div>
                    <div class="postit-container">
                        <a type="button"
                           ng-click="openNewTaskByStory(story)"
                           ng-if="taskState == 0"
                           class="btn btn-primary"
                           href>
                            <i class="fa fa-plus"></i>
                        </a>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
</div>