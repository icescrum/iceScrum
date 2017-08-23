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

<script type="text/ng-template" id="story.value.html">
<is:modal form="submit(editableStory)"
          submitButton="${message(code: 'default.button.update.label')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'todo.is.ui.story.estimate.value.by.comparison')}">
    <div>
        <label for="value">${message(code: 'is.story.value')}</label>
        <slider ng-model="editableStory.value" min="0" step="1" max="99" value="editableStory.value" on-stop-slide="updateTable()"></slider>
    </div>
    <h5><strong><g:message code="todo.is.ui.story.by.comparison"/></strong></h5>
    <div class="table-scrollable">
        <table class="table">
            <tr>
                <th class="title">${g.message(code: 'is.story.value')}</th>
                <th ng-repeat="value in values" ng-click="setValue(value)" class="clickable">
                    <span class="badge">{{ count[$index] }} <g:message code="is.ui.backlog.title.details.stories"/></span>
                    {{ value }}
                </th>
            </tr>
            <tr>
                <td class="title"><strong><g:message code="is.ui.backlog.title.details.stories"/></strong></td>
                <td ng-repeat="stories in storiesByValue">
                    <table class="table table-striped">
                        <tr ng-repeat="story in stories" title="{{ story.description | actorTag }}" ng-class="{ 'text-primary' : story.id == editableStory.id }">
                            <td>
                                <strong>{{ story.uid }}</strong>&nbsp;&nbsp;{{ story.name }}
                                <div class="text-right"><span class="badge">{{ story.state | i18n:'StoryStates' }}</span></div>
                            </td>
                        </tr>
                        <tr ng-if="count[$index] > 3">
                            <td class="text-center"><span class="small">{{ message('todo.is.ui.story.by.comparison.count', [(count[$index] - 3)]) }}</span></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</is:modal>
</script>
