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
- Authors:Marwah Soltani (msoltani@kagilum.com)
-
--}%
<script type="text/ng-template" id="home.connected.html">
<div html-sortable class="row" id="panelhome">
    <div class="col-md-5">
        <div class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.rss')}</div>
            <div class="panel-body">..</div>
        </div>
    </div>
    <div class="col-md-4">
        <div ng-controller="userCtrl" class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.notes')}</div>
            <div class="panel-body">
                <div class="form-group">
                    <textarea is-markitup
                              class="form-control"
                              name="notes"
                              ng-model="editableUser.notes"
                              is-model-html="editableUser.notes_html"
                              ng-show="showNotesTextarea"
                              ng-blur="showNotesTextarea = false; update(editableUser)"
                              placeholder="${message(code: 'is.ui.backlogelement.nonotes')}"></textarea>
                    <div class="markitup-preview"
                         ng-disabled="true"
                         ng-show="!showNotesTextarea"
                         ng-click="showNotesTextarea = true"
                         ng-class="{'placeholder': !editableUser.notes_html}"
                         tabindex="0"
                         ng-bind-html="(editableUser.notes_html ? editableUser.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-5" ng-init="type='user'">
        <div class="panel panel-primary" ng-controller="projectListCtrl">
            <div class="panel-heading">
                ${message(code: 'is.panel.myprojects')}
            </div>
            <accordion>
                <accordion-group heading="{{ project.name }}"
                                 is-open="openedProjects[project.id]"
                                 ng-repeat="project in projects">
                    <div ng-include="'project.details.html'"></div>
                </accordion-group>
            </accordion>
        </div>
    </div>
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.mood')}</div>
            <div class="panel-body" ng-controller="Ctrldate">
                <h3>Date of : {{date | date:'dd-MM-yyyy'}}</h3>
                <div ng-controller="moodCtrl">
                    <button ng-click="save('GOOD')" tooltip="Great" class="fa fa-smile-o fa-5x"></button>
                    <button ng-click="save('MEH')" tooltip="So-so" class="fa fa-meh-o fa-5x"></button>
                    <button ng-click="save('BAD')" tooltip="Bad" class="fa fa-frown-o fa-5x"></button>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-primary" ng-controller="userTaskCtrl">
            <div class="panel-heading">
                ${message(code: 'is.panel.mytask')}
            </div>
            <accordion>
                <accordion-group heading="{{task.uid }} - {{task.name }}" ng-repeat="task in tasks">
                    <table>
                        <tr><td>${message(code: 'is.panel.task.Estimation')} : {{ task.estimation }}</td></tr>
                        <tr><td>${message(code: 'is.panel.task.Etat')} : {{task.state | i18n:'TaskStates' }}</td></tr>
                        <tr><td>${message(code: 'is.panel.task.Description')} : {{ task.description }}</td></tr>
                        <tr><td>${message(code: 'is.panel.task.Story')} : {{ task.parentStory.name }}</td></tr>
                    </table>
                </accordion-group>
            </accordion>
        </div>
    </div>
</div>
</script>