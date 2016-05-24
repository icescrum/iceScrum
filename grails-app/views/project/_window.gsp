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
<is:window windowDefinition="${windowDefinition}">
    <div class="row" ng-controller="dashboardCtrl">
        <div class="widget-column">
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
                                {{ sprint.orderNumber }}
                            </uib-bar>
                            <div class="progress-empty" ng-if="release.sprints != undefined && release.sprints.length == 0">${message(code: 'todo.is.ui.nosprint')}</div>
                        </uib-progress>
                        <div class="row project-rel-dates">
                            <div class="col-md-6">{{ release.startDate | dayShort }}</div>
                            <div class="col-md-6 text-right">{{ release.endDate | dayShort }}</div>
                        </div>
                    </div>
                </div>
            </div></div>
            <div class="panel-container"><div class="panel panel-light">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="fa fa-picture-o"></i> <g:message code="is.ui.project.vision.title"/>
                        <a class="btn btn-default btn-sm pull-right visible-on-hover"
                           href="#/planning/{{ release.id }}/details"
                           ng-if="release.id && authorizedRelease('update', release)">
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
                           href="#/taskBoard/{{ currentOrNextSprint.id }}/details"
                           ng-if="currentOrNextSprint.id && authorizedSprint('update', currentOrNextSprint)">
                            <i class="fa fa-pencil"></i>
                        </a>
                    </h3>
                </div>
                <div class="panel-body"
                     ng-bind-html="(currentOrNextSprint.doneDefinition_html ? currentOrNextSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>') | sanitize">
                </div>
            </div></div>
            <div class="panel-container"><div class="panel panel-light">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="fa fa-repeat"></i> <g:message code="is.ui.project.retrospective.title"/>
                        <a class="btn btn-default btn-sm pull-right visible-on-hover"
                           href="#/taskBoard/{{ currentOrLastSprint.id }}/details"
                           ng-if="currentOrLastSprint.id && authorizedSprint('update', currentOrLastSprint)">
                            <i class="fa fa-pencil"></i>
                        </a>
                    </h3>
                </div>
                <div class="panel-body"
                     ng-bind-html="(currentOrLastSprint.retrospective_html ? currentOrLastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>') | sanitize">
                </div>
            </div></div>
        </div>
        <div class="widget-column">
            <div class="panel-container">
                <div class="panel panel-light" ng-controller="chartCtrl" ng-init="openChart('project', 'burnup')">
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
                                    <g:each var="chart" in="${contextScope.charts.project}">
                                        <li><a href ng-click="openChart('project', '${chart.id}')">${message(code: chart.name)}</a></li>
                                    </g:each>
                                    <li ng-if="release.id" class="divider"></li>
                                    <li ng-if="release.id" role="presentation" class="dropdown-header">${message(code: 'is.release')}</li>
                                    <g:each var="chart" in="${contextScope.charts.release}">
                                        <li ng-if="release.id"><a href ng-click="openChart('release', '${chart.id}', release)">${message(code: chart.name)}</a></li>
                                    </g:each>
                                    <li ng-if="currentOrLastSprint.id" class="divider"></li>
                                    <li ng-if="currentOrLastSprint.id" role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</li>
                                    <g:each var="chart" in="${contextScope.charts.sprint}">
                                        <li ng-if="currentOrLastSprint.id"><a href ng-click="openChart('sprint', '${chart.id}', currentOrLastSprint)">${message(code: chart.name)}</a></li>
                                    </g:each>
                                </ul>
                            </div>
                        </h3>
                    </div>
                    <div class="panel-body">
                        <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
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
                                <a target="_blank" href="https://www.icescrum.com/documentation/getting-started-with-icescrum?utm_source=dashboard&utm_medium=link&utm_campaign=icescrum">${message(code:'is.ui.getting.started')}</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</is:window>