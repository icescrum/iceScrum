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
    <svg class="logo loading" width="100%" height="100%" x="0px" y="0px" viewBox="0 0 150 150" style="enable-background:new 0 0 150 150;" xml:space="preserve">
        <path class="logois logois1" fill="#42A9E0" d="M77.345,118.476c0,0-44.015-24.76-47.161-26.527c-3.146-1.771-0.028-3.523-0.028-3.523  l49.521-27.854c0,0,46.335,26.058,49.486,27.833c3.154,1.771,0.008,3.545,0.008,3.545S83.921,117.4,81.978,118.492  C79.676,119.787,77.345,118.476,77.345,118.476z"/>
        <path class="logois logois2" fill="1C3660" d="M77.349,107.287c0,0-44.019-24.758-47.165-26.527s0-3.539,0-3.539L79.68,49.38  c0,0,46.332,26.062,49.482,27.834c3.154,1.775,0.008,3.547,0.008,3.547s-45.193,25.422-47.16,26.525  C79.676,108.599,77.349,107.287,77.349,107.287z"/>
        <path class="logois logois3" fill="#FFCC04" d="M77.345,95.244c0,0-44.015-24.76-47.161-26.529s0-3.541,0-3.541  s44.814-25.207,47.153-26.522c2.339-1.313,4.602-0.041,4.602-0.041l36.191,20.396c0,0,4.141,1.336,8.162-0.852  c0.33-0.178,0.924-0.553,0.922,0.732c-0.014,12.328-15.943,19.957-15.943,19.957S84.345,93.939,82.009,95.248  C79.676,96.556,77.345,95.244,77.345,95.244z"/>
    </svg>
</script>
<script type="text/ng-template" id="confirm.modal.html">
    <is:modal form="submit()"
              submitButton="${message(code:'todo.is.ui.confirm')}"
              closeButton="${message(code:'is.button.cancel')}"
              title="${message(code:'todo.is.ui.confirm.title')}">
        {{ message }}
    </is:modal>
</script>

<script type="text/ng-template" id="select.or.create.team.html">
<a>
    <span ng-show="!match.model.id">${message(code:'todo.is.ui.create.team')} </span><span>{{ match.model.name }}</span>
</a>
</script>

<script type="text/ng-template" id="select.member.html">
<a>
    <span ng-show="!match.model.id">${message(code:'todo.is.ui.user.will.be.invited')} </span><span>{{ match.model | userFullName }}</span>
</a>
</script>

<script type="text/ng-template" id="copy.html">
<is:modal title="{{ title }}">
    <input type="text" autofocus select-on-focus class="form-control" value="{{ value }}"/>
</is:modal>
</script>

<script type="text/ng-template" id="report.progress.html">
<is:modal title="${message(code:'is.dialog.report.generation')}">
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
<a  hotkey="{ '{{ menu.shortcut }}' : hotkeyClick }"
    hotkey-description="${message(code:'todo.is.ui.open.view')} {{ menu.title }}"
    uib-tooltip="{{ menu.title + ' (' + menu.shortcut + ')' }}"
    tooltip-placement="bottom"
    unavailable-feature="menu.id == 'search'"
    href="#/{{ menu.id != 'project' ? menu.id : '' }}">
    <i class="{{ menu.icon }}" as-sortable-item-handle></i> <span class="title hidden-sm">{{ menu.title }}</span>
</a>
</script>

<script type="text/ng-template" id="profile.panel.html">
    <div class="media">
        <div class="media-left">
            <img ng-src="{{ currentUser | userAvatar }}"
                 alt="{{currentUser | userFullName}}"
                 height="60px"
                 width="60px"/>
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
            </div>
        </div>
    </div>
    <div class="btn-toolbar pull-right">
        <a href
           class="btn btn-default"
           hotkey="{'U':showProfile}"
           uib-tooltip="${message(code:'is.dialog.profile')} (U)"
           ng-click="showProfile()">${message(code:'is.dialog.profile')}
        </a>
        <a class="btn btn-danger"
           href="${createLink(controller:'logout')}">
            ${message(code:'is.logout')}
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
                    <span>{{ message('is.fluxiable.' + activity.code ) }} <a href="{{ activity.story.uid | permalink: 'story' }}">{{ activity.story.name }}</a></span>
                </div>
            </div>
        </div>
    </div>
    <div class="empty-content" ng-show="groupedUserActivities != undefined && groupedUserActivities.length == 0">
        <small>${message(code:'todo.is.ui.activities.empty')}</small>
    </div>
</script>

<script type="text/ng-template" id="search.context.html">
<a class="text-ellipsis">
    <i class="fa" ng-class="match.model.type == 'feature' ? 'fa-sticky-note' : 'fa-tag'"></i> {{ match.model.term }}
</a>
</script>