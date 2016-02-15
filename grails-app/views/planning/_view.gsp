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

<style>
    .timeline {
        height:120px;
    }
    .timeline .axis text {
        font: 11px sans-serif;
    }
    .timeline .axis path {
        display: none;
    }
    .timeline .axis line {
        fill: none;
        stroke: #000;
        shape-rendering: crispEdges;
    }
    .timeline .timeline-background {
        fill: #fff;
    }
    .timeline .grid line, .timeline .grid path {
        fill: none;
        stroke: #fff;
        shape-rendering: crispEdges;
    }
    .timeline .grid .minor.tick line {
        stroke-opacity: .5;
    }
    .timeline .brush .extent {
        stroke: #999;
        fill-opacity: .075;
        shape-rendering: crispEdges;
    }
    .timeline .sprint {
        stroke: #dbdbdb;
    }
    .timeline .release-default, .timeline .sprint-default {
        fill: #eeeeee;
    }
    .timeline .release-progress, .timeline .sprint-progress {
        fill: #DAF4FF;
    }
    .timeline .release-done, .timeline .sprint-done {
        fill: #E1F5CC;
    }
</style>

<div ng-if="releases.length > 0"
     class="backlogs-list">
    <div class="timeline" timeline="releases" on-select="timelineSelected" selected="selectedItems"></div>
    <div class="btn-toolbar">
        <div class="btn-group" ng-if="hasPreviousVisibleSprints()">
            <button class="btn btn-default"
                    ng-click="visibleSprintsPrevious()">
                <i class="fa fa-step-backward"></i>
            </button>
        </div>
        <div class="btn-group" ng-if="authorizedRelease('create')">
            <a type="button"
               class="btn btn-primary"
               href="#{{ ::viewName }}/new">
                ${message(code: 'todo.is.ui.release.new')}
            </a>
        </div>
        <div class="btn-group"
             ng-if="authorizedSprint('create')">
            <a type="button"
               class="btn btn-primary"
               href="#{{ viewName + '/' + release.id }}/sprint/new">
                ${message(code: 'todo.is.ui.sprint.new')}
            </a>
        </div>
        <div class="btn-group pull-right" ng-if="hasNextVisibleSprints()">
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
                    <a href="#/taskBoard/{{ sprint.id }}/details">
                        ${message(code: 'is.sprint')} {{ sprint.orderNumber + ' - ' + (sprint.state | i18n: 'SprintStates') }}
                    </a>
                    <span class="pull-right">{{ (sprint.state > 1 ? (sprint.velocity + ' / ') : '') + sprint.capacity }} <i class="small-icon fa fa-dollar"></i></span>
                </div>
                <div class="sub-title text-muted">
                    {{ sprint.startDate | dateShorter }} <i class="fa fa-long-arrow-right"></i> {{ sprint.endDate | dateShorter }}
                </div>
            </h3>
        </div>
        <div class="panel-body">
            <div class="postits {{ (isSortingSprint(sprint) ? '' : 'sortable-disabled') + ' ' + (hasSelected() ? 'has-selected' : '') }}"
                 ng-controller="storyCtrl"
                 as-sortable="sprintSortableOptions | merge: sortableScrollOptions()"
                 is-disabled="!isSortingSprint(sprint)"
                 ng-model="backlog.stories"
                 ng-class="app.asList ? 'list-group' : 'grid-group'"
                 ng-include="'story.backlog.html'">
            </div>
        </div>
    </div>
    <div ng-if="!sprints || sprints.length == 0"
         class="panel panel-light text-center">
        <div class="panel-body">
            <p class="help-block">${message(code: 'is.ui.sprint.help')}<p>
            <a type="button"
               class="btn btn-primary"
               ng-if="authorizedSprint('create')"
               href="#{{:: viewName + '/' + release.id }}/sprint/new">
                ${message(code: 'todo.is.ui.sprint.new')}
            </a>
        </div>
    </div>
</div>
<div ng-if="releases.length == 0"
     class="panel panel-light">
    <div class="panel-body text-center">
        <p class="help-block">${message(code: 'is.ui.release.help')}<p>
        <a type="button"
           class="btn btn-primary"
           ng-if="authorizedRelease('create')"
           href="#{{ ::viewName }}/new">
            ${message(code: 'todo.is.ui.release.new')}
        </a>
    </div>
</div>