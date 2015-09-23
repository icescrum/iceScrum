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
        <div ng-controller="FeedCtrl" class="panel panel-primary">
            <div class="panel-heading">${message(code:'is.panel.rss')}
                <button class="pull-right btn btn-default"  ng-click="click()"> <i class="fa fa-cog"></i> </button>
            </div>
            <span ng-show="view">
                <table>
                    <tr>
                        <td>${message(code: 'todo.is.iu.panel.rss.input')} </td><td><input type="text" ng-model="rss.rssUrl"/> </td>
                        <td><button class="btn btn-primary" ng-click="save(rss)">Save</button></td>
                    </tr>
                    <tr><td>${message(code: 'todo.is.iu.panel.rss.list')}</td>
                        <td>
                            <select
                                class="form-control"
                                placeholder="select Rss"
                                ng-model="selectedRss"
                                ng-change="selectRss(selectedRss)"
                                ui-select2>
                                <option value="all">${message(code: 'todo.is.iu.panel.rss.title.allRss')}</option>
                                <option ng-repeat="rss in rssList" value="{{rss.id}}">{{rss.rssUrl}}</option>
                            </select>
                        </td>
                        <td><button ng-model="selectedRss" ng-click="delete(selectedRss)"
                                    class="btn btn-primary">Delete</button></td>
                    </tr>
                </table>
           </span>
            <span ng-hide="view">
                <h5><a target="_blank" href="{{feed.link}}">{{feed.title}}</a></h5>
                <p class="text-left">{{feed.description | limitTo: 100}}{{feed.description .length > 100 ? '...' : ''}}</p>
                <span class="small">{{feed.pubDate}}</span>
                <li ng-repeat="item in feedItems">
                    <h5><a target="_blank" href="{{item.item.link}}">{{item.item.title}}</a></h5>
                    <p class="text-left">{{item.item.description | limitTo: 100}}{{item.item.description.length > 100 ? '...' : ''}}</p>
                    <span class="small">{{item.item.pubDate}}</span>
                </li>
           </span>
        </div>
    </div>
    <div class="col-md-5">
        <div ng-controller="userCtrl" class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.notes')}</div>
            <div class="panel-body">
                <div class="form-group">
                    <textarea id="note-size" is-markitup
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
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.mood')}</div>
            <div class="panel-body" ng-controller="moodCtrl">
                <div ng-switch="alreadySavedToday">
                    <div ng-switch-default>
                        <button ng-click="save('GOOD')" tooltip="Great" class="fa fa-smile-o fa-5x"></button>
                        <button ng-click="save('MEH')" tooltip="So-so" class="fa fa-meh-o fa-5x"></button>
                        <button ng-click="save('BAD')" tooltip="Bad" class="fa fa-frown-o fa-5x"></button>
                    </div>
                    <div ng-switch-when="true">
                        <table ng-repeat="mood in moods">
                            <tr><td>${message(code: 'is.panel.mood.feeling')}: {{mood.feeling | i18n:'MoodFeelings'}}</td></tr>
                        </table>
                        <div ng-controller="moodChartCtrl">
                            <div class="panel-body" id="panel-chart-container">
                                <nvd3 options="options" data="data"></nvd3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-primary" ng-controller="userTaskCtrl">
            <div class="panel-heading">
                ${message(code: 'is.panel.mytask')}
            </div>
            <accordion ng-repeat="(project, tasks) in tasksByProject">
                {{project}}
                <accordion-group heading="{{task.uid }} - {{task.name }}" ng-repeat="task in tasks">
                    <table>
                        <tr><td>${message(code: 'is.panel.task.Estimation')} : {{ task.creationDate}}</td></tr>
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