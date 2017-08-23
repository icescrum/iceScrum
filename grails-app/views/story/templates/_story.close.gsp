%{--
- Copyright (c) 2016 Kagilum.
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

<script type="text/ng-template" id="story.close.html">
<is:modal form="closeSprint()"
          submitButton="{{ message('todo.is.ui.story.selector.close.button') }}"
          submitButtonColor="danger"
          closeButton="${message(code: 'is.button.cancel')}"
          title="{{ message('todo.is.ui.story.selector.close.title') }}">
    <p class="help-block"
       ng-bind-html="message('todo.is.ui.story.selector.close.description')">
    </p>
    <div class="loadable" ng-class="{'loading': !backlog.storiesLoaded}">
        <div class="loading-logo" ng-include="'loading.html'"></div>
        <div ng-if="backlog.stories.length != 0">
            <div class="text-center pull-right" style="width: 59px">${message(code: 'is.story.state.done')}</div>
            <div class="text-center">${message(code: 'is.story')}</div>
        </div>
        <div class="postits list-group postits-disabled"
             ng-controller="storyBacklogCtrl"
             ng-model="backlog.stories"
             as-sortable
             is-disabled="true">
            <div ng-if="backlog.stories.length == 0"
                 class="empty-view">
                <div ng-include="'story.backlog.close.empty.html'"></div>
            </div>
            <div ng-repeat="story in backlogStories"
                 as-sortable-item
                 class="postit-container postit-no-state">
                <div class="pull-right text-center story-checkbox">
                    <input type="checkbox"
                           ng-model="newDone[story.id]">
                </div>
                <div ng-include="'story.html'"></div>
            </div>
        </div>
    </div>
</is:modal>
</script>