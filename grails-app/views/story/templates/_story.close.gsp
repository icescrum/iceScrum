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
<is:modal button="[[action: 'closeSprint()', text: message(code: 'todo.is.ui.story.selector.close.button'), color: 'danger']]"
          closeButton="${message(code: 'is.button.cancel')}"
          title="{{ message('todo.is.ui.story.selector.close.title') }}">
    <p class="form-text"
       ng-bind-html="message('todo.is.ui.story.selector.close.description', [(storyStatesByName.DONE | i18n: 'StoryStates')])">
    </p>
    <div class="loadable" ng-class="{'loading': !backlog.storiesLoaded}">
        <div class="loading-logo" ng-include="'loading.html'"></div>
        <div class="list-group"
             ng-controller="storyBacklogCtrl"
             ng-model="backlog.stories">
            <div ng-if="backlog.stories.length == 0"
                 class="empty-view">
                <div ng-include="'story.backlog.close.empty.html'"></div>
            </div>
            <table class="table table-bordered table-striped table-story-close postits-disabled" ng-if="backlog.stories.length > 0">
                <tr>
                    <th class="text-center">${message(code: 'is.story')}</th>
                    <th class="text-center">{{:: storyStatesByName.DONE | i18n: 'StoryStates' }}</th>
                </tr>
                <tr ng-repeat="story in backlogStories" class="postit-container postit-no-state">
                    <td is-watch="story">
                        <div ng-include="'story.html'"></div>
                    </td>
                    <td>
                        <div class="text-center story-checkbox">
                            <input type="checkbox"
                                   ng-model="newDone[story.id]">
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</is:modal>
</script>