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
    <span ng-show="!match.model.id">${message(code:'todo.is.ui.user.will.be.invited')} </span><span>{{ match.model.firstName }} {{ match.model.lastName }}</span>
</a>
</script>

<script type="text/ng-template" id="copy.html">
<is:modal title="{{ title }}">
    <p class="help-block">${ message(code: 'todo.is.ui.copy.instructions')}</p>
    <input type="text" focus-me="true" select-on-focus class="form-control" value="{{ value }}"/>
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
    <progressbar value="progress.value" type="{{ progress.type }}">
        <b>{{progress.label}}</b>
    </progressbar>
</script>

<script type="text/ng-template" id="menuitem.item.html">
<a  hotkey="{ '{{ menu.shortcut }}' : hotkeyClick }"
    hotkey-description="${message(code:'todo.is.open.view')} {{ menu.title }}"
    tooltip="{{ menu.title }} ({{ menu.shortcut }})"
    tooltip-placement="bottom"
    href='#/{{ menu.id }}'>
    <span class="handle">::</span>
    <i class="visible-xs {{ menu.icon }}"></i><span class="title">{{ menu.title }}</span>
</a>
</script>

<script type="text/ng-template" id="profile.panel.html">
    <div class="panel panel-default" id="panel-current-user">
        <div class="panel-body">
            <img ng-src="{{ currentUser | userAvatar }}" height="60px" width="60px" class="pull-left"/>
            {{ currentUser.username }}
            <g:if test="${product}">
                <br/>
                <a href="javascript:;" onclick="$('#edit-members').find('a').click();"><strong> <is:displayRole product="${product.id}"/> </strong></a>
            </g:if>
        </div>
        <div class="panel-footer">
            <div class="row">
                <div>
                    <a class="btn btn-info"
                       hotkey="{'U':showProfile}"
                       tooltip="${message(code:'is.dialog.profile')} (U)"
                       tooltip-append-to-body="true"
                       ng-click="showProfile()">${message(code:'is.dialog.profile')}</a>
                </div>
                <div>
                    <a class="btn btn-danger" href="${createLink(controller:'logout')}">${message(code:'is.logout')}</a>
                </div>
            </div>
        </div>
    </div>
</script>
<script type="text/ng-template" id="notifications.panel.html">
    <table class="table">
        <tr ng-show="userActivities === undefined">
            <td class="empty-content">
                <i class="fa fa-refresh fa-spin"></i>
            </td>
        </tr>
        <tr ng-repeat="activity in userActivities"
            ng-class="{ 'info' : $index < getUnreadActivitiesCount() }">
            <td>
                <img height="21px"
                     ng-src="{{activity.poster | userAvatar}}"
                     alt="{{activity.poster | userFullName}}"/>
                <span class="text-muted">
                    <time timeago datetime="'{{ activity.dateCreated }}'">
                        {{ activity.dateCreated }}
                    </time>
                    <i class="fa fa-clock-o"></i>
                </span>
                <p>
                    <span style="width:15px; text-align: center"
                          tooltip="{{ activity.dateCreated }}"
                          tooltip-append-to-body="true"
                          class="{{ activity | activityIcon}}"
                          ng-class="{ 'important-activity' : activity.important }"></span>
                    <span>
                        {{ message('todo.is.ui.activity.type.' + activity.parentType) + ' ' + message('todo.is.ui.activity.' + activity.code ) }}
                    </span>
                </p>
            </td>
        </tr>
        <tr ng-show="userActivities !== undefined && userActivities.length == 0">
            <td class="empty-content">
                <small>${message(code:'todo.is.ui.user.activities.empty')}</small>
            </td>
        </tr>
    </table>
</script>