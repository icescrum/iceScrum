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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<script type="text/ng-template" id="story.menu.html">
<li ng-if="authorizedStory('accept', story)">
    <a href ng-click="acceptToBacklog(story)">
        ${message(code: 'is.ui.backlog.menu.acceptAsStory')}
    </a>
</li>
<li ng-if="authorizedStory('accept', story)">
    <a href ng-click="acceptAs(story, 'Feature')">
        ${message(code: 'is.ui.backlog.menu.acceptAsFeature')}
    </a>
</li>
<li ng-if="authorizedStory('accept', story)">
    <a href ng-click="acceptAs(story, 'Task')">
        ${message(code: 'is.ui.backlog.menu.acceptAsUrgentTask')}
    </a>
</li>
<li ng-if="authorizedStory('returnToSandbox', story)">
    <a href ng-click="returnToSandbox(story)">
        ${message(code: 'is.ui.backlog.menu.returnToSandbox')}
    </a>
</li>
<li ng-if="authorizedStory('unPlan', story)">
    <a href ng-click="unPlan(story)">
        ${message(code: 'is.ui.releasePlan.menu.story.dissociate')}
    </a>
</li>
<li ng-if="authorizedStory('shiftToNext', story)">
    <a href ng-click="shiftToNext(story)">
        ${message(code: 'is.ui.sprintPlan.menu.postit.shiftToNext')}
    </a>
</li>
<li ng-if="authorizedStory('done', story)">
    <a href ng-click="done(story)">
        ${message(code: 'is.ui.releasePlan.menu.story.done')}
    </a>
</li>
<li ng-if="authorizedStory('unDone', story)">
    <a href ng-click="unDone(story)">
        ${message(code: 'is.ui.releasePlan.menu.story.undone')}
    </a>
</li>
<li ng-if="authorizedStory('copy')">
    <a href ng-click="copy(story)">
        ${message(code: 'is.ui.releasePlan.menu.story.clone')}
    </a>
</li>
<li>
    <a href ng-click="showCopyModal('${message(code:'is.permalink')}', (story.uid | permalink: 'story'))">
        ${message(code: 'todo.is.ui.copy.permalink.to.clipboard')}
    </a>
</li>
<li ng-if="authorizedStory('createTemplate')">
    <a href ng-click="showNewTemplateModal(story)">
        ${message(code: 'todo.is.ui.story.template.new')}
    </a>
</li>
<li ng-if="authorizedStory('delete', story)">
    <a href ng-click="delete(story)">
        ${message(code: 'is.ui.backlog.menu.delete')}
    </a>
</li>
</script>
