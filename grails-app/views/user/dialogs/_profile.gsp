<%@ page import="org.icescrum.core.support.ApplicationSupport" %>
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
<is:modal name="profile"
          title="${message(code:'todo.is.dialog.profile')}"
          form="[action:createLink(action:'update',id:user.id,mapping:'default'),method:'POST',success:'$.icescrum.user.updateSuccess',submit:message(code:'is.button.update')]">
        <ul class="nav nav-pills nav-justified">
            <li><a href="#profile-tab" data-toggle="tab">${message(code: 'todo.is.dialog.profile.general.title')}</a></li>
            <g:if test="${projects}">
                <li><a href="#email-tab" data-toggle="tab">${message(code: 'is.dialog.profile.emailsSettings')}</a></li>
            </g:if>
            <entry:point id="${controllerName}-${actionName}-titled" model="[user:user,projects:projects]"/>
        </ul>
        <div class="tab-content">
            <div class="tab-pane scrollable-shadow" id="profile-tab">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="username">${message(code:'is.user.username')}</label>
                                <p class="form-control-static">${user.username}</p>
                            </div>
                            <div class="form-group">
                                <label for="user.firstName">${message(code:'is.user.firstname')}</label>
                                <input type="text"
                                       class="form-control"
                                       name="user.firstName"
                                       value="${user.firstName}"
                                       autofocus
                                       required/>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div id="user-avatar"
                                 class="avatar dropzone-previews"
                                 data-dz
                                 data-dz-param-name="user.avatar"
                                 data-dz-accepted-files="image/*"
                                 data-dz-clickable="#user-avatar img"
                                 data-dz-complete="$.icescrum.user.avatarUploaded"
                                 data-dz-url="${createLink(controller:'user', action:'update', id:user.id)}">
                                <img src="${is.avatar()}"/>
                            </div>
                        </div>
                    </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="user.lastName">${message(code:'is.user.lastname')}</label>
                            <input type="text"
                                   class="form-control"
                                   name="user.lastName"
                                   value="${user.lastName}"
                                   required/>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="userAvatar">${message(code:'is.user.avatar')}</label>
                            <select id= "userAvatar"
                                    name="user.avatar"
                                    style="width:100%"
                                    data-sl2
                                    class="form-control"
                                    data-sl2-change="$.icescrum.user.selectAvatar"
                                    placeholder="${message(code:'todo.is.user.avatar.placeholder')}">
                                <option></option>
                                <option value="custom">${message(code:'todo.is.user.avatar.custom')}</option>
                                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)}">
                                    <option value="gravatar">${message(code:'todo.is.user.avatar.gravatar')}</option>
                                </g:if>
                                <option value="${resource(dir: '/images/avatars', file: 'dev-ico.png')}">${message(code:'todo.is.user.avatar.std.1')}</option>
                                <option value="${resource(dir: '/images/avatars', file: 'po-ico.png')}">${message(code:'todo.is.user.avatar.std.2')}</option>
                                <option value="${resource(dir: '/images/avatars', file: 'sh-ico.png')}">${message(code:'todo.is.user.avatar.std.3')}</option>
                                <option value="${resource(dir: '/images/avatars', file: 'sm-ico.png')}">${message(code:'todo.is.user.avatar.std.4')}</option>
                                <option value="${resource(dir: '/images/avatars', file: 'admin-ico.png')}">${message(code:'todo.is.user.avatar.std.5')}</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="user.email">${message(code:'is.user.email')}</label>
                            <input type="email"
                                   name="user.email"
                                   class="form-control"
                                   value="${user.email}"
                                   onchange="$.icescrum.user.selectAvatar(null, '#userAvatar')"
                                   required/>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="user.preferences.language">${message(code:'is.user.preferences.language')}</label>
                            <select name="user.preferences.language"
                                    style="width:100%"
                                    data-sl2
                                    class="form-control">
                                <is:options selected="${user.preferences.language}" values="${is.languages()}" />
                            </select>
                        </div>
                    </div>
                </div>
                <g:if test="${!user.accountExternal}">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="user.password">${message(code:'is.user.password')}</label>
                                <input name="user.password"
                                       type="password"
                                       class="form-control"
                                       value="">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="confirmPassword">${message(code:'is.dialog.register.confirmPassword')}</label>
                                <input name="confirmPassword"
                                       type="password"
                                       class="form-control"
                                       value="">
                            </div>
                        </div>
                    </div>
                </g:if>
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <label for="user.preferences.activity">${message(code:'is.user.preferences.activity')}</label>
                            <input name="user.preferences.activity"
                                   type="text"
                                   class="form-control"
                                   value="${user.preferences.activity}"
                                   value="">
                        </div>
                    </div>
                </div>
            </div>
            <g:if test="${projects}">
                <div class="tab-pane scrollable-shadow" id="email-tab">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="user.preferences.emailsSettings.autoFollow">${message(code:'is.dialog.profile.emailsSettings.autoFollow')}</label>
                                <select name="user.preferences.emailsSettings.autoFollow"
                                        multiple="multiple"
                                        class="form-control"
                                        placeholder="todo.is.choose.project"
                                        data-sl2>
                                    <g:each in="${projects}" var="project">
                                        <option ${project.pkey in user.preferences.emailsSettings.autoFollow ? 'selected="selected"' : ''} value="${project.pkey}">${project.name}</option>
                                    </g:each>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="user.preferences.emailsSettings.onStory">${message(code:'is.dialog.profile.emailsSettings.onStory')}</label>
                                <select name="user.preferences.emailsSettings.onStory"
                                        multiple="multiple"
                                        class="form-control"
                                        placeholder="todo.is.choose.project"
                                        data-sl2>
                                    <g:each in="${projects}" var="project">
                                        <option ${project.pkey in user.preferences.emailsSettings.onStory ? 'selected="selected"' : ''} value="${project.pkey}">${project.name}</option>
                                    </g:each>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="user.preferences.emailsSettings.onUrgentTask">${message(code:'is.dialog.profile.emailsSettings.onUrgentTask')}</label>
                                <select name="user.preferences.emailsSettings.onUrgentTask"
                                        multiple="multiple"
                                        class="form-control"
                                        placeholder="todo.is.choose.project"
                                        data-sl2>
                                    <g:each in="${projects}" var="project">
                                        <option ${project.pkey in user.preferences.emailsSettings.onUrgentTask ? 'selected="selected"' : ''} value="${project.pkey}">${project.name}</option>
                                    </g:each>
                                </select>
                            </div>
                        </div>
                    </div>
                    </div>
                </g:if>
                <entry:point id="${controllerName}-${actionName}-contentd" model="[user:user,projects:projects]"/>
        </div>
</is:modal>