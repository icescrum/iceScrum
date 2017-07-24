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
          title="{{ message('todo.is.ui.story.selector.' + backlog.code + '.title') }}">
    <p class="help-block"
       ng-bind-html="message('todo.is.ui.story.selector.' + backlog.code + '.description')">
    </p>
    <div class="form-group" ng-if="selectorOptions.inputFilterEnabled">
        <div class="input-group">
            <input type="text"
                   class="form-control"
                   autofocus
                   ng-model="selectorOptions.filter.term"
                   ng-model-options="{debounce: 400}"
                   ng-change="filterStories()"
                   placeholder="${message(code:'todo.is.ui.story.selector.filter.action')}">
            <span class="input-group-btn">
                <button type="button"
                        class="btn btn-default"
                        ng-click="selectorOptions.filter.term = ''; filterStories()">
                    <i class="fa" ng-class="selectorOptions.filter.term ? 'fa-times' : 'fa-filter'"></i>
                </button>
            </span>
        </div>
    </div>
    <div selectable="selectableOptions" class="loadable" ng-class="{'loading': !backlog.storiesLoaded}">
        <div class="loading-logo" ng-include="'loading.html'"></div>
        <div class="postits list-group has-selected postits-disabled"
             ng-controller="storyBacklogCtrl"
             ng-model="backlog.stories"
             as-sortable
             is-disabled="true"
             ng-init="emptyBacklogTemplate = 'story.backlog.' + backlog.code + '.empty.html'"
             ng-include="'story.backlog.html'">
        </div>
    </div>
</is:modal>
</script>