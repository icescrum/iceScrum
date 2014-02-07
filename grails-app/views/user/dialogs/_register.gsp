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
<div data-ui-dialog
     data-ui-dialog-width="500"
     data-ui-dialog-ajax-form="true"
     data-ui-dialog-ajax-form-success="$.icescrum.user.registerSuccess"
     data-ui-dialog-ajax-form-submit-text="${message(code:'is.button.register')}"
     data-ui-dialog-ajax-form-cancel-text="${message(code:'is.button.cancel')}"
     data-ui-dialog-title="${message(code:"is.dialog.register")}">
    <div class="information">
        <g:message code="is.dialog.register.description"/>
    </div>
    <form method="POST" action="${createLink(action:'save')}">

        <div class="cols-2">
            <div class="col-1">
                <div class="field">
                    <label for="username">${message(code:'is.user.username')}</label>
                    <input type="text"
                           name="username"
                           required
                           autofocus/>
                </div>
                <hr/>
                <div class="field">
                    <label for="firstName">${message(code:'is.user.firstname')}</label>
                    <input type="text"
                           name="firstName"
                           required/>
                </div>
                <hr/>
                <div class="field">
                    <label for="lastName">${message(code:'is.user.lastname')}</label>
                    <input type="text"
                           name="lastName"
                           required/>
                </div>
                <hr/>
                <div class="field">
                    <label for="email">${message(code:'is.user.email')}</label>
                    <input type="email"
                           name="email"
                           required/>
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
                    <label for="preferences.language">${message(code:'is.user.preferences.language')}</label>
                    <select name="preferences.language"
                            style="width:100%"
                            data-sl2
                            value="en">
                        <is:options values="${is.languages()}" />
                    </select>
                </div>
            </div>
        </div>
        <hr/>
        <div class="cols-2">
            <div class="col-1">
                <div class="field">
                    <label for="password">${message(code:'is.user.password')}</label>
                    <input required
                           name="password"
                           type="password"
                           value="">
                </div>
            </div><!-- no space --><div class="col-2">
                <div class="field">
                    <label for="confirmPassword">${message(code:'is.dialog.register.confirmPassword')}</label>
                    <input required
                           name="confirmPassword"
                           type="password"
                           value="">
                </div>
            </div>
        </div>
        <hr/>
        <div class="field">
            <label for="preferences.activity">${message(code:'is.user.preferences.activity')}</label>
            <input name="preferences.activity"
                   type="text"
                   value="">
        </div>
        <input type="submit" class="hidden-submit"/>
    </form>
</div>
