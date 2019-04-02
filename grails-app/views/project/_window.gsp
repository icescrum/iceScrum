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
<is:window windowDefinition="${windowDefinition}" classes="widget-dashboard">
    <div class="d-flex flex-wrap widgets">
        <div class="widget-column col-md-6">
            <div class="card">
                <div class="card-header">
                    <span class="card-title workspace-title">
                        <span class="highlight">{{ project.name }}</span>&nbsp;<entry:point id="window-project-name-right"/>
                    </span>
                    <div class="btn-toolbar float-right visible-on-hover">
                        <button class="btn btn-secondary btn-sm"
                                ng-if="authorizedProject('update', project)"
                                ng-click="showProjectEditModal()"
                                type="button">
                            <i class="fa fa-pencil"></i>
                        </button>
                        <a ng-if="authorizedFeature('create')"
                           href="#/feature/new"
                           class="btn btn-secondary btn-sm">${message(code: "todo.is.ui.feature.new")}</a>
                        <a ui-sref="backlog.backlog.story.new({elementId: 'sandbox'})"
                           class="btn btn-secondary btn-sm">${message(code: "todo.is.ui.story.new")}</a>
                        <a ng-if="currentOrNextSprint && authorizedTask('create', {sprint: currentOrNextSprint}) && !(session.po() && !session.sm())"
                           ui-sref="taskBoard.task.new({sprintId: currentOrNextSprint.id})"
                           class="btn btn-secondary btn-sm">${message(code: "todo.is.ui.task.new")}</a>
                        <entry:point id="project-dashboard-buttons"/>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="rich-content" ng-bind-html="project.description_html ? project.description_html : '<p>' + message('todo.is.ui.project.nodescription') + '</p>'"></div>
                        </div>
                        <div class="col-md-4 text-right">
                            <span ng-repeat="user in allMembers">
                                <img ng-src="{{:: user | userAvatar }}"
                                     height="36" width="36" style="margin:5px"
                                     class="{{:: user | userColorRoles }}"
                                     defer-tooltip="{{:: user | userFullName }}"/>
                            </span>
                            <h5><i class="fa fa-users"></i> {{ project.team.name }}</h5>
                        </div>
                    </div>
                    <a ng-if="authorizedProject('update', project) && project.name.indexOf('Peetic ') != -1"
                       ng-click="showProjectEditModal('administration')">
                        ${message(code: 'is.ui.project.sample.delete')}
                    </a>
                    <div class="row project-info">
                        <div class="col-md-6" style="text-align: left;"><i class="fa fa-sticky-note"></i> {{ project.stories_count }} ${message(code: 'todo.is.ui.stories')}</div>
                        <div class="col-md-6" style="text-align: right;"><i class="fa fa-calendar"></i> {{ project.releases_count }} ${message(code: 'todo.is.ui.releases')}</div>
                    </div>
                    <ng-include src="'release.timeline.href.html'" ng-controller="releaseTimelineCtrl"></ng-include>
                    <div class="row project-rel-dates">
                        <div class="col-md-6">{{ release.startDate | dayShort }}</div>
                        <div class="col-md-6 text-right">{{ release.endDate | dayShort }}</div>
                    </div>
                    <div ng-show="currentOrNextSprint.goal">
                        <p><strong>{{ message('todo.is.ui.sprint.goal.label', [currentOrNextSprint.index]) }}</strong> {{ currentOrNextSprint.goal }}</p>
                    </div>
                </div>
            </div>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.vision.title')}
                    </span>
                    <a class="btn btn-secondary btn-sm float-right visible-on-hover"
                       href="#/planning/{{ release.id }}/details"
                       ng-if="release.id && authorizedRelease('update', release)">
                        <i class="fa fa-pencil"></i>
                    </a>
                </div>
                <div class="card-body rich-content"
                     ng-bind-html="release.vision_html ? release.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>'">
                </div>
            </div>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.doneDefinition.title')}
                    </span>
                    <a class="btn btn-secondary btn-sm float-right visible-on-hover"
                       href="#/taskBoard/{{ currentOrNextSprint.id }}/details"
                       ng-if="currentOrNextSprint.id && authorizedSprint('update', currentOrNextSprint)">
                        <i class="fa fa-pencil"></i>
                    </a>
                </div>
                <div class="card-body rich-content"
                     ng-bind-html="currentOrNextSprint.doneDefinition_html ? currentOrNextSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>'">
                </div>
            </div>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.retrospective.title')}
                    </span>
                    <a class="btn btn-secondary btn-sm float-right visible-on-hover"
                       href="#/taskBoard/{{ lastSprint.id }}/details"
                       ng-if="lastSprint.id && authorizedSprint('update', lastSprint)">
                        <i class="fa fa-pencil"></i>
                    </a>
                </div>
                <div class="card-body rich-content"
                     ng-bind-html="lastSprint.retrospective_html ? lastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>'">
                </div>
            </div>
            <div class="card"
                 flow-init
                 flow-drop
                 flow-files-submitted="attachmentQuery($flow, project)"
                 flow-drop-enabled="authorizedProject('upload', project)"
                 flow-drag-enter="dropClass='card drop-enabled'"
                 flow-drag-leave="dropClass='card'"
                 ng-class="authorizedProject('upload', project) && dropClass">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.attachment.title')}
                    </span>
                </div>
                <div class="card-body" style="padding-bottom:0">
                    <div ng-if="authorizedProject('upload', project)"
                         style="position:relative"
                         ng-controller="attachmentNestedCtrl">
                        <button type="button"
                                class="btn btn-secondary"
                                flow-btn>
                            <i class="fa fa-upload"></i> ${message(code: 'todo.is.ui.new.upload')}
                        </button>
                        <entry:point id="attachment-add-buttons"/>
                    </div>
                    <div class="row" style="max-height: 175px; margin-top:10px;">
                        <div ng-include="'attachment.list.html'">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="widget-column col-md-6">
            <div class="card" ng-controller="chartCtrl">
                <div class="card-header" ng-controller="projectChartCtrl">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.chart.title')}
                    </span>
                    <div class="btn-toolbar float-right">
                        <entry:point id="dashboard-chart-toolbar"/>
                        <div class="btn-group">
                            <button class="btn btn-secondary btn-sm"
                                    ng-click="openChartInModal(chartParams)"
                                    type="button">
                                <i class="fa fa-search-plus"></i>
                            </button>
                            <button class="btn btn-secondary btn-sm"
                                    ng-click="saveChart(chartParams)"
                                    type="button">
                                <i class="fa fa-floppy-o"></i>
                            </button>
                        </div>
                        <div uib-dropdown
                             class="btn-group btn-group-sm">
                            <button class="btn btn-secondary btn-sm"
                                    type="button"
                                    aria-label="${message(code: 'todo.is.ui.charts')}"
                                    uib-dropdown-toggle>
                                <i class="fa fa-bar-chart"></i>
                            </button>
                            <div uib-dropdown-menu
                                 class="dropdown-menu-right">
                                <span role="presentation" class="dropdown-header">${message(code: 'is.project')}</span>
                                <a class="dropdown-item"
                                   ng-repeat="chart in projectCharts.project"
                                   href
                                   ng-click="openChartAndSaveSetting('project', chart.id, project, project, 'project', 'chart')">
                                    {{ message(chart.name) }}
                                </a>
                                <div ng-if="release.id" class="dropdown-divider"></div>
                                <span ng-if="release.id" role="presentation" class="dropdown-header">${message(code: 'is.release')}</span>
                                <a class="dropdown-item"
                                   ng-if="release.id"
                                   ng-repeat="chart in projectCharts.release"
                                   href
                                   ng-click="openChartAndSaveSetting('release', chart.id, release, project, 'project', 'chart')">
                                    {{ message(chart.name) }}
                                </a>
                                <div ng-if="currentOrLastSprint.id" class="dropdown-divider"></div>
                                <span ng-if="currentOrLastSprint.id" role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</span>
                                <a class="dropdown-item"
                                   ng-if="currentOrLastSprint.id"
                                   ng-repeat="chart in projectCharts.sprint"
                                   href
                                   ng-click="openChartAndSaveSetting('sprint', chart.id, currentOrLastSprint , project, 'project', 'chart')">
                                    {{ message(chart.name) }}
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body" ng-if="userChart.item" ng-init="openChart(userChart.itemType, userChart.chartName, userChart.item)">
                    <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
                </div>
                <div class="text-right"
                     style="padding: 0 10px 6px 0">
                    <documentation doc-url="indicators-and-reporting" title="is.chart.help"/>
                </div>
            </div>
            <entry:point id="project-dashboard-top-right"/>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'todo.is.ui.history')}
                    </span>
                    <small class="float-right">
                        <a class="rss"
                           defer-tooltip="${message(code: 'todo.is.ui.feed')}"
                           href="{{ openWorkspaceUrl(project) + 'project/feed' }}">
                            <i class="fa fa-rss fa-lg visible-on-hover"></i>
                        </a>
                    </small>
                </div>
                <div class="card-body activities">
                    <div ng-repeat="activity in activities" ng-show="$index < 5 || pref.showMore">
                        <div class="activity media">
                            <img ng-src="{{activity.poster | userAvatar}}"
                                 width="37px"
                                 height="37px"
                                 class="align-self-center mr-3 {{ activity.poster | userColorRoles }}"
                                 alt="{{:: activity.poster | userFullName}}"/>
                            <div class="media-body">
                                <div class="text-muted float-right">
                                    <time timeago datetime="{{ activity.dateCreated }}">
                                        {{ activity.dateCreated | dateTime }}
                                    </time>
                                    <i class="fa fa-clock-o"></i>
                                </div>
                                <div>
                                    {{activity.poster | userFullName}}
                                </div>
                                <div>
                                    {{ activity | activityName }}
                                    <strong ng-if="activity.code != 'delete'">
                                        <a href ng-click="openFromId(activity)">{{ activity.label }}</a>
                                    </strong>
                                    <strong ng-if="activity.code == 'delete'">{{ activity.label }}</strong>
                                </div>
                            </div>
                        </div>
                        <hr ng-if="!$last">
                    </div>
                    <div ng-if="activities.length > 5 && !pref.showMore" class="text-center">
                        <a href ng-click="showMore()"><i class="fa fa-caret-down"></i></a>
                    </div>
                    <div ng-if="activities != undefined && activities.length == 0">
                        <div style="text-align: center; padding:5px; font-size:14px;">
                            <a target="_blank"
                               href="https://www.icescrum.com/documentation/getting-started-with-icescrum?utm_source=dashboard&utm_medium=link&utm_campaign=icescrum">
                                <i class="fa fa-question-circle"></i>
                                ${message(code: 'is.ui.documentation.getting.started.extended')}
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</is:window>
