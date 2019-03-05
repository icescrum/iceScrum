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
     ng-class=":: ['task', application.stickyNoteSize.task, (task.color | contrastColor), { 'task-blocked': task.blocked }]"
     ng-controller="taskCtrl">
    <div>
        <div class="sticky-note-head">
            <span class="id">{{:: task.uid }}</span>
        </div>
        <div class="sticky-note-content" ng-class="::{'has-description':!!task.description}">
            <div class="item-values">
                <span ng-if=":: task.estimation != 0"
                      ng-click="showEditEstimationModal(task, $event)">
                    ${message(code: 'is.task.estimation')} <strong>{{:: task.estimation != undefined ? task.estimation : '?' }}</strong>
                </span>
            </div>
            <div class="title"><a href="{{ link }}" style="color: #555555; text-decoration:none;">{{:: task.name }}</a></div>
            <div class="description" ng-bind-html=":: task.description | lineReturns"></div>
        </div>
        <div class="sticky-note-tags">
            <a ng-repeat="tag in ::task.tags" href>
                <span class="tag {{ getTagColor(tag, 'task') | contrastColor }}"
                      ng-style="{'background-color': getTagColor(tag, 'task') }">{{:: tag }}</span>
            </a>
        </div>
        <div class="sticky-note-actions">
            <span class="action" ng-class=":: {'active':task.attachments_count}">
                <span defer-tooltip="${message(code: 'todo.is.ui.backlogelement.attachments')}">
                    <a href="{{:: link }}">
                        <i class="fa fa-paperclip"></i>
                        <span class="badge">{{ task.attachments_count || '' }}</span>
                    </a>
                </span>
            </span>
            <span class="action" ng-class=":: {'active':task.comments_count}">
                <span defer-tooltip="${message(code: 'todo.is.ui.comments')}">
                    <a href="{{:: link }}">
                        <i class="fa" ng-class=":: task.comments_count ? 'fa-comment' : 'fa-comment-o'"></i>
                        <span class="badge">{{ task.comments_count || '' }}</span>
                    </a>
                </span>
            </span>
        </div>
    </div>
</div>
</script>