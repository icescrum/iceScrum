%{--
- Copyright (c) 2014 Kagilum SAS.
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
<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
<div data-ui-dialog
     data-ui-dialog-close-button="true"
     data-ui-dialog-title="${message(code:'todo.is.dialog.profile')}"
     data-ui-dialog-width="auto">
     <div data-ui-tabs>
        <ul>
            <li><a href="#profile-tab">${message(code: 'todo.is.dialog.profile.general.title')}</a></li>
            <g:if test="${projects}">
            <li><a href="#email-tab">${message(code: 'is.dialog.profile.emailsSettings')}</a></li>
            </g:if>
            <entry:point id="${controllerName}-${actionName}-title" model="[user:user]"/>
        </ul>
        <div id="profile-tab">
            <div class="cols-2">
                <div class="col-1">
                    <div class="field">
                        <label for="user.username">${message(code:'is.user.username')}</label>
                        <input disabled
                               name="user.username"
                               type="text"
                               value="${user.username}">
                    </div>
                    <hr/>
                    <div class="field">
                        <label for="user.firstName">${message(code:'is.user.firstname')}</label>
                        <input required
                               name="user.firstName"
                               type="text"
                               value="${user.firstName}">
                    </div>
                    <hr/>
                    <div class="field">
                        <label for="user.lastName">${message(code:'is.user.lastname')}</label>
                        <input required
                               name="user.lastName"
                               type="text"
                               value="${user.lastName}">
                    </div>
                    <hr/>
                    <div class="field">
                        <label for="user.email">${message(code:'is.user.email')}</label>
                        <input required
                            ${user.accountExternal?'readonly':''}
                               name="user.email"
                               type="email"
                               value="${user.email}">
                    </div>
                </div><!-- no space !--><div class="col-2">
                    <div id="user-avatar"
                         class="avatar dropzone-previews"
                         data-dz
                         data-dz-clickable="#user-avatar img"
                         data-dz-url="http://www.todo.com">
                        <img src="/icescrum/static/JDS9hDaNVycIa6tyoauYOQOUxFxL6qxXuxGHfgbZcvO.png">
                    </div>
                    <div class="field">
                        <label for="user.avatar">${message(code:'is.user.avatar')}</label>
                        <select name="user.avatar"
                                style="width:100%"
                                data-sl2
                                placeholder="${message(code:'todo.is.user.avatar.placeholder')}">
                                <option></option>
                                <option>${message(code:'todo.is.user.avatar.custom')}</option>
                                <option>${message(code:'todo.is.user.avatar.gravatar')}</option>
                                <option>${message(code:'todo.is.user.avatar.std.1')}</option>
                                <option>${message(code:'todo.is.user.avatar.std.2')}</option>
                                <option>${message(code:'todo.is.user.avatar.std.3')}</option>
                                <option>${message(code:'todo.is.user.avatar.std.4')}</option>
                        </select>
                    </div>
                    <hr>
                    <div class="field">
                        <label for="user.preferences.language">${message(code:'is.user.preferences.language')}</label>
                        <select name="user.preferences.language"
                                style="width:100%"
                                data-sl2
                                value="${user.preferences.language}">
                            <is:options values="${is.languages()}" />
                        </select>
                    </div>
                </div>
                <hr/>
            </div>
            <div class="cols-2">
            <g:if test="${!user.accountExternal}">
                <div class="col-1">
                    <div class="field">
                        <label for="user.password">${message(code:'is.user.password')}</label>
                        <input required
                               name="user.password"
                               type="password"
                               data-txt
                               value="">
                    </div>
                </div><!-- no space --><div class="col-2">
                    <div class="field">
                        <label for="user.passwordConfirm">${message(code:'todo.is.user.passwordConfirm')}</label>
                        <input required
                               name="user.passwordConfirm"
                               type="password"
                               data-txt
                               value="">
                    </div>
                </div>
            </g:if>
            </div>
            <hr/>
            <div class="field">
                <label for="user.activity">${message(code:'is.user.preferences.activity')}</label>
                <input name="user.preferences.activity"
                       type="text"
                       data-txt
                       value="${user.preferences.activity}">
            </div>
        </div>
        <g:if test="${projects}">
        <div id="email-tab">
            <div class="field">
                <label for="user.preferences.emailsSettings.autoFollow">${message(code:'is.dialog.profile.emailsSettings.autoFollow')}</label>
                <select name="user.preferences.emailsSettings.autoFollow"
                        multiple="multiple"
                        placeholder="todo.is.Choose project(s)"
                        data-sl2>
                    <g:each in="${projects}" var="project">
                        <option ${project.pkey in user.preferences.emailsSettings.autoFollow ? 'selected="selected"' : ''}
                                value="${project.pkey}">${project.name}</option>
                    </g:each>
                </select>
            </div>
            <hr>
            <div class="field">
                <label for="user.preferences.emailsSettings.onStory">${message(code:'is.dialog.profile.emailsSettings.onStory')}</label>
                <select name="user.preferences.emailsSettings.onStory"
                        multiple="multiple"
                        placeholder="todo.is.Choose project(s)"
                        data-sl2>
                    <g:each in="${projects}" var="project">
                        <option ${project.pkey in user.preferences.emailsSettings.onStory ? 'selected="selected"' : ''}
                                value="${project.pkey}">${project.name}</option>
                    </g:each>
                </select>
            </div>
            <hr>
            <div class="field">
                <label for="user.preferences.emailsSettings.onUrgentTask">${message(code:'is.dialog.profile.emailsSettings.onUrgentTask')}</label>
                <select name="user.preferences.emailsSettings.onUrgentTask"
                        multiple="multiple"
                        placeholder="todo.is.Choose project(s)"
                        data-sl2>
                    <g:each in="${projects}" var="project">
                        <option ${project.pkey in user.preferences.emailsSettings.onUrgentTask ? 'selected="selected"' : ''}
                                value="${project.pkey}">${project.name}</option>
                    </g:each>
                </select>
            </div>
        </div>
        </g:if>
        <entry:point id="${controllerName}-${actionName}-content" model="[user:user]"/>
     </div>
</div>