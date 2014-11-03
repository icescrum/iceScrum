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
<script type="text/ng-template" id="activity.list.html">
<tr ng-show="getSelected().activities === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="groupedActivity in groupedActivities">
    <td>
        <img height="21px"
             ng-src="{{groupedActivity.poster | userAvatar}}"
             alt="{{groupedActivity.poster | userFullName}}"/>
        <span class="text-muted">
            <time timeago datetime="'{{ groupedActivity.dateCreated }}'">
                {{ groupedActivity.dateCreated }}
            </time>
            <i class="fa fa-clock-o"></i>
        </span>
        <div ng-repeat="activity in groupedActivity.activities">
            <p ng-switch="activity.onClick !== undefined">
                <span style="width:15px; text-align: center"
                      tooltip="{{ activity.dateCreated }}"
                      tooltip-append-to-body="true"
                      class="{{ activity | activityIcon}}"></span>
                <span ng-switch-default>
                    {{ message('todo.is.ui.activity.' + activity.code )}} {{ activity.field ? activity.field : ''}} {{ activity.count > 1 ? '(x' + activity.count + ')' : ''}}
                </span>
                <span ng-switch-when="true">
                    <a href ng-click="activity.onClick()">
                        {{ message('todo.is.ui.activity.' + activity.code )}} {{ activity.field ? activity.field : ''}} {{ activity.count > 1 ? '(x' + activity.count + ')' : ''}}
                    </a>
                </span>
                <span ng-if="activity.beforeValue != null || activity.afterValue != null">
                    <i class="fa fa-question" ng-if="activity.beforeValue == null"></i>{{ activity.beforeValue != '' ? activity.beforeValue : '' }} <i class="fa fa-arrow-right"></i> <i class="fa fa-question" ng-if="activity.afterValue == null"></i>{{ activity.afterValue != '' ? activity.afterValue : '' }}
                </span>
            </p>
        </div>
    </td>
</tr>
<tr ng-if="getSelected().activities && getSelected().activities.length >= 10">
    <td ng-switch="allActivities">
        <button ng-switch-default class="btn btn-default" ng-click="activities(getSelected(), true)"><i class="fa fa-plus-square"></i> ${ message(code: 'tood.is.ui.activities.more')}</button>
        <button ng-switch-when="true" class="btn btn-default" ng-click="activities(getSelected(), false)"><i class="fa fa-minus-square"></i> ${ message(code: 'tood.is.ui.activities.less')}</button>
    </td>
</tr>
<tr ng-show="!getSelected().activities && getSelected().activities !== undefined">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.activity.empty')}</small>
    </td>
</tr>
</script>