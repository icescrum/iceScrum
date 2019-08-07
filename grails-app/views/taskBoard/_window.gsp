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
- Colin Bontemps (cbontemps@kagilum.com)
--}%
<is:window windowDefinition="${windowDefinition}">
    <div class="card card-view sprint-state-{{ sprint.state }}"
         ng-if="sprint">
        <div class="card-header kanban-header">
            <div class="card-header-left">
                <span uib-dropdown on-toggle="scrollToActiveSprint(open)">
                    <span uib-dropdown-toggle class="card-title">{{ (sprint | sprintName) }}</span>
                    <div uib-dropdown-menu role="menu">
                        <div ng-repeat="sprintEntry in sprintEntries | orderBy: 'orderNumber'"
                             ng-switch="sprintEntry.type"
                             ng-class="{'divider': 'dropdown-divider', 'release': 'dropdown-header', 'sprint': 'dropdown-item'}[sprintEntry.type]">
                            <a ng-switch-when="sprint"
                               ng-class="{'active': sprintEntry.item.id == sprint.id}"
                               href="{{ openSprintUrl(sprintEntry.item, true) }}">
                                {{ (sprintEntry.item | sprintName) + ' - ' + (sprintEntry.item.state | i18n: 'SprintStates') }}
                                <span>
                                    {{ sprintEntry.item.startDate | dayShorter }} | {{ sprintEntry.item.endDate | dayShorter }}
                                </span>
                            </a>
                            <span ng-switch-when="release">
                                {{ sprintEntry.item.name }}
                            </span>
                        </div>
                    </div>
                </span>
                <span class="state-title">
                    <span class="state-dot" ng-class="'state-dot-' + sprint.state"></span>
                    <span>{{ (sprint.state | i18n: 'SprintStates') }}</span>
                </span>
                <span class="timebox-dates">
                    <span class="start-date" title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span><span class="end-date" title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                </span>
                <span class="sprint-values">
                    <span ng-if="sprint.velocity || sprint.capacity">
                        <span>{{ message('is.sprint.' + (sprint.state > sprintStatesByName.TODO ? 'velocity' : 'plannedVelocity')) }}</span>
                        <strong ng-if="sprint.state > sprintStatesByName.TODO"
                                defer-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</strong>
                        <strong defer-tooltip="${message(code: 'is.sprint.plannedVelocity')}">{{ sprint.capacity | roundNumber:2 }}</strong>
                    </span>
                    <span>${message(code: 'is.task.estimation')} <strong>{{ totalRemainingTime(sprint.tasks | filter: currentSprintFilter.filter) | roundNumber:2 }}</strong></span>
                </span>
            </div>
            <div>
                <div class="btn-toolbar">
                    <entry:point id="taskBoard-window-toolbar-right"/>
                    <div class="btn-group" uib-dropdown>
                        <button class="btn btn-secondary btn-sm"
                                uib-dropdown-toggle
                                type="button">
                            {{ currentSprintFilter.name + ' (' + currentSprintFilter.count + ')'}}
                        </button>
                        <div uib-dropdown-menu class="dropdown-menu-right" role="menu">
                            <div role="menuitem"
                                 ng-repeat="sprintFilter in sprintFilters"
                                 ng-class="{'dropdown-divider': sprintFilter.id == 'divider'}">
                                <a ng-if="sprintFilter.id != 'divider'"
                                   class="dropdown-item"
                                   ng-click="changeSprintFilter(sprintFilter)"
                                   href>
                                    {{ sprintFilter.name + ' (' + (sprintFilter.count | orElse: 0) + ')'}}
                                </a>
                            </div>
                        </div>
                    </div>
                    <g:set var="formats" value="${is.exportFormats(windowDefinition: 'taskBoard', entryPoint: 'sprintDetails')}"/>
                    <g:if test="${formats}">
                        <div class="btn-group" uib-dropdown ng-if="authenticated()">
                            <button class="btn btn-secondary btn-sm"
                                    uib-dropdown-toggle type="button">
                                <i class="fa fa-download"></i>
                            </button>
                            <div uib-dropdown-menu
                                 class="dropdown-menu-right"
                                 role="menu">
                                <div class="dropdown-header">${message(code: 'todo.is.ui.export')}</div>
                                <g:each in="${formats}" var="format">
                                    <a role="menuitem"
                                       class="dropdown-item"
                                       href="${format.onlyJsClick ? '' : (format.resource ?: 'story') + '/sprint/{{ ::sprint.id }}/' + (format.action ?: 'print') + '/' + (format.params.format ?: '')}"
                                       ng-click="${format.jsClick ? format.jsClick : 'print'}($event)">${format.name}</a>
                                </g:each>
                            </div>
                        </div>
                    </g:if>
                    <div>
                        <a class="btn btn-icon btn-sm ml-1 mr-1"
                           href="{{ openSprintUrl(sprint) }}">
                            <span class="icon icon-details"></span>
                        </a>
                    </div>
                    <div class="btn-menu" ng-controller="sprintCtrl" uib-dropdown>
                        <shortcut-menu ng-model="sprint" model-menus="menus" view-type="viewName"></shortcut-menu>
                        <div uib-dropdown-toggle></div>
                        <div uib-dropdown-menu ng-init="itemType = 'sprint'" template-url="item.menu.html"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="card-body scrollable-selectable-container"
             data-scroll-to-visible-computed-offset-top="true"
             data-scroll-to-visible-offset=".kanban-header"
             id="tasks-board"
             ng-controller="taskCtrl">
            <div class="window-alert bg-warning"
                 ng-if="currentSprintFilter.id != 'allTasks'"
                 style="margin: 0 10px;">
                ${message(code: 'todo.is.ui.filter.current')}
                {{ currentSprintFilter.name }}
                (<strong><a href class="link" ng-click="changeSprintFilter(getDefaultFilter())">${message(code: 'todo.is.ui.disable')}</a></strong>)
            </div>
            <div selectable="selectableOptions" class="kanban" ng-class="{'has-selected' : hasSelected()}">
                <div class="kanban-states">
                    <div ng-if="sprint.state != sprintStatesByName.DONE" ng-bind-html="taskCountByState[taskStatesByName.TODO].label"></div>
                    <div ng-if="sprint.state == sprintStatesByName.IN_PROGRESS" ng-bind-html="taskCountByState[taskStatesByName.IN_PROGRESS].label"></div>
                    <div ng-if="sprint.state != sprintStatesByName.TODO" ng-bind-html="taskCountByState[taskStatesByName.DONE].label"></div>
                </div>
                <div class="kanban-swimlane"
                     ng-if="authorizedTask('showUrgent')">
                    <div class="kanban-row">
                        <div class="kanban-column-header col">
                            <span class="swimlane-title" ng-bind-html="taskCountByType[taskTypesByName.URGENT].label"></span>
                        </div>
                        <div class="kanban-column-header col" ng-if="sprint.state == sprintStatesByName.IN_PROGRESS"></div>
                        <div class="kanban-column-header col" ng-if="sprint.state == sprintStatesByName.IN_PROGRESS"></div>
                    </div>
                    <div class="kanban-row">
                        <div class="kanban-column col"
                             ng-repeat="taskState in sprintTaskStates">
                            <div class="sticky-notes grid-group"
                                 ng-class="{'show-tasks':!tasksShown(taskState, taskTypesByName.URGENT)}"
                                 ng-model="tasksByTypeByStateAndSearchFiltered[taskTypesByName.URGENT][taskState]"
                                 ng-init="taskType = taskTypesByName.URGENT"
                                 as-sortable="taskSortableOptions | merge: sortableScrollOptions('.kanban-row')"
                                 is-disabled="!isSortableTaskBoard(sprint)">
                                <div is-watch="task"
                                     ng-repeat="task in tasksByTypeByStateAndSearchFiltered[taskTypesByName.URGENT][taskState]"
                                     ng-if="tasksShown(taskState, taskTypesByName.URGENT)"
                                     ng-class="{ 'is-selected': isSelected(task) }"
                                     selectable-id="{{ ::task.id }}"
                                     as-sortable-item
                                     class="sticky-note-container sticky-note-task">
                                    <div ng-include="'task.html'"></div>
                                </div>
                                <button type="button"
                                        ng-if="!tasksShown(taskState, taskTypesByName.URGENT)"
                                        class="btn btn-secondary"
                                        ng-click="showTasks(taskTypesByName.URGENT, true)">
                                    {{ message('todo.is.ui.task.showDoneTasks', [tasksByTypeByState[taskTypesByName.URGENT][taskState].length]) }}
                                </button>
                                <div ng-if="tasksHidden(taskState, taskTypesByName.URGENT)" class="sticky-note-container sticky-note-task">
                                    <div class="hide-tasks sticky-note">
                                        <button type="button"
                                                class="btn btn-secondary"
                                                ng-click="showTasks(taskTypesByName.URGENT, false)">
                                            {{ message('todo.is.ui.task.hideDoneTasks', [tasksByTypeByState[taskTypesByName.URGENT][taskState].length]) }}
                                        </button>
                                    </div>
                                </div>
                                <div ng-if="taskState == taskStatesByName.TODO && authorizedTask('create', {sprint: sprint})" class="sticky-note-container sticky-note-task">
                                    <a class="kanban-add-task" ng-click="openNewTaskByType(taskTypesByName.URGENT)" href>
                                        <span class="plus-icon"></span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="kanban-swimlane"
                     ng-if="authorizedTask('showRecurrent')">
                    <div class="kanban-row">
                        <div class="kanban-column-header col">
                            <span class="swimlane-title">
                                <span ng-bind-html="taskCountByType[taskTypesByName.RECURRENT].label"></span>
                                <a ng-if="authorizedTask('create', {sprint: sprint})"
                                   class="swimlane-subtitle"
                                   ng-click="copyRecurrentTasks(sprint)"
                                   href>${message(code: 'is.ui.sprintPlan.kanban.copyRecurrentTasks')}</a>
                            </span>
                        </div>
                        <div class="kanban-column-header col" ng-if="sprint.state == sprintStatesByName.IN_PROGRESS"></div>
                        <div class="kanban-column-header col" ng-if="sprint.state == sprintStatesByName.IN_PROGRESS"></div>
                    </div>
                    <div class="kanban-row">
                        <div class="kanban-column col"
                             ng-repeat="taskState in sprintTaskStates">
                            <div class="sticky-notes grid-group"
                                 ng-class="{'show-tasks':!tasksShown(taskState, taskTypesByName.RECURRENT), 'has-selected' : hasSelected()}"
                                 ng-model="tasksByTypeByStateAndSearchFiltered[taskTypesByName.RECURRENT][taskState]"
                                 ng-init="taskType = taskTypesByName.RECURRENT"
                                 as-sortable="taskSortableOptions | merge: sortableScrollOptions('.kanban-row')"
                                 is-disabled="!isSortableTaskBoard(sprint)">
                                <div is-watch="task"
                                     ng-repeat="task in tasksByTypeByStateAndSearchFiltered[taskTypesByName.RECURRENT][taskState]"
                                     ng-if="tasksShown(taskState, taskTypesByName.RECURRENT)"
                                     ng-class="{ 'is-selected': isSelected(task) }"
                                     selectable-id="{{ ::task.id }}"
                                     as-sortable-item
                                     class="sticky-note-container sticky-note-task">
                                    <div ng-include="'task.html'"></div>
                                </div>
                                <button type="button"
                                        ng-if="!tasksShown(taskState, taskTypesByName.RECURRENT)"
                                        class="btn btn-secondary"
                                        ng-click="showTasks(taskTypesByName.RECURRENT, true)">
                                    {{ message('todo.is.ui.task.showDoneTasks', [tasksByTypeByState[taskTypesByName.RECURRENT][taskState].length]) }}
                                </button>
                                <div ng-if="tasksHidden(taskState, taskTypesByName.RECURRENT)" class="sticky-note-container sticky-note-task">
                                    <div class="hide-tasks sticky-note">
                                        <button type="button"
                                                class="btn btn-secondary"
                                                ng-click="showTasks(taskTypesByName.RECURRENT, false)">
                                            {{ message('todo.is.ui.task.hideDoneTasks', [tasksByTypeByState[taskTypesByName.RECURRENT][taskState].length]) }}
                                        </button>
                                    </div>
                                </div>
                                <div ng-if="taskState == taskStatesByName.TODO && authorizedTask('create', {sprint: sprint})" class="sticky-note-container sticky-note-task">
                                    <a class="kanban-add-task" ng-click="openNewTaskByType(taskTypesByName.RECURRENT)" href>
                                        <span class="plus-icon"></span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="kanban-swimlane"
                     ng-repeat="story in sprint.stories | filter: storyFilter | taskBoardSearch: tasksByStoryByState | orderBy: 'rank'"
                     ng-class="{'story-done': story.state == storyStatesByName.DONE }">
                    <div class="sticky-notes list-group list-group-small">
                        <div class="sticky-note-container sticky-note-story"
                             ng-controller="storyCtrl"
                             ng-click="selectStory($event, story.id)"
                             is-watch="story"
                             ng-class="{'is-selected': isSelected(story)}">
                            <div ng-include="'story.html'"></div>
                        </div>
                    </div>
                    <div class="kanban-row"
                         ng-class="{'is-selected': isSelected(story)}">
                        <div class="kanban-column col"
                             ng-repeat="taskState in sprintTaskStates">
                            <div class="sticky-notes grid-group"
                                 ng-class="{'show-tasks':!tasksShown(taskState, story), 'has-selected' : hasSelected()}"
                                 ng-model="tasksByStoryByState[story.id][taskState]"
                                 as-sortable="taskSortableOptions | merge: sortableScrollOptions('.kanban-row')"
                                 is-disabled="!isSortableTaskBoard(sprint) || !isSortableStory(story)">
                                <div is-watch="task"
                                     ng-repeat="task in tasksByStoryByState[story.id][taskState]"
                                     ng-if="tasksShown(taskState, story)"
                                     ng-class="{ 'is-selected': isSelected(task) }"
                                     selectable-id="{{ ::task.id }}"
                                     as-sortable-item
                                     class="sticky-note-container sticky-note-task">
                                    <div ng-include="'task.html'"></div>
                                </div>
                                <button type="button"
                                        ng-if="!tasksShown(taskState, story)"
                                        class="btn btn-secondary"
                                        ng-click="showTasks(story, true)">{{ message('todo.is.ui.task.showDoneTasks', [tasksByStoryByState[story.id][taskState].length]) }}
                                </button>
                                <div ng-if="tasksHidden(taskState, story)" class="sticky-note-container sticky-note-task">
                                    <div class="hide-tasks sticky-note">
                                        <button type="button"
                                                class="btn btn-secondary"
                                                ng-click="showTasks(story, false)">
                                            {{ message('todo.is.ui.task.hideDoneTasks', [tasksByStoryByState[story.id][taskState].length]) }}
                                        </button>
                                    </div>
                                </div>
                                <div ng-if="taskState == taskStatesByName.TODO && authorizedTask('create', {parentStory: story})" class="sticky-note-container sticky-note-task">
                                    <a class="kanban-add-task" ng-click="openNewTaskByStory(story)" href>
                                        <span class="plus-icon"></span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="kanban-swimlane story-ghost"
                     ng-repeat="story in ghostStories | filter: storyFilter | taskBoardSearch: tasksByStoryByState | orderBy: 'id'">
                    <div class="sticky-notes list-group list-group-small">
                        <div class="sticky-note-container sticky-note-story" ng-controller="storyCtrl" ng-click="selectStory($event, story.id)" ng-class="{'is-selected': isSelected(story)}">
                            <div ng-include="'story.light.html'"></div>
                        </div>
                    </div>
                    <div class="kanban-row">
                        <div class="kanban-column col"
                             ng-repeat="taskState in sprintTaskStates">
                            <div class="sticky-notes grid-group"
                                 ng-class="{'show-tasks':!tasksShown(taskState, story, true), 'has-selected' : hasSelected()}"
                                 ng-model="tasksByStoryByState[story.id][taskState]"
                                 as-sortable
                                 is-disabled="true">
                                <div is-watch="task"
                                     ng-repeat="task in tasksByStoryByState[story.id][taskState]"
                                     ng-if="tasksShown(taskState, story, true)"
                                     ng-class="{ 'is-selected': isSelected(task) }"
                                     selectable-id="{{ ::task.id }}"
                                     as-sortable-item
                                     class="sticky-note-container sticky-note-task">
                                    <div ng-include="'task.html'"></div>
                                </div>
                                <button type="button"
                                        ng-if="!tasksShown(taskState, story, true)"
                                        class="btn btn-secondary"
                                        ng-click="showTasks(story, true)">{{ message('todo.is.ui.task.showDoneTasks', [tasksByStoryByState[story.id][taskState].length]) }}
                                </button>
                                <div ng-if="tasksHidden(taskState, story, true)" class="sticky-note-container sticky-note-task">
                                    <div class="hide-tasks sticky-note">
                                        <button type="button"
                                                class="btn btn-secondary"
                                                ng-click="showTasks(story, false)">
                                            {{ message('todo.is.ui.task.hideDoneTasks', [tasksByStoryByState[story.id][taskState].length]) }}
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div ng-if="sprint.stories.length == 0 && sprint.state < sprintStatesByName.DONE">
                    <div class="empty-view">
                        <p class="form-text">${message(code: 'todo.is.ui.story.empty.taskBoard')}</p>
                        <a class="btn btn-secondary"
                           href="#/planning/{{ sprint.parentRelease.id }}/sprint/{{ sprint.id }}">
                            <i class="fa fa-inbox"></i> ${message(code: 'todo.is.ui.planning')}
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div ng-if="!sprint">
        <div class="empty-view">
            <p class="form-text">${message(code: 'todo.is.ui.taskBoard.empty')}<p>
            <a class="btn btn-primary"
               href="#planning">
                <i class="fa fa-calendar"></i> ${message(code: 'todo.is.ui.planning')}
            </a>
        </div>
    </div>
</is:window>