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
<script type="text-icescrum-template" id="tpl-story-tasks">
**# if (size(story.tasks) > 0) {
_.each(story.tasks, function(task) { **
<tr>
    <td class="avatar">
        <img tpl-src="** $.icescrum.user.formatters.avatar(task.creator) **"
             alt="** $.icescrum.user.formatters.fullName(task.creator) **"
             width="25px">
    </td>
    <td>
        <div class="content">
            <span class="clearfix text-muted"><a href="#">** task.name **</a></span>
            ** task.description **
            **# if($.icescrum.user.poOrSm() || task.creator.id == $.icescrum.creator.id) { ** <a href="#"
                                                                                                 title="${message(code:'todo.is.ui.task.delete')}"
                                                                                                 class="on-hover delete"
                                                                                                 data-toggle="tooltip"
                                                                                                 data-placement="left"><i class="fa fa-times text-danger"></i></a>
            **# } **
            <small class="clearfix text-muted">
                <time class='timeago' datetime='** task.dateCreated **'>
                    ** task.dateCreated **
                </time> <i class="fa fa-clock-o"></i>
            </small>
        </div>
    </td>
</tr>
**# }); **
**# } else if(!$.icescrum.user.inProduct()) { **
<tr>
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.task.empty')}</small>
    </td>
</tr>
**# } **
</script>

<script type="text/icescrum-template" id="tpl-task-new">
    <table class="table" id="table-task-new">
        <tbody>
        <tr>
            <td>
                <button class="btn btn-sm btn-primary pull-right"
                        type="button"
                        title="${message(code:'todo.is.ui.task.new')}"
                        data-container="body"
                        data-toggle="tooltip"
                        data-ui-toggle="task-new">
                    <span class="glyphicon glyphicon-plus"></span>
                </button>
            </td>
        </tr>
        <tr id="task-new" class="hidden">
            <td>
                <form method="POST"
                      action="${createLink(controller: 'task', action: 'save', params: [product: '** jQuery.icescrum.product.pkey **', 'task.parentStory.id': '** story.id **'])}"
                      data-ajax="true">
                    <div class="clearfix no-padding">
                        <div class="form-group col-sm-9">
                            <label>${message(code:'is.backlogelement.name')}</label>
                            <input required="required"
                                   name="task.name"
                                   type="text"
                                   class="form-control">
                        </div>
                        <div class="form-group col-sm-3">
                            <label>${message(code:'is.task.estimation')}</label>
                            <input name="task.estimation"
                                   type="number"
                                   step="any"
                                   pattern="[0-9]+([\.|,][0-9]+)?"
                                   class="form-control">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>${message(code:'is.backlogelement.description')}</label>
                        <textarea name="task.description" style="min-height:50px;" class="form-control"></textarea>
                    </div>
                    <button class="btn btn-primary pull-right"
                            data-is-shortcut
                            data-is-shortcut-key="RETURN"
                            title="${message(code:'todo.is.ui.save')} (RETURN)"
                            data-toggle="tooltip"
                            data-container="body"
                            type="submit">
                        ${message(code:'todo.is.ui.save')}
                    </button>
                </form>
            </td>
        </tr>
        </tbody>
    </table>
</script>