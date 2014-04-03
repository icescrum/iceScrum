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
<script type="text-icescrum-template" id="tpl-comment-new">
**# var type = commentable.class.toLowerCase() **
    <table class="table comment-editor">
        <tbody>
        <tr class="comment-editor">
            <td class="avatar">
                <img tpl-src="** $.icescrum.user.formatters.avatar($.icescrum.user) **" width="25px">
            </td>
            <td>
                <form role='form'
                      method='POST'
                      action='${createLink(controller:'comment', params:[product:'** jQuery.icescrum.product.pkey **', commentable:'** commentable.id **', type:'** type **'])}'
                      data-commentable-id="** commentable.id **"
                      data-commentable-type="** type **"
                      data-ajax
                      data-ajax-success='$.icescrum.comment.add'>
                    <textarea name="comment.body"
                              class="form-control"
                              data-mkp="true"
                              placeholder="${message(code:'todo.is.ui.comment')}"></textarea>
                    <div class="markItUpFooter">
                        <small class="text-muted">${message(code:'todo.is.ui.comment.cancel')}</small>
                        <button type="submit" class="btn btn-primary btn-sm pull-right">${message(code:'todo.is.ui.comment.post')}</button>
                    </div>
                </form>
            </td>
        </tr>
        </tbody>
    </table>
</script>
<script type="text-icescrum-template" id="tpl-comment-edit">
**# var type = commentable.class.toLowerCase() **
<tr class="comment-editor-edit">
    <td class="avatar">
        <img tpl-src="** $.icescrum.user.formatters.avatar($.icescrum.user) **" width="25px">
    </td>
    <td>
        <form role='form'
              method='POST'
              action='${createLink(controller:'comment', action:'update', id:'** comment.id **', params:[product:'** jQuery.icescrum.product.pkey **', commentable:'** commentable.id **', type:'** type **'])}'
              data-comment-id="** comment.id **"
              data-commentable-id="** commentable.id **"
              data-commentable-type="** type **"
              data-ajax
              data-ajax-success='$.icescrum.comment.update'>
            <textarea name="comment.body"
                      class="form-control"
                      data-mkp="true"
                      placeholder="${message(code:'todo.is.ui.comment')}">** comment.body **</textarea>
            <div class="markItUpFooter">
                <small class="text-muted">${message(code:'todo.is.ui.comment.cancel')}</small>
                <button type="submit" class="btn btn-primary btn-sm pull-right">${message(code:'todo.is.ui.comment.update')}</button>
            </div>
        </form>
    </td>
</tr>
</script>