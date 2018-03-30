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
        <h3 class="panel-title row">
            <div class="left-title">
                <i class="fa fa-file" ng-style="{color: task.color ? task.color : '#f9f157' }"></i>
                <span class="item-name" title="${message(code: 'todo.is.ui.task.new')}">${message(code: 'todo.is.ui.task.new')}</span>
            </div>
            <div class="right-title">
                <details-layout-buttons ng-if="!isModal" remove-ancestor="true"/>
            </div>
        </h3>
    </div>
    <div class="details-no-tab">
        <div class="panel-body">
            <div class="help-block">${message(code: 'is.ui.task.help')}</div>
            <div class="postits standalone">
                <div class="postit-container solo">
                    <div ng-style="'#f9f157' | createGradientBackground"
                         class="postit postit-sm {{ ('#f9f157' | contrastColor) }}">
                        <div class="head">
                            <div class="head-left">
                                <span class="id">42</span>
                            </div>
                        </div>
                        <div class="content">
                            <h3 class="title">{{ task.name }}</h3>
                        </div>
                        <div class="tags"></div>
                        <div class="actions">
                            <span class="action"><a><i class="fa fa-paperclip"></i></a></span>
                            <span class="action"><a><i class="fa fa-comment"></i></a></span>
                            <span class="action"><a><i class="fa fa-ellipsis-h"></i></a></span>
                        </div>
                    </div>
                </div>
            </div>
            <form ng-submit="save(task, false)"
                  name='formHolder.taskForm'
                  novalidate>
                <div class="clearfix no-padding">
                    <div class="form-half">
                        <label for="name">${message(code: 'is.task.name')}</label>
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
                        <label for="category">${message(code: 'todo.is.ui.task.category')}</label>
                        <ui-select class="form-control"
                                   required
                                   name="category"
                                   search-enabled="true"
                                   on-select="selectCategory()"
                                   ng-model="formHolder.category">
                            <ui-select-match placeholder="${message(code: 'todo.is.ui.task.nocategory')}">
                                <i class="fa" ng-class="{'fa-sticky-note': $select.selected.class == 'Story', 'fa-file': $select.selected.class != 'Story'}"
                                   ng-style="{color: $select.selected.class == 'Story' && $select.selected.feature ? $select.selected.feature.color : '#f9f157'}"></i> {{ $select.selected.name }}
                            </ui-select-match>
                            <ui-select-choices group-by="groupCategory" repeat="category in categories | filter: $select.search">
                                <i class="fa" ng-class="{'fa-sticky-note': category.class == 'Story', 'fa-file': category.class != 'Story'}"
                                   ng-style="{color: category.class == 'Story' && category.feature ? category.feature.color : '#f9f157'}"></i> <span ng-bind-html="category.name | highlight: $select.search"></span>
                            </ui-select-choices>
                        </ui-select>
                    </div>
                </div>
                <div ng-if="authorizedTask('create')" class="btn-toolbar pull-right">
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.taskForm.$invalid || application.submitting"
                            uib-tooltip="${message(code: 'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
                            hotkey="{'shift+return': hotkeyClick }"
                            hotkey-allow-in="INPUT"
                            hotkey-description="${message(code: 'todo.is.ui.create.and.continue')}"
                            type='button'
                            ng-click="save(task, true)">
                        ${message(code: 'todo.is.ui.create.and.continue')}
                    </button>
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.taskForm.$invalid || application.submitting"
                            type="submit">
                        ${message(code: 'default.button.create.label')}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
</script>
