%{--
- Copyright (c) 2015 Kagilum SAS
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
<div class="no-flex" ng-controller="dashboardCtrl">
    <div class="panel-column">
        <div class="panel panel-light" ng-controller="chartCtrl" ng-init="initProjectChart('burnup')">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-area-chart"></i> <g:message code="is.ui.project.chart.title"/>
                    <div class="btn-toolbar pull-right visible-on-hover"
                         uib-dropdown>
                        <button class="btn btn-default btn-sm"
                                ng-click="saveChart()"
                                type="button">
                            <span class="fa fa-floppy-o"></span>
                        </button>
                        <button class="btn btn-default btn-sm"
                                uib-tooltip="${message(code:'todo.is.ui.charts')}"
                                tooltip-append-to-body="true"
                                type="button"
                                uib-dropdown-toggle>
                            <span class="fa fa-bar-chart"></span>&nbsp;<span class="caret"></span>
                        </button>
                        <ul class="uib-dropdown-menu">
                            <li role="presentation" class="dropdown-header">${message(code: 'is.product')}</li>
                            <li><a href ng-click="openProjectChart('flowCumulative')">${message(code: 'is.ui.project.charts.productCumulativeFlow')}</a></li>
                            <li><a href ng-click="openProjectChart('burnup')">${message(code: 'is.ui.project.charts.productBurnup')}</a></li>
                            <li><a href ng-click="openProjectChart('burndown')">${message(code: 'is.ui.project.charts.productBurndown')}</a></li>
                            <li><a href ng-click="openProjectChart('parkingLot')">${message(code: 'is.ui.project.charts.productParkingLot')}</a></li>
                            <li><a href ng-click="openProjectChart('velocity')">${message(code: 'is.ui.project.charts.productVelocity')}</a></li>
                            <li><a href ng-click="openProjectChart('velocityCapacity')">${message(code: 'is.ui.project.charts.productVelocityCapacity')}</a></li>
                            <li ng-if="release.id" class="divider"></li>
                            <li ng-if="release.id" role="presentation" class="dropdown-header">${message(code: 'is.release')}</li>
                            <li ng-if="release.id"><a href ng-click="openReleaseChart('burndown', release)">${message(code: 'is.chart.releaseBurndown')}</a></li>
                            <li ng-if="release.id"><a href ng-click="openReleaseChart('parkingLot', release)">${message(code: 'is.chart.releaseParkingLot')}</a></li>
                            <li ng-if="release.id"><a href ng-click="openMoodChart('releaseUserMood')">${message(code: 'is.chart.releaseUserMood')}</a></li>
                            <li ng-if="currentOrLastSprint.id" class="divider"></li>
                            <li ng-if="currentOrLastSprint.id" role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</li>
                            <li ng-if="currentOrLastSprint.id"><a href ng-click="openSprintChart('burndownRemaining', currentOrLastSprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurndownRemainingChart')}</a></li>
                            <li ng-if="currentOrLastSprint.id"><a href ng-click="openSprintChart('burnupTasks', currentOrLastSprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurnupTasksChart')}</a></li>
                            <li ng-if="currentOrLastSprint.id"><a href ng-click="openSprintChart('burnupPoints', currentOrLastSprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurnupPointsChart')}</a></li>
                            <li ng-if="currentOrLastSprint.id"><a href ng-click="openSprintChart('burnupStories', currentOrLastSprint)">${message(code: 'is.ui.sprintPlan.charts.sprintBurnupStoriesChart')}</a></li>
                            <li ng-if="currentOrLastSprint.id"><a href ng-click="openMoodChart('sprintUserMood')">${message(code: 'is.chart.sprintUserMood')}</a></li>
                        </ul>
                    </div>
                </h3>
            </div>
            <div class="panel-body">
                <nvd3 options="options" data="data"></nvd3>
            </div>
        </div>
        <div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-picture-o"></i> <g:message code="is.ui.project.vision.title"/>
                    <button class="btn btn-default btn-sm pull-right visible-on-hover"
                            ng-if="authorizedRelease('update', release)"
                            type="button">
                        <span class="fa fa-pencil"></span>
                    </button>
                </h3>
            </div>
            <div class="panel-body"
                 ng-bind-html="(release.vision_html ? release.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>') | sanitize">
            </div>
        </div>
        <div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-check-square-o"></i> <g:message code="is.ui.project.doneDefinition.title"/>
                    <button class="btn btn-default btn-sm pull-right visible-on-hover"
                            ng-if="authorizedSprint('update', currentOrLastSprint)"
                            type="button">
                        <span class="fa fa-pencil"></span>
                    </button>
                </h3>
            </div>
            <div class="panel-body"
                 ng-bind-html="(currentOrLastSprint.doneDefinition_html ? currentOrLastSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>') | sanitize">
            </div>
        </div>
        <div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-repeat"></i> <g:message code="is.ui.project.retrospective.title"/>
                    <button class="btn btn-default btn-sm pull-right visible-on-hover"
                            ng-if="authorizedSprint('update', currentOrLastSprint)"
                            type="button">
                        <span class="fa fa-pencil"></span>
                    </button>
                </h3>
            </div>
            <div class="panel-body"
                 ng-bind-html="(currentOrLastSprint.retrospective_html ? currentOrLastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>') | sanitize">
            </div>
        </div>
    </div>
    <div class="panel-column">
        <div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-bolt"></i> <g:message code="is.ui.project.activity.title"/>
                    <small class="pull-right">
                        <g:link class="rss" data-toggle="tooltip" title="${message(code:'todo.is.ui.rss')}" mapping="${product.preferences.hidden ? 'privateURL' : ''}" action="feed" params="[product:product.pkey,lang:lang]">
                            <i class="fa fa-rss fa-lg visible-on-hover"></i>
                        </g:link>
                    </small>
                </h3>
            </div>
            <div class="panel-body activities panel-light">
                <div ng-repeat="activity in activities">
                    <div class="activity">
                        <div class="media-left">
                            <img ng-src="{{activity.poster | userAvatar}}"
                                 alt="{{activity.poster | userFullName}}"/>
                        </div>
                        <div class="media-body">
                            <div class="text-muted pull-right">
                                <time timeago datetime="{{ activity.dateCreated }}">
                                    {{ activity.dateCreated | dateTime }}
                                </time>
                                <i class="fa fa-clock-o"></i>
                            </div>
                            <div>
                                {{activity.poster | userFullName}}
                            </div>
                            <div>
                                <span class="{{ activity | activityIcon}}"></span>
                                <span>{{ message('is.fluxiable.' + activity.code ) }} <strong>{{ activity.label }}</strong></span>
                            </div>
                        </div>
                    </div>
                    <hr>
                </div>
                <div ng-if="activities != undefined && activities.length == 0" class="panel-box-empty">
                    <div style="text-align: center; padding:5px; font-size:14px;">
                        <a class="scrum-link" target="_blank" href="https://www.icescrum.com/documentation/getting-started-with-icescrum?utm_source=dashboard&utm_medium=link&utm_campaign=icescrum">${message(code:'is.ui.getting.started')}</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>