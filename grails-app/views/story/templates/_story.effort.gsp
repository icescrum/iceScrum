%{--
- Copyright (c) 2015 Kagilum.
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
          submitButton="${message(code:'default.button.update.label')}"
          closeButton="${message(code:'is.button.cancel')}"
          title="${message(code:'is.story.effort')}">
    <div>
        <label for="effort">${message(code:'is.story.effort')}</label>
        <ui-select ng-if="!isEffortCustom()"
                   class="form-control"
                   name="effort"
                   search-enabled="true"
                   on-select="updateTable()"
                   ng-model="editableStory.effort">
            <ui-select-match>{{ $select.selected }}</ui-select-match>
            <ui-select-choices repeat="i in effortSuite(isEffortNullable(editableStory)) | filter: $select.search">
                <span ng-bind-html="'' + i | highlight: $select.search"></span>
            </ui-select-choices>
        </ui-select>
        <input type="number"
               ng-if="isEffortCustom()"
               class="form-control"
               ng-change="updateTable()"
               name="effort"
               ng-model="editableStory.effort"/>
    </div>
    <div class="table-scrollable">
        <table class="table">
            <tr>
                <th ng-repeat="effort in efforts">
                    {{ effort }} ({{ count[$index] }})
                </th>
            </tr>
            <tr ng-repeat="storyRow in storyRows">
                <td ng-repeat="story in storyRow" title="{{ story | storyDescription }}" ng-class="{ 'text-primary' : story.id == editableStory.id }">
                    <div ng-if="story.id != undefined">
                        <button class="btn btn-xs btn-default" disabled="disabled">{{ story.uid }}</button> {{ story.name }}
                        <div>{{ story.state | i18n:'StoryStates' }}</div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</is:modal>
</script>

