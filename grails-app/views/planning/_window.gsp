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
<is:window windowDefinition="${windowDefinition}">
<div class="panel panel-light">
    <div ng-if="releases.length > 0"
         class="backlogs-list">
        <div class="btn-toolbar">
            <div class="btn-group visible-on-hover" ng-show="hasPreviousVisibleSprints()">
                <button class="btn btn-default"
                        ng-click="visibleSprintsPrevious()">
                        <i class="fa fa-step-backward"></i>
                </button>
            </div>
            <div class="btn-group pull-right">
                <a class="btn btn-primary"
                   ng-if="authorizedRelease('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.release.new')}
                </a>
                <a class="btn btn-primary"
                   ng-if="authorizedSprint('create')"
                   href="#{{ viewName + '/' + release.id }}/sprint/new">
                    ${message(code: 'todo.is.ui.sprint.new')}
                </a>
            </div>
            <div class="btn-group pull-right"
                 ng-if="isMultipleSprint()">
                <a class="btn btn-default"
                   href="{{ openMultipleSprintDetailsUrl() }}"
                   uib-tooltip="${message(code: 'todo.is.ui.details')}">
                    <i class="fa fa-info-circle"></i>
                </a>
            </div>
            <div class="btn-group pull-right visible-on-hover">
                <button type="button"
                        uib-tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
                        ng-click="app.asList = !app.asList"
                        class="btn btn-default">
                    <i class="fa fa-th" ng-class="{'fa-th-list': app.asList, 'fa-th': !app.asList}"></i>
                </button>
            </div>
            <div class="btn-group pull-right visible-on-hover" ng-if="hasNextVisibleSprints()">
                <button class="btn btn-default"
                        ng-click="visibleSprintsNext()">
                    <i class="fa fa-step-forward"></i>
                </button>
            </div>
        </div>
        <hr>
    </div>
    <div ng-if="releases.length > 0"
         class="backlogs-list-details"
         selectable="selectableOptions">
        <div class="panel panel-light"
             ng-repeat="sprint in visibleSprints"
             ng-controller="sprintBacklogCtrl">
            <div class="panel-heading">
                <h3 class="panel-title small-title">
                    <div>
                        {{ (sprint | sprintName) + ' - ' + (sprint.state | i18n: 'SprintStates') }}
                        <span class="pull-right">
                            <span ng-if="sprint.state > sprintStatesByName.TODO"
                                  uib-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity }} /</span>
                            <span uib-tooltip="${message(code: 'is.sprint.capacity')}">{{ sprint.capacity }}</span>
                            <i class="small-icon fa fa-dollar"></i>
                            <button class="btn btn-primary"
                                    type="button"
                                    ng-click="showStoriesSelectorModal({filter:planStories.filter,callback: planStories.callback, args:[sprint], code: 'plan'})"
                                    ng-if="authorizedSprint('plan', sprint)" style="position:relative">
                                ${message(code: 'todo.is.ui.story.plan')}
                            </button>
                            <a class="btn btn-default"
                               href="#/taskBoard/{{ sprint.id }}/details"
                               uib-tooltip="${message(code: 'todo.is.ui.taskBoard')}">
                                <i class="fa fa-tasks"></i>
                            </a>
                            <a class="btn btn-default"
                               href="{{ ::openSprintUrl(sprint) }}"
                               uib-tooltip="${message(code: 'todo.is.ui.details')}">
                                <i class="fa fa-info-circle"></i>
                            </a>
                        </span>
                    </div>
                    <div class="sub-title text-muted">
                        {{ sprint.startDate | dayShorter }} <i class="fa fa-long-arrow-right"></i> {{ sprint.endDate | dayShorter }}
                    </div>
                </h3>
            </div>
            <div class="panel-body">
                <div class="postits {{ (isSortingSprint(sprint) ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '') + ' ' + (app.sortableMoving ? 'sortable-moving' : '') }}"
                     ng-controller="storyCtrl"
                     as-sortable="sprintSortableOptions | merge: sortableScrollOptions()"
                     is-disabled="!isSortingSprint(sprint)"
                     ng-model="backlog.stories"
                     ng-class="app.asList ? 'list-group' : 'grid-group'"
                     ng-init="emptyBacklogTemplate = 'story.backlog.planning.empty.html'"
                     ng-include="'story.backlog.html'">
                </div>
            </div>
        </div>
        <div ng-if="!sprints || sprints.length == 0"
             class="panel panel-light text-center">
            <div class="panel-body">
                <div class="empty-view">
                    <p class="help-block">${message(code: 'is.ui.sprint.help')}<p>
                    <a class="btn btn-primary"
                       ng-if="authorizedSprint('create')"
                       href="#{{ viewName + '/' + release.id }}/sprint/new">
                        ${message(code: 'todo.is.ui.sprint.new')}
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div ng-if="releases.length == 0"
         class="panel panel-light">
        <div class="panel-body">
            <div class="empty-view">
                <p class="help-block">${message(code: 'is.ui.release.help')}<p>
                <a class="btn btn-primary"
                   ng-if="authorizedRelease('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.release.new')}
                </a>
            </div>
        </div>
    </div>
    <div class="timeline" timeline="releases" on-select="timelineSelected" selected="selectedItems"></div>
</div>
</is:window>