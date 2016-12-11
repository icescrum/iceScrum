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
            <h4 class="pull-left">
                <a class="link" href="#/planning/{{ release.id }}/details">
                {{ release.name + ' - ' + (release.state | i18n: 'ReleaseStates') }} <i class="fa fa-info-circle visible-on-hover"></i>
                </a>
            </h4>
            <div class="pull-right">
                <div class="btn-group btn-view">
                    <button class="btn btn-default"
                            ng-style="{'visibility': !hasPreviousVisibleSprints() ? 'hidden' : 'visible'}"
                            ng-click="visibleSprintsPrevious()">
                        <i class="fa fa-caret-left"></i>
                    </button>
                    <button class="btn btn-default"
                            ng-style="{'visibility': !hasNextVisibleSprints() ? 'hidden' : 'visible'}"
                            ng-click="visibleSprintsNext()">
                        <i class="fa fa-caret-right"></i>
                    </button>
                </div>

                <div class="btn-group btn-view hidden-xs">
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
                <div class="btn-group btn-view" role="group" ng-controller="releaseCtrl">
                    <shortcut-menu ng-model="release" model-menus="menus" view-name="viewName"></shortcut-menu>
                    <div class="btn-group" uib-dropdown>
                        <button type="button" class="btn btn-default" uib-dropdown-toggle>
                            <i class="fa fa-ellipsis-h"></i></i>
                        </button>
                        <ul uib-dropdown-menu class="pull-right" template-url="release.menu.html"></ul>
                    </div>
                </div>
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
            <div class="panel-heading" style="padding-bottom:5px;">
                <h3 class="panel-title small-title">
                    <div class="pull-left">
                        <a class="link" href="{{ openSprintUrl(sprint) }}">
                            {{ (sprint | sprintName) + ' - ' + (sprint.state | i18n: 'SprintStates') }} <i class="fa fa-info-circle visible-on-hover"></i>
                        </a>
                        <br/>
                        <span class="sub-title text-muted">
                            <i class="fa fa-calendar"></i> <span title="{{ sprint.startDate | dayShort }}">{{ sprint.startDate | dayShorter }}</span> <i class="fa fa-angle-right"></i> <span title="{{ sprint.endDate | dayShort }}">{{ sprint.endDate | dayShorter }}</span>
                            <span class="sprint-numbers">
                                <span ng-if="sprint.state > sprintStatesByName.TODO"
                                      uib-tooltip="${message(code: 'is.sprint.velocity')}">{{ sprint.velocity | roundNumber:2 }} /</span>
                                <span uib-tooltip="${message(code: 'is.sprint.capacity')}">{{ sprint.capacity | roundNumber:2 }}</span>
                                <i class="small-icon fa fa-dollar"></i>
                            </span>
                        </span>
                    </div>
                    <div class="pull-right">
                        <div class="btn-group" role="group">
                            <shortcut-menu ng-model="sprint" model-menus="menus"></shortcut-menu>
                            <div class="btn-group" uib-dropdown>
                                <button type="button" class="btn btn-default" uib-dropdown-toggle>
                                    <i class="fa fa-ellipsis-h"></i></i>
                                </button>
                                <ul uib-dropdown-menu class="pull-right" template-url="sprint.menu.html"></ul>
                            </div>
                        </div>
                    </div>
                </h3>
            </div>
            <div class="panel-body">
                <div class="postits"
                     ng-class="{'sortable-moving':app.sortableMoving, 'has-selected' : hasSelected(), 'sortable-disabled':!isSortingSprint(sprint)}"
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
                </div>
            </div>
        </div>
    </div>
    <div ng-if="releases.length == 0"
         class="panel panel-light">
        <div class="panel-body">
            <div class="empty-view" ng-controller="releaseCtrl">
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