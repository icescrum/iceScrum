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
<div class="card-body feature-stories" ng-controller="featureStoriesCtrl">
    <div ng-repeat="storyEntry in storyEntries"
         class="mb-5">
        <h5 class="text-center mb-3"
            ng-class="::{ 'mt-2': !$first }"
            ng-bind-html="storyEntry.label">
        </h5>
        <div is-disabled="!isStorySortableByState(storyEntry.state)"
             as-sortable="storySortableOptions | merge: sortableScrollOptions()"
             ng-model="storyEntry.stories">
            <div class="feature-story font-size-sm " ng-repeat="story in storyEntry.stories" as-sortable-item>
                <div class="row align-items-baseline">
                    <div class="col-sm-8">
                        <a ng-href="{{ openStoryUrl(story.id) }}">
                            <span class="mr-1" ng-if="isStorySortableByState(storyEntry.state)" as-sortable-item-handle>{{:: story.uid }}</span>
                            <span class="mr-1" ng-if="!isStorySortableByState(storyEntry.state)">{{:: story.uid }}</span>
                            <span class="text-accent">{{ story.name }}</span>
                        </a>
                    </div>
                    <div class="col-sm-4 d-flex justify-content-between align-items-baseline" ng-controller="storyCtrl">
                        <span class="state-title state-title-small mr-2">
                            <span class="state-dot" ng-class="'story-state-dot-' + story.state"></span>
                            <span class="d-none d-xl-block text-nowrap">{{ (story.state | i18n: 'StoryStates') }}</span>
                        </span>
                        <div class="btn-menu" uib-dropdown>
                            <shortcut-menu ng-model="story" model-menus="menus" view-type="'list'" btn-sm="true" btn-secondary="true"></shortcut-menu>
                            <div uib-dropdown-toggle></div>
                            <div uib-dropdown-menu ng-init="itemType = 'story'" template-url="item.menu.html"></div>
                        </div>
                    </div>
                </div>
                <div ng-if="story.description">
                    <p class="description form-control-plaintext" ng-bind-html="story.description | lineReturns | actorTag: actors"></p>
                </div>
                <hr ng-if="!$last" class="w-50 mt-2"/>
            </div>
        </div>
    </div>
    <div ng-show="selected.stories !== undefined && !selected.stories.length"
         class="empty-content">
        <small>${message(code: 'todo.is.ui.story.empty')}</small>
    </div>
</div>
<div class="card-footer" ng-controller="featureStoryCtrl">
    <div ng-if="authorizedStory('create')" ng-include="'feature.storyForm.editor.html'"></div>
</div>
</script>