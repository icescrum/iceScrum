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
<script type="text/ng-template" id="home.not.connected.html">
<div html-sortable class="row" id="panelhome">
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading ">
                <h3 class="panel-title">${message(code: 'is.connection')}</h3>
            </div>
            <div class="panel-body" ng-controller="loginCtrl">
                <form novalidate role="form"
                      ng-submit="login(credentials)">
                    <div class="form-group">
                        <div class="col-md-9">
                            <label align="text-center"
                                   for="credentials.j_username">${message(code: 'is.user.username')}</label>

                            <div class="input-group">
                                <input required="" ng-model="credentials.j_username" type="text"
                                       id="credentials.j_username"
                                       class="form-control ng-isolate-scope ng-dirty ng-valid-parse ng-valid ng-valid-required ng-touched"
                                       focus-me="true" value="">
                                <span class="input-group-btn"><a tabindex="-1" class="btn btn-default" type="button"
                                                                 href ng-click="showRegisterModal()"
                                                                 tooltip-placement="top"
                                                                 tooltip="${message(code: 'todo.is.new')}">
                                    <i class="fa fa-user"></i></a>
                                </span>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-9">
                                <label for="credentials.j_password"
                                       align="text-center">${message(code: 'is.user.password')}</label>

                                <div class="input-group">
                                    <input required="" ng-model="credentials.j_password" type="password"
                                           id="credentials.j_password"
                                           class="form-control ng-untouched ng-dirty ng-valid-parse ng-valid ng-valid-required"
                                           value="">
                                    <span class="input-group-btn">
                                        <a tabindex="-1"
                                           class="btn btn-default"
                                           type="button"
                                           tooltip-placement="top"
                                           href
                                           ng-click="showRetrieveModal()"
                                           tooltip="${message(code: 'todo.is.retrieve')}">
                                            <i class="fa fa-flash"></i>
                                        </a>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="checkbox">
                            <label>
                                <input type='checkbox'
                                       name='${rememberMeParameter}'
                                       id='remember_me'
                                       <g:if test='${hasCookie}'>checked='checked'</g:if>/> <g:message
                                    code="is.dialog.login.rememberme"/>
                            </label>
                        </div>

                        <div class="btn-toolbar pull-right">
                            <button class="btn btn-primary pull-right"
                                    tooltip="${message(code: 'is.button.connect')} (RETURN)"
                                    tooltip-append-to-body="true"
                                    type="submit">
                                ${message(code: 'is.button.connect')}
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-primary ">
            <div class="panel-heading">
                <h3 class="panel-title">${message(code: 'is.panel.rss')}</h3>
            </div>
            <div class="panel-body">.....</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading">
                <h4 class="panel-title">Projets publics</h4></div>
            <div ng-controller="Accordion">
                <div ng-controller="publicproject">
                    <accordion close-others="oneAtATime">
                        <div ng-repeat="project in projects">
                            <accordion-group><accordion-heading>{{ project.name }}</accordion-heading>
                                <table >
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
</div>
</script>


