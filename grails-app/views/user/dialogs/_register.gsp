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
<is:modal name="register"
          title="${message(code:'is.dialog.register')}"
          form="[action:createLink(),method:'POST',success:'$.icescrum.user.registerSuccess',submit:message(code:'is.button.register')]">
        <p>
            <g:message code="is.dialog.register.description"/>
        </p>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="user.username">${message(code:'is.user.username')}</label>
                    <input type="text"
                           name="user.username"
                           class="form-control"
                           required
                           focus-me="true"/>
                </div>
                <div class="form-group">
                    <label for="user.firstName">${message(code:'is.user.firstname')}</label>
                    <input type="text"
                           class="form-control"
                           name="user.firstName"
                           required/>
                </div>
            </div>
            <div class="col-md-6">
                <div id="user-avatar"
                     class="avatar">
                    <img src="${is.avatar()}">
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
                           required/>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label for="userAvatar">${message(code:'is.user.avatar')}</label>
                    <select id= "userAvatar"
                            name="user.avatar"
                            data-sl2
                            class="form-control"
                            data-sl2-change="$.icescrum.user.selectAvatar"
                            placeholder="${message(code:'todo.is.user.avatar.placeholder')}">
                        <option></option>
                        <g:if test="${ApplicationSupport.booleanValue(grailsApplication.config.icescrum.gravatar?.enable)}">
                            <option value="gravatar">${message(code:'todo.is.user.avatar.gravatar')}</option>
                        </g:if>
                        <option></option>
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
                    <label for="email">${message(code:'is.user.email')}</label>
                    <input type="email"
                           name="user.email"
                           class="form-control"
                           onchange="$.icescrum.user.selectAvatar(null, '#userAvatar')"
                           required/>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label for="user.preferences.language">${message(code:'is.user.preferences.language')}</label>
                    <select name="user.preferences.language"
                            data-sl2
                            class="form-control"
                            value="en">
                        <is:options values="${is.languages()}" />
                    </select>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="user.password">${message(code:'is.user.password')}</label>
                    <input required
                           name="user.password"
                           type="password"
                           class="form-control"
                           value="">
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label for="confirmPassword">${message(code:'is.dialog.register.confirmPassword')}</label>
                    <input required
                           name="confirmPassword"
                           type="password"
                           class="form-control"
                           value="">
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="form-group">
                    <label for="user.preferences.activity">${message(code:'is.user.preferences.activity')}</label>
                    <input name="user.preferences.activity"
                           type="text"
                           class="form-control"
                           value="">
                </div>
            </div>
        </div>
</is:modal>