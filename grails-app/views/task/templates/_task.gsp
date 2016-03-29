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
<div style="{{ task.color | createGradientBackground }}"
     ng-class="{'task-blocked': task.blocked}"
     class="postit postit-small {{ task.color | contrastColor }}">
    <div class="head">
        <div class="head-left">
            <span class="id">{{ ::task.uid }}</span>
            <img ng-src="{{ task.responsible | userAvatar }}"
                 ng-if="task.responsible"
                 class="responsible"
                 uib-tooltip="{{ task.responsible | userFullName }}">
        </div>
        <div class="head-right">
            <span class="remaining-time editable"
                  ng-if="task.estimation != 0"
                  uib-tooltip="${message(code: 'is.task.estimation')}">
                {{ task.estimation != undefined ? task.estimation : '?' }} <i class="fa {{ task.state | taskStateIcon }}"></i>
            </span>
        </div>
    </div>
    <div class="content"
         as-sortable-item-handle-if="authorizedTask('rank', task)">
        <h3 class="title"
            ng-model="task.name"
            ng-bind-html="task.name | sanitize"></h3>
    </div>
    <div class="tags">
        <a ng-repeat="tag in task.tags" ng-click="setTagContext(tag)" href><span class="tag">{{ tag }}</span></a>
    </div>
    <div class="actions">
        <span postit-menu="task.menu.html" class="action"><a><i class="fa fa-cog"></i></a></span>
        <span class="action" ng-class="{'active':task.attachments.length}">
            <a href="#/{{ ::viewName }}/task/{{ ::task.id }}"
               uib-tooltip="${message(code:'todo.is.ui.backlogelement.attachments')}">
                <i class="fa fa-paperclip"></i>
                <span class="badge">{{ task.attachments.length || '' }}</span>
            </a>
        </span>
        <span class="action" ng-class="{'active':task.comments_count}">
            <a href="#/{{ ::viewName }}/task/{{ ::task.id }}/comments"
               uib-tooltip="${message(code:'todo.is.ui.comments')}">
                <i class="fa" ng-class="task.comments_count ? 'fa-comment' : 'fa-comment-o'"></i>
                <span class="badge">{{ task.comments_count || '' }}</span>
            </a>
        </span>
        <span class="action" ng-if="authorizedTask('take', task)">
            <a href
               ng-click="take(task)"
               uib-tooltip="${message(code:'is.ui.sprintPlan.menu.task.take')}">
                <i class="fa fa-user-plus"></i>
            </a>
        </span>
        <span class="action" ng-if="authorizedTask('release', task)">
            <a href
               ng-click="release(task)"
               uib-tooltip="${message(code:'is.ui.sprintPlan.menu.task.unassign')}">
                <i class="fa fa-user-times"></i>
            </a>
        </span>
    </div>
</div>
</script>