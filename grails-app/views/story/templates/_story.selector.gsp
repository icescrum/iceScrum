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
          closeButton="${message(code: 'is.button.cancel')}"
          title="{{ message('todo.is.ui.story.selector.' + backlog.code + '.title') }}">
    <p class="help-block"
       ng-bind-html="message('todo.is.ui.story.selector.' + backlog.code + '.description')">
    </p>
    <div class="form-group">
        <div class="input-group">
            <input type="text" class="form-control" ng-model="liveFilterName" placeholder="${message(code:'todo.is.ui.search.action')}">
            <span class="input-group-addon"><i class="fa fa-search"></i></span>
        </div>
    </div>
    <div selectable="selectableOptions" class="loadable" ng-class="{'loading': !backlog.storiesLoaded}">
        <div class="loading-logo" ng-include="'loading.html'"></div>
        <div class="postits list-group has-selected sortable-disabled postits-disabled"
             ng-controller="storyCtrl"
             ng-model="backlog.stories"
             as-sortable
             is-disabled="true"
             ng-init="emptyBacklogTemplate = 'story.backlog.' + backlog.code + '.empty.html'"
             ng-include="'story.backlog.html'">
        </div>
    </div>
</is:modal>
</script>
