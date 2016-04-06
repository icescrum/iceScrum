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

<script type="text/ng-template" id="sprint.plan.html">
<is:modal form="submit(selectedIds)"
          submitButton="${message(code: 'is.dialog.selector.button')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.dialog.selector.title')}">
    <p class="help-block">
        ${message(code: 'is.dialog.selector.description')}
    </p>
    <div selectable="selectableOptions">
        <div class="postits list-group has-selected"
             ng-controller="storyCtrl"
             ng-model="backlog.stories"
             as-sortable=""
             is-disabled="true"
             ng-include="'story.backlog.html'">
        </div>
    </div>
</is:modal>
</script>
