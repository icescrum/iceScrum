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
<script type="text/ng-template" id="task.new.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            <i class="fa fa-sticky-note" style="color: #f9f157"></i>
            ${message(code: 'todo.is.ui.task.new')}
            <a class="pull-right visible-on-hover btn btn-default"
               href="#/{{ ::viewName }}"
               uib-tooltip="${message(code: 'is.ui.window.closeable')}">
                <i class="fa fa-times"></i>
            </a>
        </h3>
    </div>
    <div class="panel-body">
        <div class="help-block">${message(code:'is.ui.task.help')}</div>
        <div class="postits standalone">
            <div ellipsis class="postit-container">
                <div style="{{ '#f9f157' | createGradientBackground }}"
                     class="postit postit-small {{ '#f9f157' | contrastColor }}">
                    <div class="head">
                        <span class="id">42</span>
                    </div>
                    <div class="content">
                        <h3 class="title ellipsis-el"
                            ng-model="task.name"
                            ng-bind-html="task.name | sanitize"></h3>
                    </div>
                    <div class="tags"></div>
                    <div class="actions">
                        <span class="action"><a><i class="fa fa-cog"></i></a></span>
                        <span class="action"><a><i class="fa fa-paperclip"></i></a></span>
                        <span class="action"><a><i class="fa fa-tasks"></i></a></span>
                    </div>
                </div>
            </div>
        </div>
        <form ng-submit="save(task, sprint, false)"
              name='formHolder.taskForm'
              novalidate>
            <div class="clearfix no-padding">
                <div class="form-half">
                    <label for="name">${message(code:'is.task.name')}</label>
                    <input required
                           name="name"
                           autofocus
                           ng-model="task.name"
                           type="text"
                           class="form-control"
                           ng-disabled="!authorizedTask('create')"
                           placeholder="${message(code: 'is.ui.task.noname')}"/>
                </div>
                <div ng-if="task.parentStory" class="form-half">
                    <label for="name">${message(code:'is.story')}</label>
                    <span class="form-control-static">{{ task.parentStory.name }}</span>
                </div>
                <div ng-if="task.type" class="form-half">
                    <label for="name">${message(code:'is.task.type')}</label>
                    <span class="form-control-static">{{ task.type | i18n: 'TaskTypes' }}</span>
                </div>
            </div>
            <div ng-if="authorizedTask('create')" class="btn-toolbar pull-right">
                <button class="btn btn-primary pull-right"
                        ng-disabled="formHolder.taskForm.$invalid"
                        uib-tooltip="${message(code:'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                        hotkey="{'shift+return': hotkeyClick }"
                        hotkey-allow-in="INPUT"
                        type='button'
                        ng-click="save(task, true)">
                    ${message(code:'todo.is.ui.create.and.continue')}
                </button>
                <button class="btn btn-primary pull-right"
                        ng-disabled="formHolder.taskForm.$invalid"
                        uib-tooltip="${message(code:'default.button.create.label')} (RETURN)"
                        type="submit">
                    ${message(code:'default.button.create.label')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>
