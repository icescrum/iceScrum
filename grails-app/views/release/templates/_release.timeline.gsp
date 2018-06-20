%{--
- Copyright (c) 2016 Kagilum.
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
<script type="text/ng-template" id="release.timeline.html">
<uib-progress class="form-control-static form-bar"
              defer-tooltip="{{ release.name }}"
              max="release.duration">
    <uib-bar ng-repeat="sprint in releaseParts"
             class="{{ $last ? 'last-bar' : '' }}"
             uib-tooltip-template="'sprint.tooltip.html'"
             tooltip-enable="sprint.id"
             tooltip-placement="bottom"
             type="{{ sprint.id ? { 1: 'todo', 2: 'inProgress', 3: 'done' }[sprint.state] : 'invisible' }}"
             value="sprint.duration">
        {{ sprint.id ? sprint.index : '' }}
    </uib-bar>
    <div class="progress-empty" ng-if="release.sprints != undefined && release.sprints.length == 0">${message(code: 'todo.is.ui.nosprint')}</div>
</uib-progress>
</script>
<script type="text/ng-template" id="release.timeline.href.html">
<uib-progress class="form-control-static form-bar"
              defer-tooltip="{{ release.name }}"
              max="release.duration">
    <a href="{{ sprint.id ? openSprintUrl(sprint) : '' }}"
       ng-class="{'disabled-link':!sprint.id}"
       ng-repeat="sprint in releaseParts">
        <uib-bar class="{{ $last ? 'last-bar' : '' }}"
                 uib-tooltip-template="'sprint.tooltip.html'"
                 tooltip-enable="sprint.id"
                 tooltip-placement="bottom"
                 type="{{ sprint.id ? { 1: 'todo', 2: 'inProgress', 3: 'done' }[sprint.state] : 'invisible' }}"
                 value="sprint.duration">
            {{ sprint.id ? sprint.index : '' }}
        </uib-bar>
    </a>
    <div class="progress-empty" ng-if="release.sprints != undefined && release.sprints.length == 0">${message(code: 'todo.is.ui.nosprint')}</div>
</uib-progress>
</script>