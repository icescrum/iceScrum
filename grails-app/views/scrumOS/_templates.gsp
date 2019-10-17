%{--
- Copyright (c) 2014 Kagilum SAS.
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
<div id="templates">
    <script type="text/ng-template" id="loading.html">
    <div class="logo-loading"></div>
    </script>

    <script type="text/ng-template" id="chart.modal.html">
    <is:modal title="{{ chartTitle }}">
        <nvd3 options="options" data="data" config="{refreshDataOnly: false}"></nvd3>
    </is:modal>
    </script>

    <script type="text/ng-template" id="confirm.modal.html">
    <is:modal form="submit()"
              submitButton="{{ buttonTitle }}"
              submitButtonColor="{{ buttonColor }}"
              closeButton="${message(code: 'is.button.cancel')}"
              title="${message(code: 'todo.is.ui.confirm.title')}">
        <span ng-bind-html="message"></span>
    </is:modal>
    </script>

    <script type="text/ng-template" id="message.modal.html">
    <is:modal title="{{:: title }}">
        <span ng-bind-html="message"></span>
    </is:modal>
    </script>

    <script type="text/ng-template" id="confirm.dirty.modal.html">
    <is:modal form="saveChanges()"
              button="[[text: message(code: 'todo.is.ui.dirty.confirm.dontsave'), color: 'danger', action: 'dontSave()']]"
              submitButton="${message(code: 'todo.is.ui.dirty.confirm.save')}"
              closeButton="${message(code: 'is.button.cancel')}"
              title="${message(code: 'todo.is.ui.dirty.confirm.title')}">
        {{ message }}
    </is:modal>
    </script>

    <script type="text/ng-template" id="confirm.portfolio.cancel.modal.html">
    <is:modal form="confirmDelete()"
              submitButtonColor="danger"
              submitButton="${message(code: 'is.ui.portfolio.confirm.cancel.confirm')}"
              closeButton="${message(code: 'is.ui.portfolio.confirm.cancel.back')}"
              title="${message(code: 'todo.is.ui.confirm.title')}">
        <div class="alert bg-warning mb-3">
            <i class="fa fa-warning"></i> ${message(code: 'is.ui.portfolio.confirm.cancel.description')}
        </div>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>${message(code: 'is.project.name')}</th>
                    <th style="width:20px"><i class="fa fa-trash"></i></th>
                </tr>
            </thead>
            <tbody>
                <tr ng-repeat="project in deletableProjects">
                    <td>{{:: project.name }}</td>
                    <td><input type="checkbox" ng-model="project.delete"/></td>
                </tr>
            </tbody>
        </table>
    </is:modal>
    </script>

    <script type="text/ng-template" id="select.or.create.team.html">
    <a>
        <span ng-show="!match.model.id">${message(code: 'todo.is.ui.create.team')}</span> <strong>{{ match.model.name }}</strong>
    </a>
    </script>

    <script type="text/ng-template" id="select.or.create.project.html">
    <a ng-class="{'disabled': match.model.portfolio}">
        <span ng-show="!match.model.id">${message(code: 'todo.is.ui.project.create')}</span> <strong>{{ match.model.name }}</strong> <span ng-if="match.model.portfolio">(${message(code: 'is.project.already.in.portfolio')})</span>
    </a>
    </script>

    <script type="text/ng-template" id="button.shortcutMenu.html">
    <a ng-show="menuElement.name"
       class="btn"
       ng-class="{'btn-sm': btnSm, 'btn-primary': !btnSecondary, 'btn-secondary': btnSecondary}"
       href="{{ menuElement.url(ngModel) | orElse: '' }}"
       ng-click="menuClick(menuElement, ngModel, $event)">
        {{ menuElement | menuElementName }}
    </a>
    </script>

    <script type="text/ng-template" id="item.menu.html">
    <div ng-controller="menuItemCtrl" class="dropdown-menu dropdown-menu-right" uib-dropdown-menu role="menu">
        <a class="dropdown-item"
           ng-repeat="menuElement in menus | visibleMenuElement: getItem()"
           href="{{ menuElement.url(getItem()) | orElse: '' }}"
           ng-click="menuClick(menuElement, getItem(), $event)">
            {{:: menuElement | menuElementName }}
        </a>
    </div>
    </script>

    <script type="text/ng-template" id="select.member.html">
    <a>
        <span style="margin-top: 5px;margin-left:5px;">{{ match.model | userFullName }}</span>
        <button class="btn btn-secondary btn-sm" type="button" ng-show="!match.model.id">
            ${message(code: 'is.ui.user.will.be.invited.click')} <i class="fa fa-envelope"></i>
        </button>
    </a>
    </script>

    <script type="text/ng-template" id="report.progress.html">
    <is:modal title="${message(code: 'is.dialog.report.generation')}">
        <p class="form-text">
            <g:message code="is.dialog.report.description"/>
        </p>
        <is-progress start="progress"></is-progress>
    </is:modal>
    </script>

    <script type="text/ng-template" id="is.progress.html">
    <uib-progressbar class="m-4" value="progress.value" type="{{ progress.type }}">
        <b>{{progress.label}}</b>
    </uib-progressbar>
    </script>

    <script type="text/ng-template" id="menuitem.item.html">
    <a hotkey="{ '{{:: menu.shortcut }}' : hotkeyClick }"
       class="nav-link"
       data-toggle="collapse"
       data-target="#primary-menu.show"
       hotkey-description="${message(code: 'todo.is.ui.open.view')} {{ menu.title }}"
       href="{{ getMenuUrl(menu) }}">
        <span class="icon-main-menu" ng-class="'icon-main-menu-' + menu.id" as-sortable-item-handle></span>
        <span class="nav-link-title">{{:: menu.title }}</span>
    </a>
    </script>

    <script type="text/ng-template" id="notifications.panel.html">
    <div class="empty-content" ng-show="groupedUserActivities === undefined">
        <i class="fa fa-refresh fa-spin"></i>
    </div>
    <div ng-repeat="groupedActivity in groupedUserActivities">
        <div><h4><a href="{{ serverUrl + '/p/' + groupedActivity.project.pkey + '/' }}">{{ groupedActivity.project.name }}</a></h4></div>
        <div class="media" ng-class="{ 'unread': activity.notRead }" ng-repeat="activity in groupedActivity.activities">
            <img height="36px"
                 ng-src="{{activity.poster | userAvatar}}"
                 class="{{ activity.poster | userColorRoles }}"
                 alt="{{activity.poster | userFullName}}"/>
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
                    <span>{{ activity | activityName }} <a href="{{ activity.story.uid | permalink: 'story': groupedActivity.project.pkey }}">{{ activity.story.name }}</a></span>
                </div>
            </div>
        </div>
    </div>
    <div class="empty-content form-text" ng-show="groupedUserActivities != undefined && groupedUserActivities.length == 0">
        ${message(code: 'todo.is.ui.history.empty')}
    </div>
    </script>

    <script type="text/ng-template" id="search.context.html">
    <a class="text-truncate">
        <i class="fa" ng-class="match.model.type | contextIcon" style="color: {{ match.model.color }}"></i> {{ match.model.term }}
    </a>
    </script>

    <script type="text/ng-template" id="details.modal.html">
    <is:modal header="${false}" footer="${false}" title="{{ message('is.' + detailsType) }}" class="modal-details">
        <div ui-view="details"></div>
    </is:modal>
    </script>

    <script type="text/ng-template" id="states.html">
    <div class="states-progress">
        <div ng-repeat="state in states" class="progress-bar state {{ state.class }}"
             ng-class="{'state-completed': state.completed, 'state-current': state.current}">
            <span class="state-name" tooltip-placement="left" defer-tooltip="{{ state.tooltip  }}">{{ state.name }}</span>
        </div>
    </div>
    </script>

    <script type="text/ng-template" id="details.layout.buttons.html">
    <span>
        <a class="btn btn-icon" href ng-click="closeDetailsViewUrl()"><span class="icon icon-close"></span></a>
    </span>
    </script>

    <script type="text/ng-template" id="icon.with.badge.html">
    <span class="action {{:: classes }}">
        <a href="{{:: href }}"
           class="action-link"
           defer-tooltip="{{:: tooltip }}">
            <span class="action-icon action-icon-{{:: icon }}"></span>
            <span class="badge"><span class="limited">{{:: countString }}</span><span class="full">{{:: count }}</span></span>
        </a>
    </span>
    </script>

    <script type="text/ng-template" id="addWidget.modal.html">
    <is:modal title="${message(code: 'is.ui.widget.new')}"
              form="addWidget(widgetDefinition)"
              submitButton="${message(code: 'is.ui.widget.add')}"
              class="modal-split">
        <div class="row">
            <div class="col-sm-3 modal-split-left">
                <div class="modal-split-search">
                    <input type="text"
                           ng-model="widgetDefinitionSearch"
                           class="form-control search-input"
                           placeholder="${message(code: 'todo.is.ui.search.action')}">
                </div>
                <ul class="nav nav-pills nav-fill flex-column">
                    <li class="nav-item"
                        ng-repeat="currentWidgetDefinition in widgetDefinitions | filter:widgetDefinitionSearch">
                        <a ng-click="detailsWidgetDefinition(currentWidgetDefinition)"
                           class="nav-link"
                           ng-class="{ 'active': currentWidgetDefinition.id == widgetDefinition.id }"
                           href>
                            {{ currentWidgetDefinition.name }}
                        </a>
                    </li>
                </ul>
            </div>
            <div class="col-sm-9 modal-split-right" ng-switch="widgetDefinitions != undefined && widgetDefinitions.length == 0">
                <div ng-switch-when="true">
                    ${message(code: 'is.ui.widget.noAvailableWidgetDefinitions')}
                </div>
                <div class="col-md-12" ng-switch-default>
                    <h4>{{ widgetDefinition.name }}</h4>
                    <p>{{ widgetDefinition.description }}</p>
                </div>
            </div>
        </div>
    </is:modal>
    </script>

    <script type="text/ng-template" id="project.digest.html">
    <h4 class="col-12 clearfix">
        <div class="float-left"><a href="{{:: project.pkey | projectUrl }}" class="link">{{:: project.name }}</a> <small>owned by {{:: project.owner | userFullName }}</small></div>
        <div class="time-stamp float-right">
            <time timeago datetime="{{:: project.lastUpdated }}">{{ project.lastUpdated | dateTime }}</time>
        </div>
    </h4>
    <div class="col-9">
        <div class="description" ng-bind-html="project.description_html | truncateAndSeeMore:project.pkey:(widget.settings.width == 2 ? 195 : null)"></div>
        <div ng-if="project.currentOrNextRelease.currentOrNextSprint.goal" style="margin-top:8px;">
            <p><strong>{{:: message('todo.is.ui.sprint.goal.label', [project.currentOrNextRelease.currentOrNextSprint.index]) }}</strong>
                <span ng-bind-html="project.currentOrNextRelease.currentOrNextSprint.goal | truncateAndSeeMore:project.pkey:(widget.settings.width == 2 ? 20 : 80):'/#/taskBoard/'+project.currentOrNextRelease.currentOrNextSprint.id"></span>
            </p>
        </div>
    </div>
    <div class="col-3">
        <div class="backlogCharts chart float-right" ng-controller="chartCtrl" ng-init="openChart('backlog', 'state', (project | retrieveBacklog:'all'), backlogChartOptions)">
            <nvd3 options="options" ng-if="data.length > 0" data="data" config="{refreshDataOnly: false}"></nvd3>
        </div>
        <div class="team-name text-truncate" title="{{:: project.team.name }}"><i class="fa fa-users"></i> {{:: project.team.name }}</div>
    </div>
    <div class="col-9" style="margin-top:2px">
        <div class="row">
            <ul class="list-inline text-muted col-md-12">
                <li class="release" ng-if=":: project.currentOrNextRelease">
                    <a href="{{:: project.pkey | projectUrl }}#/planning/{{:: project.currentOrNextRelease.id }}" class="link"><i class="fa fa-calendar {{:: project.currentOrNextRelease.state | releaseStateColor }}"></i> <span
                            class="text-truncate">{{:: project.currentOrNextRelease.name }}</span></a>
                </li>
                <li class="features" ng-if=":: project.features_count">
                    <a href="{{:: project.pkey | projectUrl }}#/feature" class="link"><i class="fa fa-puzzle-piece"></i> {{:: project.features_count }} <g:message code="is.ui.feature"/></a>
                </li>
                <li class="stories" ng-if=":: project.stories_count">
                    <a href="{{:: project.pkey | projectUrl }}#/backlog" class="link"><i class="fa fa-sticky-note"></i> {{:: project.stories_count }} <g:message code="todo.is.ui.stories"/></a>
                </li>
                <li class="sprint" ng-if=":: project.currentOrNextRelease.currentOrNextSprint">
                    <a href="{{:: project.pkey | projectUrl }}#/taskBoard/{{:: project.currentOrNextRelease.currentOrNextSprint.id }}" class="link"><div
                            class="progress {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor:'background-light' }}">
                        <span class="progress-value">{{:: project.currentOrNextRelease.currentOrNextSprint | sprintName }}</span>
                        <div class="progress-bar {{:: project.currentOrNextRelease.currentOrNextSprint.state | sprintStateColor:'background' }}" role="progressbar"
                             aria-valuenow="{{:: project.currentOrNextRelease.currentOrNextSprint | computePercentage:'velocity':'capacity' }}" aria-valuemin="0" aria-valuemax="100"
                             style="width: {{:: project.currentOrNextRelease.currentOrNextSprint | computePercentage:'velocity':'capacity' }}%;"></div>
                    </div></a>
                    <span class="time-stamp" ng-if="project.currentOrNextRelease.currentOrNextSprint.state == 2">
                        <time timeago datetime="{{:: project.currentOrNextRelease.currentOrNextSprint.endDate }}">{{ project.currentOrNextRelease.currentOrNextSprint.endDate | dateTime }}</time>
                    </span>
                    <span class="time-stamp" ng-if="project.currentOrNextRelease.currentOrNextSprint.state == 1">
                        <time timeago datetime="{{:: project.currentOrNextRelease.currentOrNextSprint.startDate }}">{{ project.currentOrNextRelease.currentOrNextSprint.startDate | dateTime }}</time>
                    </span>
                </li>
            </ul>
        </div>
    </div>
    <div class="col-3 users" style="margin-top:2px">
        <img ng-src="{{:: user | userAvatar }}"
             ng-repeat="user in ::project.allUsers | limitTo:2"
             height="20" width="20" style="margin-left:5px;"
             class="{{:: user | userColorRoles:project }}"
             defer-tooltip="{{:: user | userFullName }}"/>
        <span class="team-count" ng-if=":: project.allUsers.length > 2">+ {{ project.allUsers.length - 2 }}</span>
    </div>
    </script>

    <script type="text/ng-template" id="documentation.html">
    <a target="_blank"
       ng-class="{small: !big}"
       class="link-documentation"
       href="https://www.icescrum.com/documentation/{{ docUrl }}?utm_source=tool&utm_medium=link&utm_campaign=icescrum">
        <div class="icon-help"></div>
        <span ng-bind-html="message(title != null ? title : 'is.ui.documentation')"></span>
    </a>
    </script>

    <g:render template="/team/templates"/>
    <g:render template="/sprint/templates"/>
    <g:render template="/portfolio/templates"/>
    <g:render template="/project/templates"/>
    <g:render template="/release/templates"/>
    <g:render template="/task/templates/task.light"/>
    <g:render template="/user/templates"/>
    <g:render template="/task/templates/task.estimation"/>
    <g:render template="/feature/templates"/>
    <g:render template="/story/templates"/>
    <g:render template="/attachment/templates"/>
    <g:render template="/activity/templates"/>
    <g:render template="/comment/templates"/>
    <g:render template="/task/templates"/>
    <g:render template="/acceptanceTest/templates"/>
    <entry:point id="templates"/>
    <g:if test="${params.project}">
        <g:render template="/app/templates"/>
        <g:render template="/release/templates"/>
        <g:render template="/timeBoxNotesTemplate/templates"/>
        <g:render template="/backlog/templates"/>
        <entry:point id="templates-project"/>
    </g:if>
    <g:if test="${g.meta(name: 'app.displayWhatsNew')}">
        <script type="text/ng-template" id="is.dialog.whatsNew.html">
        <is:modal title="${message(code: 'is.dialog.about.whatsNew.title')}">
            <g:render template="/scrumOS/about/whatsNew"/>
        </is:modal>
        </script>
    </g:if>
</div>
