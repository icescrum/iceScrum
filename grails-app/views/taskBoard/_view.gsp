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
     ng-class="{'sortable-disabled': !isSortingTaskBoard(sprint), 'sprint-not-done': sprint.state != 3}">
    <div class="panel-heading">
        <h3 class="panel-title">
            <div class="btn-toolbar">
                <a href="{{ ::urlOpenSprint(sprint) }}">
                    {{ sprint.parentRelease.name + ' - ${message(code: 'is.sprint')} ' + sprint.orderNumber }}
                </a>
                <div class="btn-group pull-right"
                     uib-dropdown>
                    <button type="button"
                            ng-if="isSortableTaskBoard(sprint)"
                            class="btn btn-default"
                            ng-click="enableSortable()"
                            uib-tooltip="{{ isSortingTaskBoard(sprint) ? '${message(code: /todo.is.ui.sortable.enabled/)}' : '${message(code: /todo.is.ui.sortable.enable/)}' }}">
                        <span ng-class="isSortingTaskBoard(sprint) ? 'text-success' : 'text-danger'" class="fa fa-hand-pointer-o"></span>
                    </button>
                    <button class="btn btn-default"
                            uib-dropdown-toggle
                            uib-tooltip="${message(code:'todo.is.ui.filters')}"
                            type="button">
                        <span>{{ currentSprintFilter.name }}</span>
                        <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu" role="menu">
                        <li role="menuitem" ng-repeat="sprintFilter in sprintFilters">
                            <a ng-click="changeSprintFilter(sprintFilter)" href>{{ sprintFilter.name }}</a>
                        </li>
                    </ul>
                </div>
                <div class="btn-group pull-right visible-on-hover">
                    <g:if test="${params?.printable}">
                        <button type="button"
                                class="btn btn-default"
                                uib-tooltip="${message(code:'is.ui.window.print')} (P)"
                                unavailable-feature="true"
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
            </div>
            <div ng-if="isSortableTaskBoard(sprint) && !isSortingTaskBoard(sprint)" class="toolbar-warning">
                <i class="fa fa-exclamation-triangle"></i>
                ${message(code: 'todo.is.ui.sortable.sprintPlan.warning')}
                <button type="button" class="btn btn-default btn-sm" ng-click="enableSortable()">
                    <span class="text-danger fa fa-hand-pointer-o"></span>
                </button>
            </div>
        </h3>
    </div>
    <div class="panel-body" sticky-list sticky-watch="tasksByTypeByState">
        <table class="table" selectable="selectableOptions">
            <thead ng-switch="sprint.state">
            <tr class="header" ng-switch-when="2">
                <th>
                    Type
                </th>
                <th>
                    <span>${message(code: 'is.task.state.wait')}</span>
                </th>
                <th>
                    <span>${message(code: 'is.task.state.inprogress')}</span>
                </th>
                <th>
                    <span>${message(code: 'is.task.state.done')}</span>
                </th>
            </tr>
            <tr ng-switch-when="1">
                <th>
                    Type
                </th>
                <th>
                    <span>${message(code: 'is.task.state.wait')}</span>
                </th>
            </tr>
            <tr ng-switch-when="3">
                <th>
                    Type
                </th>
                <th>
                    <span>${message(code: 'is.task.state.done')}</span>
                </th>
            </tr>
            </thead>
            <tbody ng-controller="taskSprintCtrl">
            <tr>
                <td>
                    ${message(code: 'is.ui.sprintPlan.kanban.urgentTasks')}
                </td>
                <td class="postits grid-group"
                    ng-class="hasSelected() ? 'has-selected' : ''"
                    ng-model="tasksByTypeByState[11][taskState]"
                    ng-init="taskType = 11"
                    as-sortable="taskSortableOptions | merge: sortableScrollOptions('tbody')"
                    is-disabled="!isSortingTaskBoard(sprint)"
                    ng-repeat="taskState in sprintTaskStates">
                    <div ng-repeat="task in tasksByTypeByState[11][taskState] | search"
                         ng-class="{ 'is-selected': isSelected(task) }"
                         selectable-id="{{ ::task.id }}"
                         as-sortable-item
                         class="postit-container">
                        <div ng-include="'task.html'"></div>
                    </div>
                    <div ng-if="authorizedTask('create', {sprint: sprint})" class="postit-container">
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
                <td>
                    ${message(code: 'is.ui.sprintPlan.kanban.recurrentTasks')}
                </td>
                <td class="postits grid-group"
                    ng-class="hasSelected() ? 'has-selected' : ''"
                    ng-model="tasksByTypeByState[10][taskState]"
                    ng-init="taskType = 10"
                    as-sortable="taskSortableOptions | merge: sortableScrollOptions('tbody')"
                    is-disabled="!isSortingTaskBoard(sprint)"
                    ng-repeat="taskState in sprintTaskStates">
                    <div ng-repeat="task in tasksByTypeByState[10][taskState] | search"
                         ng-class="{ 'is-selected': isSelected(task) }"
                         selectable-id="{{ ::task.id }}"
                         as-sortable-item
                         class="postit-container">
                        <div ng-include="'task.html'"></div>
                    </div>
                    <div ng-if="authorizedTask('create', {sprint: sprint})" class="postit-container">
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
            <tr ng-repeat="story in backlog.stories | filter: storyFilter | search | orderBy: 'rank'"
                ng-class="{'sortable-disabled': !isSortingStory(story), 'story-done': story.state == 7}">
                <td class="postits grid-group"
                    ng-controller="storyCtrl">
                    <div class="postit-container">
                        <div ng-include="'story.html'"></div>
                    </div>
                </td>
                <td class="postits grid-group"
                    ng-class="hasSelected() ? 'has-selected' : ''"
                    ng-model="tasksByStoryByState[story.id][taskState]"
                    as-sortable="taskSortableOptions | merge: sortableScrollOptions('tbody')"
                    is-disabled="!isSortingTaskBoard(sprint) || !isSortingStory(story)"
                    ng-repeat="taskState in sprintTaskStates">
                    <div ng-repeat="task in tasksByStoryByState[story.id][taskState]"
                         ng-class="{ 'is-selected': isSelected(task) }"
                         selectable-id="{{ ::task.id }}"
                         as-sortable-item
                         class="postit-container">
                        <div ng-include="'task.html'"></div>
                    </div>
                    <div ng-if="authorizedTask('create', {parentStory: story})" class="postit-container">
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
</div>