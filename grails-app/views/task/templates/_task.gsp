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
     class="postit postit-small {{ task.color | contrastColor }}">
    <div class="head">
        <span class="id">{{ ::task.uid }}</span>
        <span class="estimation editable"
              uib-tooltip="${message(code: 'is.task.estimation')}"
              tooltip-append-to-body="true">
            {{ task.estimation != undefined ? task.estimation : '?' }} <i class="fa fa-dollar"></i>
        </span>
    </div>
    <div class="content"
         as-sortable-item-handle>
        <h3 class="title ellipsis-el"
            ng-model="task.name"
            ng-bind-html="task.name | sanitize"></h3>
        <div class="description ellipsis-el"
             ng-model="task.description"
             ng-bind-html="task.description | sanitize"></div>
    </div>
    <div class="tags">
        <a ng-repeat="tag in task.tags" href="#"><span class="tag">{{ tag }}</span></a>
    </div>
    <div class="actions">
        <span uib-dropdown class="action">
            <a uib-dropdown-toggle
               uib-tooltip="${message(code: 'todo.is.ui.actions')}"
               tooltip-append-to-body="true">
                <i class="fa fa-cog"></i>
            </a>
            <ul class="uib-dropdown-menu"
                ng-include="'task.menu.html'"></ul>
        </span>
        <span class="action" ng-class="{'active':task.attachments.length}">
            <a href="#/{{ ::viewName }}/{{ task.id }}"
               uib-tooltip="{{ task.attachments.length | orElse: 0 }} ${message(code:'todo.is.ui.backlogelement.attachments.count')}"
               tooltip-append-to-body="true">
                <i class="fa fa-paperclip"></i>
                <span class="badge" ng-show="task.attachments.length">{{ task.attachments.length }}</span>
            </a>
        </span>
    </div>
</div>
</script>