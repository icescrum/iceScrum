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

<script type="text/ng-template" id="nested.stories.html">
<div class="panel-body">
    <div ng-repeat="story in selected.stories">
        <button class="btn btn-xs btn-default"
                disabled="disabled">{{ story.uid }}</button>
        <a href="{{ story.uid | permalink: 'story' }}">{{ story.name }}</a>
        <div class="pretty-printed"
             ng-bind-html="story | storyDescriptionHtml | sanitize">
        </div>
        <hr ng-if="!$last"/>
    </div>
    <div ng-show="selected.stories !== undefined && selected.stories.length == 0">
        <div class="empty-content">
            <small>${message(code:'todo.is.ui.story.empty')}</small>
        </div>
    </div>
</div>
</script>