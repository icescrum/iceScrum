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
<div>
    <button type="button"
            class="btn btn-primary"
            ng-click="goToNewRelease()">
        ${message(code: 'todo.is.ui.release.new')}
    </button>
    <button type="button"
            class="btn btn-primary"
            ng-click="goToNewSprint(release)">
        ${message(code: 'todo.is.ui.sprint.new')}
    </button>
    <div>
        <div ng-repeat="release in releases | orderBy: 'orderNumber'"
             style="margin:20px;"
             class="pull-left"
             ng-controller="releaseCtrl">
            <div ng-click="goToRelease(release)"
                 class="pull-left"
                 uib-tooltip="{{ release.state | i18n: 'ReleaseStates' }}">
                {{ release.name }}
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
            <div>
                <div ng-repeat="sprint in release.sprints | orderBy: 'orderNumber'"
                     class="pull-left"
                     style="margin:10px;"
                     ng-controller="sprintCtrl"
                     ng-click="goToSprint(sprint)"
                     uib-tooltip="{{ sprint.state | i18n: 'SprintStates' }} {{ sprint.startDate | date: message('is.date.format.short') }} -> {{ sprint.endDate | date: message('is.date.format.short') }}">
                    {{ sprint.orderNumber }}
                    <input type="checkbox"
                           ng-click="$event.stopPropagation()"
                           ng-change="updateSelectedSprints()"
                           ng-model="selectedSprintsModel[sprint.id]">
                    <div class="btn-group"
                         uib-dropdown
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
    </div>
</div>
<div class="panel panel-light pull-left"
     ng-repeat="sprint in selectedSprints"
     ng-controller="sprintBacklogCtrl">
    <div class="panel-header">
        {{ sprint.parentRelease.name }} {{ sprint.orderNumber }}
    </div>
    <div class="panel-body">
        <div class="postits grid-group pull-left"
             ng-include="'story.html'">
        </div>
    </div>
</div>