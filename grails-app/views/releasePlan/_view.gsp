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
    <div>
        <div ng-repeat="release in releases | orderBy: 'orderNumber'"
             style="margin:10px; padding:10px; border:1px solid #DCDCDC"
             class="pull-left"
             ng-controller="releaseCtrl">
            <div class="pull-left"
                 uib-tooltip="{{ release.state | i18n: 'ReleaseStates' }}">
                <a href
                   ng-click="goToRelease(release)">
                   {{ release.name }}
                </a>
                <div class="btn-group"
                     uib-dropdown
                     ng-if="authorizedRelease('update', release)"
                     uib-tooltip="${message(code: 'todo.is.ui.actions')}"
                     tooltip-append-to-body="true">
                    <button type="button" class="btn btn-small btn-default" uib-dropdown-toggle>
                        <span class="fa fa-cog"></span> <span class="caret"></span>
                    </button>
                    <ul class="uib-dropdown-menu" ng-include="'release.menu.html'"></ul>
                </div>
                <div>
                    {{ release.startDate | date: message('is.date.format.short') }} -> {{ release.endDate | date: message('is.date.format.short') }}
                </div>
            </div>
            <div style="clear:both">
                <div ng-repeat="sprint in release.sprints | orderBy: 'orderNumber'"
                     class="pull-left"
                     style="margin:5px; padding:10px; border: 1px solid #DCDCDC"
                     ng-controller="sprintCtrl"
                     uib-tooltip="{{ sprint.state | i18n: 'SprintStates' }} {{ sprint.startDate | date: message('is.date.format.short') }} -> {{ sprint.endDate | date: message('is.date.format.short') }}">
                    <div ng-click="manageShownSprint(sprint)"
                         style="margin: 0 4px;"
                         class="pull-left">
                        <i class="fa" ng-class="isShownSprint(sprint) ? 'fa-dot-circle-o' : 'fa-circle-o'"></i>
                    </div>
                    <a href ng-click="goToSprint(sprint)">
                        {{ sprint.orderNumber }}
                    </a>
                    <div class="btn-group pull-right"
                         uib-dropdown
                         style="margin: 0 4px;"
                         ng-if="authorizedSprint('update', sprint)"
                         uib-tooltip="${message(code: 'todo.is.ui.actions')}"
                         tooltip-append-to-body="true">
                        <button type="button" class="btn btn-small btn-default" uib-dropdown-toggle>
                            <span class="fa fa-cog"></span> <span class="caret"></span>
                        </button>
                        <ul class="uib-dropdown-menu" ng-include="'sprint.menu.html'"></ul>
                    </div>
                </div>
            </div>
        </div>
        <div class="btn-toolbar pull-right">
            <div class="btn-group btn-view visible-on-hover">
                <button type="button"
                        uib-tooltip="${message(code:'todo.is.ui.toggle.grid.list')}"
                        tooltip-append-to-body="true"
                        tooltip-placement="right"
                        ng-click="app.asList = !app.asList"
                        class="btn btn-default">
                    <span class="fa fa-th" ng-class="{'fa-th-list': app.asList, 'fa-th': !app.asList}"></span>
                </button>
                <g:if test="${params?.fullScreen}">
                    <button type="button"
                            class="btn btn-default"
                            ng-show="!app.isFullScreen"
                            ng-click="fullScreen()"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')} (F)"
                            tooltip-append-to-body="true"
                            tooltip-placement="bottom"
                            hotkey="{'F': fullScreen }"><span class="fa fa-expand"></span>
                    </button>
                    <button type="button"
                            class="btn btn-default"
                            ng-show="app.isFullScreen"
                            uib-tooltip="${message(code:'is.ui.window.fullscreen')}"
                            tooltip-append-to-body="true"
                            tooltip-placement="bottom"
                            ng-click="fullScreen()"><span class="fa fa-compress"></span>
                    </button>
                </g:if>
            </div>
            <a type="button"
               class="btn btn-primary"
               ng-if="authorizedRelease('create')"
               href="#{{ ::viewName }}/new">
                ${message(code: 'todo.is.ui.release.new')}
            </a>
            <a type="button"
               class="btn btn-primary"
               ng-if="authorizedSprint('create')"
               href="#{{ ::viewName }}/sprint/new">
                ${message(code: 'todo.is.ui.sprint.new')}
            </a>
        </div>
    </div>
    <hr style="clear: both"/>
</div>
<div class="backlogs-list-details">
    <div class="panel panel-light"
         ng-repeat="sprint in selectedSprints"
         ng-controller="sprintBacklogCtrl">
        <div class="panel-heading">
            <h3 class="panel-title">
                <a href ng-click="goToSprint(sprint)">
                    {{ sprint.parentRelease.name }} {{ sprint.orderNumber }}
                </a>
                <div class="btn-group pull-right visible-on-hover">
                    <button type="button"
                            class="btn btn-default"
                            tooltip-placement="bottom"
                            tooltip-append-to-body="true"
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
                 ng-include="'story.html'">
            </div>
        </div>
    </div>
</div>