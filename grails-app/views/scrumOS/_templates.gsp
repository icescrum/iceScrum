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
<script type="text/ng-template" id="loading.html">
<svg class="logo" viewBox="0 0 150 150">
    <g:render template="/scrumOS/logo"/>
</svg>
</script>

<script type="text/ng-template" id="confirm.modal.html">
<is:modal form="submit()"
          submitButton="${message(code: 'todo.is.ui.confirm')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'todo.is.ui.confirm.title')}">
    {{ message }}
</is:modal>
</script>

<script type="text/ng-template" id="select.or.create.team.html">
<a>
    <span ng-show="!match.model.id">${message(code: 'todo.is.ui.create.team')}</span> <strong>{{ match.model.name }}</strong>
</a>
</script>

<script type="text/ng-template" id="select.member.html">
<a>
    <span ng-show="!match.model.id">${message(code: 'todo.is.ui.user.will.be.invited')}</span> <span>{{ match.model | userFullName }}</span>
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
    <i class="fa fa-{{ menu.icon }}" as-sortable-item-handle></i> <span class="title hidden-sm">{{ menu.title }}</span>
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
            <g:if test="${product}">
                <div>
                    <strong><is:displayRole product="${product.id}"/></strong>
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
                <span class="{{ activity | activityIcon}}"></span>
                <span>{{ message('is.fluxiable.' + activity.code ) }} <a href="{{ activity.story.uid | permalink: 'story': groupedActivity.project.pkey }}">{{ activity.story.name }}</a></span>
            </div>
        </div>
    </div>
</div>
<div class="empty-content" ng-show="groupedUserActivities != undefined && groupedUserActivities.length == 0">
    <small>${message(code: 'todo.is.ui.activities.empty')}</small>
</div>
</script>

<script type="text/ng-template" id="search.context.html">
<a class="text-ellipsis">
    <i class="fa" ng-class="match.model.type == 'feature' ? 'fa-sticky-note' : 'fa-tag'"></i> {{ match.model.term }}
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


<script type="text/ng-template" id="manageApps.modal.html">
<is:modal title="${message(code: 'is.dialog.manageApps.title')}"
          validate="true"
          name="manageAppsForm"
          form="manageApp(app)"
          class="manage-apps split-modal">
    <div class="row" ng-class="{ 'hide-left-panel': viewApp == 'list' }">
        <div class="left-panel">
            <div class="left-panel-header">
                <div class="input-group">
                    <input type="text"
                           ng-model="appSearch"
                           name="app-search-input"
                           value="{{ appSearch }}"
                           class="form-control"
                           placeholder="${message(code: 'todo.is.ui.search.action')}">
                    <span class="input-group-btn">
                        <button class="btn btn-default" type="button"><i class="fa fa-search"></i></button>
                    </span>
                </div>
            </div>
            <ul class="left-panel-body nav nav-list">
                <div class="text-center more-results" ng-hide="filteredApps.length">
                    <a href="${message(code: 'is.dialog.manageApps.store.query')}{{ appSearch }}">${message(code:'is.dialog.manageApps.store.search')}</a>
                </div>
                <li ng-class="{ 'current': currentApp == holder.app }"
                    ng-repeat="currentApp in filteredApps = (apps | filter:appSearch)">
                    <a ng-click="detailsApp(currentApp)" href>
                        <i class="fa fa-{{ currentApp.icon }}"></i>
                        {{ currentApp.name }}
                        <i ng-if="currentApp.installed" class="fa fa-check text-success"></i>
                    </a>
                </li>
            </ul>
        </div>
        <div class="right-panel" ng-switch on="viewApp">
            <div ng-switch-when="details" class="details-app">
                <div ng-include="'app.details.html'"></div>
            </div>
            <div ng-switch-when="empty" class="more-results">
                <a href="${message(code: 'is.dialog.manageApps.store.query')}">${message(code:'is.dialog.manageApps.store.search')}</a>
            </div>
            <div ng-switch-default>
                <div ng-include="'app.list.html'"></div>
            </div>
        </div>
    </div>
</is:modal>
</script>

<script type="text/ng-template" id="app.list.html">
<div class="row">
    <div class="col-md-offset-1 col-md-10 text-center">
            <div class="input-group">
                <input type="text"
                   ng-model="appSearch"
                   value="{{ appSearch }}"
                   name="app-search-input"
                   class="form-control"
                   placeholder="${message(code: 'todo.is.ui.search.action')}">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"><i class="fa fa-search"></i></button>
            </span>
        </div>
    </div>
</div>
<div class="row list">
    <div class="col-xs-6 col-md-3" ng-repeat="currentApp in filteredApps = (apps | filter:appSearch)">
        <a ng-click="detailsApp(currentApp)" class="thumbnail">
            <img ng-src="currentApp.logo" alt="currentApp.name">
        </a>
    </div>
    <div class="text-center more-results" ng-hide="filteredApps.length">
        <a href="${message(code: 'is.dialog.manageApps.store.query')}{{ appSearch }}">${message(code:'is.dialog.manageApps.store.search')}</a>
    </div>
</div>
</script>

<script type="text/ng-template" id="app.details.html">
<h3><i class="fa fa-{{ holder.app.icon }}"></i> {{ holder.app.name }}
    <div class="pull-right">
        <button ng-click="detailsApp()"
                class="btn btn-default"><i class="fa fa-times"></i></button>
    </a>
    </div>
</h3>
<h4>${message(code: 'is.app.screenshots')}</h4>
<div class="row">
    <div class="col-md-8">
        <div class="col-md-6" ng-repeat="screenshot in holder.app.screenshots">
            <a href
               class="thumbnail"
               ng-click="selectScreenshot(screenshot)"
               ng-class="{'current':holder.screenshot == screenshot}">
                <img ng-src="{{ screenshot }}">
            </a>
        </div>
    </div>
    <div class="col-md-4">
        <div class="text-center actions">
            <p>
                <button type="submit"
                        class="btn btn-success"
                        ng-if="holder.app.enabled">${message(code: 'is.dialog.manageApps.enable')}</button>
                <button type="submit"
                        class="btn btn-danger"
                        ng-if="!holder.app.enabled">${message(code: 'is.dialog.manageApps.disable')}</button>
            </p>
            <p>
                <a href
                   ng-if="!holder.app.enabled"
                   class="btn btn-default">
                    ${message(code: 'is.dialog.manageApps.configure')}
                </a>
            </p>
            <p>
                <a href="{{ holder.app.documentation }}"
                   class="btn btn-default">
                    ${message(code: 'is.app.url.documentation')}
                </a>
            </p>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-8">
        <h4>${message(code: 'is.app.description')}</h4>
        <p class="description" ng-bind-html="holder.app.description"></p>
    </div>
    <div class="col-md-4">
        <h4>${message(code: 'is.dialog.manageApps.information')}</h4>
        <table class="table information">
            <tr>
                <td class="text-right">${message(code:'is.app.author')}</td>
                <td><a href="mailto:{{ holder.app.email }}">{{ holder.app.author }}</a></td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.version')}</td>
                <td>{{ holder.app.version }}</td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.updated')}</td>
                <td>{{ holder.app.updated }}</td>
            </tr>
            <tr>
                <td class="text-right">${message(code:'is.app.widgets')}</td>
                <td>{{ holder.app.widgets ? '${message(code:'is.yes')}' : '${message(code:'is.no')}' }}</td>
            </tr>
            <tr>
                <td colspan="2" class="text-center"><a href="{{ holder.app.website }}">${message(code:'is.app.url.website')}</a></td>
            </tr>
        </table>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <span class="text-muted" ng-repeat="tag in holder.app.tags track by $index"><a href ng-click="search(tag)">{{ tag }}</a>{{$last ? '' : ', '}}</span>
    </div>
</div>
</script>
