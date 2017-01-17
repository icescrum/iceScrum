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
              title="${message(code:'todo.is.ui.story.estimate.effort.by.comparison')}">
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
        <table class="table table-bordered">
            <tr>
                <th class="title">${g.message(code:'is.story.effort')}</th>
                <th ng-repeat="effort in efforts">
                    {{ effort }}
                    <span class="badge">{{ count[$index] }} <g:message code="is.ui.backlog.title.details.stories"/></span>
                </th>
            </tr>
            <tr>
                <td class="title"><strong><g:message code="is.ui.backlog.title.details.stories"/></strong></td>
                <td ng-repeat="stories in storiesByEffort">
                    <table class="table table-striped">
                        <tr ng-repeat="story in stories" title="{{ story.description | actorTag }}" ng-class="{ 'text-primary' : story.id == editableStory.id }">
                            <td>
                                <strong>{{ story.uid }}</strong>&nbsp;&nbsp;{{ story.name }}
                                <div class="text-right"> <span class="badge">{{ story.state | i18n:'StoryStates' }}</span></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</is:modal>
</script>

