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
<script type="text/ng-template" id="story.new.html">
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">${message(code: "is.ui.sandbox.toolbar.new")} ${message(code: "is.story")}</h3>
        <div class="help-block">${message(code:'is.ui.sandbox.help')}</div>
    </div>
    <div class="panel-body">
        <div class="postits standalone">
            <div class="postit-container">
                <div style="{{ (storyPreview.feature ? storyPreview.feature.color : '#f9f157') | createGradientBackground }}"
                     class="postit story {{ (storyPreview.feature ? storyPreview.feature.color : '#f9f157') | contrastColor }}">
                    <div class="head">
                        <span class="id">42</span>
                    </div>
                    <div class="content">
                        <h3 class="title" ng-bind-html="story.name | sanitize" ellipsis></h3>
                        <div class="description-template" ng-bind-html="storyPreview.description | sanitize" ellipsis></div>
                    </div>
                    <div class="tags">
                        <a ng-repeat="tag in storyPreview.tags"><span class="tag">{{ tag }}</span></a>
                    </div>
                    <div class="actions">
                        <span class="action">
                            <a>
                                <i class="fa fa-cog"></i>
                            </a>
                        </span>
                        <span class="action">
                            <a tooltip="${message(code:'todo.is.backlogelement.attachments')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-paperclip"></i>
                            </a>
                        </span>
                        <span class="action">
                            <a tooltip="${message(code:'todo.is.story.comments')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-comment-o"></i>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':storyPreview.tasks_count}">
                            <a tooltip="{{ storyPreview.tasks_count }} ${message(code:'todo.is.story.tasks')}"
                               tooltip-append-to-body="true">
                                <i class="fa fa-tasks"></i>
                                <span class="badge" ng-show="storyPreview.tasks_count">{{ storyPreview.tasks_count }}</span>
                            </a>
                        </span>
                        <span class="action" ng-class="{'active':storyPreview.acceptanceTests_count}">
                            <a tooltip="{{ storyPreview.acceptanceTests_count }} ${message(code:'todo.is.acceptanceTests')}"
                               tooltip-append-to-body="true"
                               ng-switch="storyPreview.acceptanceTests_count">
                                <i class="fa fa-check-square-o" ng-switch-when="0"></i>
                                <i class="fa fa-check-square" ng-switch-default></i>
                                <span class="badge" ng-if="storyPreview.acceptanceTests_count">{{ storyPreview.acceptanceTests_count }}</span>
                            </a>
                        </span>
                    </div>
                    <div class="progress">
                        <span class="status">3/6</span>
                        <div class="progress-bar" style="width:16.666666666666668%">
                        </div>
                    </div>
                    <div class="state">{{ defaultStoryState | i18n:'storyState' }}</div>
                </div>
            </div>
        </div>

        <form ng-submit="save(story, false)"
              name='formHolder.storyForm'
              show-validation
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="name">${message(code:'is.story.name')}</label>
                    <input required
                           name="name"
                           type="text"
                           class="form-control"
                           focus-me="true"
                           placeholder="${message(code: 'is.ui.story.noname')}"
                           ng-maxlength="100"
                           ng-model="story.name"
                           ng-change="findDuplicates(story.name)"
                           ng-readonly="!authorizedStory('create')"/>
                           <div ng-if="messageDuplicate"
                                class="help-block bg-warning"
                                ng-bind-html="messageDuplicate | sanitize"></div>
                </div>
                <div class="form-half">
                    <label for="story.template">${message(code: 'todo.is.ui.story.template.choose')}</label>
                    <div ng-class="{'input-group': authorizedStory('updateTemplate')}">
                        <input type="hidden"
                               name="story.template"
                               class="form-control"
                               ng-model="story.template"
                               ng-readonly="!authorizedStory('create')"
                               ng-change="templateSelected()"
                               data-placeholder="${message(code:'todo.is.ui.story.placeholder')}"
                               ui-select2="selectTemplateOptions"/>
                        <span class="input-group-btn" ng-show="authorizedStory('updateTemplate')">
                            <button type="button"
                                    tabindex="-1"
                                    tooltip="${message(code:'todo.is.ui.story.template.edit')}"
                                    tooltip-placement="left"
                                    tooltip-append-to-body="true"
                                    ng-click="showEditTemplateModal()"
                                    class="btn btn-default">
                                <i class="fa fa-pencil"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div ng-if="authorizedStory('create')" class="btn-toolbar pull-right">
                <button class="btn btn-primary pull-right"
                        ng-disabled="formHolder.storyForm.$invalid"
                        tooltip="${message(code:'todo.is.ui.save')} (RETURN)"
                        tooltip-append-to-body="true"
                        type="submit">
                    ${message(code:'todo.is.ui.save')}
                </button>
                <button class="btn btn-primary pull-right"
                        ng-disabled="formHolder.storyForm.$invalid"
                        tooltip="${message(code:'todo.is.ui.save.and.continue')} (SHIFT+RETURN)"
                        tooltip-append-to-body="true"
                        hotkey="{'shift+return': hotkeyClick }"
                        hotkey-allow-in="INPUT"
                        type='button'
                        ng-click="save(story, true)">
                    ${message(code:'todo.is.ui.save.and.continue')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>
