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
<div class="row" ng-controller="dashboardCtrl">
    <div class="panel-column">
        <div class="panel-container"><div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-home"></i> {{ project.name + ' (' + project.pkey + ')' }}
                    <button class="btn btn-default btn-sm pull-right visible-on-hover"
                            ng-if="authorizedProject('update', project)"
                            ng-click="showProjectEditModal()"
                            type="button">
                        <i class="fa fa-pencil"></i>
                    </button>
                </h3>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-5">
                        <div ng-bind-html="(project.description_html ? project.description_html : '<p>${message(code: 'todo.is.ui.project.nodescription')}</p>') | sanitize"></div>
                        <div ng-if="project.productOwners.length">
                            ${ message(code: 'todo.is.ui.project.productOwners')}
                            <div style="margin: 4px 0" ng-repeat="user in project.productOwners" ng-include="'user.item.html'"></div>
                        </div>
                    </div>
                    <div class="col-md-7 text-right">
                        <h4><i class="fa fa-users"></i> {{ project.team.name }}</h4>
                        <div style="margin: 4px 0" ng-repeat="user in project.team.members" ng-class="{'strong': user.scrumMaster}" ng-include="'user.item.html'"></div>
                    </div>
                </div>
                <div class="well">
                    <div class="row project-info">
                        <div class="col-md-6" style="text-align: left;"><i class="fa fa-sticky-note"></i> {{ project.stories_count }} ${ message(code: 'todo.is.ui.stories') }</div>
                        <div class="col-md-6" style="text-align: right;"><i class="fa fa-calendar"></i> {{ project.releases_count }} ${ message(code: 'todo.is.ui.releases') }</div>
                    </div>
                    <uib-progress class="form-control-static form-bar"
                                  uib-tooltip="{{ release.name }}"
                                  max="release.duration">
                        <uib-bar ng-repeat="sprint in release.sprints"
                                 class="{{ $last ? 'last-bar' : '' }}"
                                 uib-tooltip-template="'sprint.tooltip.html'"
                                 tooltip-placement="bottom"
                                 type="{{ { 1: 'default', 2: 'progress', 3: 'done' }[sprint.state] }}"
                                 value="sprint.duration">
                            #{{ sprint.orderNumber }}
                        </uib-bar>
                        <div class="progress-empty" ng-if="release.sprints != undefined && release.sprints.length == 0">${message(code: 'todo.is.ui.nosprint')}</div>
                    </uib-progress>
                    <div class="row project-rel-dates">
                        <div class="col-md-6">{{ release.startDate | date: message('is.date.format.short') }}</div>
                        <div class="col-md-6 text-right">{{ release.endDate | date: message('is.date.format.short') }}</div>
                    </div>
                </div>
            </div>
        </div></div>
        <div class="panel-container"><div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-picture-o"></i> <g:message code="is.ui.project.vision.title"/>
                    <a class="btn btn-default btn-sm pull-right visible-on-hover"
                       href="#/planning/{{ release.id }}"
                       ng-if="authorizedRelease('update', release)">
                        <i class="fa fa-pencil"></i>
                    </a>
                </h3>
            </div>
            <div class="panel-body"
                 ng-bind-html="(release.vision_html ? release.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>') | sanitize">
            </div>
        </div></div>
        <div class="panel-container"><div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-check-square-o"></i> <g:message code="is.ui.project.doneDefinition.title"/>
                    <a class="btn btn-default btn-sm pull-right visible-on-hover"
                       href="#/taskBoard/{{ currentOrLastSprint.id }}/details"
                       ng-if="authorizedSprint('update', currentOrLastSprint)">
                        <i class="fa fa-pencil"></i>
                    </a>
                </h3>
            </div>
            <div class="panel-body"
                 ng-bind-html="(currentOrLastSprint.doneDefinition_html ? currentOrLastSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>') | sanitize">
            </div>
        </div></div>
        <div class="panel-container"><div class="panel panel-light">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <i class="fa fa-repeat"></i> <g:message code="is.ui.project.retrospective.title"/>
                    <a class="btn btn-default btn-sm pull-right visible-on-hover"
                       href="#/taskBoard/{{ currentOrLastSprint.id }}/details"
                       ng-if="authorizedSprint('update', currentOrLastSprint)">
                        <i class="fa fa-pencil"></i>
                    </a>
                </h3>
            </div>
            <div class="panel-body"
                 ng-bind-html="(currentOrLastSprint.retrospective_html ? currentOrLastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>') | sanitize">
            </div>
        </div></div>
    </div>
    <div class="panel-column">
        <div class="panel-container">
            <div class="panel panel-light" ng-controller="chartCtrl" ng-init="openProjectChart('burnup')">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="fa fa-area-chart"></i> <g:message code="is.ui.project.chart.title"/>
                        <div class="btn-toolbar pull-right visible-on-hover"
                             uib-dropdown>
                            <button class="btn btn-default btn-sm"
                                    ng-click="saveChart()"
                                    type="button">
                                <i class="fa fa-floppy-o"></i>
                            </button>
                            <button class="btn btn-default btn-sm"
                                    uib-tooltip="${message(code:'todo.is.ui.charts')}"
                                    type="button"
                                    uib-dropdown-toggle>
                                <i class="fa fa-bar-chart"></i>&nbsp;<i class="caret"></i>
                            </button>
                            <ul uib-dropdown-menu>
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
        </div>
        <div class="panel-container">
            <div class="panel panel-light">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="fa fa-bolt"></i> <g:message code="is.ui.project.activity.title"/>
                        <small class="pull-right">
                            <g:link class="rss" uib-tooltip="${message(code: 'todo.is.ui.feed')}" mapping="${product.preferences.hidden ? 'privateURL' : ''}" action="feed" params="[product:product.pkey,lang:lang]">
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
</div>