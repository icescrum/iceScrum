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
<div class="backlogs-list">
    <div class="timeline" project-timeline="project"></div>
    <hr>
</div>

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

.timeline .grid line,
.timeline .grid path {
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
<div class="backlogs-list-details">
    <div class="panel panel-light"
         ng-repeat="sprint in selectedSprints"
         ng-controller="sprintBacklogCtrl">
        <div class="panel-heading">
            <h3 class="panel-title">
                <a href="#/{{ ::viewName }}/sprint/{{ ::sprint.id }}">{{ sprint.parentRelease.name }} {{ sprint.orderNumber }}</a>
                <div class="btn-group pull-right visible-on-hover">
                    <button type="button"
                            class="btn btn-default"
                            ng-click="manageShownSprint(sprint)"
                            uib-tooltip="${message(code:'is.ui.window.closeable')}">
                        <span class="fa fa-times"></span>
                    </button>
                </div>
            </h3>
        </div>
        <div class="panel-body">
            <div class="postits {{ isSortingSprint(sprint) ? '' : 'sortable-disabled' }}"
                 as-sortable="sprintSortableOptions"
                 is-disabled="!isSortingSprint(sprint)"
                 ng-model="backlog.stories"
                 ng-class="app.asList ? 'list-group' : 'grid-group'"
                 ng-include="'story.backlog.html'">
            </div>
        </div>
    </div>
</div>