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
   unavailable-feature="menu.id == 'search'"
   href="#/{{ menu.id != 'project' ? menu.id : '' }}">
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
                        <button class="btn btn-default" type="button"><i class="fa fa-search"></i></button>
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


<script type="text/ng-template" id="manageExtensions.modal.html">
<is:modal title="${message(code: 'is.dialog.manageExtensions.title')}"
          validate="true"
          name="manageExtensionsForm"
          form="manageExtension(extension)"
          class="manage-extensions split-modal">
    <div class="row">
        <div class="left-panel col-sm-3">
            <div class="left-panel-header">
                <div class="input-group">
                    <input type="text"
                           ng-model="extensionSearch"
                           name="extension-search-input"
                           class="form-control"
                           placeholder="${message(code: 'todo.is.ui.search.action')}">
                    <span class="input-group-btn">
                        <button class="btn btn-default" type="button"><i class="fa fa-search"></i></button>
                    </span>
                </div>
            </div>
            <ul class="left-panel-body nav nav-list">
                <li ng-class="{ 'current': currentExtension == holder.extension }"
                    ng-repeat="currentExtension in extensions | filter:extensionSearch">
                    <a ng-click="detailsExtension(currentExtension)" href>
                        <i class="fa fa-{{ currentExtension.icon }}"></i>
                        {{ currentExtension.name }}
                        <i ng-if="currentExtension.installed" class="fa fa-check text-success"></i>
                    </a>
                </li>
            </ul>
        </div>
        <div class="right-panel col-sm-9" ng-switch="extensions != undefined && extensions.length == 0">
            <div ng-switch-when="true">
                ${message(code: 'is.dialog.noAvailableExtensions')}
            </div>
            <div ng-switch-default>
                <div ng-include="'extension.details.html'"></div>
            </div>
        </div>
    </div>
</is:modal>
</script>

<script type="text/ng-template" id="extension.details.html">
<h4><i class="fa fa-{{ holder.extension.icon }}"></i> {{ holder.extension.name }} <small>v{{ holder.extension.version }} {{ holder.extension.publishDate ? ' - ' + holder.extension.publishDate : '' }}</small>
    <div class="pull-right">
        <div class="btn-group" ng-if="holder.extension.installed">
            <a href
               unavailable-feature="true"
               uib-tooltip="${message(code: 'is.dialog.manageExtensions.configure')}" tooltip-placement="top"
               class="btn btn-default">
                <i class="fa fa-cog"></i>
            </a>
            <button ng-if="!holder.extension.includedWithLicense"
                    unavailable-feature="true"
                    uib-tooltip="${message(code: 'is.dialog.manageExtensions.uninstall')}" tooltip-placement="top"
                    class="btn btn-default"><i class="fa fa-times"></i></button>
        </div>
        <button disabled
                class="btn btn-success"
                style="margin-left:15px"
                ng-if="holder.extension.installed && holder.extension.includedWithLicense">${message(code: 'is.dialog.manageExtensions.includedWithLicense')}</button>
        <button disabled
                class="btn btn-success"
                style="margin-left:15px"
                ng-if="holder.extension.installed && !holder.extension.includedWithLicense">${message(code: 'is.dialog.manageExtensions.installed')}</button>
        <button type="submit"
                class="btn btn-primary"
                unavailable-feature="true"
                ng-if="!holder.extension.installed">${message(code: 'is.dialog.manageExtensions.install')}</button>
    </div>
</h4>
<p>${message(code: 'is.dialog.manageExtensions.from')} <a
        href="{{ holder.extension.website }}">{{ holder.extension.author }}</a>, <a
        href="{{ holder.extension.documentation }}">${message(code: 'is.dialog.manageExtensions.documentation')}</a></p>
<uib-tabset type="tabs">
    <uib-tab heading="${message(code: 'is.dialog.manageExtensions.description')}">
        <p ng-bind-html="holder.extension.description"></p>
    </uib-tab>
    <uib-tab heading="${message(code: 'is.dialog.manageExtensions.screenshots')}">
        <div class="row"
             ng-if="holder.screenshot">
            <div class="col-xs-10 col-md-9">
                <img ng-src="{{ holder.screenshot }}" class="screenshot">
            </div>
            <div class="col-xs-2 col-md-3 screenshots">
                <div class="row">
                    <div class="col-md-12" ng-repeat="screenshot in holder.extension.screenshots">
                        <a href
                           class="thumbnail"
                           ng-click="selectScreenshot(screenshot)"
                           ng-class="{'current':holder.screenshot == screenshot}">
                            <img ng-src="{{ screenshot }}">
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </uib-tab>
</uib-tabset>
</script>