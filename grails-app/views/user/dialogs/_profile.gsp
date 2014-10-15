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
          form="update(dataUser)"
          validate="true"
          submitButton="${message(code:'todo.is.ui.save')}"
          closeButton="${message(code:'is.button.cancel')}"
          title="${message(code:'todo.is.dialog.profile')}">
    <tabset type="pills" justified="true">
        <tab heading="${message(code: 'todo.is.dialog.profile.general.title')}"
             active="tabSelected.general"
             select="setTabSelected('general')">
            <div flow-files-added="dataUser.avatar = 'custom';"
                 flow-files-submitted="$flow.upload()"
                 flow-files-success="dataUser.avatar = 'custom'"
                 flow-file-added="!! {png:1,jpg:1,jpeg:1} [$file.getExtension()]"
                 flow-init="{target:'${createLink(controller:'user', action:'update', id:user.id)}', singleFile:true, simultaneousUploads:1}"
                 flow-single-file="true"
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
                                <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)}">
                                    <img ng-click="dataUser.avatar = 'gravatar'"
                                         ng-class="{'selected': dataUser.avatar == 'gravatar' }"
                                         src="${"https://secure.gravatar.com/avatar/" + user.email.encodeAsMD5()}"/>
                                </g:if>
                                <div class="choose-file">
                                    <span ng-class="{'hide': dataUser.avatar == 'custom' }"
                                          flow-btn class="btn btn-default"><i class="fa fa-photo"></i></span>
                                    <img flow-btn
                                         ng-class="{'selected': dataUser.avatar == 'custom', 'hide': dataUser.avatar != 'custom' }"
                                         flow-img="$flow.files[0] ? $flow.files[0] : '${asset.assetPath(src: 'avatars/dev-ico.png')}'" />
                                </div>
                            </div>
                            <div class="col-md-12">
                                <img ng-click="dataUser.avatar = 'dev-ico.png'"
                                     ng-class="{'selected': dataUser.avatar == 'dev-ico.png' }"
                                     src="${asset.assetPath(src: 'avatars/dev-ico.png')}"/>
                                <img ng-click="dataUser.avatar = 'po-ico.png'"
                                     ng-class="{'selected': dataUser.avatar == 'po-ico.png' }"
                                     src="${asset.assetPath(src: 'avatars/po-ico.png')}"/>
                                <img ng-click="dataUser.avatar = 'sh-ico.png'"
                                     ng-class="{'selected': dataUser.avatar == 'sh-ico.png' }"
                                     src="${asset.assetPath(src: 'avatars/sh-ico.png')}"/>
                                <img ng-click="dataUser.avatar = 'sm-ico.png'"
                                     ng-class="{'selected': dataUser.avatar == 'sm-ico.png' }"
                                     src="${asset.assetPath(src: 'avatars/sm-ico.png')}"/>
                                <img ng-click="dataUser.avatar = 'admin-ico.png'"
                                     ng-class="{'selected': dataUser.avatar == 'admin-ico.png' }"
                                     src="${asset.assetPath(src: 'avatars/admin-ico.png')}"/>
                            </div>
                            <input type="hidden"
                                   name="user.avatar"
                                   ng-model="dataUser.avatar"/>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="form-half">
                        <label for="user.firstName">${message(code:'is.user.firstname')}</label>
                        <input type="text"
                               class="form-control"
                               name="user.firstName"
                               ng-model="dataUser.firstName"
                               focus-me="true"
                               required/>
                    </div>
                    <div class="form-half">
                        <label for="user.lastName">${message(code:'is.user.lastname')}</label>
                        <input type="text"
                               class="form-control"
                               name="user.lastName"
                               ng-model="dataUser.lastName"
                               required/>
                    </div>
                </div>
                <div class="row">
                    <div class="form-half">
                        <label for="user.email">${message(code:'is.user.email')}</label>
                        <input type="email"
                               name="user.email"
                               class="form-control"
                               ng-model="dataUser.email"
                               ng-blur="refreshAvatar(dataUser)"
                               required/>
                    </div>
                    <div class="form-half">
                        <label for="user.preferences.language">${message(code:'is.user.preferences.language')}</label>
                        <select name="user.preferences.language"
                                ui-select2
                                class="form-control"
                                ng-model="dataUser.preferences.language">
                            <is:options values="${is.languages()}" />
                        </select>
                    </div>
                </div>
                <div class="row" ng-show="!dataUser.accountExternal">
                    <div class="form-half">
                        <label for="user.password">${message(code:'is.user.password')}</label>
                        <input name="user.password"
                               type="password"
                               class="form-control"
                               ng-model="dataUser.password">
                        <div ng-password-strength="dataUser.password"></div>
                    </div>
                    <div class="form-half">
                        <label for="confirmPassword">${message(code:'is.dialog.register.confirmPassword')}</label>
                        <input name="confirmPassword"
                               type="password"
                               class="form-control"
                               is-match="dataUser.password"
                               ng-model="passwordConfirm">
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="user.preferences.activity">${message(code:'is.user.preferences.activity')}</label>
                        <input name="user.preferences.activity"
                               type="text"
                               class="form-control"
                               ng-model="dataUser.preferences.activity">
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
                                ng-model="dataUser.preferences.emailsSettings.autoFollow">
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
                                ng-model="dataUser.preferences.emailsSettings.onStory">
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
                                ng-model="dataUser.preferences.emailsSettings.onUrgentTask">
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