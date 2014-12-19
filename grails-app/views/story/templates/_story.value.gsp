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

<script type="text/ng-template" id="story.value.html">
<is:modal form="submit(editableStory)"
          submitButton="${message(code:'todo.is.ui.update')}"
          closeButton="${message(code:'is.button.cancel')}"
          title="${message(code:'todo.is.ui.story.value.edit.title')}">
    <div>
        <label for="value">${message(code:'is.story.value')}</label>
        <select class="form-control"
                name="value"
                ng-model="editableStory.value"
                ng-options="i for i in integerSuite"
                ng-change="updateTable()"
                ui-select2>
        </select>
    </div>
    <div class="table-scrollable">
        <table class="table">
            <tr>
                <th ng-repeat="value in values">
                    {{ value }} ({{ count[$index] }})
                </th>
            </tr>
            <tr ng-repeat="storyRow in storyRows">
                <td ng-repeat="story in storyRow" title="{{ story | storyDescription }}" ng-class="{ 'text-primary' : story.id == editableStory.id }">
                    <div ng-if="story.id != undefined">
                        <button class="btn btn-xs btn-default" disabled="disabled">{{ story.uid }}</button> {{ story.name }}
                        <div>{{ story.state | i18n:'storyState' }}</div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</is:modal>
</script>
