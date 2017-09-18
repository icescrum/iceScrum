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

<script type="text/ng-template" id="timeBoxNotesTemplate.html">
<is:modal form="update(editableTimeBoxNotesTemplate)"
          name='formHolder.timeBoxNoteTemplateForm'
          submitButton="${message(code: 'default.button.update.label')}"
          closeButton="${message(code: 'is.button.cancel')}"
          title="${message(code: 'todo.is.ui.timeBoxNoteTemplate.title')}">
    <div class="panel-body">
        <div class="form-group">
            <label for="name">${message(code: 'todo.is.ui.timeBoxNoteTemplate.name')}</label>
            <input required
                   name="name"
                   ng-maxlength="100"
                   ng-model="editableTimeBoxNotesTemplate.name"
                   type="text"
                   class="form-control"/>
        </div>
        <div class="form-group">
            <label for="header">${message(code: 'todo.is.ui.timeBoxNoteTemplate.header')}</label>
            <textarea
                    name="header"
                    ng-maxlength="5000"
                    rows="2"
                    ng-model="editableTimeBoxNotesTemplate.header"
                    class="form-control fixedRow"></textarea>
        </div>
        <hr>
        <div>
            <h5>${message(code: 'todo.is.ui.timeBoxNoteTemplate.section', args: ["1"])}</h5>
            <div class="form-group">
                <label for="configs-0-header">${message(code: 'todo.is.ui.timeBoxNoteTemplate.section.header')}</label>
                <textarea name="configs[0].header"
                          ng-maxlength="5000"
                          rows="2"
                          ng-model="editableTimeBoxNotesTemplate.configs[0].header"
                          class="form-control fixedRow"></textarea>
            </div>
            <div class="clearfix no-padding">
                <div class="form-2-tiers">
                    <label for="configs-0-storyTags">${message(code: 'todo.is.ui.timeBoxNoteTemplate.storyTags')}</label>
                    <ui-select ng-click="retrieveTags()"
                               ng-disabled="_.isEmpty(tags)"
                               class="form-control"
                               multiple
                               name="configs-0-storyTags"
                               ng-model="editableTimeBoxNotesTemplate.configs[0].storyTags">
                        <ui-select-match
                                placeholder="${message(code: 'todo.is.ui.timeBoxNoteTemplate.chooseTags')}">{{ $item }}</ui-select-match>
                        <ui-select-choices repeat="tag in tags | filter: $select.search">
                            <span ng-bind-html="tag | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>
                <div class="form-1-tier">
                    <label for="configs-0-storyType">${message(code: 'todo.is.ui.timeBoxNoteTemplate.storyType')}</label>
                    <ui-select class="form-control"
                               name="configs-0-storyType"
                               ng-model="editableTimeBoxNotesTemplate.configs[0].storyType">
                        <ui-select-match allow-clear="true"
                                         placeholder="${message(code: 'todo.is.ui.timeBoxNoteTemplate.storyTypeAll')}"><i
                                class="fa fa-{{ $select.selected | storyTypeIcon }}"></i> {{ $select.selected | i18n:'StoryTypes' }}
                        </ui-select-match>
                        <ui-select-choices repeat="storyType in storyTypes"><i
                                class="fa fa-{{ ::storyType | storyTypeIcon }}"></i> {{ ::storyType | i18n:'StoryTypes' }}
                        </ui-select-choices>
                    </ui-select>
                </div>
            </div>
            <div class="form-group">
                <label for="configs-0-lineTemplate">${message(code: 'todo.is.ui.timeBoxNoteTemplate.lineTemplate')}</label>
                <textarea required
                          name="configs-0-lineTemplate"
                          ng-maxlength="5000"
                          rows="2"
                          ng-model="editableTimeBoxNotesTemplate.configs[0].lineTemplate"
                          class="form-control fixedRow"></textarea>
            </div>
            <div class="form-group">
                <label for="configs-0-footer">${message(code: 'todo.is.ui.timeBoxNoteTemplate.section.footer')}</label>
                <textarea name="configs-0-footer"
                          ng-maxlength="5000"
                          rows="2"
                          ng-model="editableTimeBoxNotesTemplate.configs[0].footer"
                          class="form-control fixedRow"></textarea>
            </div>
        </div>
        <hr>
        <div>
            <h5>${message(code: 'todo.is.ui.timeBoxNoteTemplate.section', args: ["2"])}</h5>
            <div class="form-group">
                <label for="configs-1-header">${message(code: 'todo.is.ui.timeBoxNoteTemplate.section.header')}</label>
                <textarea name="configs-1-header"
                          ng-maxlength="5000"
                          rows="2"
                          ng-model="editableTimeBoxNotesTemplate.configs[1].header"
                          class="form-control fixedRow"></textarea>
            </div>
            <div class="clearfix no-padding">
                <div class="form-2-tiers">
                    <label for="configs-1-storyTags">${message(code: 'todo.is.ui.timeBoxNoteTemplate.storyTags')}</label>
                    <ui-select ng-click="retrieveTags()"
                               ng-disabled="_.isEmpty(tags)"
                               class="form-control"
                               multiple
                               name="configs-1-storyTags"
                               ng-model="editableTimeBoxNotesTemplate.configs[1].storyTags">
                        <ui-select-match
                                placeholder="${message(code: 'todo.is.ui.timeBoxNoteTemplate.chooseTags')}">{{ $item }}</ui-select-match>
                        <ui-select-choices repeat="tag in tags | filter: $select.search">
                            <span ng-bind-html="tag | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>

                <div class="form-1-tier">
                    <label for="configs-1-storyType">${message(code: 'todo.is.ui.timeBoxNoteTemplate.storyType')}</label>
                    <ui-select class="form-control"
                               name="configs-1-storyType"
                               ng-model="editableTimeBoxNotesTemplate.configs[1].storyType">
                        <ui-select-match allow-clear="true"
                                         placeholder="${message(code: 'todo.is.ui.timeBoxNoteTemplate.storyTypeAll')}"><i
                                class="fa fa-{{ $select.selected | storyTypeIcon }}"></i> {{ $select.selected | i18n:'StoryTypes' }}
                        </ui-select-match>
                        <ui-select-choices repeat="storyType in storyTypes"><i
                                class="fa fa-{{ ::storyType | storyTypeIcon }}"></i> {{ ::storyType | i18n:'StoryTypes' }}
                        </ui-select-choices>
                    </ui-select>
                </div>
            </div>
            <div class="form-group">
                <label for="configs-1-lineTemplate">${message(code: 'todo.is.ui.timeBoxNoteTemplate.lineTemplate')}</label>
                <textarea required
                          name="configs-1-lineTemplate"
                          ng-maxlength="5000"
                          rows="2"
                          ng-model="editableTimeBoxNotesTemplate.configs[1].lineTemplate"
                          class="form-control fixedRow"></textarea>
            </div>
            <div class="form-group">
                <label for="configs-1-footer">${message(code: 'todo.is.ui.timeBoxNoteTemplate.section.footer')}</label>
                <textarea name="configs-1-footer"
                          ng-maxlength="5000"
                          rows="2"
                          ng-model="editableTimeBoxNotesTemplate.configs[1].footer"
                          class="form-control fixedRow"></textarea>
            </div>
        </div>
        <hr>
        <div class="form-group">
            <label for="footer">${message(code: 'todo.is.ui.timeBoxNoteTemplate.footer')}</label>
            <textarea name="footer"
                      ng-maxlength="5000"
                      rows="2"
                      ng-model="editableTimeBoxNotesTemplate.footer"
                      class="form-control fixedRow"></textarea>
        </div>
    </div>
</is:modal>
</script>

