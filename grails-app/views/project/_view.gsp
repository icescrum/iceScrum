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
<div ng-controller="dashboardCtrl">
    <div class="row">
        <div class="col-sm-6">
            <ng-include src="'project.details.html'"></ng-include>
        </div>
        <div class="col-sm-6">
            <h2 class="sub-header">
                <i class="fa fa-bolt"></i> <g:message code="is.ui.project.activity.title"/>
                <small class="pull-right">
                    <g:link class="rss" data-toggle="tooltip" title="${message(code:'todo.is.ui.rss')}" mapping="${product.preferences.hidden ? 'privateURL' : ''}" action="feed" params="[product:product.pkey,lang:lang]">
                        <i class="fa fa-rss fa-lg"></i>
                    </g:link>
                </small>
            </h2>
            <div class="activities">
                <div class="activity" ng-repeat="activity in activities">
                    <div class="media-left">
                        <img height="36px"
                             ng-src="{{activity.poster | userAvatar}}"
                             alt="{{activity.poster | userFullName}}"/>
                    </div>
                    <div class="media-body">
                        <div class="text-muted pull-right">
                            <time timeago datetime="'{{ activity.dateCreated }}'">
                                {{ activity.dateCreated }}
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
                <div ng-if="activities != undefined && activities.length == 0" class="panel-box-empty">
                    <div style="text-align: center; padding:5px; font-size:14px;">
                        <a class="scrum-link" target="_blank" href="https://www.icescrum.com/documentation/getting-started-with-icescrum?utm_source=dashboard&utm_medium=link&utm_campaign=icescrum">${message(code:'is.ui.getting.started')}</a>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6" ng-controller="chartCtrl" ng-init="init('burnup')" id="panel-chart-container">
            <h2 class="sub-header">
                <i class="fa fa-area-chart"></i> <g:message code="is.ui.project.chart.title"/>
                <small class="pull-right">
                    <div dropdown class="btn-group"
                         tooltip="${message(code:'todo.is.ui.charts')}"
                         tooltip-append-to-body="true">
                        <button class="btn btn-default btn-sm dropdown-toggle" type="button" dropdown-toggle>
                            <span class="fa fa-bar-chart"></span>&nbsp;<span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <li role="presentation" class="dropdown-header">${message(code: 'is.product')}</li>
                            <li><a href ng-click="openProjectChart('cumulativeFlow')">${message(code: 'is.ui.project.charts.productCumulativeFlow')}</a></li>
                            <li><a href ng-click="openProjectChart('burnup')">${message(code: 'is.ui.project.charts.productBurnup')}</a></li>
                            <li><a href ng-click="openProjectChart('burndown')">${message(code: 'is.ui.project.charts.productBurndown')}</a></li>
                            <li><a href ng-click="openProjectChart('parkingLot')">${message(code: 'is.ui.project.charts.productParkingLot')}</a></li>
                            <li><a href ng-click="openProjectChart('velocity')">${message(code: 'is.ui.project.charts.productVelocity')}</a></li>
                            <li><a href ng-click="openProjectChart('velocityCapacity')">${message(code: 'is.ui.project.charts.productVelocityCapacity')}</a></li>
                            <li class="divider"></li>
                            <li role="presentation" class="dropdown-header">${message(code: 'is.mood')}</li>
                            <li><a href ng-click="openMoodSprintChart() ">${message(code: 'is.ui.project.charts.MoodSprintChart')}</a></li>
                            <li><a href ng-click="openMoodUserChart()">${message(code: 'is.ui.project.MoodUserChart')}</a></li>
                            <li><a href ng-click="openChartTeam()">${message(code: 'is.ui.project.MoodTeam')}</a></li>
                            <li><a href ng-click="openTeamMoodReleaseChart()">${message(code: 'is.ui.project.MoodTeamBysprint')}</a></li>
                            <li class="divider"></li>
                            <li role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</li>
                            <li><a href ng-click="openSprintChart('burndownRemaining')">${message(code: 'is.ui.project.chart.option.remaining')}</a></li>
                            <li><a href ng-click="openSprintChart('burnupTasks')">${message(code: 'is.ui.project.chart.option.tasks')}</a></li>
                            <li><a href ng-click="openSprintChart('burnupPoints')">${message(code: 'is.ui.project.chart.option.points')}</a></li>
                            <li><a href ng-click="openSprintChart('burnupStories')">${message(code: 'is.ui.project.chart.option.stories')}</a></li>
                        </ul>
                    </div>
                </small>
            </h2>
            <div>
                <button class="btn btn-default btn-sm"
                        ng-click="saveChart()"
                        type="button">
                    <span class="fa fa-floppy-o"></span>
                </button>
                <nvd3 options="options" data="data"></nvd3>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-6">
            <h2 class="sub-header">
                <i class="fa fa-eye"></i> <g:message code="is.ui.project.vision.title"/>
            </h2>
            <div class="body">
                <textarea is-markitup
                          class="form-control"
                          name="vision"
                          ng-model="editableRelease.vision"
                          is-model-html="editableRelease.vision_html"
                          ng-show="showVisionTextarea"
                          ng-blur="showVisionTextarea = false; updateRelease(editableRelease)"
                          placeholder="${message(code: 'todo.is.ui.release.novision')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="true"
                     ng-show="!showVisionTextarea"
                     ng-click="showVisionTextarea = authorizedRelease('update', editableRelease); editRelease(showVisionTextarea)"
                     ng-class="{'placeholder': !editableRelease.vision_html}"
                     tabindex="0"
                     ng-bind-html="(editableRelease.vision_html ? editableRelease.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>') | sanitize"></div>
            </div>
        </div>
        <div class="col-sm-6">
            <h2 class="sub-header">
                <i class="fa fa-check-square-o"></i> <g:message code="is.ui.project.doneDefinition.title"/>
            </h2>
            <div class="body">
                <textarea is-markitup
                          class="form-control"
                          name="doneDefinition"
                          ng-model="editableCurrentOrLastSprint.doneDefinition"
                          is-model-html="editableCurrentOrLastSprint.doneDefinition_html"
                          ng-show="showDoneDefinitionTextarea"
                          ng-blur="showDoneDefinitionTextarea = false; updateSprint(editableCurrentOrLastSprint)"
                          placeholder="${message(code: 'todo.is.ui.sprint.nodonedefinition')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="true"
                     ng-show="!showDoneDefinitionTextarea"
                     ng-click="showDoneDefinitionTextarea = authorizedSprint('updateDoneDefinition', editableCurrentOrLastSprint); editSprint(showDoneDefinitionTextarea)"
                     ng-class="{'placeholder': !editableCurrentOrLastSprint.doneDefinition_html}"
                     tabindex="0"
                     ng-bind-html="(editableCurrentOrLastSprint.doneDefinition_html ? editableCurrentOrLastSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>') | sanitize"></div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-6">
            <h2 class="sub-header">
                <i class="fa fa-repeat"></i> <g:message code="is.ui.project.retrospective.title"/>
            </h2>
            <div class="body">
                <textarea is-markitup
                          class="form-control"
                          name="retrospective"
                          ng-model="editableCurrentOrLastSprint.retrospective"
                          is-model-html="editableCurrentOrLastSprint.retrospective_html"
                          ng-show="showRetrospectiveTextarea"
                          ng-blur="showRetrospectiveTextarea = false; updateSprint(editableCurrentOrLastSprint)"
                          placeholder="${message(code: 'todo.is.ui.sprint.noretrospective')}"></textarea>
                <div class="markitup-preview"
                     ng-disabled="true"
                     ng-show="!showRetrospectiveTextarea"
                     ng-click="showRetrospectiveTextarea = authorizedSprint('updateRetrospective', editableCurrentOrLastSprint); editSprint(showRetrospectiveTextarea)"
                     ng-class="{'placeholder': !editableCurrentOrLastSprint.retrospective_html}"
                     tabindex="0"
                     ng-bind-html="(editableCurrentOrLastSprint.retrospective_html ? editableCurrentOrLastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>') | sanitize"></div>
            </div>
        </div>
    </div>
</div>