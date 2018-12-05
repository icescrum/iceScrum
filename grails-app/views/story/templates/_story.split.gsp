%{--
- Copyright (c) 2017 Kagilum.
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
<script type="text/ng-template" id="story.split.html">
<is:modal form="submit(stories)"
          name="formHolder.storySplitForm"
          validate="true"
          submitButton="${message(code: 'is.ui.backlog.menu.split')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'is.dialog.split.title')}">
    <p class="form-text">${message(code: 'is.dialog.split.description')}</p>
    <div class="form-group col-sm-12">
        <slider ng-model="splitCount"
                min="2"
                step="1"
                max="10"
                value="splitCount"
                on-stop-slide="onChangeSplitNumber()"></slider>
    </div>
    <table class="table table-striped">
        <tr ng-repeat="story in stories track by $index">
            <td>
                <div class="clearfix">
                    <div class="form-group col-sm-8">
                        <label>${message(code: 'is.story.name')}</label>
                        <input required
                               name="name{{ $index }}"
                               ng-maxlength="100"
                               ng-remote-validate="{{ getCheckStoryNameUrl(stories[$index]) }}"
                               ng-remote-validate-code="story.name.unique"
                               custom-validate="validateStoryName"
                               custom-validate-item="stories[$index]"
                               custom-validate-code="story.name.unique"
                               type="text"
                               ng-model="stories[$index].name"
                               class="form-control">
                    </div>
                    <div class="form-group col-sm-2" ng-show="authorizedStory('updateEstimate', stories[$index])">
                        <label>${message(code: 'is.story.effort')}</label>
                        <ui-select ng-if="!isEffortCustom()"
                                   class="form-control"
                                   name="effort{{ $index }}"
                                   search-enabled="true"
                                   ng-model="stories[$index].effort">
                            <ui-select-match placeholder="?">{{ $select.selected }}</ui-select-match>
                            <ui-select-choices repeat="i in effortSuite(isEffortNullable(stories[$index])) | filter: $select.search">
                                <span ng-bind-html="'' + i | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                        <input type="number"
                               ng-if="isEffortCustom()"
                               class="form-control"
                               name="effort{{ $index }}"
                               min="0"
                               ng-model="stories[$index].effort"/>
                    </div>
                    <div class="form-group col-sm-2">
                        <label>${message(code: 'is.story.value')}</label>
                        <ui-select class="form-control"
                                   name="value{{ $index }}"
                                   search-enabled="true"
                                   ng-model="stories[$index].value">
                            <ui-select-match>{{ $select.selected }}</ui-select-match>
                            <ui-select-choices repeat="i in integerSuite | filter: $select.search">
                                <span ng-bind-html="'' + i | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                    </div>
                    <div class="form-group col-sm-12">
                        <label for="description">
                            <span class="text-muted small pull-right"><i class="fa fa-question-circle"></i> ${message(code: 'is.actor.help.description')}</span>
                            <div>${message(code: 'is.backlogelement.description')}</div>
                        </label>
                        <textarea at="atOptions"
                                  name="description{{ $index }}"
                                  ng-maxlength="3000"
                                  type="text"
                                  ng-model="stories[$index].description"
                                  class="form-control"></textarea>
                    </div>
                </div>
            </td>
        </tr>
    </table>
</is:modal>
</script>