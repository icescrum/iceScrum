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
<div class="activities card-body" ng-controller="activityCtrl">
    <div ng-repeat="groupedActivity in groupedActivities">
        <div class="activity media">
            <div class="{{ groupedActivity.poster | userColorRoles }} avatar mr-3">
                <img ng-src="{{groupedActivity.poster | userAvatar}}"
                     width="37"
                     height="37"
                     class="align-self-center"
                     alt="{{ groupedActivity.poster | userFullName}}"/>
            </div>
            <div class="media-body">
                <div class="time-stamp float-right">
                    <time timeago datetime="{{ groupedActivity.dateCreated }}">
                        {{ groupedActivity.dateCreated | dateTime }}
                    </time>
                </div>
                <div>{{groupedActivity.poster | userFullName}}</div>
                <ul>
                    <li ng-repeat="activity in groupedActivity.activities">
                        <span defer-tooltip="{{:: activity.dateCreated | dateTime }}">{{:: activity.text }}</span>
                        <a ng-if="activity.onClick !== undefined"
                           ng-click="activity.onClick()"
                           href>
                            {{ activity.label | ellipsis: 50 }}
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
    <div ng-if="(selected.activities.length < selected.activities_total) || allActivities"
         ng-switch="allActivities"
         class="text-center">
        <span ng-switch-default
              class="toggle-more"
              ng-click="activities(selected, true)">
            ${message(code: 'todo.is.ui.history.more')}
        </span>
        <span ng-switch-when="true"
              class="toggle-more toggle-invert"
              ng-click="activities(selected, false)">
            ${message(code: 'todo.is.ui.history.less')}
        </span>
    </div>
</div>
</script>
