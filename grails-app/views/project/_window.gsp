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
                                class="btn btn-danger btn-sm hover-display text-nowrap"
                                ng-click="showProjectEditModal('administration')"
                                type="button">
                            ${message(code: 'is.ui.project.sample.delete')}
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
                    <div ng-controller="userRatingCtrl">
                        <div class="rating-container" ng-if=":: online && showRating()">
                            <a class="btn btn-icon rating-close" href="" ng-if="showReview" ng-click="removeRating()"><span class="icon icon-close"></span></a>
                            <div class="rating-content">
                                <div ng-if="!thankYou && !showRatingText">
                                    <div class="rating-title">
                                        ${message(code: 'is.ui.rating.text.part.start')}
                                        <a class="link" href ng-click="showReleaseNotesModal()">iceScrum ${g.meta(name: "app.version")}</a>
                                        ${message(code: 'is.ui.rating.text.part.end')}
                                    </div>
                                    <div star-rating rating-value="currentUser.preferences.iceScrumRating" max="5" on-rating-selected="onSelectRating(rating)"></div>
                                </div>
                                <div class="form rating-textarea" ng-if="!thankYou && showRatingText">
                                    <div class="form-group">
                                        <label>${g.message(code: 'is.ui.rating.text.label')}</label>
                                        <textarea class="form-control" ng-model="rating.text"></textarea>
                                        <button type="button"
                                                ng-disabled="!rating.text"
                                                ng-click="submitRating()"
                                                class="btn btn-primary float-right">
                                            ${message(code: 'is.ui.rating.submit')}
                                        </button>
                                    </div>
                                </div>
                                <div ng-if="thankYou">
                                    <h3>${g.message(code: 'is.ui.rating.thankyou')}</h3>
                                    <br/>
                                    <h3 ng-if="showReview"><a href="https://www.icescrum.com/rating.php?{{ queryStringRating }}" class="link">${g.message(code: 'is.ui.rating.review')}</a></h3>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="float-right">
                        <button class="btn btn-icon btn-secondary btn-sm hover-visible text-nowrap"
                                ng-if="authorizedProject('update', project)"
                                ng-click="showProjectEditModal()"
                                type="button">
                            <i class="icon icon-edit"></i>
                        </button>
                    </div>
                    <div class="rich-content" ng-bind-html="project.description_html ? project.description_html : '<p>' + message('todo.is.ui.project.nodescription') + '</p>'"></div>
                    <div class="avatars-and-stats">
                        <div class="avatars d-flex align-items-center justify-content-center"
                             ng-class="{'avatars-size-sm': allMembers.length >= 12 && allMembers.length < 18, 'avatars-size-xs': allMembers.length >= 18, 'flex-wrap': allMembers.length >= 35}">
                            <div class="avatar {{ user | userColorRoles }}" ng-repeat="user in allMembers">
                                <img ng-src="{{:: user | userAvatar }}"
                                     uib-tooltip="{{:: user | userFullName }}"/>
                            </div>
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
                </div>
                <div class="card-body rich-content">
                    <div class="float-right">
                        <a class="btn btn-icon btn-secondary btn-sm float-right hover-visible"
                           href="#/taskBoard/{{ currentOrNextSprint.id }}/details"
                           ng-if="currentOrNextSprint.id && authorizedSprint('update', currentOrNextSprint)">
                            <i class="icon icon-edit"></i>
                        </a>
                    </div>
                    <div ng-bind-html="currentOrNextSprint.doneDefinition_html ? currentOrNextSprint.doneDefinition_html : '<p>${message(code: 'todo.is.ui.sprint.nodonedefinition')}</p>'"></div>
                </div>
            </div>
            <div class="card hover-container">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.retrospective.title')}
                    </span>
                </div>
                <div class="card-body rich-content">
                    <div class="float-right">
                        <a class="btn btn-icon btn-secondary btn-sm float-right hover-visible"
                           href="#/taskBoard/{{ lastSprint.id }}/details"
                           ng-if="lastSprint.id && authorizedSprint('update', lastSprint)">
                            <i class="icon icon-edit"></i>
                        </a>
                    </div>
                    <div ng-bind-html="lastSprint.retrospective_html ? lastSprint.retrospective_html : '<p>${message(code: 'todo.is.ui.sprint.noretrospective')}</p>'"></div>
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
                            <span class="attachment-icon"></span><span flow-btn class="link">${message(code: 'todo.is.ui.attachment.add')}</span>&nbsp;<span class="d-none d-md-inline">${message(code: 'todo.is.ui.attachment.drop')}</span>
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
            <entry:point id="project-dashboard-before-charts"/>
            <div class="card project-indicators" ng-controller="chartCtrl">
                <div class="card-header" ng-controller="projectChartCtrl">
                    <span class="card-title">
                        ${message(code: 'is.ui.project.chart.title')}
                    </span>
                    <entry:point id="project-dashboard-charts-after-title"/>
                    <div class="btn-toolbar float-right">
                        <div uib-dropdown
                             class="btn-group">
                            <button class="btn btn-link btn-sm"
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
                                   ng-class="{'active': chart.id == chartParams.chartName && chartParams.itemType == 'project'}"
                                   href
                                   ng-click="openChartAndSaveSetting('project', chart.id, project, project, 'project', 'chart', dashboardChartOptions)">
                                    {{ message(chart.name) }}
                                </a>
                                <div ng-if="release.id" class="dropdown-divider"></div>
                                <span ng-if="release.id" role="presentation" class="dropdown-header">${message(code: 'is.release')}</span>
                                <a class="dropdown-item"
                                   ng-class="{'active': chart.id == chartParams.chartName && chartParams.itemType == 'release'}"
                                   ng-if="release.id"
                                   ng-repeat="chart in projectCharts.release"
                                   href
                                   ng-click="openChartAndSaveSetting('release', chart.id, release, project, 'project', 'chart', dashboardChartOptions)">
                                    {{ message(chart.name) }}
                                </a>
                                <div ng-if="currentOrLastSprint.id" class="dropdown-divider"></div>
                                <span ng-if="currentOrLastSprint.id" role="presentation" class="dropdown-header">${message(code: 'is.sprint')}</span>
                                <a class="dropdown-item"
                                   ng-class="{'active': chart.id == chartParams.chartName && chartParams.itemType == 'sprint'}"
                                   ng-if="currentOrLastSprint.id"
                                   ng-repeat="chart in projectCharts.sprint"
                                   href
                                   ng-click="openChartAndSaveSetting('sprint', chart.id, currentOrLastSprint , project, 'project', 'chart', dashboardChartOptions)">
                                    {{ message(chart.name) }}
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body" ng-if="userChart.item" ng-init="openChart(userChart.itemType, userChart.chartName, userChart.item, dashboardChartOptions)">
                    <div class="clearfix mb-2">
                        <div class="float-right">
                            <div class="btn-group">
                                <entry:point id="dashboard-chart-toolbar"/>
                                <button class="btn-icon btn btn-secondary btn-sm"
                                        ng-click="saveChart(chartParams)"
                                        type="button">
                                    <i class="icon icon-save"></i>
                                </button>
                                <button class="btn-icon btn btn-secondary btn-sm"
                                        ng-click="openChartInModal(chartParams)"
                                        type="button">
                                    <i class="icon icon-expand"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
                    <div class="clearfix mt-2">
                        <div class="float-right">
                            <documentation doc-url="indicators-and-reporting" title=""/>
                        </div>
                    </div>
                </div>
            </div>
            <entry:point id="project-dashboard-before-history"/>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">
                        ${message(code: 'todo.is.ui.history')}
                    </span>
                    <a class="btn btn-icon btn-secondary btn-sm float-right"
                       href="{{ (project.pkey | projectUrl) + 'project/feed' }}">
                        <i class="icon icon-rss"></i>
                    </a>
                </div>
                <div class="card-body font-size-sm">
                    <div ng-repeat="activity in activities" ng-show="$index < 5 || pref.showMore['activities']">
                        <div class="activity media">
                            <div class="{{ activity.poster | userColorRoles }} avatar mr-3">
                                <img ng-src="{{activity.poster | userAvatar}}"
                                     width="37px"
                                     height="37px"
                                     class="align-self-center"
                                     alt="{{:: activity.poster | userFullName}}"/>
                            </div>
                            <div class="media-body">
                                <div class="time-stamp float-right">
                                    <time timeago datetime="{{ activity.dateCreated }}">
                                        {{ activity.dateCreated | dateTime }}
                                    </time>
                                </div>
                                <div>
                                    {{activity.poster | userFullName}}
                                </div>
                                <div>
                                    <span class="text-accent">{{ activity | activityName }}</span>
                                    <a href ng-click="openFromId(activity)" ng-if="activity.code != 'delete'" class="link">{{ activity.label }}</a>
                                    <span ng-if="activity.code == 'delete'">{{ activity.label }}</span>
                                </div>
                            </div>
                        </div>
                        <hr ng-if="!$last">
                    </div>
                    <div ng-if="activities.length > 5 && !pref.showMore['activities']" class="text-center">
                        <span ng-click="showMore('activities')" class="toggle-more">${message(code: 'todo.is.ui.history.more')}</span>
                    </div>
                    <div ng-if="activities != undefined && activities.length == 0">
                        <div class="text-center" style="padding:5px; font-size:14px;">
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
