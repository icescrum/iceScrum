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
<div class="panel panel-light" ng-class="{'simulation':simulationMode.active}">
    <div ng-if="releases.length > 0"
         class="backlogs-list">
        <div class="btn-toolbar">
            <div class="btn-group visible-on-hover" ng-show="hasPreviousVisibleSprints()">
                <button class="btn btn-default"
                        ng-click="visibleSprintsPrevious()">
                        <i class="fa fa-angle-left fa-lg"></i>
                </button>
            </div>
            <div class="btn-group pull-right">
                <a class="btn btn-primary hidden-on-simulation"
                   ng-if="authorizedRelease('create')"
                   href="#{{ ::viewName }}/new">
                    ${message(code: 'todo.is.ui.release.new')}
                </a>
                <a class="btn btn-primary hidden-on-simulation"
                   ng-if="authorizedSprint('create')"
                   href="#{{ viewName + '/' + release.id }}/sprint/new">
                    ${message(code: 'todo.is.ui.sprint.new')}
                </a>
            </div>
            %{--<div class="btn-group pull-right">--}%
                %{--<button type="button"--}%
                        %{--class="btn btn-danger hidden-on-simulation"--}%
                        %{--ng-click="enterSimulationMode()">--}%
                     %{--${message(code: 'todo.is.ui.planning.simulate.enter')}--}%
                %{--</button>--}%
                %{--<button type="button"--}%
                        %{--class="btn btn-danger visible-on-simulation"--}%
                        %{--ng-click="exitSimulationMode()">--}%
                    %{--${message(code: 'todo.is.ui.planning.simulate.exit')}--}%
                %{--</button>--}%
            %{--</div>--}%
            %{--<div class="simulation-slider pull-right visible-on-simulation text-center">--}%
                %{--<slider tooltip="hide"--}%
                        %{--ng-model="simulationMode.capacity"--}%
                        %{--min="simulationMode.min"--}%
                        %{--step="simulationMode.step"--}%
                        %{--max="simulationMode.max"--}%
                        %{--on-stop-slide="refreshSimulation($event,value)"--}%
                        %{--value="simulationMode.capacity">--}%
                %{--</slider>--}%
                %{--${message(code: 'is.dialog.promptCapacityAutoPlan.title')} {{ simulationMode.capacity }}--}%
            %{--</div>--}%
            <div class="btn-group pull-right hidden-on-simulation"
                 ng-if="isMultipleSprint()">
                <a class="btn btn-default"
                   href="{{ openMultipleSprintDetailsUrl() }}"
                   uib-tooltip="${message(code: 'todo.is.ui.details')}">
                    <i class="fa fa-info-circle"></i>
                </a>
            </div>
            <div class="btn-group pull-right visible-on-hover">
                <button type="button"
                        class="btn btn-default"
                        uib-tooltip="${message(code: 'todo.is.ui.postit.size')}"
                        ng-click="setPostitSize(viewName)"><i class="fa {{ iconCurrentPostitSize(viewName, 'grid-group') }}"></i>
                </button>
                <button type="button"
                        class="btn btn-default hidden-on-simulation"
                        ng-click="fullScreen()"
                        uib-tooltip="${message(code:'is.ui.window.fullscreen')}"><i class="fa fa-arrows-alt"></i>
                </button>
            </div>
            <div class="btn-group pull-right visible-on-hover" ng-if="hasNextVisibleSprints()">
                <button class="btn btn-default"
                        ng-click="visibleSprintsNext()">
                    <i class="fa fa-angle-right fa-lg"></i>
                </button>
            </div>
        </div>
        <hr>
    </div>
    <div ng-if="releases.length > 0"
         class="backlogs-list-details loadable"
         ng-class="{'loading': simulationMode.working}"
         selectable="selectableOptions">
        <div class="loading-logo" ng-include="'loading.html'"></div>
        <div class="panel panel-light"
             ng-repeat="sprint in visibleSprints"
             ng-controller="sprintBacklogCtrl">
            <div class="panel-heading">
                <h3 class="panel-title small-title">
                    <div>
                        {{ (sprint | sprintName) + ' - ' + (sprint.state | i18n: 'SprintStates') }}
                        <span class="pull-right">
                            <span ng-if="sprint.state > sprintStatesByName.TODO"
                                  uib-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</span>
                            <span uib-tooltip="${message(code: 'is.sprint.capacity')}">{{ sprint.capacity | roundNumber:2 }}</span>
                            <i class="small-icon fa fa-dollar"></i>
                            <button class="btn btn-primary hidden-on-simulation"
                                    type="button"
                                    ng-click="openPlanModal(sprint)"
                                    ng-if="authorizedSprint('plan', sprint)" style="position:relative">
                                ${message(code: 'todo.is.ui.story.plan')}
                            </button>
                            <a class="btn btn-default hidden-on-simulation"
                               href="#/taskBoard/{{ sprint.id }}/details"
                               uib-tooltip="${message(code: 'todo.is.ui.taskBoard')}">
                                <i class="fa fa-tasks"></i>
                            </a>
                            <a class="btn btn-default hidden-on-simulation"
                               href="{{ openSprintUrl(sprint) }}"
                               uib-tooltip="${message(code: 'todo.is.ui.details')}">
                                <i class="fa fa-info-circle"></i>
                            </a>
                        </span>
                    </div>
                    <div class="sub-title text-muted">
                        <i class="fa fa-calendar"></i> <span title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span> <i class="fa fa-long-arrow-right"></i> <span title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                    </div>
                </h3>
            </div>
            <div class="panel-body">
                <div class="postits {{ currentPostitSize(viewName, 'grid-group size-sm')+ ' ' + (isSortingSprint(sprint) ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '') + ' ' + (app.sortableMoving ? 'sortable-moving' : '') }}"
                     postits-screen-size
                     ng-controller="storyCtrl"
                     as-sortable="sprintSortableOptions | merge: sortableScrollOptions()"
                     is-disabled="!isSortingSprint(sprint)"
                     ng-model="backlog.stories"
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
                    <a class="btn btn-primary hidden-on-simulation"
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
                <a class="btn btn-primary hidden-on-simulation"
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