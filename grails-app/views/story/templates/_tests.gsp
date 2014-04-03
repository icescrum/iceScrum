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
<script type="text-icescrum-template" id="tpl-story-tests">
**# if (size(story.acceptanceTests) > 0) {
_.each(story.acceptanceTests, function(acceptanceTest) { **
<tr>
    <td class="avatar">
        <img tpl-src="** $.icescrum.user.formatters.avatar(acceptanceTest.creator) **"
             alt="** $.icescrum.user.formatters.fullName(acceptanceTest.creator) **"
             width="25px">
    </td>
    <td>
        <div class="content">
            <span class="clearfix text-muted"><a href="#">** acceptanceTest.name **</a></span>
            ** acceptanceTest.description **
            **# if($.icescrum.user.poOrSm()) { ** <a href="#"
                                                     title="${message(code:'todo.is.ui.acceptanceTest.delete')}"
                                                     class="on-hover delete"
                                                     data-toggle="tooltip"
                                                     data-placement="left"><i class="fa fa-times text-danger"></i></a>
            **# } **
            <small class="clearfix text-muted">
                <time class='timeago' datetime='** acceptanceTest.dateCreated **'>
                    ** acceptanceTest.dateCreated **
                </time> <i class="fa fa-clock-o"></i>
            </small>
        </div>
    </td>
</tr>
**# }); **
**# } else if(!$.icescrum.user.inProduct()) { **
<tr>
    <td class="empty-content">
        <small>${message(code:'todo.is.ui.acceptanceTest.empty')}</small>
    </td>
</tr>
**# } **
</script>