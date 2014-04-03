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
<script type="text/icescrum-template" id="tpl-story-row">
<tr data-elemid="** story.id **"
    data-ui-popover
    data-ui-popover-placement="right"
    data-ui-popover-trigger="keep-hover"
    data-ui-popover-delay="500"
    data-ui-popover-html-content="#popover-story-row-** story.id ** > .content"
    data-ui-popover-html-title="#popover-story-row-** story.id ** > .title"
    class="row-story **# if($.icescrum.user.poOrSm && story.effort) { ** estimated **# } **">
    <td class="drag text-muted" style="border-left: 4px solid **# if(story.feature){ ** ** story.feature.color ** **# } else { ** none **# } **;padding-left: 2px;">
        <span class="glyphicon glyphicon-th"></span>
        <span class="glyphicon glyphicon-th"></span>
        <span class="glyphicon glyphicon-th"></span>
        <span class="glyphicon glyphicon-th"></span>
    </td>
    <td>** story.uid **</td>
    <td>** story.name ** **# if(story.effort > 1) { ** (** story.effort ** pts) **# } **</td>
    <td id="popover-story-row-** story.id **" class="hidden">
        <div class="title">
            ** story.name **
        </div>
        <div class="content">
            ** story.description **
        </div>
    </td>
</tr>
</script>