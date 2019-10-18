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

<script type="text/ng-template" id="task.light.html">
<div sticky-note-color="{{:: task.color }}"
     class="sticky-note"
     ng-class=":: ['task', (task.color | contrastColor), { 'task-blocked': task.blocked }]"
     ng-controller="taskCtrl">
    <div>
        <div class="sticky-note-head">
            <span class="id"><a href="{{ link }}">{{:: task.uid }}</a></span>
        </div>
        <div class="sticky-note-content" ng-class="::{'has-description':!!task.description}">
            <div class="item-values">
                <span ng-if=":: task.estimation != 0">
                    ${message(code: 'is.task.estimation')} <strong ng-click="showEditEstimationModal(task, $event)">{{:: task.estimation != undefined ? task.estimation : '?' }}</strong>
                </span>
            </div>
            <a href="{{ link }}">
                <div class="title">{{:: task.name }}</div>
                <div class="description" ng-bind-html=":: task.description | lineReturns"></div>
            </a>
        </div>
        <div class="sticky-note-tags">
            <a ng-repeat="tag in ::task.tags" href>
                <span class="tag {{ getTagColor(tag) | contrastColor }}"
                      ng-style="{'background-color': getTagColor(tag) }">{{:: tag }}</span>
            </a>
        </div>
        <div class="sticky-note-actions">
            <span class="action" ng-class=":: {'active':task.attachments_count}">
                <a class="action-link" href="{{:: link }}" defer-tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}">
                    <span class="action-icon action-icon-attach"></span>
                    <span class="badge">{{ task.attachments_count || '' }}</span>
                </a>
            </span>
            <span class="action" ng-class=":: {'active':task.comments_count}">
                <a class="action-link" href="{{:: link }}" defer-tooltip="${message(code: 'todo.is.ui.comments')}">
                    <span class="action-icon action-icon-comment"></span>
                    <span class="badge">{{ task.comments_count || '' }}</span>
                </a>
            </span>
            <span class="action">
                <a class="action-link" href="{{:: link }}">
                    <span class="action-icon action-icon-unassign"></span>
                </a>
            </span>
            <span class="action">
                <a class="action-link" href="{{:: link }}">
                    <span class="action-icon action-icon-menu"></span>
                </a>
            </span>
        </div>
    </div>
</div>
</script>