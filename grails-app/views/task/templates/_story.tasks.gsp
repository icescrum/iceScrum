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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<script type="text/ng-template" id="story.tasks.html">
<tr ng-show="story.tasks === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="task in story.tasks | orderBy:'dateCreated'" ng-controller="taskCtrl">
    <td>
        <div class="content">
            <div class="pull-right">
                <button class="btn btn-xs btn-danger"
                        type="button"
                        tooltip-placement="left"
                        tooltip="${message(code:'todo.is.ui.task.delete')}"
                        ng-if="deletable()"
                        ng-click="confirm('${message(code: 'is.confirm.delete')}', delete, [task, story])"><span class="fa fa-times"></span></button>
            </div>
            <div>
                <span class="label label-default"
                      tooltip-placement="left"
                      tooltip="${message(code: 'is.backlogelement.id')}">{{ task.uid }}</span>
                <strong>{{ task.name }}</strong>
            </div>
            <div class="pretty-printed"
                 ng-bind-html="task.description | lineReturns | sanitize">
            </div>
        </div>
    </td>
</tr>
<tr ng-show="!story.tasks.length">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.task.empty')}</small>
    </td>
</tr>
</script>