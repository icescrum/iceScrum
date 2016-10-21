%{--
- Copyright (c) 2016 Kagilum.
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

<script type="text/ng-template" id="user.form.html">
<div class="row">
    <div class="form-half">
        <label for="username">${message(code:'is.user.username')}</label>
        <input required
               type="text"
               class="form-control"
               name="user.username"
               ng-model="user.username"
               ng-remote-validate="/user/available/username"
               ng-remote-validate-code="user.username.unique"
               autofocus/>
    </div>
</div>
<div class="row">
    <div class="form-half">
        <label for="user.firstName">${message(code:'is.user.firstname')}</label>
        <input required
               type="text"
               class="form-control"
               name="user.firstName"
               ng-model="user.firstName"/>
    </div>
    <div class="form-half">
        <label for="user.lastName">${message(code:'is.user.lastname')}</label>
        <input required
               type="text"
               class="form-control"
               name="user.lastName"
               ng-model="user.lastName"/>
    </div>
</div>
<div class="row">
    <div class="form-half">
        <label for="user.email">${message(code:'is.user.email')}</label>
        <input required
               type="email"
               name="user.email"
               class="form-control"
               ng-model="user.email"
               ng-remote-validate-code="user.email.unique"
               ng-remote-validate="/user/available/email"/>
    </div>
    <div class="form-half">
        <label for="user.preferences.language">${message(code:'is.user.preferences.language')}</label>
        <ui-select required
                   name="user.preferences.language"
                   class="form-control"
                   ng-model="user.preferences.language">
            <ui-select-match>{{ languages[$select.selected] }}</ui-select-match>
            <ui-select-choices repeat="languageKey in languageKeys">{{ languages[languageKey] }}</ui-select-choices>
        </ui-select>
    </div>
</div>
<div class="row" ng-show="!editableUser.accountExternal">
    <div class="form-half">
        <label for="user.password">${message(code:'is.user.password')}</label>
        <input ng-required="!user.id"
               name="user.password"
               type="password"
               class="form-control"
               ng-model="user.password"
               ng-password-strength>
    </div>
    <div class="form-half">
        <label for="confirmPassword">${message(code:'is.dialog.register.confirmPassword')}</label>
        <input name="confirmPassword"
               type="password"
               class="form-control"
               is-match="user.password"
               ng-model="user.confirmPassword">
    </div>
</div>
<div class="row">
    <div class="col-md-12 form-group">
        <label for="user.preferences.activity">${message(code:'is.user.preferences.activity')}</label>
        <input name="user.preferences.activity"
               type="text"
               class="form-control"
               ng-model="user.preferences.activity">
    </div>
</div>
</script>