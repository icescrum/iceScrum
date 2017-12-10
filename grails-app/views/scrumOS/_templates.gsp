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
    <svg class="logo" viewBox="0 0 150 150">
        <g:render template="/scrumOS/logo"/>
    </svg>
    </script>

    <script type="text/ng-template" id="chart.modal.html">
    <is:modal title="${message(code: 'is.ui.widget.chart.chart')}">
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
    <is:modal title="${message(code: 'todo.is.ui.message.title')}">
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

    <script type="text/ng-template" id="select.or.create.team.html">
    <a>
        <span ng-show="!match.model.id">${message(code: 'todo.is.ui.create.team')}</span> <strong>{{ match.model.name }}</strong>
    </a>
    </script>

    <script type="text/ng-template" id="button.shortcutMenu.html">
    <a ng-show="menuElement.name"
       class="btn"
       title="{{ message(menuElement.name) }}"
       ng-class="{'btn-sm': btnSm, 'btn-primary': btnPrimary, 'btn-default': !btnPrimary}"
       ng-href="{{ menuElement.url(ngModel) }}"
       ng-click="menuElement.action(ngModel)">
        {{ message(menuElement.name) }}
    </a>
    </script>

    <script type="text/ng-template" id="item.menu.html">
    <ul ng-controller="menuItemCtrl" class="dropdown-menu dropdown-menu-right" uib-dropdown-menu role="menu">
        <li ng-repeat="menuElement in menus | visibleMenuElement: getItem()">
            <a ng-href="{{ menuElement.url(getItem()) }}"
               ng-click="menuElement.action(getItem())">
                {{ message(menuElement.name) }}
            </a>
        </li>
    </ul>
    </script>

    <script type="text/ng-template" id="select.member.html">
    <a>
        <span style="margin-top: 5px;margin-left:5px;">{{ match.model | userFullName }}</span> <button class="btn btn-default btn-sm" type="button" ng-show="!match.model.id">${message(code: 'todo.is.ui.user.will.be.invited.click')}</button>
    </a>
    </script>

    <script type="text/ng-template" id="copy.html">
    <is:modal title="{{ title }}">
        <input type="text" autofocus select-on-focus class="form-control" value="{{ value }}"/>
    </is:modal>
    </script>

    <script type="text/ng-template" id="report.progress.html">
    <is:modal title="${message(code: 'is.dialog.report.generation')}">
        <p class="help-block">
            <g:message code="is.dialog.report.description"/>
        </p>
        <is-progress start="progress"></is-progress>
    </is:modal>
    </script>

    <script type="text/ng-template" id="is.progress.html">
    <uib-progressbar value="progress.value" type="{{ progress.type }}">
        <b>{{progress.label}}</b>
    </uib-progressbar>
    </script>

    <script type="text/ng-template" id="menuitem.item.html">
    <a hotkey="{ '{{ menu.shortcut }}' : hotkeyClick }"
       hotkey-description="${message(code: 'todo.is.ui.open.view')} {{ menu.title }}"
       uib-tooltip="{{ menu.title + ' (' + menu.shortcut + ')' }}"
       tooltip-placement="bottom"
       href="#/{{ menu.id }}">
        <i class="fa fa-lg" ng-class="'fa-' + menu.icon" as-sortable-item-handle></i> <span class="title hidden-sm">{{ menu.title }}</span>
    </a>
    </script>

    <script type="text/ng-template" id="profile.panel.html">
    <div class="media">
        <div class="media-left">
            <img ng-src="{{ currentUser | userAvatar }}"
                 alt="{{currentUser | userFullName}}"
                 height="50px"
                 width="50px"/>
        </div>
        <div class="media-body">
            <div>
                {{ (currentUser | userFullName) + ' (' + currentUser.username + ')' }}
            </div>
            <div class="text-muted">
                <div>{{currentUser.email}}</div>
                <div>{{currentUser.preferences.activity}}</div>
                <g:if test="${project}">
                    <div>
                        <strong><is:displayRole project="${project}"/></strong>
                    </div>
                </g:if>
                <entry:point id="user-profile-panel"/>
            </div>
        </div>
    </div>
    <div class="btn-toolbar pull-right">
        <a href
           class="btn btn-default"
           hotkey="{'U':showProfile}"
           hotkey-description="${message(code: 'todo.is.ui.profile')}"
           uib-tooltip="${message(code: 'is.dialog.profile')} (U)"
           ng-click="showProfile()">${message(code: 'is.dialog.profile')}
        </a>
        <a class="btn btn-danger"
           href="${createLink(controller: 'logout')}">
            ${message(code: 'is.logout')}
        </a>
    </div>
    </script>

    <script type="text/ng-template" id="notifications.panel.html">
    <div class="empty-content" ng-show="groupedUserActivities === undefined">
        <i class="fa fa-refresh fa-spin"></i>
    </div>
    <div ng-repeat="groupedActivity in groupedUserActivities">
        <div><h4><a href="{{ serverUrl + '/p/' + groupedActivity.project.pkey + '/' }}">{{ groupedActivity.project.name }}</a></h4></div>
        <div class="media" ng-class="{ 'unread': activity.notRead }" ng-repeat="activity in groupedActivity.activities">
            <div class="media-left">
                <img height="36px"
                     ng-src="{{activity.poster | userAvatar}}"
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
                    <span>{{ activity | activityName }} <a href="{{ activity.story.uid | permalink: 'story': groupedActivity.project.pkey }}">{{ activity.story.name }}</a></span>
                </div>
            </div>
        </div>
    </div>
    <div class="empty-content" ng-show="groupedUserActivities != undefined && groupedUserActivities.length == 0">
        <small>${message(code: 'todo.is.ui.history.empty')}</small>
    </div>
    </script>

    <script type="text/ng-template" id="search.context.html">
    <a class="text-ellipsis">
        <i class="fa" ng-class="match.model.type | contextIcon" style="color: {{ match.model.color }}"></i> {{ match.model.term }}
    </a>
    </script>

    <script type="text/ng-template" id="details.modal.html">
    <is:modal footer="${false}" title="{{ message('is.' + detailsType) }}" class="modal-details">
        <div ui-view="details"></div>
    </is:modal>
    </script>

    <script type="text/ng-template" id="states.html">
    <div class="states-container">
        <div class="states">
            <div ng-repeat="state in states" class="progress-bar state {{ state.class }}"
                 ng-class="{'state-completed': state.completed, 'state-current': state.current}"
                 tooltip-placement="left"
                 uib-tooltip="{{ state.tooltip  }}"
                 ng-style="{width: state.width + '%'}">
                <span class="state-name">{{ state.name }}</span>
            </div>
        </div>
    </div>
    </script>

    <script type="text/ng-template" id="details.layout.buttons.html">
    <div class="btn-group">
        <button class="btn btn-default minimizable"
                ng-click="toggleMinimizedDetailsView()"
                uib-tooltip="${message(code: 'is.ui.window.minimize')}">
            <i ng-class="['fa fa-window-minimize', application.minimizedDetailsView ? 'fa-rotate-180' : '']"></i>
        </button>
        <button class="btn btn-default detachable"
                ng-click="toggleDetachedDetailsView()"
                uib-tooltip="${message(code: 'is.ui.window.detach')}">
            <i ng-class="['fa', application.detachedDetailsView ? 'fa-window-maximize' : 'fa-window-restore']"></i>
        </button>
        <a class="btn btn-default"
           href="{{ closeDetailsViewUrl() }}"
           uib-tooltip="${message(code: 'is.ui.window.closeable')}">
            <i class="fa fa-times"></i>
        </a>
    </div>
    </script>

    <script type="text/ng-template" id="icon.with.badge.html">
    <span ng-class="::[classes,'action',{'active': count > 0}]">
        <a href="{{:: href }}"
           uib-tooltip="{{:: count + ' ' + tooltip }}">
            <i class="fa {{:: count > 0 ? icon : iconEmpty }}"></i>
            <span class="badge"><span class="limited">{{:: countString }}</span><span class="full">{{:: count }}</span></span>
        </a>
    </span>
    </script>

    <script type="text/ng-template" id="addWidget.modal.html">
    <is:modal title="${message(code: 'is.ui.widget.new')}"
              validate="true"
              name="addWidgetForm"
              form="addWidget(widgetDefinition)"
              submitButton="${message(code: 'is.ui.widget.add')}"
              class="add-widget split-modal">
        <div class="row">
            <div class="left-panel col-sm-3">
                <div class="left-panel-header">
                    <div class="input-group">
                        <input type="text"
                               ng-model="widgetDefinitionSearch"
                               name="widget-definition-search-input"
                               class="form-control"
                               placeholder="${message(code: 'todo.is.ui.search.action')}">
                        <span class="input-group-btn">
                            <button class="btn btn-default"
                                    type="button"
                                    ng-click="widgetDefinitionSearch = ''">
                                <i class="fa" ng-class="widgetDefinitionSearch ? 'fa-times' : 'fa-search'"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <ul class="left-panel-body nav nav-list">
                    <li ng-class="{ 'current': currentWidgetDefinition.id == widgetDefinition.id }"
                        ng-repeat="currentWidgetDefinition in widgetDefinitions | filter:widgetDefinitionSearch">
                        <a ng-click="detailsWidgetDefinition(currentWidgetDefinition)" href>
                            <i class="fa fa-{{ currentWidgetDefinition.icon }}"></i> {{ currentWidgetDefinition.name }}
                        </a>
                    </li>
                </ul>
            </div>
            <div class="right-panel col-sm-9" ng-switch="widgetDefinitions != undefined && widgetDefinitions.length == 0">
                <div ng-switch-when="true">
                    ${message(code: 'is.ui.widget.noAvailableWidgetDefinitions')}
                </div>
                <div class="col-md-12" ng-switch-default>
                    <div ng-include="'widgetDefinition.details.html'"></div>
                </div>
            </div>
        </div>
    </is:modal>
    </script>

    <script type="text/ng-template" id="widgetDefinition.details.html">
    <h4><i class="fa fa-{{ widgetDefinition.icon }}"></i> {{ widgetDefinition.name }}</h4>
    <p>{{ widgetDefinition.description }}</p>
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
