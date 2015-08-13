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
    <div class="col-md-5">
        <div  ng-controller="savenote" class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.notes')}</div>
            <div class="panel-body">
                <div class="form-group">
                    <label for="notes">${message(code:'is.backlogelement.notes')}</label>
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
                         ng-focus="editForm(true)"
                         ng-class="{'placeholder': !editableUser.notes_html}"
                         tabindex="0"
                         ng-bind-html="(editableUser.notes_html ? editableUser.notes_html : '<p>${message(code: 'is.ui.backlogelement.nonotes')}</p>') | sanitize"> </div>
                </div>
                </div>
            </div>
            </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-primary">
            <div class="panel-heading">
                ${message(code: 'is.panel.myprojects')}
            </div>
            <div ng-controller="Accordion">
                <div ng-controller="userproject">
                    <accordion close-others="oneAtATime">
                        <div ng-repeat="project in projects">
                            <accordion-group><accordion-heading> {{ project.name }} </accordion-heading>
                                <table>
                                    <tr>
                                        <td>name</td>
                                        <td>{{ project.name }}</td>
                                    </tr>
                                    <tr>
                                        <td>pkey</td>
                                        <td>{{ project.pkey }}</td>
                                    </tr>
                                    <tr>
                                        <td>description</td>
                                        <td>{{ project.description }}</td>
                                    </tr>
                                    <tr>
                                        <td>startDate</td>
                                        <td>{{ project.startDate }}</td>
                                    </tr>
                                    <tr>
                                        <td>releases_count</td>
                                        <td>{{ project.releases_count }}</td>
                                    </tr>
                                    <tr>
                                        <td>features_count</td>
                                        <td>{{ project.features_count }}</td>
                                    </tr>
                                    <tr>
                                        <td>stories_count</td>
                                        <td>{{ project.stories_count }}</td>
                                    </tr>
                                    <tr>
                                        <td>actors_count</td>
                                        <td>{{ project.actors_count }}</td>
                                    </tr>
                                </table>
                            </accordion-group>
                        </div>
                    </accordion>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-primary">
            <div class="panel-heading">${message(code: 'is.panel.mood')}</div>
            <div class="panel-body">..</div>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-primary">
            <div class="panel-heading">
                ${message(code: 'is.panel.mytask')}
            </div>
            <div ng-controller="Accordion">
                <div ng-controller="usertaskCtrl">
                    <accordion close-others="oneAtATime">
                             <div ng-repeat="task in tasks ">
                            <accordion-group><accordion-heading> {{task.name }} </accordion-heading></accordion-group>
                             </div>
                    </accordion>
                </div>
            </div>
        </div>
    </div>
</div>
</script>