%{--
- Copyright (c) 2015 Kagilum.
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

<script type="text/ng-template" id="task.html">
<div sticky-note-color="{{:: task.color }}"
     class="sticky-note"
     ng-class=":: ['task', (task.color | contrastColor), { 'task-blocked': task.blocked }]">
    <div as-sortable-item-handle="authorizedTask('rank', task)">
        <div class="sticky-note-head">
            <span class="id">{{:: task.uid }}</span>
            <span class="avatar"><img ng-src="{{:: task.responsible | userAvatar }}"
                     ng-if=":: task.responsible"
                     class="responsible"
                     defer-tooltip="{{:: task.responsible | userFullName }}"></span>
        </div>
        <div class="sticky-note-content" ng-class="::{'has-description':!!task.description}">
            <div class="item-values">
                <span ng-if=":: task.estimation != 0">
                    ${message(code: 'is.task.estimation')} <strong ng-click="showEditEstimationModal(task, $event)">{{:: task.estimation != undefined ? task.estimation : '?' }}</strong>
                </span>
            </div>
            <div class="title">{{:: task.name }}</div>
            <div class="description" ng-bind-html=":: task.description | lineReturns"></div>
        </div>
        <div class="sticky-note-tags">
            <icon-badge class="float-right" tooltip="${message(code: 'is.backlogelement.tags')}"
                        href="#/{{:: viewName }}/{{:: sprint.id }}/task/{{:: task.id }}"
                        icon="fa-tags"
                        max="3"
                        hide="true"
                        count="{{:: task.tags.length }}"></icon-badge>
            <a ng-repeat="tag in ::task.tags"
               href="{{:: tagContextUrl(tag) }}">
                <span class="tag {{ getTagColor(tag) | contrastColor }}"
                      ng-style="{'background-color': getTagColor(tag) }">{{:: tag }}</span>
            </a>
        </div>
        <div class="sticky-note-actions">
            <icon-badge tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}"
                        href="#/{{:: viewName }}/{{:: sprint.id }}/task/{{:: task.id }}"
                        icon="attach"
                        count="{{:: task.attachments_count }}"></icon-badge>
            <icon-badge classes="comments"
                        tooltip="${message(code: 'todo.is.ui.comments')}"
                        href="#/{{:: viewName }}/{{:: sprint.id }}/task/{{:: task.id }}/comments"
                        icon="comment"
                        count="{{:: task.comments_count }}"></icon-badge>
            <span class="action" ng-if="::authorizedTask('take', task)">
                <a href
                   class="action-link"
                   ng-click="take(task)"
                   defer-tooltip="${message(code: 'is.ui.sprintPlan.menu.task.take')}">
                    <span class="action-icon action-icon-take"></span>
                </a>
            </span>
            <span class="action" ng-if="::authorizedTask('release', task)">
                <a href
                   class="action-link"
                   ng-click="release(task)"
                   defer-tooltip="${message(code: 'is.ui.sprintPlan.menu.task.unassign')}">
                    <span class="action-icon action-icon-unassign"></span>
                </a>
            </span>
            <span sticky-note-menu="item.menu.html" ng-init="itemType = 'task'" class="action"><a class="action-link"><span class="action-icon action-icon-menu"></span></a></span>
        </div>
        <entry:point id="task-sticky-note-bottom"/>
    </div>
</div>
</script>