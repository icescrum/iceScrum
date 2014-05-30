%{--
- Copyright (c) 2014 Kagilum.
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
--}%
<script type="text/ng-template" id="story.tasks.html">
<tr ng-show="selected.tasks === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="task in selected.tasks" ng-controller="taskCtrl">
    <td class="avatar">
        <img ng-src="{{task.creator | userAvatar}}"
             alt="{{task.creator | userFullName}}"
             tooltip="{{task.creator | userFullName}}"
             width="25px">
    </td>
    <td>
        <div class="content">
            <span class="clearfix text-muted"><a href="#">{{ task.name }}</a></span>
            {{ task.description }}
            <a href
                ng-if="deletable()"
                ng-click="delete(task, selected)"
                tooltip-placement="left"
                tooltip="${message(code:'todo.is.ui.task.delete')}"
                class="on-hover delete"><i class="fa fa-times text-danger"></i></a>
            <small class="clearfix text-muted">
                <time class='timeago' datetime='{{ task.dateCreated }}'>
                    {{ task.dateCreated }}
                </time> <i class="fa fa-clock-o"></i>
            </small>
        </div>
    </td>
</tr>
<tr ng-show="!selected.tasks.length">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.task.empty')}</small>
    </td>
</tr>
</script>