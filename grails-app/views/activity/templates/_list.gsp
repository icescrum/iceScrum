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
<div class="activities panel-body" ng-controller="activityCtrl">
    <div ng-repeat="groupedActivity in groupedActivities">
        <div class="activity">
            <div class="media-left">
                <img ng-src="{{groupedActivity.poster | userAvatar}}" class="{{ groupedActivity.poster | userColorRoles }}" alt="{{groupedActivity.poster | userFullName}}"/>
            </div>
            <div class="media-body">
                <div class="text-muted pull-right">
                    <time timeago datetime="{{ groupedActivity.dateCreated }}">
                        {{ groupedActivity.dateCreated | dateTime }}
                    </time>
                    <i class="fa fa-clock-o"></i>
                </div>
                <div>{{groupedActivity.poster | userFullName}}</div>
                <ul>
                    <li ng-repeat="activity in groupedActivity.activities">
                        <span uib-tooltip="{{:: activity.dateCreated | dateTime }}">{{:: activity.text }}</span>
                        <a ng-if="activity.onClick !== undefined"
                           ng-click="activity.onClick()"
                           href>
                            {{ (activity.label | limitTo: 50) + (activity.label.length > 50 ? '...' : '') }}
                        </a>
                        <span ng-if="(activity.beforeValue != null || activity.afterValue != null) && activity.code == 'update'">
                            ${message(code: 'is.fluxiable.updateField.newValue')} <em>{{:: activity.afterValue != null && activity.afterValue != '' ? activity.afterValue : '_' }}</em>
                        </span>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <hr/>
    <div ng-if="selected.activities.length >= 10"
         ng-switch="allActivities"
         class="text-center">
        <button ng-switch-default
                class="btn btn-default"
                ng-click="activities(selected, true)">
            <i class="fa fa-plus-square"></i> ${message(code: 'todo.is.ui.history.more')}
        </button>
        <button ng-switch-when="true"
                class="btn btn-default"
                ng-click="activities(selected, false)">
            <i class="fa fa-minus-square"></i> ${message(code: 'todo.is.ui.history.less')}
        </button>
    </div>
</div>
</script>
