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
    <div class="row">
        <div class="widget-column">
            <div class="panel-container">
                <div class="panel panel-light">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <i tooltip-placement="right"
                               defer-tooltip="${message(code: 'is.ui.project.public')}"
                               ng-if="!project.preferences.hidden"
                               ng-click="authorizedProject('edit') && showProjectEditModal()"
                               class="fa fa-eye"></i>&nbsp;<i class="fa fa-folder"></i>&nbsp;{{ project.name + ' (' + project.pkey + ')' }}&nbsp;<entry:point id="window-project-name-right"/>
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
                            <div class="col-md-8">
                                <div class="rich-content" ng-bind-html="project.description_html ? project.description_html : '<p>' + message('todo.is.ui.project.nodescription') + '</p>'"></div>
                            </div>
                            <div class="col-md-4 text-right">
                                <span ng-repeat="user in allMembers">
                                    <img ng-src="{{:: user | userAvatar }}"
                                         height="36" width="36" style="margin-left:5px;"
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
            </div>
            <div class="panel-container">
                <div class="panel panel-light">
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
                    <div class="panel-body rich-content"
                         ng-bind-html="release.vision_html ? release.vision_html : '<p>${message(code: 'todo.is.ui.release.novision')}</p>'">
                    </div>
                </div>
            </div>
            <div class="panel-container">
                <div class="panel panel-light">
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
                    <div class="panel-body rich-content"
                         ng-bind-html="currentOrNextSprint.doneDefinition_html ? currentOrNextSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>'">
                    </div>
                </div>
            </div>
            <div class="panel-container">
                <div class="panel panel-light">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <i class="fa fa-repeat"></i> <g:message code="is.ui.project.retrospective.title"/>
                            <a class="btn btn-default btn-sm pull-right visible-on-hover"
                               href="#/taskBoard/{{ lastSprint.id }}/details"
                               ng-if="lastSprint.id && authorizedSprint('update', lastSprint)">
                                <i class="fa fa-pencil"></i>
                            </a>
                        </h3>
                    </div>
                    <div class="panel-body rich-content"
                         ng-bind-html="lastSprint.retrospective_html ? lastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>'">
                    </div>
                </div>
            </div>
            <div class="panel-container">
                <div class="panel panel-light"
                     flow-init
                     flow-drop
                     flow-files-submitted="attachmentQuery($flow, project)"
                     flow-drop-enabled="authorizedProject('upload', project)"
                     flow-drag-enter="dropClass='panel panel-light drop-enabled'"
                     flow-drag-leave="dropClass='panel panel-light'"
                     ng-class="authorizedProject('upload', project) && dropClass">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <i class="fa fa-file"></i> <g:message code="is.ui.project.attachment.title"/>
                        </h3>
                    </div>
                    <div class="panel-body" style="padding-bottom:0">
                        <div ng-if="authorizedProject('upload', project)"
                             style="position:relative"
                             ng-controller="attachmentNestedCtrl">
                            <button type="button"
                                    class="btn btn-default"
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
        </div>
        <div class="widget-column">
            <div class="panel-container">
                <div class="panel panel-light" ng-controller="chartCtrl">
                    <div class="panel-heading" ng-controller="projectChartCtrl">
                        <h3 class="panel-title">
                            <i class="fa fa-area-chart"></i> ${message(code: 'is.ui.project.chart.title')}
                            <div class="btn-toolbar pull-right visible-on-hover"
                                 uib-dropdown>
                                <div class="btn-group">
                                    <button class="btn btn-default btn-sm"
                                            ng-click="openChartInModal(chartParams)"
                                            type="button">
                                        <i class="fa fa-search-plus"></i>
                                    </button>
                                    <button class="btn btn-default btn-sm"
                                            ng-click="saveChart(chartParams)"
                                            type="button">
                                        <i class="fa fa-floppy-o"></i>
                                    </button>
                                </div>
                                <button class="btn btn-default btn-sm"
                                        type="button"
                                        uib-dropdown-toggle>
                                    <span defer-tooltip="${message(code: 'todo.is.ui.charts')}"><i class="fa fa-bar-chart"></i> <i class="fa fa-caret-down"></i></span>
                                </button>
                                <ul uib-dropdown-menu>
                                    <li role="presentation" class="dropdown-header">${message(code: 'is.project')}</li>
                                    <li ng-repeat="chart in projectCharts.project"><a href ng-click="openChartAndSaveSetting('project', chart.id, project, project, 'project', 'chart')">{{ message(chart.name) }}</a></li>
                                    <li ng-if="release.id" class="divider"></li>
                                    <li ng-if="release.id" role="presentation" class="dropdown-header">${message(code: 'is.release')}</li>
                                    <li ng-if="release.id" ng-repeat="chart in projectCharts.release"><a href ng-click="openChartAndSaveSetting('release', chart.id, release, project, 'project', 'chart')">{{ message(chart.name) }}</a></li>
                                    <li ng-if="currentOrLastSprint.id" class="divider"></li>
                                    <li ng-if="currentOrLastSprint.id" role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</li>
                                    <li ng-if="currentOrLastSprint.id" ng-repeat="chart in projectCharts.sprint"><a href
                                                                                                                    ng-click="openChartAndSaveSetting('sprint', chart.id, currentOrLastSprint , project, 'project', 'chart')">{{ message(chart.name) }}</a>
                                    </li>
                                </ul>
                            </div>
                        </h3>
                    </div>
                    <div class="panel-body" ng-if="userChart.item" ng-init="openChart(userChart.itemType, userChart.chartName, userChart.item)">
                        <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
                    </div>
                    <div class="text-right"
                         style="padding: 0 10px 6px 0">
                        <documentation doc-url="indicators-and-reporting" title="is.chart.help"/>
                    </div>
                </div>
            </div>
            <entry:point id="project-dashboard-top-right"/>
            <div class="panel-container">
                <div class="panel panel-light">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <i class="fa fa-clock-o"></i> <g:message code="todo.is.ui.history"/>
                            <small class="pull-right">
                                <a class="rss"
                                   defer-tooltip="${message(code: 'todo.is.ui.feed')}"
                                   href="{{ openWorkspaceUrl(project) + 'project/feed' }}">
                                    <i class="fa fa-rss fa-lg visible-on-hover"></i>
                                </a>
                            </small>
                        </h3>
                    </div>
                    <div class="panel-body activities panel-light">
                        <div ng-repeat="activity in activities" ng-show="$index < 5 || pref.showMore">
                            <div class="activity">
                                <div class="media-left">
                                    <img ng-src="{{activity.poster | userAvatar}}"
                                         class="{{ activity.poster | userColorRoles }}"
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
    </div>
</is:window>
