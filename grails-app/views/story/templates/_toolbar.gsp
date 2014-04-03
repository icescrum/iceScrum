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
<script type="text/icescrum-template" id="tpl-story-buttons">
<a href="${g.createLink(controller:'story', action:'like', id:'**.story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
   class="btn btn-default"
   role="button"
   tabindex="0"
   data-status-title="likers"
   data-status-suffix="up"
   data-status-toggle="fa-thumbs">
    <i class="fa fa-thumbs-o-up"></i>
    <span class="badge"></span>
</a>
<button name="activities" class="btn btn-default"
        title="${message(code:'todo.is.story.lastActivity')}"
        data-toggle="tooltip"
        data-container="body"
        data-scrollto
        data-scrollto-id="activities"
        data-scrollto-tabs="true"
        data-scrollto-container="#right">
    <span class="fa fa-clock-o"></span>
</button>
<button class="btn btn-default"
        title="** size(story.attachments) ** ${message(code:'todo.is.backlogelement.attachments')}"
        data-toggle="tooltip"
        data-container="body"
        data-scrollto
        data-scrollto-id="attachments"
        data-scrollto-tabs="true"
        data-scrollto-container="#right">
    <span class="fa fa-paperclip"></span>
    <span class="badge" style="** noSize(story.attachments, 'display:none') **">** size(story.attachments) **</span>
</button>
<button name="comments" class="btn btn-default"
        title="** size(story.comments()) ** ${message(code:'todo.is.story.comments')}"
        data-toggle="tooltip"
        data-container="body"
        data-scrollto
        data-scrollto-id="comments"
        data-scrollto-tabs="true"
        data-scrollto-container="#right">
    <span class="fa fa-comment** noSize(story.comments(),'-o') **"></span>
    <span class="badge" style="** noSize(story.comments(), 'display:none') **">** size(story.comments()) **</span>
</button>
<button name="tasks" class="btn btn-default"
        title="** size(story.tasks) ** ${message(code:'todo.is.story.tasks')}"
        data-toggle="tooltip"
        data-container="body"
        data-scrollto
        data-scrollTo-id="tasks"
        data-scrollto-tabs="true"
        data-scrollto-container="#right">
    <span class="fa fa-tasks"></span>
    <span class="badge" style="** noSize(story.tasks, 'display:none') **">** size(story.tasks) **</span>
</button>
<button name="tests" class="btn btn-default"
        title="** size(story.tests) ** ${message(code:'todo.is.acceptanceTests')}"
        data-toggle="tooltip"
        data-container="body"
        data-placement="left"
        data-scrollto
        data-scrollto-id="tests"
        data-scrollto-tabs="true"
        data-scrollto-container="#right">
    <span class="fa fa-check-square** noSize(story.tests,'-o') **"></span>
    <span class="badge" style="** noSize(story.tests, 'display:none') **">** size(story.tests) **</span>
</button>
</script>