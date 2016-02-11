%{--
- Copyright (c) 2015 Kagilum.
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

<script type="text/ng-template" id="story.backlog.html">
<div ng-class="{ 'is-selected': isSelected(story) }"
     selectable-id="{{ ::story.id }}"
     on-repeat-completed="backlog.storiesRendered = true"
     ng-repeat="story in backlog.stories | search"
     as-sortable-item
     class="postit-container">
    <div ng-include="'story.html'" ng-init="sortableStory = authorizedStory('rank', story)"></div>
</div>
</script>
