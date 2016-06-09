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
<div class="tasks panel-body">
    <table class="table">
        <tr ng-repeat="task in selected.tasks | orderBy: tasksOrderBy">
            <td class="content {{:: authorizedTask('delete', task) ? 'toggle-container' : '' }}">
                <div class="clearfix no-padding">
                    <div class="col-sm-1">
                        <button class="btn btn-default elemid toggle-hidden"
                                disabled="disabled">{{ task.uid }}</button>
                        <button class="btn btn-danger toggle-visible"
                                ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [task] })"
                                uib-tooltip="${message(code:'default.button.delete.label')}"><i class="fa fa-times"></i>
                        </button>
                    </div>
                    <div class="form-group col-sm-8">
                        <span class="name form-control-static">
                            <a ng-if="!isModal"
                               ui-sref=".task.details({taskId: task.id})">{{ task.name }}</a>
                            <span ng-if="isModal">{{ task.name }}</span>
                        </span>
                    </div>
                    <div class="form-group col-sm-3">
                        <span class="form-control-static text-right">{{ task.estimation != undefined ? task.estimation : '?' }} <i class="small-icon fa {{ task.state | taskStateIcon }}"></i></span>
                    </div>
                </div>
                <div class="clearfix no-padding" ng-if="task.description">
                    <p class="description form-control-static" ng-bind-html="task.description | lineReturns | sanitize"></p>
                </div>
                <hr ng-if="!$last"/>
            </td>
        </tr>
        <tr ng-show="selected.tasks !== undefined && !selected.tasks.length">
            <td class="empty-content">
                <small>${message(code:'todo.is.ui.task.empty')}</small>
            </td>
        </tr>
    </table>
</div>
<div class="panel-footer">
    <div ng-if="authorizedTask('create', {parentStory: selected})" ng-include="'story.task.new.html'"></div>
</div>
</script>