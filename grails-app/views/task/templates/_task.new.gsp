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
<div class="card">
    <div class="details-header">
        <details-layout-buttons ng-if="!isModal" remove-ancestor="true"/>
    </div>
    <div class="card-header">
        <div class="card-title">
            <div class="details-title">
                <span class="item-name" title="${message(code: 'todo.is.ui.task.new')}">${message(code: 'todo.is.ui.task.new')}</span>
            </div>
        </div>
        <div class="form-text">
            ${message(code: 'is.ui.task.help')}
            <documentation doc-url="features-stories-tasks#tasks"/>
        </div>
        <div class="sticky-notes sticky-notes-standalone grid-group">
            <div class="sticky-note-container sticky-note-task">
                <div ng-style="'#ffcc01' | createGradientBackground"
                     class="sticky-note {{ ('#f9f157' | contrastColor) }}">
                    <div class="sticky-note-head">
                        <span class="id">42</span>
                    </div>
                    <div class="sticky-note-content">
                        <div class="item-values"></div>
                        <div class="title">{{ task.name }}</div>
                    </div>
                    <div class="sticky-note-tags"></div>
                    <div class="sticky-note-actions">
                        <span class="action"><a class="action-link"><span class="action-icon action-icon-attach"></span></a></span>
                        <span class="action"><a class="action-link"><span class="action-icon action-icon-comment"></span></a></span>
                        <span class="action"><a class="action-link"><span class="action-icon action-icon-menu"></span></a></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="details-no-tab">
        <form ng-submit="save(task, false)"
              name='formHolder.taskForm'
              novalidate>
            <div class="card-body">
                <div class="row is-form-row">
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
            </div>
            <div class="card-footer" ng-if="authorizedTask('create')" >
                <div class="btn-toolbar">
                    <button class="btn btn-primary"
                            ng-disabled="formHolder.taskForm.$invalid || application.submitting"
                            defer-tooltip="${message(code: 'todo.is.ui.create.and.continue')} (SHIFT+RETURN)"
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
            </div>
        </form>
    </div>
</div>
</script>
