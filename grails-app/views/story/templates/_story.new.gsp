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
<script type="text/ng-template" id="story.new.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            <i class="fa fa-sticky-note" style="color: {{ storyPreview.feature ? storyPreview.feature.color : '#f9f157' }}"></i>
            ${message(code: 'todo.is.ui.story.new')}
            <a class="pull-right visible-on-hover btn btn-default"
                    href="#/{{ ::viewName }}/sandbox"
                    uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                <i class="fa fa-times"></i>
            </a>
        </h3>
    </div>
    <div class="panel-body">
        <div class="help-block">${message(code:'is.ui.sandbox.help')}</div>
        <div class="postits standalone">
            <div ellipsis class="postit-container">
                <div style="{{ (storyPreview.feature ? storyPreview.feature.color : '#f9f157') | createGradientBackground }}"
                     class="postit {{ (storyPreview.feature ? storyPreview.feature.color : '#f9f157') | contrastColor }}">
                    <div class="head">
                        <div class="head-left">
                            <span class="id">42</span>
                        </div>
                    </div>
                    <div class="content">
                        <h3 class="title ellipsis-el"
                            ng-model="story.name"
                            ng-bind-html="story.name | sanitize"></h3>
                        <div class="description-template ellipsis-el"
                             ng-model="storyPreview.description"
                             ng-bind-html="storyPreview.description | sanitize"></div>
                    </div>
                    <div class="footer">
                        <div class="tags">
                            <a ng-repeat="tag in storyPreview.tags" ng-click="setTagContext(tag)" href><span class="tag">{{ tag }}</span></a>
                        </div>
                        <div class="actions">
                            <span class="action">
                                <a>
                                    <i class="fa fa-cog"></i>
                                </a>
                            </span>
                            <span class="action">
                                <a uib-tooltip="${message(code:'todo.is.ui.backlogelement.attachments')}">
                                    <i class="fa fa-paperclip"></i>
                                </a>
                            </span>
                            <span class="action">
                                <a uib-tooltip="${message(code:'todo.is.ui.comments')}">
                                    <i class="fa fa-comment-o"></i>
                                </a>
                            </span>
                            <span class="action" ng-class="{'active':storyPreview.tasks_count}">
                                <a uib-tooltip="${message(code:'todo.is.ui.tasks')}">
                                    <i class="fa fa-tasks"></i>
                                    <span class="badge">{{ storyPreview.tasks_count || '' }}</span>
                                </a>
                            </span>
                            <span class="action" ng-class="{'active':storyPreview.acceptanceTests_count}">
                                <a uib-tooltip="${message(code:'todo.is.ui.acceptanceTests')}">
                                    <i class="fa" ng-class="storyPreview.acceptanceTests_count ? 'fa-check-square' : 'fa-check-square-o'"></i>
                                    <span class="badge">{{ storyPreview.acceptanceTests_count || '' }}</span>
                                </a>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <form ng-submit="save(story, false)"
              name='formHolder.storyForm'
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="name">${message(code:'is.story.name')}</label>
                    <input required
                           name="name"
                           type="text"
                           class="form-control"
                           autofocus
                           placeholder="${message(code: 'is.ui.story.noname')}"
                           ng-maxlength="100"
                           ng-model="story.name"
                           ng-change="findDuplicates(story.name)"
                           ng-disabled="!authorizedStory('create')"/>
                    <div ng-if="messageDuplicate"
                         class="help-block bg-warning"
                         ng-bind-html="messageDuplicate | sanitize"></div>
                </div>
                <div class="form-half" ng-if="templateEntries.length > 0">
                    <label for="story.template">${message(code: 'todo.is.ui.story.template')}</label>
                    <div ng-class="{'input-group': authorizedStory('updateTemplate')}">
                        <ui-select name="story.template"
                                   class="form-control"
                                   ng-model="story.template"
                                   ng-disabled="!authorizedStory('create')"
                                   on-select="templateSelected()">
                            <ui-select-match allow-clear="true" placeholder="${message(code:'todo.is.ui.story.template.placeholder')}">{{ $select.selected.text }}</ui-select-match>
                            <ui-select-choices repeat="templateEntry in templateEntries">{{ templateEntry.text }}</ui-select-choices>
                        </ui-select>
                        <span class="input-group-btn"
                              ng-show="authorizedStory('updateTemplate')">
                            <button type="button"
                                    ng-disabled="templateEntries.length == 0"
                                    tabindex="-1"
                                    uib-tooltip="${message(code:'todo.is.ui.story.template.manage')}"
                                    ng-click="showEditTemplateModal()"
                                    class="btn btn-default">
                                <i class="fa fa-pencil"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div ng-if="authorizedStory('create')" class="btn-toolbar pull-right">
                <button class="btn btn-primary"
                        ng-disabled="formHolder.storyForm.$invalid"
                        uib-tooltip="${message(code:'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                        hotkey="{'shift+return': hotkeyClick }"
                        hotkey-allow-in="INPUT"
                        type='button'
                        ng-click="save(story, true)">
                    ${message(code:'todo.is.ui.create.and.continue')}
                </button>
                <button class="btn btn-primary"
                        ng-disabled="formHolder.storyForm.$invalid"
                        type="submit">
                    ${message(code:'default.button.create.label')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>
