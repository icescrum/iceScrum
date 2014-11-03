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
<div ng-if="story">
    <table ng-init="tasks(story)" ng-controller="taskCtrl" class="table">
        <tbody ng-if="authorizedTask('create')" ng-include="'story.task.new.html'"></tbody>
    </table>
    <table class="table">
        <tr ng-show="story.tasks === undefined">
            <td class="empty-content">
                <i class="fa fa-refresh fa-spin"></i>
            </td>
        </tr>
        <tr ng-repeat="task in story.tasks | orderBy:'dateCreated'" ng-controller="taskCtrl">
            <td>
                <div class="content form-editable" ng-mouseover="showDelete=authorizedTask('delete', task)" ng-mouseleave="showDelete=false">
                    <div class="clearfix no-padding">
                        <div class="col-sm-1" ng-switch="showDelete">
                            <button ng-switch-default
                                    class="btn btn-default elemid"
                                    disabled="disabled">{{ task.uid }}</button>
                            <button ng-switch-when="true"
                                    class="btn btn-danger"
                                    ng-click="confirm({ message: '${message(code: 'is.confirm.delete')}', callback: delete, args: [task, story] })"
                                    tooltip-placement="left"
                                    tooltip-append-to-body="true"
                                    tooltip="${message(code:'todo.is.ui.task.delete')}"><span class="fa fa-times"></span>
                            </button>
                        </div>
                        <div class="form-group col-sm-8">
                            <span class="form-control form-control-static">{{ task.name }}</span>
                        </div>
                        <div class="form-group col-sm-3">
                            <span class="form-control form-control-static text-right">{{ task.estimation }}</span>
                        </div>
                    </div>
                    <div class="clearfix no-padding" ng-if="task.description">
                        <p class="form-control form-control-static" ng-bind-html="task.description | lineReturns | sanitize"></p>
                    </div>
                </div>
            </td>
        </tr>
        <tr ng-show="!story.tasks.length">
            <td class="empty-content">
                <small>${message(code:'todo.is.ui.task.empty')}</small>
            </td>
        </tr>
    </table>
</div>
</script>