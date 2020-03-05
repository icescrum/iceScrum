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
        <div class="form-text alert bg-warning mb-3">
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
        <span ng-show="match.model.name && !match.model.id">${message(code: 'todo.is.ui.create.team')}</span> <strong>{{ match.model.name }}</strong>
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
           ng-class="::{'text-danger':menuElement.deleteMenu}"
           ng-repeat="menuElement in menus | visibleMenuElement: getItem(): viewType"
           href="{{ menuElement.url(getItem()) | orElse: '' }}"
           ng-click="menuClick(menuElement, getItem(), $event)">
            <span class="name">{{:: menuElement | menuElementName }}</span>
        </a>
    </div>
    </script>

    <script type="text/ng-template" id="select.member.html">
    <a>
        <span ng-if="match.model.id">{{ match.model | userFullName }}</span>
        <button class="btn btn-secondary btn-sm"
                ng-if="!match.model.id"
                type="button">
            {{ 'is.ui.user.will.be.invited.click' | message: [(match.model | userFullName)] }} <i class="fa fa-envelope"></i>
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
       hotkey-description="${message(code: 'todo.is.ui.open.view')} {{ menu.title }}"
       href="{{ getMenuUrl(menu) }}">
        <div data-toggle="collapse"
             data-target="#primary-menu.show"
             class="d-flex align-items-center">
            <span class="icon-main-menu" ng-class="'icon-main-menu-' + menu.id" as-sortable-item-handle></span>
            <span class="nav-link-title">{{:: menu.title }}</span>
        </div>
    </a>
    </script>

    <script type="text/ng-template" id="notifications.panel.html">
    <div class="empty-content" ng-show="groupedUserActivities === undefined">
        <i class="fa fa-refresh fa-spin"></i>
    </div>

    <div ng-repeat="groupedActivity in groupedUserActivities"
         ng-class="{'mb-3': !$last}">
        <div class="pl-3 pr-3">
            <a href="{{ groupedActivity.project.pkey | projectUrl }}">
                <strong class="text-accent font-size-base">{{ groupedActivity.project.name }}</strong>
            </a>
        </div>
        <div class="pt-2 pl-3 pr-3"
             ng-class="{ 'activity-unread': activity.notRead, 'pb-2': $last }"
             ng-repeat="activity in groupedActivity.activities">
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
                        <a href="{{:: activity.story.permalink }}" class="link">{{ activity.story.name }}</a>
                    </div>
                </div>
            </div>
            <hr ng-if="!$last" class="mb-0 mt-2"/>
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
                <ul class="nav nav-pills flex-column">
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
    <div class="rich-content font-size-sm" ng-bind-html="project.description_html ? (project.description_html | stripTags : '<br><p>') : ''"></div>
    <div ng-if="project.currentOrNextRelease" class="release-vision mb-0 mt-3">
        <div class="d-flex justify-content-between">
            <div><strong class="text-accent">{{ project.currentOrNextRelease.name }}</strong></div>
            <div>{{ project.currentOrNextRelease.startDate | dayShorter }} | {{ project.currentOrNextRelease.endDate | dayShorter }}</div>
        </div>
        <div class="rich-content"
             ng-if="project.currentOrNextRelease.vision_html"
             ng-bind-html="project.currentOrNextRelease.vision_html">
        </div>
    </div>
    <div ng-if="project.currentOrNextRelease.currentOrNextSprint.goal" class="sprint-goal mr-0">
        <div class="sprint-goal-label d-flex justify-content-between">
            <div>{{ message('todo.is.ui.sprint.goal.label', [project.currentOrNextRelease.currentOrNextSprint.index]) }}</div>
            <div>{{ project.currentOrNextRelease.currentOrNextSprint.startDate | dayShorter }} | {{ project.currentOrNextRelease.currentOrNextSprint.endDate | dayShorter }}</div>
        </div>
        <div>{{ project.currentOrNextRelease.currentOrNextSprint.goal }}</div>
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
