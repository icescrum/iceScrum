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
               href="{{:: $state.href('^.^') }}"
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
                     class="postit postit{{ app.postitSize }} {{ '#f9f157' | contrastColor }}">
                    <div class="head">
                        <div class="head-left">
                            <span class="id">42</span>
                        </div>
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
        <form ng-submit="save(task, false)"
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
                <div class="form-half">
                    <label for="category">${message(code:'todo.is.ui.task.category')}</label>
                    <ui-select class="form-control"
                               required
                               name="category"
                               search-enabled="true"
                               on-select="selectCategory()"
                               ng-model="formHolder.category">
                        <ui-select-match placeholder="${message(code: 'todo.is.ui.task.nocategory')}">{{ $select.selected.name }}</ui-select-match>
                        <ui-select-choices group-by="groupCategory" repeat="category in categories | filter: $select.search">
                            <span ng-bind-html="category.name | highlight: $select.search"></span>
                        </ui-select-choices>
                    </ui-select>
                </div>
            </div>
            <div ng-if="authorizedTask('create')" class="btn-toolbar pull-right">
                <button class="btn btn-primary"
                        ng-disabled="formHolder.taskForm.$invalid"
                        uib-tooltip="${message(code:'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                        hotkey="{'shift+return': hotkeyClick }"
                        hotkey-allow-in="INPUT"
                        type='button'
                        ng-click="save(task, true)">
                    ${message(code:'todo.is.ui.create.and.continue')}
                </button>
                <button class="btn btn-primary"
                        ng-disabled="formHolder.taskForm.$invalid"
                        type="submit">
                    ${message(code:'default.button.create.label')}
                </button>
            </div>
        </form>
    </div>
</div>
</script>
