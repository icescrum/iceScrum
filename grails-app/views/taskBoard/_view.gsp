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
     ng-if="sprint"
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
                        <span ng-class="isSortingTaskBoard(sprint) ? 'text-success' : 'forbidden-stack text-danger'" class="fa fa-hand-pointer-o"></span>
                    </button>
                    <button class="btn btn-default"
                            uib-dropdown-toggle
                            uib-tooltip="${message(code:'todo.is.ui.filters')}"
                            type="button">
                        <span>{{ currentSprintFilter.name }}</span>
                        <span class="caret"></span>
                    </button>
                    <ul uib-dropdown-menu role="menu">
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
                                hotkey="{'P': hotkeyClick }"><i class="fa fa-print"></i>
                        </button>
                    </g:if>
                    <g:if test="${params?.fullScreen}">
                        <button type="button"
                                class="btn btn-default"
                                ng-show="!app.isFullScreen"
                                ng-click="fullScreen()"
                                uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                                hotkey="{'F': fullScreen }"><i class="fa fa-expand"></i>
                        </button>
                        <button type="button"
                                class="btn btn-default"
                                ng-show="app.isFullScreen"
                                uib-tooltip="${message(code:'is.ui.window.fullscreen')}"
                                ng-click="fullScreen()"><i class="fa fa-compress"></i>
                        </button>
                    </g:if>
                </div>
            </div>
        </h3>
    </div>
    <div class="panel-body" id="tasks-board" ng-controller="taskSprintCtrl">
        <table class="table" selectable="selectableOptions" sticky-list="#tasks-board">
            <thead>
            <tr class="table-header sticky-header sticky-stack">
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
            </thead>
            <tbody>
                <tr class="sticky-header">
                    <td colspan="{{ sprint.state != 2 ? 1 : 3 }}" class="task-type">
                        <h3 class="title">${message(code: 'is.ui.sprintPlan.kanban.urgentTasks')}</h3>
                    </td>
                </tr>
                <tr>
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
                <tr class="sticky-header">
                    <td colspan="{{ sprint.state != 2 ? 1 : 3 }}" class="task-type">
                        <h3 class="title">${message(code: 'is.ui.sprintPlan.kanban.recurrentTasks')}</h3>
                    </td>
                </tr>
                <tr>
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
            </tbody>
            </tbody>
            <tbody ng-repeat="story in sprint.stories | filter: storyFilter | search | orderBy: 'rank'">
                <tr class="sticky-header list-group">
                    <td colspan="3" class="postit-container">
                        <div ng-include="'story.html'" ng-init="disabledGradient = true"></div>
                    </td>
                </tr>
                <tr class="postits grid-group" ng-controller="storyCtrl" ng-class="{'sortable-disabled': !isSortingStory(story), 'story-done': story.state == 7}">
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
            <tr ng-if="sprint.stories.length == 0">
                <td>
                    <div class="empty-view">
                        <p class="help-block">${message(code: 'todo.is.ui.story.empty.sprint')}<p>
                        <a type="button"
                           class="btn btn-primary"
                           ng-if="sprint.state != 3"
                           href="#backlog">
                            <i class="fa fa-inbox"></i> ${message(code: 'is.ui.backlogs')}
                        </a>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</div>
<div ng-if="!sprint"
     class="panel panel-light">
    <div class="panel-body">
        <div class="empty-view">
            <p class="help-block">${message(code: 'todo.is.ui.taskBoard.empty')}<p>
            <a type="button"
               class="btn btn-primary"
               href="#planning">
                <i class="fa fa-calendar"></i> ${message(code: 'todo.is.ui.planning')}
            </a>
        </div>
    </div>
</div>