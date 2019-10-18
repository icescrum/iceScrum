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

<script type="text/ng-template" id="story.selector.html">
<is:modal form="submit(selectedIds)"
          submitButton="{{ message('todo.is.ui.story.selector.' + backlog.code + '.button') }}"
          submitButtonColor="{{ buttonColor }}"
          closeButton="${message(code: 'is.button.cancel')}"
          class="modal-no-padding story-selector"
          title="{{ message('todo.is.ui.story.selector.' + backlog.code + '.title') }}">
    <div class="row">
        <div class="modal-search text-center">
            <input type="text"
                   class="form-control search-input"
                   autofocus
                   ng-model="selectorOptions.filter.term"
                   ng-model-options="{debounce: 400}"
                   ng-change="filterStories()"
                   placeholder="{{ message('todo.is.ui.story.selector.' + backlog.code + '.search') }}">
        </div>
        <div class="sticky-notes list-group w-100"
             ng-controller="storyBacklogCtrl"
             ng-model="backlog.stories">
            <div ng-if="backlog.stories.length == 0"
                 class="empty-view">
                <div ng-include="'story.backlog.' + backlog.code + '.empty.html'"></div>
            </div>
            <table class="table table-bordered table-story-close sticky-notes-disabled" ng-if="backlog.stories.length > 0">
                <tr ng-repeat="story in backlogStories" class="sticky-note-container sticky-note-story sticky-note-no-state" ng-click="selectedIds[story.id] = !selectedIds[story.id]">
                    <td is-watch="story" class="pt-0 pb-0">
                        <div ng-include="'story.html'"></div>
                    </td>
                    <td class="align-middle">
                        <div class="text-center story-checkbox">
                            <input type="checkbox"
                                   ng-model="selectedIds[story.id]">
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</is:modal>
</script>