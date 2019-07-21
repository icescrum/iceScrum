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
<is:window windowDefinition="${windowDefinition}" classes="widget-view">
    <div class="d-flex flex-wrap panels">
        <div class="panel-column col-md-6">
            <div class="card hover-container project-summary">
                <div class="card-header d-md-flex justify-content-md-between align-items-end">
                    <div class="card-title workspace-title text-truncate">
                        <span class="sharpie-highlight">{{ project.name }}</span>
                        <entry:point id="window-project-name-right"/>
                    </div>
                    <div class="btn-toolbar ml-1 mt-1 mt-lg-0 align-items-end d-block d-md-flex flex-nowrap">
                        <button ng-if="authorizedProject('update', project) && project.name.indexOf('Peetic ') != -1"
                                class="btn btn-secondary btn-sm hover-visible text-danger text-nowrap"
                                ng-click="showProjectEditModal('administration')"
                                type="button">
                            ${message(code: 'is.ui.project.sample.delete')}
                        </button>
                        <button class="btn btn-action btn-secondary btn-sm hover-visible text-nowrap"
                                ng-if="authorizedProject('update', project)"
                                ng-click="showProjectEditModal()"
                                type="button">
                            <i class="action action-edit"></i>
                        </button>
                        <a ng-if="authorizedFeature('create')"
                           href="#/feature/new"
                           class="btn btn-secondary btn-sm text-nowrap">${message(code: "todo.is.ui.feature.new")}</a>
                        <a ui-sref="backlog.backlog.story.new({elementId: 'sandbox'})"
                           class="btn btn-secondary btn-sm text-nowrap">${message(code: "todo.is.ui.story.new")}</a>
                        <a ng-if="currentOrNextSprint && authorizedTask('create', {sprint: currentOrNextSprint}) && !(session.po() && !session.sm())"
                           ui-sref="taskBoard.task.new({sprintId: currentOrNextSprint.id})"
                           class="btn btn-secondary btn-sm text-nowrap">${message(code: "todo.is.ui.task.new")}</a>
                        <entry:point id="project-dashboard-buttons"/>
                    </div>
                </div>
                <div class="card-body">
                    <div class="rich-content" ng-bind-html="project.description_html ? project.description_html : '<p>' + message('todo.is.ui.project.nodescription') + '</p>'"></div>
                    <div class="avatars-and-stats">
                        <div class="avatars">
                            <img ng-src="{{:: user | userAvatar }}"
                                 ng-repeat="user in allMembers"
                                 height="41" width="41"
                                 class="avatar {{:: user | userColorRoles }}"
                                 uib-tooltip="{{:: user | userFullName }}"/>
                        </div>
                        <div class="stats d-block d-sm-flex text-center flex-wrap justify-content-md-around justify-content-lg-center">
                            <div class="stat-number mr-lg-2">{{ project.stories_count }}</div>
                            <div class="stat-title">${message(code: 'todo.is.ui.stories')}</div>
                        </div>
                        <div class="stats d-block d-sm-flex text-center flex-wrap justify-content-md-around justify-content-lg-center">
                            <div class="stat-number mr-lg-2">{{ project.releases_count }}</div>
                            <div class="stat-title">${message(code: 'todo.is.ui.releases')}</div>
                        </div>
                    </div>
                    <div ng-if="release.vision_html" class="release-vision">
                        <strong class="text-accent">${message(code: 'is.release')} {{ release.name }}</strong>
                        <div class="rich-content"
                             ng-bind-html="release.vision_html">
                        </div>
                    </div>
                    <div class="row release-dates">
                        <div class="col-6"><strong>{{ release.startDate | dayShort }}</strong></div>
                        <div class="col-6 text-right"><strong>{{ release.endDate | dayShort }}</strong></div>
                    </div>
                    <ng-include src="'release.timeline.html'" ng-controller="releaseTimelineCtrl"></ng-include>
                    <div ng-if="currentOrNextSprint.goal" class="sprint-goal">
                        <div class="sprint-goal-label">{{ message('todo.is.ui.sprint.goal.label', [currentOrNextSprint.index]) }}</div>
                        <div>{{ currentOrNextSprint.goal }}</div>
                    </div>
                </div>
            </div>
            <div class="card hover-container">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.doneDefinition.title')}
                    </span>
                    <a class="btn btn-action btn-secondary btn-sm float-right hover-visible btn-icon btn-edit"
                       href="#/taskBoard/{{ currentOrNextSprint.id }}/details"
                       ng-if="currentOrNextSprint.id && authorizedSprint('update', currentOrNextSprint)">
                        <i class="action action-edit"></i>
                    </a>
                </div>
                <div class="card-body rich-content"
                     ng-bind-html="currentOrNextSprint.doneDefinition_html ? currentOrNextSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>'">
                </div>
            </div>
            <div class="card hover-container">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.retrospective.title')}
                    </span>
                    <a class="btn btn-action btn-secondary btn-sm float-right hover-visible"
                       href="#/taskBoard/{{ lastSprint.id }}/details"
                       ng-if="lastSprint.id && authorizedSprint('update', lastSprint)">
                        <i class="action action-edit"></i>
                    </a>
                </div>
                <div class="card-body rich-content"
                     ng-bind-html="lastSprint.retrospective_html ? lastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>'">
                </div>
            </div>
            <div class="card attachments"
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
                <div class="card-body">
                    <div class="drop-zone d-flex align-items-center justify-content-center">
                        <div>
                            <asset:image src="application/upload.svg" width="70" height="70"/>
                            <span class="drop-text">${message(code: 'todo.is.ui.drop.here')}</span>
                        </div>
                    </div>
                    <div ng-if="authorizedProject('upload', project)" ng-controller="attachmentNestedCtrl" class="upload-and-apps row">
                        <div class="upload-file col-6">
                            <span class="attachment-icon"></span><span flow-btn class="link">Add file</span><span class="d-none d-md-inline">or drop file</span>
                        </div>
                        <div class="upload-apps col-6">
                            <entry:point id="attachment-add-buttons"/>
                        </div>
                    </div>
                    <div ng-include="'attachment.list.html'"></div>
                </div>
            </div>
        </div>
        <div class="panel-column col-md-6">
            <div class="card project-indicators" ng-controller="chartCtrl">
                <div class="card-header" ng-controller="projectChartCtrl">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.chart.title')}
                    </span>
                    <div class="btn-toolbar float-right">
                        <div uib-dropdown
                             class="btn-group btn-group-sm">
                            <button class="btn btn-secondary btn-sm btn-color-lighter"
                                    type="button"
                                    aria-label="${message(code: 'todo.is.ui.charts')}"
                                    uib-dropdown-toggle>
                                {{ options.title.text }}
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
                    <div class="clearfix mb-2">
                        <div class="float-right">
                            <div class="btn-group">
                                <entry:point id="dashboard-chart-toolbar"/>
                                <button class="btn-action btn btn-secondary btn-sm"
                                        ng-click="saveChart(chartParams)"
                                        type="button">
                                    <i class="action action-save"></i>
                                </button>
                                <button class="btn-action btn btn-secondary btn-sm"
                                        ng-click="openChartInModal(chartParams)"
                                        type="button">
                                    <i class="action action-expand"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
                    <div class="clearfix mt-2">
                        <div class="float-right">
                            <documentation doc-url="indicators-and-reporting" title="${message(code:'is.chart.help')}"/>
                        </div>
                    </div>
                </div>
            </div>
            <entry:point id="project-dashboard-top-right"/>
            <div class="card hover-container">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'todo.is.ui.history')}
                    </span>
                    <a class="btn btn-action btn-secondary btn-sm float-right hover-visible btn-icon"
                       href="{{ openWorkspaceUrl(project) + 'project/feed' }}"
                       defer-tooltip="${message(code: 'todo.is.ui.feed')}">
                        <i class="action action-rss"></i>
                    </a>
                </div>
                <div class="card-body activities">
                    <div ng-repeat="activity in activities" ng-show="$index < 5 || pref.showMore['activities']">
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
                                </div>
                                <div>
                                    {{activity.poster | userFullName}}
                                </div>
                                <div>
                                    <span class="activity-name">{{ activity | activityName }}</span>
                                    <a href ng-click="openFromId(activity)" ng-if="activity.code != 'delete'" class="link">{{ activity.label }}</a>
                                    <span ng-if="activity.code == 'delete'">{{ activity.label }}</span>
                                </div>
                            </div>
                        </div>
                        <hr ng-if="!$last">
                    </div>
                    <div ng-if="activities.length > 5 && !pref.showMore['activities']" class="text-center">
                        <span ng-click="showMore('activities')" class="toggle-more">See more</span>
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
