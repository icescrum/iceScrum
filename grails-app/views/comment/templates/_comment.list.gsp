%{--
- Copyright (c) 2014 Kagilum.
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
--}%
<script type="text/ng-template" id="comment.list.html">
<tr ng-show="selected.comments === undefined">
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
<tr ng-repeat="comment in selected.comments" ng-controller="commentCtrl">
    <img ng-src="{{comment.poster | userAvatar}}"
         alt="{{comment.poster | userFullName}}"
         tooltip="{{comment.poster | userFullName}}"
         width="25px">
    <td>
        <div class="content">
            <span class="clearfix text-muted">
                ${message(code:'todo.is.ui.comment.by')} <a href="#">{{comment.poster | userFullName}}</a>
                **# if(comment.poster.id == $.icescrum.user.id) { ** - <a href
                                                                          ng-click="edit(comment, selected)"
                                                                          tooltip="${message(code:'todo.is.ui.comment.edit')}"
                                                                          class="text-muted"
                                                                          tooltip-append-to-body="true">${message(code:'todo.is.ui.comment.edit')}</a>
                **# } **
            </span>
            <div class="pretty-printed">
                {{ comment.body }}
            </div>
            **# if($.icescrum.user.poOrSm() || comment.poster.id == $.icescrum.user.id) { ** <a href
                                                                                                ng-click="delete(comment, selected)"
                                                                                                tooltip="${message(code:'todo.is.ui.comment.delete')}"
                                                                                                class="on-hover delete"
                                                                                                tooltip-append-to-body="true"><i class="fa fa-times text-danger"></i></a>
            **# } **
            <small class="clearfix text-muted">
                <time class='timeago' datetime='{{ comment.dateCreated }}'>
                    {{ comment.dateCreated }}
                </time> <span ng-show="comment.dateCreated != comment.lastUpdated">${message(code:'todo.is.ui.commnent.edited')}</span> <i class="fa fa-clock-o"></i>
            </small>
        </div>
    </td>
</tr>
<tr ng-show="!selected.comments && selected.comments !== undefined">
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.comment.empty')}</small>
    </td>
</tr>
</script>