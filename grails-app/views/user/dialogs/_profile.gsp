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
<is:modal name="formHolder.profileForm"
          form="update(currentUser)"
          validate="true"
          submitButton="${message(code:'todo.is.ui.save')}"
          closeButton="${message(code:'is.button.cancel')}"
          title="${message(code:'todo.is.dialog.profile')}">
    <tabset type="pills" justified="true">
        <tab heading="${message(code: 'todo.is.dialog.profile.general.title')}"
             active="tabSelected.general"
             select="setTabSelected('general')">
            <div flow-files-added="currentUser.avatar = 'custom';"
                 flow-files-submitted="$flow.upload()"
                 flow-init="{target:'${createLink(controller:'user', action:'update', id:user.id)}', singleFile:true, simultaneousUploads:1}"
                 flow-drop>
                <div class="row">
                    <div class="form-half">
                        <label for="username">${message(code:'is.user.username')}</label>
                        <p class="form-control-static">${user.username}</p>
                    </div>
                    <div class="col-md-6">
                        <label for="userAvatar">${message(code:'is.user.avatar')}</label>
                        <div id="user-avatar" class="form-control-static">
                            <div class="col-md-12">
                                <img height="40"
                                     width="40"
                                     src="${asset.assetPath(src: 'avatars/dev-ico.png')}"/>
                                <img height="40"
                                     width="40"
                                     src="${asset.assetPath(src: 'avatars/po-ico.png')}"/>
                                <img height="40"
                                     width="40"
                                     src="${asset.assetPath(src: 'avatars/sh-ico.png')}"/>
                                <img height="40"
                                     width="40"
                                     src="${asset.assetPath(src: 'avatars/sm-ico.png')}"/>
                            </div>
                            <div class="col-md-12">
                                <img height="40"
                                     width="40"
                                     src="${asset.assetPath(src: 'avatars/admin-ico.png')}"/>
                                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)}">
                                    <img height="40"
                                         width="40"
                                         src="${"https://secure.gravatar.com/avatar/" + user.email.encodeAsMD5()}"/>
                                </g:if>
                                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)}">
                                    <img height="40"
                                         width="40"
                                         flow-img="$flow.files[0]"
                                         flow-single-file="true"
                                         flow-btn/>
                                </g:if>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="form-half">
                        <label for="user.firstName">${message(code:'is.user.firstname')}</label>
                        <input type="text"
                               class="form-control"
                               name="user.firstName"
                               ng-model="currentUser.firstName"
                               focus-me="true"
                               required/>
                    </div>
                    <div class="form-half">
                        <label for="user.lastName">${message(code:'is.user.lastname')}</label>
                        <input type="text"
                               class="form-control"
                               name="user.lastName"
                               ng-model="currentUser.lastName"
                               required/>
                    </div>
                </div>
                <div class="row">
                    <div class="form-half">
                        <label for="user.email">${message(code:'is.user.email')}</label>
                        <input type="email"
                               name="user.email"
                               class="form-control"
                               ng-model="currentUser.email"
                               ng-blur="refreshAvatar(currentUser)"
                               required/>
                    </div>
                    <div class="form-half">
                        <label for="user.preferences.language">${message(code:'is.user.preferences.language')}</label>
                        <select name="user.preferences.language"
                                ui-select2
                                class="form-control"
                                ng-model="currentUser.preferences.language">
                            <is:options values="${is.languages()}" />
                        </select>
                    </div>
                </div>
                <div class="row" ng-show="!currentUser.accountExternal">
                    <div class="form-half">
                        <label for="user.password">${message(code:'is.user.password')}</label>
                        <input name="user.password"
                               type="password"
                               class="form-control"
                               ng-model="currentUser.password">
                        <div ng-password-strength="currentUser.password"></div>
                    </div>
                    <div class="form-half">
                        <label for="confirmPassword">${message(code:'is.dialog.register.confirmPassword')}</label>
                        <input name="confirmPassword"
                               type="password"
                               class="form-control"
                               match="currentUser.password"
                               ng-model="passwordConfirm">
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="user.preferences.activity">${message(code:'is.user.preferences.activity')}</label>
                        <input name="user.preferences.activity"
                               type="text"
                               class="form-control"
                               ng-model="currentUser.preferences.activity">
                    </div>
                </div>
            </div>
        </tab>
        <g:if test="${projects}">
            <tab heading="${message(code: 'is.dialog.profile.emailsSettings')}"
                 active="tabSelected.emailSettings"
                 select="setTabSelected('emailSettings')">
                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="user.preferences.emailsSettings.autoFollow">${message(code:'is.dialog.profile.emailsSettings.autoFollow')}</label>
                        <select name="user.preferences.emailsSettings.autoFollow"
                                class="form-control"
                                multiple
                                ng-model="currentUser.preferences.emailsSettings.autoFollow">
                            <g:each in="${projects}" var="project">
                                <option value="${project.pkey}">${project.name}</option>
                            </g:each>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="user.preferences.emailsSettings.onStory">${message(code:'is.dialog.profile.emailsSettings.onStory')}</label>
                        <select name="user.preferences.emailsSettings.onStory"
                                multiple="multiple"
                                class="form-control"
                                ng-model="currentUser.preferences.emailsSettings.onStory">
                            <g:each in="${projects}" var="project">
                                <option value="${project.pkey}">${project.name}</option>
                            </g:each>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="user.preferences.emailsSettings.onUrgentTask">${message(code:'is.dialog.profile.emailsSettings.onUrgentTask')}</label>
                        <select name="user.preferences.emailsSettings.onUrgentTask"
                                multiple="multiple"
                                class="form-control"
                                ng-model="currentUser.preferences.emailsSettings.onUrgentTask">
                            <g:each in="${projects}" var="project">
                                <option value="${project.pkey}">${project.name}</option>
                            </g:each>
                        </select>
                    </div>
                </div>
            </tab>
        </g:if>
        <entry:point id="${controllerName}-${actionName}-contentd"/>
    </tabset>
</is:modal>