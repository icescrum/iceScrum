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
<script type="text/ng-template" id="sprint.multiple.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title row">
            <div class="left-title">
                ${ message(code: 'todo.is.ui.sprints') } ({{ sprints.length }})
            </div>
            <div class="right-title">
                <a class="btn visible-on-hover btn-default"
                   href="{{:: $state.href('^') }}"
                   uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                    <i class="fa fa-times"></i>
                </a>
            </div>
        </h3>
    </div>
    <div class="panel-body">
        <div class="btn-toolbar" ng-if="authorizedSprints('autoPlan', sprints) || authorizedSprints('unPlan', sprints)">
            <div ng-if="authorizedSprints('autoPlan', sprints)"
                 class="btn-group">
                <button type="button"
                        class="btn btn-default"
                        ng-click="showAutoPlanModal({callback: autoPlanMultiple, args: [sprints]})">
                    <g:message code='is.ui.releasePlan.toolbar.autoPlan'/>
                </button>
            </div>
            <div ng-if="authorizedSprints('unPlan', sprints)"
                 class="btn-group">
                <button type="button"
                        class="btn btn-default"
                        ng-click="unPlanMultiple(sprints)">
                    <g:message code='is.ui.releasePlan.menu.sprint.dissociateAll'/>
                </button>
            </div>
        </div>
        <br/>
        <div class="table-responsive">
            <table class="table">
                <tr><td>${message(code: 'is.release')}</td><td>{{ release.name }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.startDate')}</td><td>{{ startDate | dayShort }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.endDate')}</td><td>{{ endDate | dayShort }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.story.sum')}</td><td>{{ sumStory }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.story.mean')}</td><td>{{ meanStory }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.velocity.mean')}</td><td>{{ meanVelocity }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.capacity.mean')}</td><td>{{ meanCapacity }}</td></tr>
            </table>
        </div>
    </div>
</div>
</script>