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

<script type="text/ng-template" id="story.effort.html">
<is:modal form="submit(editableStory)"
          submitButton="${message(code:'todo.is.ui.update')}"
          closeButton="${message(code:'is.button.cancel')}"
          title="${message(code:'todo.is.ui.story.effort.edit.title')}">
    <div ng-switch="isEffortCustom()">
        <label for="effort">${message(code:'is.story.effort')}</label>
        <select ng-switch-default
                class="form-control"
                name="effort"
                ng-model="editableStory.effort"
                ng-options="i for i in effortSuite()"
                ui-select2>
            <option ng-show="isEffortNullable(editableStory)" value="">?</option>
        </select>
        <input type="number"
               ng-switch-when="true"
               class="form-control"
               name="effort"
               ng-model="editableStory.effort"/>
    </div></is:modal>
</script>

