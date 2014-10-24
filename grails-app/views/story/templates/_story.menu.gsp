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
    <a href ng-click="accept(story)">
        <g:message code='is.ui.sandbox.menu.acceptAsStory'/>
    </a>
</li>
<li ng-if="authorizedStory('accept', story)">
    <a href ng-click="acceptAs(story, 'Feature')">
        <g:message code='is.ui.sandbox.menu.acceptAsFeature'/>
    </a>
</li>
<li ng-if="authorizedStory('accept', story)">
    <a href ng-click="acceptAs(story, 'Task')">
        <g:message code='is.ui.sandbox.menu.acceptAsUrgentTask'/>
    </a>
</li>
<li>
    <a href ng-if="authorizedStory('create')" ng-click="copy(story)">
        <g:message code='is.ui.releasePlan.menu.story.clone'/>
    </a>
</li>
<li>
    <a href ng-if="authorizedStory('delete', story)" ng-click="delete(story)">
        <g:message code='is.ui.sandbox.menu.delete'/>
    </a>
</li>
<li>
    <a href ng-if="authorizedStory('createTemplate')" ng-click="showNewTemplateModal(story)">
        ${message(code: 'todo.is.ui.story.template.new')}
    </a>
</li>
<li>
    <a href="{{ story.uid | permalink }}" ng-click="showCopyModal('${message(code:'is.permalink')}', $event.target.href); $event.preventDefault();">
        ${message(code: 'todo.is.ui.copy.permalink.to.clipboard')}
    </a>
</li>
</script>
