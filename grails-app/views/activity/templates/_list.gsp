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
<div class="activities panel-body">
    <div class="empty-content" ng-show="selected.activities === undefined">
        <i class="fa fa-refresh fa-spin"></i>
    </div>

    <div ng-repeat="groupedActivity in groupedActivities">
        <div class="activity">
            <div class="media-left">
                <img ng-src="{{groupedActivity.poster | userAvatar}}" alt="{{groupedActivity.poster | userFullName}}"/>
            </div>

            <div class="media-body">
                <div class="text-muted pull-right">
                    <time timeago datetime="{{ groupedActivity.dateCreated }}">
                        {{ groupedActivity.dateCreated }}
                    </time>
                    <i class="fa fa-clock-o"></i>
                </div>

                <div>{{groupedActivity.poster | userFullName}}</div>

                <div ng-switch="activity.onClick !== undefined" ng-repeat="activity in groupedActivity.activities">
                    <span uib-tooltip="{{ activity.dateCreated }}"
                          tooltip-append-to-body="true"
                          class="{{ activity | activityIcon}}"
                          ng-class="{ 'important-activity' : activity.important }"></span>
                    <span ng-switch-default>
                        {{ message('is.fluxiable.' + activity.code )}} {{ activity.field ? activity.field : ''}} {{ activity.count > 1 ? '(x' + activity.count + ')' : ''}}
                    </span>
                    <span ng-switch-when="true">
                        <a href ng-click="activity.onClick()">
                            {{ message('is.fluxiable.' + activity.code )}} {{ activity.field ? activity.field : ''}} {{ activity.count > 1 ? '(x' + activity.count + ')' : ''}}
                        </a>
                    </span>
                    <span ng-if="activity.beforeValue != null || activity.afterValue != null">
                        <i class="fa fa-question"
                           ng-if="activity.beforeValue == null"></i>{{ activity.beforeValue != '' ? activity.beforeValue : '' }} <i
                            class="fa fa-arrow-right"></i> <i class="fa fa-question"
                                                              ng-if="activity.afterValue == null"></i>{{ activity.afterValue != '' ? activity.afterValue : '' }}
                    </span>
                </div>
            </div>
        </div>
        <hr/>
    </div>

    <div ng-if="selected.activities.length >= 10" ng-switch="allActivities" class="text-center">
        <button ng-switch-default class="btn btn-default" ng-click="activities(selected, true)"><i
                class="fa fa-plus-square"></i> ${message(code: 'tood.is.ui.activities.more')}</button>
        <button ng-switch-when="true" class="btn btn-default" ng-click="activities(selected, false)"><i
                class="fa fa-minus-square"></i> ${message(code: 'tood.is.ui.activities.less')}</button>
    </div>
</div>
</script>
