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
- Colin Bontemps (cbontemps@kagilum.com)
--}%

<script type="text/ng-template" id="timeBoxNotesTemplate.new.html">
<is:modal form="save(timeBoxNotesTemplate)"
          name="formHolder.timeBoxNotesTemplateForm"
          validate="true"
          submitButton="${message(code: 'default.button.create.label')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'todo.is.ui.timeBoxNotesTemplate.new')}">
    <div class="card-body">
        <div class="form-group">
            <label for="name">${message(code: 'todo.is.ui.timeBoxNotesTemplate.name')}</label>
            <input required
                   name="name"
                   ng-maxlength="255"
                   ng-model="timeBoxNotesTemplate.name"
                   type="text"
                   class="form-control"/>
        </div>
        <div class="form-group">
            <label for="header">${message(code: 'todo.is.ui.timeBoxNotesTemplate.header')}</label>
            <textarea name="header"
                      ng-maxlength="5000"
                      rows="2"
                      ng-model="timeBoxNotesTemplate.header"
                      class="form-control fixedRow"></textarea>
        </div>
        <hr/>
        <label for="header">${message(code: 'todo.is.ui.timeBoxNotesTemplate.sections')}</label>
        <div as-sortable="sectionSortOptions" ng-model="timeBoxNotesTemplate.configs">
            <div class="card"
                 ng-repeat="config in timeBoxNotesTemplate.configs"
                 is-open="collapseSectionStatus[$index]"
                 as-sortable-item>
                <div class="card-header" as-sortable-item-handle ng-class="{'open': !collapseSectionStatus[$index]}">
                    <div as-sortable-item-handle
                         class="text-ellipsis"
                         style="display: inline-block; width: 200px">
                        ${message(code: 'todo.is.ui.timeBoxNotesTemplate.section')} {{($index+1) + (config.header ? " - "+config.header : "")}}
                    </div>
                    <button type="button"
                            class="btn btn-secondary btn-sm pull-right"
                            name="expand"
                            ng-click="expandSection($index)">
                        <i class="fa fa-pencil"></i>
                    </button>
                </div>
                <div class="card-body" uib-collapse="collapseSectionStatus[$index]">
                    <div class="form-group">
                        <label for="configs-{($index}}-header">${message(code: 'todo.is.ui.timeBoxNotesTemplate.section.header')}</label>
                        <textarea name="configs-{($index}}-header"
                                  ng-maxlength="5000"
                                  rows="2"
                                  ng-model="config.header"
                                  class="form-control fixedRow">
                        </textarea>
                    </div>
                    <div class="clearfix no-padding">
                        <div class="form-2-tiers">
                            <label for="configs-{($index}}-storyTags">${message(code: 'todo.is.ui.timeBoxNotesTemplate.storyTags')}</label>
                            <ui-select ng-click="retrieveTags()"
                                       ng-disabled="_.isEmpty(tags)"
                                       class="form-control"
                                       multiple
                                       name="configs-{($index}}-storyTags"
                                       ng-model="config.storyTags">
                                <ui-select-match
                                        placeholder="${message(code: 'todo.is.ui.timeBoxNotesTemplate.chooseTags')}">{{ $item }}</ui-select-match>
                                <ui-select-choices repeat="tag in tags | filter: $select.search">
                                    <span ng-bind-html="tag | highlight: $select.search"></span>
                                </ui-select-choices>
                            </ui-select>
                        </div>
                        <div class="form-1-tier">
                            <label for="configs-{($index}}-storyType">${message(code: 'todo.is.ui.timeBoxNotesTemplate.storyType')}</label>
                            <ui-select class="form-control"
                                       name="configs-{($index}}-storyType"
                                       ng-model="config.storyType">
                                <ui-select-match allow-clear="true"
                                                 placeholder="${message(code: 'todo.is.ui.timeBoxNotesTemplate.storyTypeAll')}"><i
                                        class="fa fa-{{ $select.selected | storyTypeIcon }}"></i> {{ $select.selected | i18n:'StoryTypes' }}
                                </ui-select-match>
                                <ui-select-choices repeat="storyType in storyTypes"><i
                                        class="fa fa-{{ ::storyType | storyTypeIcon }}"></i> {{ ::storyType | i18n:'StoryTypes' }}
                                </ui-select-choices>
                            </ui-select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="configs-{($index}}-lineTemplate">${message(code: 'todo.is.ui.timeBoxNotesTemplate.lineTemplate')}</label>
                        <textarea required
                                  name="configs-{{$index}}-lineTemplate"
                                  ng-maxlength="5000"
                                  rows="2"
                                  ng-model="config.lineTemplate"
                                  class="form-control fixedRow"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="configs-{($index}}-footer">${message(code: 'todo.is.ui.timeBoxNotesTemplate.section.footer')}</label>
                        <textarea name="configs-{($index}}-footer"
                                  ng-maxlength="5000"
                                  rows="2"
                                  ng-model="config.footer"
                                  class="form-control fixedRow"></textarea>
                    </div>
                    <button class="btn btn-danger btn-sm pull-right"
                            type="button"
                            name="delete"
                            ng-click="confirmDelete({callback: deleteSection, args: [timeBoxNotesTemplate, config]});">
                        ${message(code: 'default.button.delete.label')}
                    </button>
                </div>
            </div>
            <button class="btn btn-secondary"
                    style="width: 100%"
                    type="button"
                    name="delete"
                    ng-click="addSection(timeBoxNotesTemplate)">${message(code: 'todo.is.ui.timeBoxNotesTemplate.section.new')}</i>
            </button>
        </div>
        <hr/>
        <div class="form-group">
            <label for="footer">${message(code: 'todo.is.ui.timeBoxNotesTemplate.footer')}</label>
            <textarea name="footer"
                      ng-maxlength="5000"
                      rows="2"
                      ng-model="timeBoxNotesTemplate.footer"
                      class="form-control fixedRow">
            </textarea>
        </div>
    </div>
</is:modal>
</script>

