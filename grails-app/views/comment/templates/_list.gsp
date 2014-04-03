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
<script type="text-icescrum-template" id="tpl-commentable-comments">
**# var type = commentable.class.toLowerCase() **
**# if (!commentable.comments()) { **
<tr>
    <td class="empty-content">
        <i class="fa fa-refresh fa-spin"></i>
    </td>
</tr>
**# } else if (size(commentable.comments()) > 0) {
_.each(commentable.comments(), function(comment) { **
<tr id="** type **-** commentable.id **-** comment.id **">
    <td class="avatar">
        <img tpl-src="** $.icescrum.user.formatters.avatar(comment.poster) **"
             alt="** $.icescrum.user.formatters.fullName(comment.poster) **"
             width="25px">
    </td>
    <td>
        <div class="content">
            <span class="clearfix text-muted">
                ${message(code:'todo.is.ui.comment.by')} <a href="#">** $.icescrum.user.formatters.fullName(comment.poster) **</a>
                **# if(comment.poster.id == $.icescrum.user.id) { ** - <a href="#" title="${message(code:'todo.is.ui.comment.edit')}"
                                                                          class="text-muted edit-comment"
                                                                          data-commentable-type="** type **"
                                                                          data-commentable-id="** commentable.id **"
                                                                          data-comment-id="** comment.id **"
                                                                          data-toggle="tooltip"
                                                                          data-container="body">${message(code:'todo.is.ui.comment.edit')}</a>
                **# } **
            </span>
            <div class="pretty-printed">
                ** comment.body_html **
            </div>
        **# if($.icescrum.user.poOrSm() || comment.poster.id == $.icescrum.user.id) { ** <a href="${createLink(controller:'comment', id:'** comment.id **', params:[product:'** jQuery.icescrum.product.pkey **', commentable:'** commentable.id **', type:'** type **'])}"
                                                                                            data-ajax="true"
                                                                                            data-ajax-method="DELETE"
                                                                                            data-commentable-type="** type **"
                                                                                            data-commentable-id="** commentable.id **"
                                                                                            data-comment-id="** comment.id **"
                                                                                            data-ajax-success="$.icescrum.comment.delete"
                                                                                            title="${message(code:'todo.is.ui.comment.delete')}"
                                                                                            class="on-hover delete"
                                                                                            data-toggle="tooltip"
                                                                                            data-placement="left"><i class="fa fa-times text-danger"></i></a>
            **# } **
            <small class="clearfix text-muted">
                <time class='timeago' datetime='** comment.dateCreated **'>
                    ** comment.dateCreated **
                </time> ** iff(comment.dateCreated != comment.lastUpdated, '(${message(code:'todo.is.ui.commnent.edited')})')  ** <i class="fa fa-clock-o"></i>
            </small>
        </div>
    </td>
</tr>
**# }); **
**# } else { **
<tr>
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.comment.empty')}</small>
    </td>
</tr>
**# } **
</script>